require 'test_helper'

class GetPackageUrlsToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Package", GetPackageUrlsTool.category
  end

  test "should have description" do
    assert_not_nil GetPackageUrlsTool.description
    assert_not_empty GetPackageUrlsTool.description
  end

  test "should have input schema" do
    schema = GetPackageUrlsTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
