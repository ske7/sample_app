# == Schema Information
#
# Table name: microposts
#
#  id         :integer          not null, primary key
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_microposts_on_user_id                 (user_id)
#  index_microposts_on_user_id_and_created_at  (user_id,created_at)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:test_user)
    @micropost = @user.microposts.build(content: 'Lorem Ipsum')
  end

  test 'should be valid' do
    assert @micropost.valid?
  end

  test 'user id should be present' do
    @micropost.user_id = nil

    assert_not @micropost.valid?
  end

  test 'content should be present' do
    @micropost.content = '   '

    assert_not @micropost.valid?
  end

  test 'content should be at most 140 characters' do
    @micropost.content = 'a' * 141

    assert_not @micropost.valid?
  end

  test 'order should be most recent first' do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
