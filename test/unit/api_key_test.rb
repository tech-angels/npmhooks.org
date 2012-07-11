require 'test_helper'

class ApiKeyTest < ActiveSupport::TestCase
  def test_random_key
    key = ApiKey.random_key
    assert_equal 32, key.length

    key2 = ApiKey.random_key
    assert_not_equal key, key2
  end

  def test_random_unique_key
    expected = '*' * 32
    ApiKey.expects(:random_key).times(2).returns(api_keys(:cjoudrey_key).api_key, expected)
    assert_equal expected, ApiKey.random_unique_key
  end

  def test_create
    key = ApiKey.create({
      :user => users(:cjoudrey)
    }, :without_protection => true)

    assert_not_nil key.api_key
  end
end
