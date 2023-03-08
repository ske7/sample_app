require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  class UsersLogin < ActionDispatch::IntegrationTest
    def setup
      @user = users(:test_user)
    end
  end

  class InvalidPasswordTest < UsersLogin
    test 'login path' do
      get login_path

      assert_template 'sessions/new'
    end

    test 'login with valid email/invalid password' do
      post login_path, params: { session: { email: @user.email, password: 'invalid' } }

      assert_not_predicate(self, :logged_in_for_test?)
      assert_response :unprocessable_entity
      assert_template 'sessions/new'
      assert_not flash.empty?
      get root_path

      assert_empty(flash)
    end
  end

  class ValidLogin < UsersLogin
    def setup
      super
      post login_path, params: { session: { email: @user.email, password: 'password' } }
    end
  end

  class ValidLoginTest < ValidLogin
    test 'valid login' do
      assert_predicate(self, :logged_in_for_test?)
      assert_redirected_to @user
    end

    test 'redirect after login' do
      follow_redirect!

      assert_template 'users/show'
      assert_select 'a[href=?]', login_path, count: 0
      assert_select 'a[href=?]', logout_path
      assert_select 'a[href=?]', user_path(@user)
    end
  end

  class Logout < ValidLogin
    def setup
      super
      delete logout_path
    end
  end

  class LogoutTest < Logout
    test 'successful logout' do
      assert_not_predicate(self, :logged_in_for_test?)
      assert_response :see_other
      assert_redirected_to root_url
    end

    test 'redirect after logout' do
      follow_redirect!

      assert_select 'a[href=?]', login_path
      assert_select 'a[href=?]', logout_path, count: 0
      assert_select 'a[href=?]', user_path(@user), count: 0
    end
  end
end
