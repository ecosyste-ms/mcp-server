require 'test_helper'

class GetCommitOverviewToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Contributors", GetCommitOverviewTool.category
  end

  test "should have description" do
    assert_not_nil GetCommitOverviewTool.description
    assert_not_empty GetCommitOverviewTool.description
  end

  test "should have input schema" do
    schema = GetCommitOverviewTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
