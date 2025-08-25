class GetRepoReleasesTool < BaseTool
  def self.description
    "Get repository releases using ecosyste.ms repos API"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" },
        page: { type: "number", description: "Page number (default: 1)" },
        per_page: { type: "number", description: "Items per page (default: 30)" },
        context: { type: "string", description: "Context for why this tool is being used" }
      },
      required: ["repo_url", "context"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    page = arguments[:page] || arguments["page"] || 1
    per_page = arguments[:per_page] || arguments["per_page"] || 30

    # Look up repository metadata first
    repo_lookup = @client.repository_lookup(repo_url)
    return { error: "Repository not found" } unless repo_lookup

    # Use the direct releases API URL from the lookup response
    releases_api_url = repo_lookup["releases_url"]
    return { error: "Releases API URL not available" } unless releases_api_url
    
    # Add pagination parameters to the URL
    releases_url_with_params = "#{releases_api_url}?page=#{page}&per_page=#{per_page}"

    # Make API call using the direct URL
    releases = @client.fetch_external_api(releases_url_with_params)
    
    if releases && releases.any?
      {
        releases: releases.map do |release|
          {
            tag_name: release["tag_name"],
            name: release["name"],
            body: release["body"],
            draft: release["draft"],
            prerelease: release["prerelease"],
            published_at: release["published_at"]
          }
        end,
        pagination: { page: page, per_page: per_page }
      }
    else
      { releases: [], pagination: { page: page, per_page: per_page } }
    end
  end
end