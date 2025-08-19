require 'test_helper'

class GetRepoTagsToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoTagsTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoTagsTool.description
    assert_not_empty GetRepoTagsTool.description
  end

  test "should have input schema" do
    schema = GetRepoTagsTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
