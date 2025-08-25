class GetRepoApiUrlsTool < BaseTool
  def self.description
    "Get ecosyste.ms JSON API URLs for repository analysis"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g. github.com/numpy/numpy) or PURL (e.g. pkg:pypi/numpy, pkg:github/octobox/octobox, pkg:git/example/repo)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["repo_url", "context"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup
    
    # Extract basic info
    host_name = repo_lookup["host"]["name"]
    full_name = repo_lookup["full_name"]
    owner = repo_lookup["owner"]
    repo_name = repo_lookup["name"]
    
    # Repository API URLs from the lookup response
    repository_api_urls = {
      repository_lookup: "https://repos.ecosyste.ms/api/v1/repositories/lookup?url=#{CGI.escape(repo_lookup["html_url"] || repo_url)}",
      repository: repo_lookup["repository_url"],
      repository_tags: repo_lookup["tags_url"],
      repository_releases: repo_lookup["releases_url"],
      repository_manifests: repo_lookup["manifests_url"],
      repository_sbom: repo_lookup["sbom_url"],
      repository_scorecard: repo_lookup["scorecard_url"]
    }.compact
    
    # Owner API URLs
    if repo_lookup["owner_url"]
      repository_api_urls[:repository_owner] = repo_lookup["owner_url"]
      repository_api_urls[:owner_repositories] = repo_lookup["owner"]["repositories_url"] if repo_lookup["owner"]
    end
    
    # Host API URLs
    if repo_lookup["host"]
      host = repo_lookup["host"]
      repository_api_urls[:host] = host["url"]
      repository_api_urls[:host_repositories] = host["repositories_url"]
      repository_api_urls[:host_owners] = host["owners_url"]
    end
    
    # Issues and Commits API URLs (these use different base URLs)
    if host_name && full_name
      encoded_full_name = CGI.escape(full_name)
      repository_api_urls[:repository_issues] = "https://issues.ecosyste.ms/api/v1/hosts/#{host_name}/repositories/#{encoded_full_name}"
      repository_api_urls[:repository_commits] = "https://commits.ecosyste.ms/api/v1/hosts/#{host_name}/repositories/#{encoded_full_name}"
      repository_api_urls[:repository_committers] = "https://commits.ecosyste.ms/api/v1/hosts/#{host_name}/repositories/#{encoded_full_name}/committers"
      repository_api_urls[:repository_activity] = "https://issues.ecosyste.ms/api/v1/hosts/#{host_name}/repositories/#{encoded_full_name}/activity"
    end
    
    # Archive API URLs for file contents
    if host_name && owner && repo_name
      encoded_owner = CGI.escape(owner)
      encoded_repo = CGI.escape(repo_name)
      repository_api_urls[:repository_readme] = "https://archives.ecosyste.ms/api/v1/repositories/#{host_name}/#{encoded_owner}/#{encoded_repo}/readme"
      repository_api_urls[:repository_files] = "https://archives.ecosyste.ms/api/v1/repositories/#{host_name}/#{encoded_owner}/#{encoded_repo}/files"
      repository_api_urls[:repository_changelog] = "https://archives.ecosyste.ms/api/v1/repositories/#{host_name}/#{encoded_owner}/#{encoded_repo}/changelog"
    end
    
    {
      repository_url: repo_lookup["html_url"] || repo_url,
      full_name: full_name,
      host: host_name,
      owner: owner,
      name: repo_name,
      api_urls: repository_api_urls
    }
  end
end