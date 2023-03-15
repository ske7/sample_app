require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test_user)
  end

  test 'unsuccessfull edit' do
    log_in_as(@user)
    get edit_user_path(@user)

    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: '',
                                              email: 'user@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' } }

    assert_template 'users/edit'
    assert_select 'div.alert', text: 'The form contains 4 errors.'
  end

  test 'successfull edit with friendly forwarding' do
    get edit_user_path(@user)
    log_in_as(@user)

    assert_redirected_to edit_user_url(@user)
    assert_nil session[:forwarding_url]
    name = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(@user), params: { user: { name:,
                                              email:,
                                              password: '',
                                              password_confirmation: '' } }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload

    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
