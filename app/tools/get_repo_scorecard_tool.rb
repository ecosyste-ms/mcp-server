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

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      scorecard = @client.repository_scorecard("GitHub", owner, repo)
      
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
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end