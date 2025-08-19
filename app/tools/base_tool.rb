class BaseTool
  def initialize(client = nil)
    @client = client || EcosystemsClient.new
  end

  def self.tool_name
    name.underscore.gsub('_tool', '')
  end

  def self.description
    raise NotImplementedError, "Must implement description"
  end

  def self.input_schema
    raise NotImplementedError, "Must implement input_schema"
  end

  def call(arguments)
    raise NotImplementedError, "Must implement call method"
  end

  def self.to_mcp_tool
    {
      name: tool_name,
      description: description,
      inputSchema: input_schema
    }
  end

  protected

  def extract_purl(args)
    args[:purl] || args["purl"]
  end

  def extract_repo_url(args)
    args[:repo_url] || args["repo_url"]
  end
end