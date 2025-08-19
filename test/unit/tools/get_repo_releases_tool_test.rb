require 'test_helper'

class GetRepoReleasesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Repository", GetRepoReleasesTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoReleasesTool.description
    assert_not_empty GetRepoReleasesTool.description
  end

  test "should have input schema" do
    schema = GetRepoReleasesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
