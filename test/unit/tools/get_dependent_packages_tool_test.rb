require 'test_helper'

class GetDependentPackagesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Dependencies", GetDependentPackagesTool.category
  end

  test "should have description" do
    assert_not_nil GetDependentPackagesTool.description
    assert_not_empty GetDependentPackagesTool.description
  end

  test "should have input schema" do
    schema = GetDependentPackagesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
