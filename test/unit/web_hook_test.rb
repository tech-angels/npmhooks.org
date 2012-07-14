require 'test_helper'

class WebHookTest < ActiveSupport::TestCase
  should belong_to(:user)
  should validate_presence_of(:user)
  should validate_presence_of(:url)
  should validate_uniqueness_of(:url)

  test '#success_message' do
    url = 'http://example.com'
    web_hook = WebHook.new(:url => url)
    assert_equal "Successfully created webhook to #{url}", web_hook.success_message
  end

  test '#removed_message' do
    url = 'http://example.com'
    web_hook = WebHook.new(:url => url)
    assert_equal "Successfully removed webhook to #{url}", web_hook.removed_message
  end
end
