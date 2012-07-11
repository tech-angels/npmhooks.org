require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_auto_assign_api_key_on_create
    user = User.create({
      :provider => 'github',
      :uid      => '1234',
      :login    => '1234'
    }, :without_protection => true)

    assert_not_nil user.api_keys
  end

  def test_auto_assign_api_key_only_on_create
    users(:cjoudrey).save
    assert_equal 1, users(:cjoudrey).api_keys.length
  end
end
