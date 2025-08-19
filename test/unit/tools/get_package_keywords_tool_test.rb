require 'test_helper'

class GetPackageKeywordsToolTest < ActiveSupport::TestCase
  test "should have correct category" do
    assert_equal "Package", GetPackageKeywordsTool.category
  end

  test "should have description" do
    assert_not_nil GetPackageKeywordsTool.description
    assert_not_empty GetPackageKeywordsTool.description
  end

  test "should have input schema" do
    schema = GetPackageKeywordsTool.input_schema
    assert_not_nil schema
    assert_equal "object", schema[:type]
    assert schema[:properties].is_a?(Hash)
    assert schema[:required].is_a?(Array)
  end
end
