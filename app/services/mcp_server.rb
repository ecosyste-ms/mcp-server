require 'json'

# Simple MCP server implementation without fast-mcp dependency issues
class McpServer
  def initialize
    @client = EcosystemsClient.new
    @service = PackageInfoService.new
  end

  def handle_request(request_body, user_agent: nil, request_id: nil, ip_address: nil)
    request = JSON.parse(request_body, symbolize_names: true)
    
    case request[:method]
    when "initialize"
      handle_initialize(request)
    when "initialized"
      handle_initialized(request)
    when "tools/list"
      handle_tools_list(request)
    when "tools/call"
      handle_tool_call(request, user_agent: user_agent, request_id: request_id, ip_address: ip_address)
    else
      {
        jsonrpc: "2.0",
        id: request[:id],
        error: {
          code: -32601,
          message: "Method not found"
        }
      }
    end
  rescue JSON::ParserError => e
    {
      jsonrpc: "2.0",
      error: {
        code: -32700,
        message: "Parse error",
        data: e.message
      }
    }
  rescue => e
    Rails.logger.error "MCP Error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # Return a generic internal error response
    {
      jsonrpc: "2.0",
      id: request[:id],
      error: {
        code: -32603,
        message: "Internal error",
        data: e.message
      }
    }
  end

  def tools_list
    available_tool_classes.map(&:to_mcp_tool).sort_by { |tool| [tool[:category], tool[:name]] }
  end

  def handle_initialize(request)
    {
      jsonrpc: "2.0",
      id: request[:id],
      result: {
        protocolVersion: "2024-11-05",
        capabilities: {
          tools: {}
        },
        serverInfo: {
          name: "Ecosyste.ms MCP Server",
          version: "1.0.0"
        }
      }
    }
  end

  def handle_initialized(request)
    {
      jsonrpc: "2.0",
      id: request[:id],
      result: {}
    }
  end

  def handle_tools_list(request)
    {
      jsonrpc: "2.0",
      id: request[:id],
      result: {
        tools: tools_list
      }
    }
  end

  def handle_tool_call(request, user_agent: nil, request_id: nil, ip_address: nil)
    tool_name = request.dig(:params, :name)
    arguments = request.dig(:params, :arguments) || {}
    
    # Extract PURL from arguments if present
    purl = arguments[:purl] || arguments["purl"] || arguments[:repo_url] || arguments["repo_url"]
    
    # Log the tool call
    ToolCall.log_call(
      tool_name: tool_name,
      arguments: arguments,
      purl: purl,
      user_agent: user_agent,
      request_id: request_id,
      ip_address: ip_address
    )
    
    tool_class = find_tool_class(tool_name)
    if tool_class
      tool_instance = tool_class.new(@client)
      result = tool_instance.call(arguments)
    else
      result = { error: "Unknown tool: #{tool_name}" }
    end

    {
      jsonrpc: "2.0",
      id: request[:id],
      result: {
        content: [
          {
            type: "text",
            text: result.to_json
          }
        ]
      }
    }
  end

  private

  def available_tool_classes
    # Dynamically find all tool classes that inherit from BaseTool
    Rails.application.eager_load! unless Rails.application.config.cache_classes
    BaseTool.descendants
  end

  def find_tool_class(tool_name)
    available_tool_classes.find { |klass| klass.tool_name == tool_name }
  end
end