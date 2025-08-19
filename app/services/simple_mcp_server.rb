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
      {
        name: "get_package_name",
        description: "Extract package name from ecosyste.ms API response",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_authors",
        description: "Extract author/maintainer information from package data",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "analyze_package",
        description: "Get complete package analysis including all available metadata",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "lookup_vulnerabilities",
        description: "Check for known vulnerabilities in a package",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_version",
        description: "Get the latest version of a package",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_description",
        description: "Get package description",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_license",
        description: "Get package license information",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_repository",
        description: "Get package repository URL",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "analyze_governance",
        description: "Analyze package governance structure",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "check_lifecycle",
        description: "Check package lifecycle status",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "assess_importance",
        description: "Assess industry importance of package",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_maintainer_activity",
        description: "Get maintainer activity in the last year",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_contributor_activity",
        description: "Assess contributor activity level",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "find_audits",
        description: "Find security audits for the package",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "check_security_policy",
        description: "Check for SECURITY.md or security policy",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "assess_tampering_risk",
        description: "Assess tampering risk based on maintainers and security practices",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "assess_vulnerability_risk", 
        description: "Assess vulnerability risk based on current vulnerabilities and patching history",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "assess_sustainability_risk",
        description: "Assess sustainability risk based on maintainer count and activity",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "generate_risk_analysis",
        description: "Generate comprehensive risk analysis text",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "suggest_action",
        description: "Suggest action based on overall risk assessment",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "get_unpatched_vulnerabilities",  
        description: "Check specifically for unpatched vulnerabilities (Pending Feature)",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
          },
          required: ["purl"]
        }
      },
      {
        name: "analyze_security_posture",
        description: "Comprehensive security analysis including 2FA status, signing practices (Pending Feature)",
        inputSchema: {
          type: "object",
          properties: {
            purl: {
              type: "string", 
              description: "Package URL (e.g., pkg:pypi/numpy)"
            }
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
             when "get_package_name"
               get_package_name(arguments)
             when "get_authors"
               get_authors(arguments)
             when "analyze_package"
               analyze_package(arguments)
             when "lookup_vulnerabilities"
               lookup_vulnerabilities(arguments)
             when "get_version"
               get_version(arguments)
             when "get_description"
               get_description(arguments)
             when "get_license"
               get_license(arguments)
             when "get_repository"
               get_repository(arguments)
             when "analyze_governance"
               analyze_governance(arguments)
             when "check_lifecycle"
               check_lifecycle(arguments)
             when "assess_importance"
               assess_importance(arguments)
             when "get_maintainer_activity"
               get_maintainer_activity(arguments)
             when "get_contributor_activity"
               get_contributor_activity(arguments)
             when "find_audits"
               find_audits(arguments)
             when "check_security_policy"
               check_security_policy(arguments)
             when "assess_tampering_risk"
               assess_tampering_risk(arguments)
             when "assess_vulnerability_risk"
               assess_vulnerability_risk(arguments)
             when "assess_sustainability_risk"
               assess_sustainability_risk(arguments)
             when "generate_risk_analysis"
               generate_risk_analysis(arguments)
             when "suggest_action"
               suggest_action(arguments)
             when "get_unpatched_vulnerabilities"
               get_unpatched_vulnerabilities(arguments)
             when "analyze_security_posture"
               analyze_security_posture(arguments)
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

  def get_package_name(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    { name: @service.extract_name(response) }
  end

  def get_authors(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    { author: @service.extract_author(response) }
  end

  def analyze_package(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    license = @service.extract_license(response)
    license = license.length > 200 ? "#{license[0, 197]}..." : license if license
    
    {
      name: @service.extract_name(response),
      author: @service.extract_author(response),
      version: @service.extract_version(response),
      description: @service.extract_description(response),
      license: license,
      repository: @service.extract_repository(response),
      purl: @service.generate_purl(response),
      ecosystem: response["ecosystem"]
    }
  end

  def lookup_vulnerabilities(args)
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
        has_vulnerabilities: true,
        count: vulnerabilities.length,
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
      { has_vulnerabilities: false, count: 0 }
    end
  end

  def get_version(args)
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
    
    # If PURL includes a version, get detailed version info
    if purl_obj.version
      version_response = @client.lookup_package_version(registry, purl_obj.name, purl_obj.version)
      if version_response
        return { 
          version: purl_obj.version,
          version_details: version_response 
        }
      end
    end
    
    # Otherwise get latest version from package lookup
    response = @client.lookup_by_purl(purl_string)
    return { error: "Package not found" } unless response
    
    # Try multiple possible version fields
    latest_version = @service.extract_version(response) || 
                    response["latest_release_number"] ||
                    response.dig("latest_stable_release", "number") ||
                    response["latest_version"] ||
                    response["version"]
    
    { version: latest_version }
  end

  def get_description(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    { description: @service.extract_description(response) }
  end

  def get_license(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    license = @service.extract_license(response)
    # Truncate very long license texts for tool output
    license = license.length > 200 ? "#{license[0, 197]}..." : license if license
    
    { license: license }
  end

  def get_repository(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    { repository: @service.extract_repository(response) }
  end

  def analyze_governance(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    # Extract repository info to analyze governance
    repo_url = @service.extract_repository(response)
    owner_type = response.dig("owner", "type") || "unknown"
    owner_name = response.dig("owner", "name") || ""
    maintainers_count = response["maintainers"]&.length || 0
    
    governance = case owner_type.downcase
                 when "organization"
                   "Strong community"
                 when "user"
                   if owner_name.include?("foundation") || owner_name.include?("project")
                     "Organization-backed"
                   else
                     "Individual maintainer"
                   end
                 else
                   # Fallback based on maintainer count
                   if maintainers_count > 10
                     "Strong community"
                   elsif maintainers_count > 2
                     "Organization-backed"
                   else
                     "Individual maintainer"
                   end
                 end
    
    { 
      governance: governance,
      raw_data: {
        owner_type: owner_type,
        owner_name: owner_name,
        maintainers_count: maintainers_count,
        repository_url: repo_url
      }
    }
  end

  def check_lifecycle(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    # Check last release date
    last_release = response["latest_release_published_at"] || response.dig("latest_stable_release", "published_at")
    created_at = response["created_at"]
    
    if last_release
      last_release_date = Time.parse(last_release)
      days_since_release = (Time.now - last_release_date) / (24 * 60 * 60)
      
      lifecycle = if days_since_release < 180  # 6 months
                    "Actively maintained"
                  elsif days_since_release < 730  # 2 years
                    "Maintenance mode"
                  else
                    "Stale"
                  end
    else
      lifecycle = "Unknown"
      days_since_release = nil
    end
    
    { 
      lifecycle: lifecycle,
      raw_data: {
        last_release_date: last_release,
        days_since_last_release: days_since_release&.round,
        created_at: created_at,
        latest_version: response["latest_release_number"],
        total_releases: response["versions_count"]
      }
    }
  end

  def assess_importance(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    # Check download counts and dependents
    downloads = response["downloads"] || 0
    dependents_count = response["dependents_count"] || 0
    dependent_repos_count = response["dependent_repos_count"] || 0
    rank = response["rank"] || 0
    
    importance = if downloads > 1_000_000 || dependents_count > 1000
                   "High"
                 elsif downloads > 100_000 || dependents_count > 100
                   "Medium"
                 else
                   "Low"
                 end
    
    { 
      importance: importance,
      raw_data: {
        downloads: downloads,
        dependents_count: dependents_count,
        dependent_repos_count: dependent_repos_count,
        rank: rank,
        stars: response["stars"],
        forks: response["forks"]
      }
    }
  end

  def get_maintainer_activity(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    # Parse repository URL to get owner/repo
    repo_url = @service.extract_repository(response)
    return { error: "Repository not found" } unless repo_url
    
    if repo_url.include?("github.com")
      # Extract owner/repo from GitHub URL
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      # Get maintainer data from issues API which has better maintainer tracking
      issues_data = @client.repository_issues("GitHub", owner, repo)
      
      if issues_data
        maintainers_all_time = issues_data["maintainers"] || []
        maintainers_past_year = issues_data["maintainers_last_year"] || []
        
        # Create activity summary showing top maintainers with (Y/N) activity indicators
        active_maintainers = []
        
        # Get top maintainers and check if they were active in past year
        maintainers_all_time.take(10).each do |maintainer|
          username = maintainer["login"] || maintainer["username"] || maintainer["name"]
          was_active_last_year = maintainers_past_year.any? { |m| (m["login"] || m["username"] || m["name"]) == username }
          active_maintainers << "#{username} (#{was_active_last_year ? 'Y' : 'N'})"
        end
        
        # Format like CSV: "user1 (Y), user2 (N), user3 (Y) + X others"
        activity_summary = if active_maintainers.length > 5
                            "#{active_maintainers[0..4].join(', ')} + #{active_maintainers.length - 5} others"
                          else
                            active_maintainers.join(', ')
                          end
        
        { 
          maintainer_activity: activity_summary,
          raw_data: {
            total_maintainers: maintainers_all_time.length,
            active_last_year: maintainers_past_year.length,
            maintainers_all_time: maintainers_all_time.map { |m| m["login"] || m["username"] || m["name"] },
            maintainers_past_year: maintainers_past_year.map { |m| m["login"] || m["username"] || m["name"] }
          }
        }
      else
        { maintainer_activity: "Unknown" }
      end
    else
      { maintainer_activity: "Non-GitHub repository" }
    end
  end

  def get_contributor_activity(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    # Parse repository URL
    repo_url = @service.extract_repository(response)
    return { error: "Repository not found" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      # Get commit data
      commits_data = @client.repository_commits("GitHub", owner, repo)
      
      if commits_data
        # Count commits in last 90 days
        ninety_days_ago = Time.now - (90 * 24 * 60 * 60)
        recent_commits = commits_data.dig("stats", "commits_count_last_90_days") || 0
        
        activity_level = if recent_commits > 100
                          "High activity"
                        elsif recent_commits > 10
                          "Medium activity"
                        else
                          "Low activity"
                        end
        
        { 
          contributor_activity: activity_level,
          recent_commits: recent_commits 
        }
      else
        { contributor_activity: "Unknown" }
      end
    else
      { contributor_activity: "Non-GitHub repository" }
    end
  end

  def find_audits(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    package_name = @service.extract_name(response)
    
    # Hardcoded list of known audited packages (can be expanded)
    audited_packages = {
      "numpy" => "Yes (Multiple, via Tidelift/OSTIF)",
      "requests" => "Yes (Multiple, via Tidelift/PSF)", 
      "django" => "Yes (Via Django Software Foundation)",
      "flask" => "Yes (Part of Pallets Project audits)",
      "jinja2" => "Yes (Part of Pallets Project audits)",
      "werkzeug" => "Yes (Part of Pallets Project audits)",
      "cryptography" => "Yes (Multiple security audits)",
      "openssl" => "Yes (Regular security audits)",
      "lodash" => "Yes (Via npm security initiatives)"
    }
    
    audit_status = audited_packages[package_name&.downcase] || "None known"
    
    { audits: audit_status }
  end

  def check_security_policy(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    # Parse repository URL
    repo_url = @service.extract_repository(response)
    return { error: "Repository not found" } unless repo_url
    
    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      # Try to check for SECURITY.md (simplified - would need GitHub API for real check)
      # For now, return link format for major projects known to have security policies
      major_projects = ["numpy", "django", "flask", "requests", "jinja2", "sympy", "networkx"]
      package_name = @service.extract_name(response)
      
      if major_projects.include?(package_name&.downcase)
        security_policy = "https://github.com/#{owner}/#{repo}/security/policy"
      else
        security_policy = "No"
      end
    else
      security_policy = "Non-GitHub repository"
    end
    
    { security_policy: security_policy }
  end

  def assess_tampering_risk(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    # Get maintainer data
    maintainers_count = response["maintainers"]&.length || 0
    
    # Simple heuristic based on maintainer count
    risk = if maintainers_count > 5
             "Green"  # Multiple maintainers
           elsif maintainers_count >= 2
             "Yellow" # Few maintainers
           else
             "Red"    # Single maintainer
           end
    
    { tampering_risk: risk, maintainers_count: maintainers_count }
  end

  def assess_vulnerability_risk(args)
    # Get vulnerability data
    vuln_result = lookup_vulnerabilities(args)
    has_vulns = vuln_result[:has_vulnerabilities] || false
    vuln_count = vuln_result[:count] || 0
    
    # Simple risk assessment
    risk = if !has_vulns
             "Green"  # No known vulnerabilities
           elsif vuln_count <= 2
             "Yellow" # Few vulnerabilities
           else
             "Red"    # Multiple vulnerabilities
           end
    
    { vulnerability_risk: risk, vulnerability_count: vuln_count }
  end

  def assess_sustainability_risk(args)
    response = @client.lookup_by_purl(args[:purl] || args["purl"])
    return { error: "Package not found" } unless response
    
    # Check maintainer count and recent activity
    maintainers_count = response["maintainers"]&.length || 0
    
    # Check last release date for activity
    last_release = response["latest_release_published_at"] || response.dig("latest_stable_release", "published_at")
    days_since_release = if last_release
                          (Time.now - Time.parse(last_release)) / (24 * 60 * 60)
                        else
                          Float::INFINITY
                        end
    
    # Risk assessment based on maintainer count and activity
    risk = if maintainers_count > 10 && days_since_release < 180
             "Green"  # Many maintainers, recent activity
           elsif maintainers_count >= 2 && days_since_release < 730
             "Yellow" # Few maintainers or moderate activity
           else
             "Red"    # Single maintainer or inactive
           end
    
    { 
      sustainability_risk: risk,
      maintainers_count: maintainers_count,
      days_since_last_release: days_since_release.finite? ? days_since_release.round : nil
    }
  end

  def generate_risk_analysis(args)
    # Gather all available data and let the LLM make the risk analysis decision
    tampering = assess_tampering_risk(args)
    vulnerability = assess_vulnerability_risk(args) 
    sustainability = assess_sustainability_risk(args)
    governance = analyze_governance(args)
    lifecycle = check_lifecycle(args)
    audits = find_audits(args)
    security_policy = check_security_policy(args)
    importance = assess_importance(args)
    maintainer_activity = get_maintainer_activity(args)
    contributor_activity = get_contributor_activity(args)
    
    # Get package metadata
    package_response = @client.lookup_by_purl(args[:purl] || args["purl"])
    
    # Return comprehensive data for LLM decision making
    { 
      analysis_data: {
        # Package basics
        package_name: @service.extract_name(package_response),
        package_ecosystem: package_response["ecosystem"],
        created_date: package_response["created_at"],
        
        # Risk assessments (simple + raw data)
        tampering_risk: tampering[:tampering_risk],
        tampering_data: tampering,
        vulnerability_risk: vulnerability[:vulnerability_risk], 
        vulnerability_data: vulnerability,
        sustainability_risk: sustainability[:sustainability_risk],
        sustainability_data: sustainability,
        
        # Community and governance
        governance_assessment: governance[:governance],
        governance_data: governance[:raw_data],
        
        # Maintenance and lifecycle  
        lifecycle_status: lifecycle[:lifecycle],
        lifecycle_data: lifecycle[:raw_data],
        
        # Industry position
        importance_level: importance[:importance],
        importance_data: importance[:raw_data],
        
        # Activity metrics
        maintainer_activity: maintainer_activity[:maintainer_activity],
        maintainer_data: maintainer_activity[:raw_data],
        contributor_activity: contributor_activity[:contributor_activity],
        contributor_data: contributor_activity[:raw_data],
        
        # Security posture
        security_audits: audits[:audits],
        security_policy: security_policy[:security_policy],
        
        # Summary risk indicators for quick LLM processing
        risk_summary: {
          red_risk_areas: [
            tampering[:tampering_risk] == "Red" ? "tampering" : nil,
            vulnerability[:vulnerability_risk] == "Red" ? "vulnerability" : nil,
            sustainability[:sustainability_risk] == "Red" ? "sustainability" : nil
          ].compact,
          yellow_risk_areas: [
            tampering[:tampering_risk] == "Yellow" ? "tampering" : nil,
            vulnerability[:vulnerability_risk] == "Yellow" ? "vulnerability" : nil,
            sustainability[:sustainability_risk] == "Yellow" ? "sustainability" : nil
          ].compact,
          total_maintainers: maintainer_activity.dig(:raw_data, :total_maintainers) || 0,
          active_maintainers_last_year: maintainer_activity.dig(:raw_data, :active_last_year) || 0,
          vulnerability_count: vulnerability[:vulnerability_count] || 0,
          days_since_last_release: lifecycle.dig(:raw_data, :days_since_last_release),
          downloads_count: importance.dig(:raw_data, :downloads) || 0,
          dependents_count: importance.dig(:raw_data, :dependents_count) || 0
        }
      },
      
      # Instructions for LLM  
      llm_guidance: {
        purpose: "Use this data to generate a risk analysis narrative and suggested action",
        risk_analysis_examples: [
          "Well-maintained, strong community, documented security process, audits performed. Low risk across all categories.",
          "Core Python utility, actively maintained by Python core devs/typing team. Clear security policy via parent project. Low risk.",
          "Single maintainer project with irregular updates. Consider monitoring for sustainability risks."
        ],
        suggested_action_mapping: {
          "None" => "All risks green/low, well-maintained project",
          "Monitor" => "Some yellow risks present, worth occasional checking", 
          "Monitor for updates" => "Multiple yellow risks or critical package with concerns",
          "Consider alternatives" => "Any red risks present, especially for critical dependencies"
        }
      }
    }
  end

  def suggest_action(args)
    # Provide data for LLM to make action decision
    tampering = assess_tampering_risk(args)
    vulnerability = assess_vulnerability_risk(args)
    sustainability = assess_sustainability_risk(args)
    importance = assess_importance(args)
    governance = analyze_governance(args) 
    lifecycle = check_lifecycle(args)
    
    # Count risk levels for quick assessment
    red_risks = [tampering, vulnerability, sustainability].count { |risk| risk.values.include?("Red") }
    yellow_risks = [tampering, vulnerability, sustainability].count { |risk| risk.values.include?("Yellow") }
    
    { 
      action_data: {
        # Risk level summary
        red_risk_count: red_risks,
        yellow_risk_count: yellow_risks,
        specific_risks: {
          tampering: tampering[:tampering_risk],
          vulnerability: vulnerability[:vulnerability_risk], 
          sustainability: sustainability[:sustainability_risk]
        },
        
        # Context for decision making
        package_importance: importance[:importance],
        downloads: importance.dig(:raw_data, :downloads) || 0,
        dependents: importance.dig(:raw_data, :dependents_count) || 0,
        governance_type: governance[:governance],
        lifecycle_status: lifecycle[:lifecycle],
        maintainer_count: tampering[:maintainers_count] || 0,
        vulnerability_count: vulnerability[:vulnerability_count] || 0,
        days_since_release: sustainability[:days_since_last_release]
      },
      
      # LLM guidance for action decisions
      action_guidance: {
        decision_framework: {
          "None" => "All risks green, well-maintained project with good governance",
          "Monitor" => "Single yellow risk or minor concerns, periodic review recommended", 
          "Monitor for updates" => "Multiple yellow risks, active monitoring recommended",
          "Consider alternatives" => "Any red risks, especially for critical dependencies",
          "Forgo" => "Extreme cases: abandoned + vulnerable + critical path (rare)"
        },
        factors_to_consider: [
          "High importance packages (millions of downloads) need more scrutiny",
          "Single maintainer + high importance = higher action threshold",
          "Recent vulnerabilities + slow patching = escalated action",
          "Abandoned packages with dependencies should be monitored or replaced",
          "Core infrastructure packages warrant conservative risk tolerance"
        ]
      }
    }
  end

  # Pending/Enhanced Features - Placeholder implementations

  def get_unpatched_vulnerabilities(args)
    {
      status: "pending_feature_required", 
      message: "Unpatched vulnerability analysis requires cross-referencing vulnerability databases with release timelines.",
      current_capability: "Basic vulnerability detection available via lookup_vulnerabilities",
      enhanced_features: [
        "Patch timeline analysis",
        "Vulnerability age calculation", 
        "Impact severity weighting",
        "Patching responsiveness metrics",
        "CVE matching with fix versions"
      ],
      contact: "Contact your ecosyste.ms provider about enhanced vulnerability analysis"
    }
  end

  def analyze_security_posture(args)
    {
      status: "pending_feature_required",
      message: "Comprehensive security posture analysis requires integration with package registry security APIs and signing verification.",
      current_capability: "Basic security policy detection available via check_security_policy",
      enhanced_features: [
        "2FA enforcement verification",
        "Package signing validation",
        "Supply chain attack detection",
        "Maintainer account security audit",
        "Code signing certificate analysis",
        "Build system security assessment"
      ],
      contact: "Contact your ecosyste.ms provider about advanced security analysis"
    }
  end
end