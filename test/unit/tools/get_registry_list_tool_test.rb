require 'test_helper'

class GetRegistryListToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Registry", GetRegistryListTool.category
  end

  test "should have description" do
    assert_not_nil GetRegistryListTool.description
    assert_not_empty GetRegistryListTool.description
  end

  test "should have input schema" do
    schema = GetRegistryListTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
    assert_includes schema[:required], "context"
  end

  test "should handle call method" do
    tool = GetRegistryListTool.new
    
    # Test with context parameter
    result = tool.call({ context: "test" })
    assert_not_nil result
    assert result.key?(:registries) || result.key?("registries")
    assert result.key?(:registries_count) || result.key?("registries_count")
  end
end