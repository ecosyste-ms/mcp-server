require "test_helper"

class ToolCallLoggingTest < ActionDispatch::IntegrationTest
  test "should log tool calls when making MCP requests" do
    # Count initial tool calls
    initial_count = ToolCall.count
    
    # Make a tools/call request
    post "/mcp", params: {
      jsonrpc: "2.0",
      id: 1,
      method: "tools/call",
      params: {
        name: "get_package_basic_info",
        arguments: {
          purl: "pkg:pypi/numpy"
        }
      }
    }.to_json, headers: {
      "Content-Type" => "application/json",
      "User-Agent" => "Test-Client/1.0"
    }
    
    # Check that a tool call was logged
    assert_equal initial_count + 1, ToolCall.count
    
    # Check the logged data
    logged_call = ToolCall.last
    assert_equal "get_package_basic_info", logged_call.tool_name
    assert_includes logged_call.arguments, "pkg:pypi/numpy"
    assert_equal "pkg:pypi/numpy", logged_call.purl
    assert_equal "Test-Client/1.0", logged_call.user_agent
    assert_not_nil logged_call.ip_address
    assert_not_nil logged_call.request_id
  end

  test "should not log tool calls for non-tool requests" do
    initial_count = ToolCall.count
    
    # Make an initialize request
    post "/mcp", params: {
      jsonrpc: "2.0",
      id: 1,
      method: "initialize",
      params: {
        protocolVersion: "2024-11-05"
      }
    }.to_json, headers: {
      "Content-Type" => "application/json"
    }
    
    # Check that no tool call was logged
    assert_equal initial_count, ToolCall.count
  end

  test "should handle tool calls with repo_url parameter" do
    initial_count = ToolCall.count
    
    post "/mcp", params: {
      jsonrpc: "2.0",
      id: 1,
      method: "tools/call",
      params: {
        name: "get_repo_basic_info",
        arguments: {
          repo_url: "github.com/numpy/numpy"
        }
      }
    }.to_json, headers: {
      "Content-Type" => "application/json"
    }
    
    assert_equal initial_count + 1, ToolCall.count
    
    logged_call = ToolCall.last
    assert_equal "get_repo_basic_info", logged_call.tool_name
    assert_equal "github.com/numpy/numpy", logged_call.purl
  end
end