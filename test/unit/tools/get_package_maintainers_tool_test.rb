require 'test_helper'

class GetPackageMaintainersToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Package", GetPackageMaintainersTool.category
  end

  test "should have description" do
    assert_not_nil GetPackageMaintainersTool.description
    assert_not_empty GetPackageMaintainersTool.description
  end

  test "should have input schema" do
    schema = GetPackageMaintainersTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
