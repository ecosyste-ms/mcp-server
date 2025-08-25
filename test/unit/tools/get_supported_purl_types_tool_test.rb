require 'test_helper'

class GetSupportedPurlTypesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Registry", GetSupportedPurlTypesTool.category
  end

  test "should have description" do
    assert_not_nil GetSupportedPurlTypesTool.description
    assert_not_empty GetSupportedPurlTypesTool.description
  end

  test "should have input schema" do
    schema = GetSupportedPurlTypesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
    assert_includes schema[:required], "context"
  end

  test "should handle call method" do
    tool = GetSupportedPurlTypesTool.new
    
    # Test with context parameter
    result = tool.call({ context: "test" })
    assert_not_nil result
    assert result.key?(:supported_purl_types) || result.key?("supported_purl_types")
    assert result.key?(:total_count) || result.key?("total_count")
    assert result.key?(:categories) || result.key?("categories")
  end
end