require 'test_helper'

class GetRepoCommunityToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoCommunityTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoCommunityTool.description
    assert_not_empty GetRepoCommunityTool.description
  end

  test "should have input schema" do
    schema = GetRepoCommunityTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
