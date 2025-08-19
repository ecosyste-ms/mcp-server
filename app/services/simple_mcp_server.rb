require 'json'

# Simple MCP server implementation without fast-mcp dependency issues
class SimpleMcpServer
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
    [
      {
        name: "get_package_basic_info",
        description: "Get basic package information (id, name, ecosystem, description, homepage, licenses)",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_vulnerability_list",
        description: "Get detailed list of all vulnerabilities",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_repo_basic_info",
        description: "Get repository basic info (id, full_name, owner, description, archived, fork)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy) or PURL (e.g., pkg:pypi/numpy)" }
          },
          required: ["repo_url"]
        }
      }
    ]
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
    
    result = case tool_name
             when "get_package_basic_info"
               get_package_basic_info(arguments)
             when "get_vulnerability_list"
               get_vulnerability_list(arguments)
             when "get_repo_basic_info"
               get_repo_basic_info(arguments)
             else
               { error: "Unknown tool: #{tool_name}" }
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

  def get_package_basic_info(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    {
      id: response["id"],
      name: response["name"],
      ecosystem: response["ecosystem"],
      description: response["description"],
      homepage: response["homepage"],
      licenses: response["licenses"]
    }
  end

  def get_vulnerability_list(args)
    purl_string = args[:purl] || args["purl"]
    return { error: "PURL required" } unless purl_string
    
    vulnerabilities = @client.vulnerabilities_by_purl(purl_string)
    
    if vulnerabilities && vulnerabilities.any?
      {
        vulnerabilities: vulnerabilities.map do |vuln|
          {
            uuid: vuln["uuid"],
            title: vuln["title"],
            severity: vuln["severity"],
            cvss_score: vuln["cvss_score"],
            published_at: vuln["published_at"],
            url: vuln["url"],
            identifiers: vuln["identifiers"]
          }
        end
      }
    else
      { vulnerabilities: [] }
    end
  end

  def get_repo_basic_info(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    # Check if this looks like a PURL (starts with pkg:)
    if repo_url.start_with?("pkg:")
      # Look up the package to get repository_url
      package_response = @client.lookup_by_purl(repo_url)
      return { error: "Package not found" } unless package_response
      
      repository_url = package_response["repository_url"]
      return { error: "No repository URL found for this package" } unless repository_url
      
      repo_url = repository_url
    end
    
    # Parse GitHub URL to get owner/repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      repo_data = @client.repository_info("GitHub", owner, repo)
      return { error: "Repository not found" } unless repo_data
      
      {
        id: repo_data["id"],
        full_name: repo_data["full_name"],
        owner: repo_data["owner"],
        description: repo_data["description"],
        archived: repo_data["archived"],
        fork: repo_data["fork"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end