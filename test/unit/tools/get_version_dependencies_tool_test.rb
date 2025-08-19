require 'test_helper'

class GetVersionDependenciesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Version", GetVersionDependenciesTool.category
  end

  test "should have description" do
    assert_not_nil GetVersionDependenciesTool.description
    assert_not_empty GetVersionDependenciesTool.description
  end

  test "should have input schema" do
    schema = GetVersionDependenciesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end

test "should handle call method" do
  tool = GetVersionDependenciesTool.new
  
  # Test with missing required parameters
  result = tool.call({})
  assert result.key?(:error) || result.key?("error")
  
  # Test with invalid parameters should not crash
  result = tool.call({ invalid_param: "test" })
  assert_not_nil result
end
end
