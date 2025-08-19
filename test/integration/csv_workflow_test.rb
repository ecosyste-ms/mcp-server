require 'test_helper'
require 'net/http'
require 'json'

class CsvWorkflowTest < ActionDispatch::IntegrationTest
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

  def test_csv_workflow_demonstration
    skip "Skipping integration test unless RUN_INTEGRATION_TESTS=1" unless ENV['RUN_INTEGRATION_TESTS']
    
    # Simulate how an LLM would generate CSV data by calling individual tools
    packages = ["pkg:pypi/numpy", "pkg:pypi/jinja2"]
    
    csv_data = []
    
    packages.each do |purl|
      puts "Analyzing #{purl}..."
      
      # Get all the data needed for CSV columns
      name_result = make_mcp_request("tools/call", { name: "get_package_name", arguments: { purl: purl } })
      author_result = make_mcp_request("tools/call", { name: "get_authors", arguments: { purl: purl } })
      version_result = make_mcp_request("tools/call", { name: "get_version", arguments: { purl: purl } })
      description_result = make_mcp_request("tools/call", { name: "get_description", arguments: { purl: purl } })
      license_result = make_mcp_request("tools/call", { name: "get_license", arguments: { purl: purl } })
      repository_result = make_mcp_request("tools/call", { name: "get_repository", arguments: { purl: purl } })
      governance_result = make_mcp_request("tools/call", { name: "analyze_governance", arguments: { purl: purl } })
      lifecycle_result = make_mcp_request("tools/call", { name: "check_lifecycle", arguments: { purl: purl } })
      importance_result = make_mcp_request("tools/call", { name: "assess_importance", arguments: { purl: purl } })
      maintainer_result = make_mcp_request("tools/call", { name: "get_maintainer_activity", arguments: { purl: purl } })
      vuln_result = make_mcp_request("tools/call", { name: "lookup_vulnerabilities", arguments: { purl: purl } })
      tampering_result = make_mcp_request("tools/call", { name: "assess_tampering_risk", arguments: { purl: purl } })
      vuln_risk_result = make_mcp_request("tools/call", { name: "assess_vulnerability_risk", arguments: { purl: purl } })
      sustainability_result = make_mcp_request("tools/call", { name: "assess_sustainability_risk", arguments: { purl: purl } })
      risk_analysis_result = make_mcp_request("tools/call", { name: "generate_risk_analysis", arguments: { purl: purl } })
      action_result = make_mcp_request("tools/call", { name: "suggest_action", arguments: { purl: purl } })
      
      # Parse responses and extract simple values for CSV
      name_data = JSON.parse(name_result[:result][:content][0][:text], symbolize_names: true)
      author_data = JSON.parse(author_result[:result][:content][0][:text], symbolize_names: true) 
      version_data = JSON.parse(version_result[:result][:content][0][:text], symbolize_names: true)
      description_data = JSON.parse(description_result[:result][:content][0][:text], symbolize_names: true)
      license_data = JSON.parse(license_result[:result][:content][0][:text], symbolize_names: true)
      repository_data = JSON.parse(repository_result[:result][:content][0][:text], symbolize_names: true)
      governance_data = JSON.parse(governance_result[:result][:content][0][:text], symbolize_names: true)
      lifecycle_data = JSON.parse(lifecycle_result[:result][:content][0][:text], symbolize_names: true)
      importance_data = JSON.parse(importance_result[:result][:content][0][:text], symbolize_names: true)
      maintainer_data = JSON.parse(maintainer_result[:result][:content][0][:text], symbolize_names: true)
      vuln_data = JSON.parse(vuln_result[:result][:content][0][:text], symbolize_names: true)
      tampering_data = JSON.parse(tampering_result[:result][:content][0][:text], symbolize_names: true)
      vuln_risk_data = JSON.parse(vuln_risk_result[:result][:content][0][:text], symbolize_names: true)
      sustainability_data = JSON.parse(sustainability_result[:result][:content][0][:text], symbolize_names: true)
      risk_analysis_data = JSON.parse(risk_analysis_result[:result][:content][0][:text], symbolize_names: true)
      action_data = JSON.parse(action_result[:result][:content][0][:text], symbolize_names: true)
      
      # Build CSV row
      csv_row = {
        name: name_data[:name],
        author: author_data[:author],
        version: version_data[:version],
        description: description_data[:description],
        dependency_type: "Core", # This would be determined by consuming application
        license: license_data[:license],
        maintainers_active: maintainer_data[:maintainer_activity],
        contributors_active: "High activity", # Simplified for demo
        purl: purl,
        repository: repository_data[:repository],
        governance: governance_data[:governance],
        lifecycle: lifecycle_data[:lifecycle],
        vulnerabilities: vuln_data[:has_vulnerabilities] ? "Yes" : "No",
        industry_importance: importance_data[:importance],
        audits: "None known", # Simplified for demo
        security_md: "Link", # Simplified for demo
        tampering_risk: tampering_data[:tampering_risk],
        vulnerability_risk: vuln_risk_data[:vulnerability_risk],
        sustainability_risk: sustainability_data[:sustainability_risk],
        risk_analysis: risk_analysis_data[:risk_analysis],
        suggested_action: action_data[:suggested_action]
      }
      
      csv_data << csv_row
      puts "✅ Completed analysis for #{name_data[:name]}"
    end
    
    # Verify we got data for both packages
    assert_equal 2, csv_data.length
    
    # Verify key fields are populated
    csv_data.each do |row|
      assert row[:name].present?
      assert row[:author].present?
      assert row[:version].present?
      assert row[:governance].present?
      assert row[:lifecycle].present?
      assert row[:tampering_risk].present?
      assert row[:vulnerability_risk].present?
      assert row[:sustainability_risk].present?
    end
    
    puts "\n📊 CSV Analysis Complete:"
    csv_data.each do |row|
      puts "#{row[:name]}: #{row[:governance]} governance, #{row[:lifecycle]}, #{row[:tampering_risk]}/#{row[:vulnerability_risk]}/#{row[:sustainability_risk]} risks"
    end
    
    puts "\n✅ Successfully demonstrated CSV workflow using individual MCP tools!"
  end
end