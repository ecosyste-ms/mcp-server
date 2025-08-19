require 'test_helper'

class GetPackageDependenciesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Dependencies", GetPackageDependenciesTool.category
  end

  test "should have description" do
    assert_not_nil GetPackageDependenciesTool.description
    assert_not_empty GetPackageDependenciesTool.description
  end

  test "should have input schema" do
    schema = GetPackageDependenciesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
