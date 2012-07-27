require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_random_key
    key = User.random_key
    assert_equal 32, key.length

    key2 = User.random_key
    assert_not_equal key, key2
  end

  def test_random_unique_key
    expected = '*' * 32
    User.expects(:random_key).times(2).returns(users(:cjoudrey).api_key, expected)
    assert_equal expected, User.random_unique_key
  end

  def test_auto_assign_api_key_on_create
    user = User.create({
      :provider => 'github',
      :uid      => 1234,
      :login    => '1234'
    }, :without_protection => true)

    assert_not_nil user.api_key
  end

  def test_auto_assign_api_key_only_on_create
    old_key = users(:cjoudrey).api_key
    users(:cjoudrey).save
    assert_equal old_key, users(:cjoudrey).api_key
  end
end
