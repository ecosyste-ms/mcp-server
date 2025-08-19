require 'test_helper'

class GetRepoUrlsToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoUrlsTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoUrlsTool.description
    assert_not_empty GetRepoUrlsTool.description
  end

  test "should have input schema" do
    schema = GetRepoUrlsTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
