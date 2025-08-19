class PagesController < ApplicationController
  def home
    mcp_server = McpServer.new
    tools = mcp_server.tools_list
    @tools_by_category = tools.group_by { |tool| tool[:category] }
    @total_tools = tools.length
  end
end