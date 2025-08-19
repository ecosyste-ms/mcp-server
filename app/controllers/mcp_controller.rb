class McpController < ApplicationController
  skip_before_action :verify_authenticity_token

  def handle
    begin
      request_body = request.body.read
      Rails.logger.info "MCP Request: #{request_body}"
      
      mcp_server = SimpleMcpServer.new
      response_data = mcp_server.handle_request(request_body)
      Rails.logger.info "MCP Response: #{response_data}"
      
      render json: response_data
    rescue => e
      Rails.logger.error "MCP Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      render json: {
        jsonrpc: "2.0",
        error: {
          code: -32603,
          message: "Internal error",
          data: e.message
        }
      }, status: 500
    end
  end

  def health
    # Simple health check without creating the full MCP server
    render json: {
      status: "healthy",
      server: "Ecosyste.ms MCP Server",
      version: "1.0.0",
      tools: [
        "get_package_name",
        "get_authors", 
        "get_version",
        "get_description",
        "get_license",
        "get_repository",
        "analyze_governance",
        "check_lifecycle",
        "assess_importance",
        "get_maintainer_activity",
        "get_contributor_activity",
        "find_audits",
        "check_security_policy",
        "assess_tampering_risk",
        "assess_vulnerability_risk", 
        "assess_sustainability_risk",
        "generate_risk_analysis",
        "suggest_action",
        "analyze_package",
        "lookup_vulnerabilities",
        "get_unpatched_vulnerabilities",
        "analyze_security_posture"
      ]
    }
  end
end