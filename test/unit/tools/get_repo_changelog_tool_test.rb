require 'test_helper'

class GetRepoChangelogToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoChangelogTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoChangelogTool.description
    assert_not_empty GetRepoChangelogTool.description
  end

  test "should have input schema" do
    schema = GetRepoChangelogTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
