require 'test_helper'

class GetContributorCountsToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Contributors", GetContributorCountsTool.category
  end

  test "should have description" do
    assert_not_nil GetContributorCountsTool.description
    assert_not_empty GetContributorCountsTool.description
  end

  test "should have input schema" do
    schema = GetContributorCountsTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end

test "should handle call method" do
  tool = GetContributorCountsTool.new
  
  # Test with missing required parameters
  result = tool.call({})
  assert result.key?(:error) || result.key?("error")
  
  # Test with invalid parameters should not crash
  result = tool.call({ invalid_param: "test" })
  assert_not_nil result
end
end
