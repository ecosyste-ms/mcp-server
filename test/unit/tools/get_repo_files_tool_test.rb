require 'test_helper'

class GetRepoFilesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoFilesTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoFilesTool.description
    assert_not_empty GetRepoFilesTool.description
  end

  test "should have input schema" do
    schema = GetRepoFilesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
