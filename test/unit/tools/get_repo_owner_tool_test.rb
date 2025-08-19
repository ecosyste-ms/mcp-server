require 'test_helper'

class GetRepoOwnerToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoOwnerTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoOwnerTool.description
    assert_not_empty GetRepoOwnerTool.description
  end

  test "should have input schema" do
    schema = GetRepoOwnerTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
