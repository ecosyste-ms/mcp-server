require 'test_helper'
require 'net/http'
require 'json'

class NewToolsTest < ActionDispatch::IntegrationTest
  def setup
    @base_url = "http://localhost:3000"
  end

  def make_mcp_request(method, params = {})
    uri = URI("#{@base_url}/mcp")
    http = Net::HTTP.new(uri.host, uri.port)
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = {
      jsonrpc: "2.0",
      id: rand(1000),
      method: method,
      params: params
    }.to_json
    
    response = http.request(request)
    JSON.parse(response.body, symbolize_names: true)
  end

  def test_analyze_governance_tool
    skip "Skipping integration test unless RUN_INTEGRATION_TESTS=1" unless ENV['RUN_INTEGRATION_TESTS']
    
    response = make_mcp_request("tools/call", {
      name: "analyze_governance", 
      arguments: { purl: "pkg:pypi/numpy" }
    })
    
    assert_equal "2.0", response[:jsonrpc]
    assert response[:result]
    assert response[:result][:content]
    
    content = JSON.parse(response[:result][:content][0][:text], symbolize_names: true)
    assert content[:governance]
    assert_includes ["Strong community", "Organization-backed", "Individual maintainer"], content[:governance]
  end

  def test_check_lifecycle_tool
    skip "Skipping integration test unless RUN_INTEGRATION_TESTS=1" unless ENV['RUN_INTEGRATION_TESTS']
    
    response = make_mcp_request("tools/call", {
      name: "check_lifecycle", 
      arguments: { purl: "pkg:pypi/numpy" }
    })
    
    assert_equal "2.0", response[:jsonrpc]
    assert response[:result]
    assert response[:result][:content]
    
    content = JSON.parse(response[:result][:content][0][:text], symbolize_names: true)
    assert content[:lifecycle]
    assert_includes ["Actively maintained", "Maintenance mode", "Stale", "Unknown"], content[:lifecycle]
  end

  def test_assess_importance_tool
    skip "Skipping integration test unless RUN_INTEGRATION_TESTS=1" unless ENV['RUN_INTEGRATION_TESTS']
    
    response = make_mcp_request("tools/call", {
      name: "assess_importance", 
      arguments: { purl: "pkg:pypi/numpy" }
    })
    
    assert_equal "2.0", response[:jsonrpc]
    assert response[:result]
    assert response[:result][:content]
    
    content = JSON.parse(response[:result][:content][0][:text], symbolize_names: true)
    assert content[:importance]
    assert_includes ["High", "Medium", "Low"], content[:importance]
    assert content[:raw_data]
    assert content[:raw_data].key?(:downloads)
    assert content[:raw_data].key?(:dependents_count)
  end

  def test_tools_list_includes_new_tools
    skip "Skipping integration test unless RUN_INTEGRATION_TESTS=1" unless ENV['RUN_INTEGRATION_TESTS']
    
    response = make_mcp_request("tools/list")
    
    assert_equal "2.0", response[:jsonrpc]
    assert response[:result]
    
    tool_names = response[:result][:tools].map { |tool| tool[:name] }
    assert_includes tool_names, "analyze_governance"
    assert_includes tool_names, "check_lifecycle"
    assert_includes tool_names, "assess_importance"
  end
end