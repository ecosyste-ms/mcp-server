require "test_helper"

class ToolCallTest < ActiveSupport::TestCase
  test "should create tool call with required fields" do
    tool_call = ToolCall.log_call(
      tool_name: "get_package_basic_info",
      arguments: { purl: "pkg:pypi/numpy" },
      purl: "pkg:pypi/numpy",
      user_agent: "Claude-Code/1.0",
      request_id: "req-123",
      ip_address: "192.168.1.1"
    )
    
    assert_not_nil tool_call
    assert_equal "get_package_basic_info", tool_call.tool_name
    assert_equal '{"purl":"pkg:pypi/numpy"}', tool_call.arguments
    assert_equal "pkg:pypi/numpy", tool_call.purl
    assert_equal "Claude-Code/1.0", tool_call.user_agent
    assert_equal "req-123", tool_call.request_id
    assert_equal "192.168.1.1", tool_call.ip_address
    assert_not_nil tool_call.created_at
  end

  test "should create tool call with minimal fields" do
    tool_call = ToolCall.log_call(tool_name: "get_package_basic_info")
    
    assert_not_nil tool_call
    assert_equal "get_package_basic_info", tool_call.tool_name
    assert_equal "{}", tool_call.arguments
  end

  test "should extract purl from arguments with symbol keys" do
    tool_call = ToolCall.log_call(
      tool_name: "get_package_basic_info",
      arguments: { purl: "pkg:pypi/requests" }
    )
    
    assert_equal "pkg:pypi/requests", tool_call.purl
  end

  test "should extract purl from arguments with string keys" do
    tool_call = ToolCall.log_call(
      tool_name: "get_package_basic_info",
      arguments: { "purl" => "pkg:npm/react" }
    )
    
    assert_equal "pkg:npm/react", tool_call.purl
  end

  test "should handle logging errors gracefully" do
    # Force a validation error by not providing tool_name
    tool_call = ToolCall.log_call(tool_name: nil)
    
    assert_nil tool_call
  end

  test "should validate presence of tool_name" do
    tool_call = ToolCall.new(arguments: '{}')
    
    assert_not tool_call.valid?
    assert_includes tool_call.errors[:tool_name], "can't be blank"
  end
end