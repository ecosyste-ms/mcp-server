class GetRepoScorecardTool < BaseTool
  def self.description
    "Get repository security scorecard using ecosyste.ms repos API"
  end

  def self.category
    "Repository"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy) or PURL (e.g., pkg:pypi/numpy)" },
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

    # Use the direct scorecard API URL from the lookup response
    scorecard_api_url = repo_lookup["scorecard_url"]
    return { error: "Scorecard API URL not available" } unless scorecard_api_url

    # Make API call using the direct URL
    scorecard = @client.fetch_external_api(scorecard_api_url)
    
    if scorecard
      {
        overall_score: scorecard["overall_score"],
        checks: scorecard["checks"] || [],
        date: scorecard["date"],
        repo: scorecard["repo"]
      }
    else
      { error: "Scorecard not available for this repository" }
    end
  end
end