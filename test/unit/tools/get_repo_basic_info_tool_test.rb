require 'test_helper'

class GetRepoBasicInfoToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoBasicInfoTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoBasicInfoTool.description
    assert_not_empty GetRepoBasicInfoTool.description
  end

  test "should have input schema" do
    schema = GetRepoBasicInfoTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
