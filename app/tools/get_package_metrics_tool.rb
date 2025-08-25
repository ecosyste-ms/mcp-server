class GetPackageMetricsTool < BaseTool
  def self.description
    "Get package metrics including downloads, dependents, stars, forks, rankings, maintainers, and repository stats"
  end

  def self.category
    "Package"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        purl: { type: "string", description: "Package URL (e.g. pkg:pypi/numpy)" }
      },
      required: ["purl"]
    }
  end

  def call(arguments)
    purl_string = extract_purl(arguments)
    return { error: "PURL required" } unless purl_string

    response = @client.lookup_by_purl(purl_string)
    return { error: "Package not found" } unless response
    
    result = {
      downloads: response["downloads"],
      downloads_period: response["downloads_period"],
      dependents_count: response["dependents_count"],
      dependent_repos_count: response["dependent_repos_count"],
      stars: response["stars"],
      forks: response["forks"],
      subscribers_count: response["subscribers_count"],
      size: response["size"],
      rank: response["rank"],
      maintainers_count: response["maintainers"] ? response["maintainers"].length : nil
    }
    
    # Add commit stats if present
    if response["commit_stats"]
      result[:commits_count] = response["commit_stats"]["total_commits"]
      result[:committers_count] = response["commit_stats"]["total_committers"]
    end
    
    # Add issue/PR stats if present
    if response["issue_metadata"]
      result[:issues_count] = response["issue_metadata"]["issues_count"]
      result[:pull_requests_count] = response["issue_metadata"]["pull_requests_count"]
    end
    
    # Add docker stats if present (these may not exist in all packages)
    result[:docker_downloads_count] = response["docker_downloads_count"]
    result[:docker_dependents_count] = response["docker_dependents_count"]
    
    # Add rankings (should always exist)
    result[:rankings] = response["rankings"]
    
    result
  end
end