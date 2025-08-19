require 'test_helper'

class GetPackageDatesToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Package", GetPackageDatesTool.category
  end

  test "should have description" do
    assert_not_nil GetPackageDatesTool.description
    assert_not_empty GetPackageDatesTool.description
  end

  test "should have input schema" do
    schema = GetPackageDatesTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
