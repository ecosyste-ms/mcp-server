require 'test_helper'

class GetVersionUrlsToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Version", GetVersionUrlsTool.category
  end

  test "should have description" do
    assert_not_nil GetVersionUrlsTool.description
    assert_not_empty GetVersionUrlsTool.description
  end

  test "should have input schema" do
    schema = GetVersionUrlsTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end

test "should handle call method" do
  tool = GetVersionUrlsTool.new
  
  # Test with missing required parameters
  result = tool.call({})
  assert result.key?(:error) || result.key?("error")
  
  # Test with invalid parameters should not crash
  result = tool.call({ invalid_param: "test" })
  assert_not_nil result
end
end
