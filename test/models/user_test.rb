# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  activated         :boolean          default(FALSE)
#  activated_at      :datetime
#  activation_digest :string
#  admin             :boolean          default(FALSE)
#  email             :string
#  name              :string
#  password_digest   :string
#  remember_digest   :string
#  reset_digest      :string
#  reset_sent_at     :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.org',
                     password: 'foobar', password_confirmation: 'foobar')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '    '

    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '    '

    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51

    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = "#{'a' * 244}@example.com"

    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w[user@example.com USER@foo.COM A_us-ser@foo.bar.com
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address

      assert @user.valid?
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@baz_bar.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address

      assert_not @user.valid?
    end
  end

  test 'email address should be unique' do
    duplicate_user = @user.dup
    @user.save

    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lowercase' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save

    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 6

    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 5

    assert_not @user.valid?
  end

  test 'authenticated? should return false for a user with a nil digest' do
    assert_not @user.authenticated?(:remember, 'some')
  end

  test 'associated micropost should be destroyd' do
    @user.save
    @user.microposts.create!(content: 'Lorem ipsum')

    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow a user' do
    test_user = users(:test_user)
    other_user = users(:other_user)

    assert_not test_user.following?(other_user)
    test_user.follow(other_user)

    assert test_user.following?(other_user)
    assert_includes other_user.followers, test_user
    test_user.unfollow(other_user)

    assert_not test_user.following?(other_user)

    # Users can't follow themselves.
    test_user.follow(test_user)

    assert_not test_user.following?(test_user)
  end

  test 'feed should have the right posts' do
    test_user = users(:test_user)
    other_user = users(:other_user)
    bob = users(:bob)

    # Posts from followed user
    bob.microposts.each do |post_following|
      assert_includes test_user.feed, post_following
    end

    # Self-posts for user with followers
    test_user.microposts.each do |post_self|
      assert_includes test_user.feed, post_self
      assert_equal test_user.feed.distinct, test_user.feed
    end

    # Posts from non-followed user
    other_user.microposts.each do |post_unfollowed|
      assert_not test_user.feed.include?(post_unfollowed)
    end
  end
end
