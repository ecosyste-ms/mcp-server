class GetRepoReadmeTool < BaseTool
  def self.description
    "Get repository README content using archives API"
  end

  def self.input_schema
    {
      type: "object",
      properties: {
        repo_url: { type: "string", description: "Repository URL (e.g., github.com/numpy/numpy)" }
      },
      required: ["repo_url"]
    }
  end

  def call(arguments)
    repo_url = extract_repo_url(arguments)
    return { error: "Repository URL required" } unless repo_url

    if repo_url.include?("github.com")
      parts = repo_url.gsub("https://", "").gsub("http://", "").gsub("github.com/", "").split("/")
      return { error: "Invalid GitHub URL" } if parts.length < 2
      
      owner, repo = parts[0], parts[1]
      
      readme = @client.repository_readme("GitHub", owner, repo)
      
      {
        readme: readme,
        exists: !readme.nil?
      }
    else
      { error: "Only GitHub repositories supported currently" }
    end
  end
end