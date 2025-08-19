Rails.application.config.after_initialize do
  Rails.logger.info "Initializing Ecosyste.ms MCP Server..."
  
  # Ensure our services are loaded
  require_dependency 'ecosystems_client'
  require_dependency 'package_info_service'
  require_dependency 'mcp_server'
  
  # Load all tool classes
  Dir[Rails.root.join('app', 'tools', '*.rb')].each do |file|
    require_dependency file
  end
  
  Rails.logger.info "Ecosyste.ms MCP Server initialized successfully"
  Rails.logger.info "Loaded #{BaseTool.descendants.length} tools: #{BaseTool.descendants.map(&:tool_name).join(', ')}"
end