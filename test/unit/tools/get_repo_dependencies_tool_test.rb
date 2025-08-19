require 'test_helper'

class GetRepoDependenciesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Dependencies", GetRepoDependenciesTool.category
  end

  test "should have description" do
    assert_not_nil GetRepoDependenciesTool.description
    assert_not_empty GetRepoDependenciesTool.description
  end

  test "should have input schema" do
    schema = GetRepoDependenciesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
