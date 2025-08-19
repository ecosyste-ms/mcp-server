require 'test_helper'

class GetRepoFileContentsToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoFileContentsTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoFileContentsTool.description
    assert_not_empty GetRepoFileContentsTool.description
  end

  test "should have input schema" do
    schema = GetRepoFileContentsTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
