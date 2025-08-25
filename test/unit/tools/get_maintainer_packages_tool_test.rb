require 'test_helper'

class GetMaintainerPackagesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Maintainer", GetMaintainerPackagesTool.category
  end

  test "should have description" do
    assert_not_nil GetMaintainerPackagesTool.description
    assert_not_empty GetMaintainerPackagesTool.description
  end

  test "should have input schema" do
    schema = GetMaintainerPackagesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
    assert_includes schema[:required], "registry"
    assert_includes schema[:required], "maintainer"
    assert_includes schema[:required], "context"
  end

  test "should handle call method" do
    tool = GetMaintainerPackagesTool.new
    
    # Test with missing required parameters
    result = tool.call({})
    assert result.key?(:error) || result.key?("error")
    
    # Test with missing maintainer
    result = tool.call({ registry: "npm" })
    assert result.key?(:error) || result.key?("error")
    
    # Test with invalid parameters should not crash
    result = tool.call({ invalid_param: "test" })
    assert_not_nil result
  end
end