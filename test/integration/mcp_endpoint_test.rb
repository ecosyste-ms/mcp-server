require 'test_helper'

class McpEndpointTest < ActionDispatch::IntegrationTest
  test "health endpoint returns server information" do
    get "/mcp/health"
    
    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert_equal "healthy", response_data["status"]
    assert_equal "Ecosyste.ms MCP Server", response_data["server"]
    assert response_data["tools"].is_a?(Array)
    assert response_data["tools"].length > 0
  end

  test "can list tools via MCP protocol" do
    request_body = {
      jsonrpc: "2.0",
      id: 1,
      method: "tools/list"
    }.to_json
    
    post "/mcp", params: request_body, headers: { 'Content-Type': 'application/json' }
    
    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert_equal "2.0", response_data["jsonrpc"]
    assert_equal 1, response_data["id"]
    assert response_data["result"].is_a?(Hash)
    assert response_data["result"]["tools"].is_a?(Array)
    
    # Check that our tools are present
    tool_names = response_data["result"]["tools"].map { |t| t["name"] }
    assert_includes tool_names, "get_package_basic_info"
    assert_includes tool_names, "get_vulnerability_list"
    assert_includes tool_names, "get_repo_basic_info"
  end

  test "can call get_package_basic_info tool" do
    skip "Integration test - requires network" unless ENV['RUN_INTEGRATION_TESTS']
    
    request_body = {
      jsonrpc: "2.0",
      id: 2,
      method: "tools/call",
      params: {
        name: "get_package_basic_info",
        arguments: {
          purl: "pkg:cargo/rand"
        }
      }
    }.to_json
    
    post "/mcp", params: request_body, headers: { 'Content-Type': 'application/json' }
    
    assert_response :success
    
    response_data = JSON.parse(response.body)
    assert_equal "2.0", response_data["jsonrpc"]
    assert_equal 2, response_data["id"]
    
    result = response_data["result"]["content"][0]["text"]
    parsed_result = JSON.parse(result)
    
    assert_equal "rand", parsed_result["name"]
    assert_not_nil parsed_result["description"]
    assert_equal "cargo", parsed_result["ecosystem"]
  end

  test "handles non-existent package gracefully" do
    skip "Integration test - requires network" unless ENV['RUN_INTEGRATION_TESTS']
    
    request_body = {
      jsonrpc: "2.0",
      id: 3,
      method: "tools/call",
      params: {
        name: "get_package_basic_info",
        arguments: {
          purl: "pkg:pypi/this-package-definitely-does-not-exist-12345"
        }
      }
    }.to_json
    
    post "/mcp", params: request_body, headers: { 'Content-Type': 'application/json' }
    
    assert_response :success
    
    response_data = JSON.parse(response.body)
    result = response_data["result"]["content"][0]["text"]
    parsed_result = JSON.parse(result)
    
    assert_equal "Package not found", parsed_result["error"]
  end

  test "uses forwarded IP address from X-Forwarded-For header" do
    original_count = ToolCall.count
    client_ip = "203.0.113.1"
    
    request_body = {
      jsonrpc: "2.0",
      id: 4,
      method: "tools/call",
      params: {
        name: "get_package_basic_info",
        arguments: {
          purl: "pkg:pypi/nonexistent-test-package"
        }
      }
    }.to_json
    
    post "/mcp", params: request_body, headers: { 
      'Content-Type': 'application/json',
      'X-Forwarded-For': "#{client_ip}, 198.51.100.1"
    }
    
    assert_response :success
    
    # Verify the tool call was logged with the correct IP
    assert_equal original_count + 1, ToolCall.count
    latest_call = ToolCall.order(:created_at).last
    assert_equal client_ip, latest_call.ip_address
  end

  test "falls back to remote_ip when X-Forwarded-For header is not present" do
    original_count = ToolCall.count
    
    request_body = {
      jsonrpc: "2.0",
      id: 5,
      method: "tools/call",
      params: {
        name: "get_package_basic_info",
        arguments: {
          purl: "pkg:pypi/nonexistent-test-package"
        }
      }
    }.to_json
    
    post "/mcp", params: request_body, headers: { 
      'Content-Type': 'application/json'
    }
    
    assert_response :success
    
    # Verify the tool call was logged with some IP (should be 127.0.0.1 in tests)
    assert_equal original_count + 1, ToolCall.count
    latest_call = ToolCall.order(:created_at).last
    assert_not_nil latest_call.ip_address
    assert latest_call.ip_address.length > 0
  end
end