require 'json'

# Simple MCP server implementation without fast-mcp dependency issues
class SimpleMcpServer
  def initialize
    @client = EcosystemsClient.new
    @service = PackageInfoService.new
  end

  def handle_request(request_body)
    request = JSON.parse(request_body, symbolize_names: true)
    
    case request[:method]
    when "initialize"
      handle_initialize(request)
    when "initialized"
      handle_initialized(request)
    when "tools/list"
      handle_tools_list(request)
    when "tools/call"
      handle_tool_call(request)
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

  private

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
    tools = [
      # Package Metadata Tools
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
        name: "get_package_dates",
        description: "Get package creation and update dates",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_package_repository_info",
        description: "Get repository URL and social metrics (stars, forks)",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_package_versions_info",
        description: "Get version count and latest release info",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_package_keywords",
        description: "Get package keywords and categories",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_package_urls",
        description: "Get ecosyste.ms URLs for package analysis and exploration",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      },
      
      # Version-Specific Tools
      {
        name: "get_version_info",
        description: "Get specific version metadata (published_at, downloads, author)",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL with version (e.g., pkg:pypi/numpy@1.24.0)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_version_dependencies",
        description: "Get dependencies for a specific version",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL with version (e.g., pkg:cargo/rand@0.9.2)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_package_dependencies",
        description: "Get dependencies for latest version of a package",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL without version (e.g., pkg:cargo/rand)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_version_urls",
        description: "Get ecosyste.ms URLs for specific version analysis",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL with version (e.g., pkg:pypi/numpy@1.24.0)" }
          },
          required: ["purl"]
        }
      },
      
      # Repository Analysis Tools
      {
        name: "get_repo_basic_info",
        description: "Get repository basic info (id, full_name, owner, description, archived, fork)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_activity",
        description: "Get repository activity metrics (pushed_at, size, last_synced_at)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_community",
        description: "Get community metrics (stars, forks, subscribers, open_issues)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_metadata",
        description: "Get repository metadata (topics, language, license, default_branch)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_dependencies",
        description: "Get dependencies for a repository from manifest files",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/octobox/octobox)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_urls",
        description: "Get ecosyste.ms URLs for repository analysis across all platforms",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_metafiles",
        description: "Get list of interesting metadata files from repository info (LICENSE, README, etc.)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_files",
        description: "Get complete list of files in repository using archives API",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_file_contents",
        description: "Get contents of a specific file from a repository using archives API",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" },
            file_path: { type: "string", description: "Path to file within repository (e.g., LICENSE, README.md)" }
          },
          required: ["repo_url", "file_path"]
        }
      },
      {
        name: "get_repo_readme",
        description: "Get repository README content using archives API",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_changelog",
        description: "Get repository changelog with parsed version entries using archives API",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" },
            version: { type: "string", description: "Optional specific version to get changes for (e.g., '4.0.4')" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_repo_repomix",
        description: "Get AI-friendly concatenated string of all repository file contents using archives API",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      
      # Issue Tracking Tools
      {
        name: "get_issue_counts",
        description: "Get issue and PR counts (total, closed)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_issue_timing",
        description: "Get average time to close issues and PRs",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_maintainer_info",
        description: "Get maintainer lists (all-time and active)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_contributor_counts",
        description: "Get contributor counts for PRs and issues",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_past_year_activity",
        description: "Get past year issue and PR activity",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      
      # Commit Activity Tools
      {
        name: "get_commit_overview",
        description: "Get repository commit overview (id, full_name, default_branch)",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_committer_list",
        description: "Get complete list of committers with commit counts",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
          },
          required: ["repo_url"]
        }
      },
      {
        name: "get_top_committers",
        description: "Get top N committers by commit count",
        inputSchema: {
          type: "object",
          properties: {
            repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" },
            limit: { type: "number", description: "Number of top committers to return (default: 10)" }
          },
          required: ["repo_url"]
        }
      },
      
      # Vulnerability Tools
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
        name: "get_vulnerability_counts_by_severity",
        description: "Get vulnerability counts grouped by severity",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_latest_vulnerability_date",
        description: "Get the date of the most recent vulnerability",
        inputSchema: {
          type: "object",
          properties: {
            purl: { type: "string", description: "Package URL (e.g., pkg:pypi/numpy)" }
          },
          required: ["purl"]
        }
      }
    ]

    {
      jsonrpc: "2.0",
      id: request[:id],
      result: {
        tools: tools
      }
    }
  end

  def handle_tool_call(request)
    tool_name = request.dig(:params, :name)
    arguments = request.dig(:params, :arguments) || {}
    
    result = case tool_name
             # Package Metadata Tools
             when "get_package_basic_info"
               get_package_basic_info(arguments)
             when "get_package_dates"
               get_package_dates(arguments)
             when "get_package_repository_info"
               get_package_repository_info(arguments)
             when "get_package_versions_info"
               get_package_versions_info(arguments)
             when "get_package_keywords"
               get_package_keywords(arguments)
             when "get_package_urls"
               get_package_urls(arguments)
             
             # Version-Specific Tools
             when "get_version_info"
               get_version_info(arguments)
             when "get_version_dependencies"
               get_version_dependencies(arguments)
             when "get_package_dependencies"
               get_package_dependencies(arguments)
             when "get_version_urls"
               get_version_urls(arguments)
             
             # Repository Analysis Tools
             when "get_repo_basic_info"
               get_repo_basic_info(arguments)
             when "get_repo_activity"
               get_repo_activity(arguments)
             when "get_repo_community"
               get_repo_community(arguments)
             when "get_repo_metadata"
               get_repo_metadata(arguments)
             when "get_repo_dependencies"
               get_repo_dependencies(arguments)
             when "get_repo_urls"
               get_repo_urls(arguments)
             when "get_repo_metafiles"
               get_repo_metafiles(arguments)
             when "get_repo_files"
               get_repo_files(arguments)
             when "get_repo_file_contents"
               get_repo_file_contents(arguments)
             when "get_repo_readme"
               get_repo_readme(arguments)
             when "get_repo_changelog"
               get_repo_changelog(arguments)
             when "get_repo_repomix"
               get_repo_repomix(arguments)
             
             # Issue Tracking Tools
             when "get_issue_counts"
               get_issue_counts(arguments)
             when "get_issue_timing"
               get_issue_timing(arguments)
             when "get_maintainer_info"
               get_maintainer_info(arguments)
             when "get_contributor_counts"
               get_contributor_counts(arguments)
             when "get_past_year_activity"
               get_past_year_activity(arguments)
             
             # Commit Activity Tools
             when "get_commit_overview"
               get_commit_overview(arguments)
             when "get_committer_list"
               get_committer_list(arguments)
             when "get_top_committers"
               get_top_committers(arguments)
             
             # Vulnerability Tools
             when "get_vulnerability_list"
               get_vulnerability_list(arguments)
             when "get_vulnerability_counts_by_severity"
               get_vulnerability_counts_by_severity(arguments)
             when "get_latest_vulnerability_date"
               get_latest_vulnerability_date(arguments)
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

