class GetRepoTagsTool < BaseTool
  def self.description
    "Get repository tags using ecosyste.ms repos API"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy) or PURL (e.g. pkg:pypi/numpy, pkg:github/octobox/octobox, pkg:git/example/repo)" },
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

    # Use the direct tags API URL from the lookup response
    tags_api_url = repo_lookup["tags_url"]
    return { error: "Tags API URL not available" } unless tags_api_url
    
    # Add pagination parameters to the URL
    tags_url_with_params = "#{tags_api_url}?page=#{page}&per_page=#{per_page}"

    # Make API call using the direct URL
    tags = @client.fetch_external_api(tags_url_with_params)
    
    if tags && tags.any?
      {
        tags: tags.map do |tag|
          {
            name: tag["name"],
            sha: tag["sha"],
            kind: tag["kind"],
            published_at: tag["published_at"]
          }
        end,
        pagination: { page: page, per_page: per_page }
      }
    else
      { tags: [], pagination: { page: page, per_page: per_page } }
    end
  end
end