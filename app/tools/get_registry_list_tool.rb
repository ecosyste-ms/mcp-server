class GetRegistryListTool < BaseTool
  def self.description
    "Get list of all available package registries"
  end

  def self.category
    "Registry"
  end

  def self.input_schema
    {
      type: "object",
      properties: {},
      required: []
    }
  end

  def call(arguments)
    registries = @client.registry_list
    
    if registries && registries.is_a?(Array)
      {
        registries: registries,
        registries_count: registries.length
      }
    else
      {
        registries: [],
        registries_count: 0
      }
    end
  end
end