# Package Metadata Tools
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

  def get_package_dates(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    {
      created_at: response["created_at"],
      updated_at: response["updated_at"],
      first_release_published_at: response["first_release_published_at"]
    }
  end

  def get_package_repository_info(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    {
      repository_url: response["repository_url"],
      stargazers_count: response["stargazers_count"],
      forks_count: response["forks_count"]
    }
  end

  def get_package_versions_info(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    {
      versions_count: response["versions_count"],
      latest_release_number: response["latest_release_number"],
      latest_release_published_at: response["latest_release_published_at"]
    }
  end

  def get_package_keywords(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    {
      keywords: response["keywords"],
      categories: response["categories"]
    }
  end

  def get_package_urls(args)
    purl_string = args[:purl] || args["purl"]
    purl_obj = Purl::PackageURL.parse(purl_string)
    
    response = @client.lookup_by_purl(purl_string)
    return { error: "Package not found" } unless response
    
    registry_name = response.dig("registry", "name")
    package_name = response["name"]
    
    base_url = "https://packages.ecosyste.ms"
    
    {
      ecosystems_package_url: "#{base_url}/registries/#{registry_name}/packages/#{package_name}",
      ecosystems_api_url: "#{base_url}/api/v1/registries/#{registry_name}/packages/#{package_name}",
      purl_lookup_url: "#{base_url}/api/v1/packages/lookup?purl=#{CGI.escape(purl_string)}",
      vulnerabilities_url: response["vulnerabilities_url"],
      repository_url: response["repository_url"],
      homepage: response["homepage"],
      icon_url: response["icon_url"]
    }
  end

  # Version-Specific Tools
  def get_version_info(args)
    purl_string = args[:purl] || args["purl"]
    purl_obj = Purl::PackageURL.parse(purl_string)
    
    # Map purl types to registry names
    registry = case purl_obj.type
               when "pypi" then "pypi"
               when "npm" then "npmjs"
               when "cargo" then "crates.io"
               when "gem" then "rubygems"
               when "nuget" then "nuget"
               when "maven" then "maven"
               else purl_obj.type
               end
    
    if purl_obj.version
      version_response = @client.lookup_package_version(registry, purl_obj.name, purl_obj.version)
      return { error: "Version not found" } unless version_response
      
      {
        number: version_response["number"],
        published_at: version_response["published_at"],
        downloads: version_response.dig("metadata", "downloads"),
        published_by: version_response.dig("metadata", "published_by"),
        checksum: version_response.dig("metadata", "checksum"),
        size: version_response.dig("metadata", "crate_size") || version_response.dig("metadata", "size")
      }
    else
      { error: "Version must be specified in PURL (e.g., pkg:pypi/numpy@1.24.0)" }
    end
  end

  def get_version_dependencies(args)
    purl_string = args[:purl] || args["purl"]
    purl_obj = Purl::PackageURL.parse(purl_string)
    
    if purl_obj.version
      # First get package info to determine registry
      base_purl = "pkg:#{purl_obj.type}/#{purl_obj.name}"
      package_response = @client.lookup_by_purl(base_purl)
      return { error: "Package not found" } unless package_response
      
      registry_name = package_response.dig("registry", "name")
      return { error: "Registry not found" } unless registry_name
      
      # Now get version-specific dependencies
      version_response = @client.lookup_package_version(registry_name, purl_obj.name, purl_obj.version)
      return { error: "Version not found" } unless version_response
      
      {
        dependencies: version_response["dependencies"] || []
      }
    else
      { error: "Version must be specified in PURL (e.g., pkg:cargo/rand@0.9.2)" }
    end
  end

  def get_package_dependencies(args)
    purl_string = args[:purl] || args["purl"]
    
    # First get package info to find latest version
    package_response = @client.lookup_by_purl(purl_string)
    return { error: "Package not found" } unless package_response
    
    latest_version = package_response["latest_release_number"]
    return { error: "No latest version found" } unless latest_version
    
    # Build PURL with version and use existing method
    purl_with_version = "#{purl_string}@#{latest_version}"
    get_version_dependencies({ purl: purl_with_version }).merge({
      package_version: latest_version
    })
  end

  def get_version_urls(args)
    purl_string = args[:purl] || args["purl"]
    purl_obj = Purl::PackageURL.parse(purl_string)
    
    return { error: "Version must be specified in PURL" } unless purl_obj.version
    
    # Get package info to determine registry
    base_purl = "pkg:#{purl_obj.type}/#{purl_obj.name}"
    package_response = @client.lookup_by_purl(base_purl)
    return { error: "Package not found" } unless package_response
    
    registry_name = package_response.dig("registry", "name")
    package_name = package_response["name"]
    version = purl_obj.version
    
    base_url = "https://packages.ecosyste.ms"
    
    {
      ecosystems_version_url: "#{base_url}/registries/#{registry_name}/packages/#{package_name}/versions/#{version}",
      ecosystems_api_url: "#{base_url}/api/v1/registries/#{registry_name}/packages/#{package_name}/versions/#{version}",
      purl_lookup_url: "#{base_url}/api/v1/packages/lookup?purl=#{CGI.escape(purl_string)}",
      registry_url: package_response.dig("registry", "url"),
      download_url: "#{package_response.dig("registry", "url")}/#{package_name}/#{version}",
      repository_url: package_response["repository_url"],
      homepage: package_response["homepage"],
      icon_url: package_response["icon_url"]
    }
  end

  # Repository Analysis Tools
  def get_repo_basic_info(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
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

  def get_repo_activity(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      repo_data = @client.repository_info("GitHub", owner, repo)
      return { error: "Repository not found" } unless repo_data
      
      {
        pushed_at: repo_data["pushed_at"],
        size: repo_data["size"],
        last_synced_at: repo_data["last_synced_at"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_community(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      repo_data = @client.repository_info("GitHub", owner, repo)
      return { error: "Repository not found" } unless repo_data
      
      {
        stargazers_count: repo_data["stargazers_count"],
        forks_count: repo_data["forks_count"],
        subscribers_count: repo_data["subscribers_count"],
        open_issues_count: repo_data["open_issues_count"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_metadata(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      repo_data = @client.repository_info("GitHub", owner, repo)
      return { error: "Repository not found" } unless repo_data
      
      {
        topics: repo_data["topics"],
        homepage: repo_data["homepage"],
        language: repo_data["language"],
        license: repo_data["license"],
        default_branch: repo_data["default_branch"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_dependencies(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      manifests_data = @client.repository_manifests("GitHub", owner, repo)
      return { error: "Manifests data not found" } unless manifests_data
      
      {
        manifests: manifests_data
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_urls(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      encoded_repo_path = "#{CGI.escape(owner)}%2F#{CGI.escape(repo)}"
      
      {
        repos_ecosystems_url: "https://repos.ecosyste.ms/hosts/GitHub/repositories/#{owner}/#{repo}",
        repos_api_url: "https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/#{owner}/#{repo}",
        manifests_url: "https://repos.ecosyste.ms/api/v1/hosts/GitHub/repositories/#{encoded_repo_path}/manifests",
        issues_ecosystems_url: "https://issues.ecosyste.ms/hosts/GitHub/repositories/#{encoded_repo_path}",
        issues_api_url: "https://issues.ecosyste.ms/api/v1/hosts/GitHub/repositories/#{encoded_repo_path}",
        commits_ecosystems_url: "https://commits.ecosyste.ms/hosts/GitHub/repositories/#{owner}/#{repo}",
        commits_api_url: "https://commits.ecosyste.ms/api/v1/hosts/GitHub/repositories/#{owner}/#{repo}",
        github_url: "https://github.com/#{owner}/#{repo}"
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_metafiles(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    # Parse repository URL to extract host, owner, and repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      repo_data = @client.repository_info("GitHub", owner, repo)
      
      if repo_data && repo_data.dig("metadata", "files")
        files_object = repo_data.dig("metadata", "files")
        # Convert the files object to an array of key-value pairs for better readability
        files_array = files_object.filter_map { |key, value| { type: key.to_s, file: value } if value }
        { files: files_array }
      else
        { files: [] }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_files(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    # Parse repository URL to extract host, owner, and repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      repo_data = @client.repository_info("GitHub", owner, repo)
      download_url = repo_data&.dig("download_url")
      
      return { error: "Could not get repository download URL" } unless download_url
      
      # Use the archives API to get complete file list
      archives_url = "https://archives.ecosyste.ms/api/v1/archives/list"
      params = { url: download_url }
      
      url_with_params = "#{archives_url}?#{URI.encode_www_form(params)}"
      
      begin
        response = @client.fetch_external_api(url_with_params)
        
        if response && response.is_a?(Array)
          { files: response }
        else
          { files: [] }
        end
      rescue => e
        Rails.logger.error "Error fetching file list: #{e.message}"
        { error: "Failed to retrieve file list: #{e.message}" }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_file_contents(args)
    repo_url = args[:repo_url] || args["repo_url"]
    file_path = args[:file_path] || args["file_path"]
    
    return { error: "Repository URL required" } unless repo_url
    return { error: "File path required" } unless file_path
    
    # Parse repository URL to extract host, owner, and repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      repo_data = @client.repository_info("GitHub", owner, repo)
      download_url = repo_data&.dig("download_url")
      
      return { error: "Could not get repository download URL" } unless download_url
      
      # Use the archives API to get file contents
      archives_url = "https://archives.ecosyste.ms/api/v1/archives/contents"
      params = {
        url: download_url,
        path: file_path
      }
      
      url_with_params = "#{archives_url}?#{URI.encode_www_form(params)}"
      
      begin
        response = @client.fetch_external_api(url_with_params)
        
        if response && response["contents"]
          {
            file_path: file_path,
            contents: response["contents"],
            size: response["size"],
            download_url: download_url
          }
        else
          { error: "File not found or could not retrieve contents" }
        end
      rescue => e
        Rails.logger.error "Error fetching file contents: #{e.message}"
        { error: "Failed to retrieve file contents: #{e.message}" }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_readme(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    # Parse repository URL to extract host, owner, and repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      repo_data = @client.repository_info("GitHub", owner, repo)
      download_url = repo_data&.dig("download_url")
      
      return { error: "Could not get repository download URL" } unless download_url
      
      # Use the archives README API
      readme_url = "https://archives.ecosyste.ms/api/v1/archives/readme"
      params = { url: download_url }
      
      url_with_params = "#{readme_url}?#{URI.encode_www_form(params)}"
      
      begin
        response = @client.fetch_external_api(url_with_params)
        
        if response && response["raw"]
          {
            readme_path: response["name"],
            contents: response["raw"],
            size: response["size"],
            download_url: download_url
          }
        else
          { error: "README not found or could not retrieve contents" }
        end
      rescue => e
        Rails.logger.error "Error fetching README: #{e.message}"
        { error: "Failed to retrieve README: #{e.message}" }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_changelog(args)
    repo_url = args[:repo_url] || args["repo_url"]
    version = args[:version] || args["version"]
    return { error: "Repository URL required" } unless repo_url
    
    # Parse repository URL to extract host, owner, and repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      repo_data = @client.repository_info("GitHub", owner, repo)
      download_url = repo_data&.dig("download_url")
      
      return { error: "Could not get repository download URL" } unless download_url
      
      # Use the archives changelog API
      changelog_url = "https://archives.ecosyste.ms/api/v1/archives/changelog"
      params = { url: download_url }
      
      url_with_params = "#{changelog_url}?#{URI.encode_www_form(params)}"
      
      begin
        response = @client.fetch_external_api(url_with_params)
        
        if response && response["parsed"]
          if version && !version.empty?
            # Return specific version if requested
            version_changes = response["parsed"][version]
            if version_changes
              {
                changelog_path: response["name"],
                version: version,
                changes: version_changes,
                download_url: download_url
              }
            else
              { error: "Version '#{version}' not found in changelog" }
            end
          else
            # Return all parsed changelog data
            {
              changelog_path: response["name"],
              raw: response["raw"],
              parsed: response["parsed"],
              download_url: download_url
            }
          end
        else
          { error: "Changelog not found or could not be parsed" }
        end
      rescue => e
        Rails.logger.error "Error fetching changelog: #{e.message}"
        { error: "Failed to retrieve changelog: #{e.message}" }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_repo_repomix(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    # Parse repository URL to extract host, owner, and repo
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      repo_data = @client.repository_info("GitHub", owner, repo)
      download_url = repo_data&.dig("download_url")
      
      return { error: "Could not get repository download URL" } unless download_url
      
      # Use the archives repomix API
      repomix_url = "https://archives.ecosyste.ms/api/v1/archives/repomix"
      params = { url: download_url }
      
      url_with_params = "#{repomix_url}?#{URI.encode_www_form(params)}"
      
      begin
        response = @client.fetch_external_api(url_with_params)
        
        if response && response["output"]
          {
            repository: "#{owner}/#{repo}",
            contents: response["output"],
            download_url: download_url
          }
        else
          { error: "Repository contents could not be processed by repomix" }
        end
      rescue => e
        Rails.logger.error "Error fetching repomix: #{e.message}"
        { error: "Failed to retrieve repository repomix: #{e.message}" }
      end
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  # Issue Tracking Tools
  def get_issue_counts(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      issues_data = @client.repository_issues("GitHub", owner, repo)
      return { error: "Issues data not found" } unless issues_data
      
      {
        issues_count: issues_data["issues_count"],
        pull_requests_count: issues_data["pull_requests_count"],
        issues_closed_count: issues_data["issues_closed_count"],
        pull_requests_closed_count: issues_data["pull_requests_closed_count"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_issue_timing(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      issues_data = @client.repository_issues("GitHub", owner, repo)
      return { error: "Issues data not found" } unless issues_data
      
      {
        avg_time_to_close_issue: issues_data["avg_time_to_close_issue"],
        avg_time_to_close_pull_request: issues_data["avg_time_to_close_pull_request"],
        past_year_avg_time_to_close_issue: issues_data["past_year_avg_time_to_close_issue"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_maintainer_info(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      issues_data = @client.repository_issues("GitHub", owner, repo)
      return { error: "Issues data not found" } unless issues_data
      
      {
        maintainers: issues_data["maintainers"],
        active_maintainers: issues_data["active_maintainers"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_contributor_counts(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      issues_data = @client.repository_issues("GitHub", owner, repo)
      return { error: "Issues data not found" } unless issues_data
      
      {
        pull_request_authors_count: issues_data["pull_request_authors_count"],
        issue_authors_count: issues_data["issue_authors_count"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_past_year_activity(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      issues_data = @client.repository_issues("GitHub", owner, repo)
      return { error: "Issues data not found" } unless issues_data
      
      {
        past_year_issues_count: issues_data["past_year_issues_count"],
        past_year_pull_requests_count: issues_data["past_year_pull_requests_count"],
        past_year_pull_requests_closed_count: issues_data["past_year_pull_requests_closed_count"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  # Commit Activity Tools
  def get_commit_overview(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      commits_data = @client.repository_commits("GitHub", owner, repo)
      return { error: "Commits data not found" } unless commits_data
      
      {
        id: commits_data["id"],
        full_name: commits_data["full_name"],
        default_branch: commits_data["default_branch"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_committer_list(args)
    repo_url = args[:repo_url] || args["repo_url"]
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      commits_data = @client.repository_commits("GitHub", owner, repo)
      return { error: "Commits data not found" } unless commits_data
      
      {
        committers: commits_data["committers"]
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  def get_top_committers(args)
    repo_url = args[:repo_url] || args["repo_url"]
    limit = args[:limit] || args["limit"] || 10
    return { error: "Repository URL required" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      commits_data = @client.repository_commits("GitHub", owner, repo)
      return { error: "Commits data not found" } unless commits_data
      
      committers = commits_data["committers"] || []
      top_committers = committers.sort_by { |c| -(c["count"] || 0) }.take(limit)
      
      {
        top_committers: top_committers,
        limit_used: limit
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end

  # Vulnerability Tools
  def get_vulnerability_list(args)
    # Parse the purl to get ecosystem and name
    purl_obj = Purl::PackageURL.parse(args[:purl] || args["purl"])
    ecosystem = case purl_obj.type
                when "pypi" then "pypi"
                when "npm" then "npm"
                when "cargo" then "cargo"
                when "gem" then "rubygems"
                when "nuget" then "nuget"
                when "maven" then "maven"
                else purl_obj.type
                end
    
    vulnerabilities = @client.vulnerabilities(ecosystem, purl_obj.name)
    
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
            identifiers: vuln["identifiers"],
            vulnerable_versions: vuln["packages"]&.map { |pkg| pkg["vulnerable_version_range"] }&.compact
          }
        end
      }
    else
      { vulnerabilities: [] }
    end
  end

  def get_vulnerability_counts_by_severity(args)
    # Parse the purl to get ecosystem and name
    purl_obj = Purl::PackageURL.parse(args[:purl] || args["purl"])
    ecosystem = case purl_obj.type
                when "pypi" then "pypi"
                when "npm" then "npm"
                when "cargo" then "cargo"
                when "gem" then "rubygems"
                when "nuget" then "nuget"
                when "maven" then "maven"
                else purl_obj.type
                end
    
    vulnerabilities = @client.vulnerabilities(ecosystem, purl_obj.name)
    
    if vulnerabilities && vulnerabilities.any?
      severity_counts = vulnerabilities.group_by { |v| v["severity"]&.upcase || "UNKNOWN" }
                                      .transform_values(&:count)
      
      {
        critical: severity_counts["CRITICAL"] || 0,
        high: severity_counts["HIGH"] || 0,
        moderate: severity_counts["MODERATE"] || severity_counts["MEDIUM"] || 0,
        low: severity_counts["LOW"] || 0,
        unknown: severity_counts["UNKNOWN"] || 0,
        total: vulnerabilities.length
      }
    else
      {
        critical: 0,
        high: 0,
        moderate: 0,
        low: 0,
        unknown: 0,
        total: 0
      }
    end
  end

  def get_latest_vulnerability_date(args)
    # Parse the purl to get ecosystem and name
    purl_obj = Purl::PackageURL.parse(args[:purl] || args["purl"])
    ecosystem = case purl_obj.type
                when "pypi" then "pypi"
                when "npm" then "npm"
                when "cargo" then "cargo"
                when "gem" then "rubygems"
                when "nuget" then "nuget"
                when "maven" then "maven"
                else purl_obj.type
                end
    
    vulnerabilities = @client.vulnerabilities(ecosystem, purl_obj.name)
    
    if vulnerabilities && vulnerabilities.any?
      latest_date = vulnerabilities.map { |v| v["published_at"] }
                                  .compact
                                  .map { |date| Time.parse(date) rescue nil }
                                  .compact
                                  .max
      
      {
        latest_vulnerability_date: latest_date&.iso8601,
        days_since_latest: latest_date ? ((Time.now - latest_date) / (24 * 60 * 60)).round : nil
      }
    else
      {
        latest_vulnerability_date: nil,
        days_since_latest: nil
      }
    end
  end
end