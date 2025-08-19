require 'test_helper'

class GetIssueCountsToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Issues", GetIssueCountsTool.category
  end

  test "should have description" do
    assert_not_nil GetIssueCountsTool.description
    assert_not_empty GetIssueCountsTool.description
  end

  test "should have input schema" do
    schema = GetIssueCountsTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
