Rails.application.config.after_initialize do
  Rails.logger.info "Initializing Ecosyste.ms MCP Server..."
  
  # Ensure our services are loaded
  require_dependency 'ecosystems_client'
  require_dependency 'package_info_service'
  require_dependency 'simple_mcp_server'
  
  Rails.logger.info "Ecosyste.ms MCP Server initialized successfully"
end