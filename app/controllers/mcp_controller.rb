class McpController < ApplicationController
  skip_before_action :verify_authenticity_token

  def handle
    begin
      request_body = request.body.read
      
      mcp_server = McpServer.new
      response_data = mcp_server.handle_request(request_body, user_agent: request.headers["User-Agent"], request_id: request.request_id, ip_address: request.remote_ip)

      render json: response_data
    # rescue => e
    #   Rails.logger.error "MCP Error: #{e.message}"
    #   Rails.logger.error e.backtrace.join("\n")

    #   render json: {
    #     jsonrpc: "2.0",
    #     error: {
    #       code: -32603,
    #       message: "Internal error",
    #       data: e.message
    #     }
    #   }, status: 500
    end
  end

  def health
    mcp_server = McpServer.new
    tools = mcp_server.tools_list

    render json: {
      status: "healthy",
      server: "Ecosyste.ms MCP Server",
      version: "1.0.0",
      tools_count: tools.length,
      message: "#{tools.length} MCP tools available for package ecosystem analysis",
      tools: tools.map { |tool| { name: tool[:name], description: tool[:description] } }
    }
  end

  def admin
    @tool_calls = ToolCall.order(created_at: :desc).limit(1000)
    @failed_calls = ToolCall.failed.order(created_at: :desc).limit(100)
    @stats = {
      total_calls: ToolCall.count,
      successful_calls: ToolCall.successful.count,
      failed_calls: ToolCall.failed.count,
      success_rate: ToolCall.count > 0 ? (ToolCall.successful.count.to_f / ToolCall.count * 100).round(2) : 0,
      unique_tools: ToolCall.distinct.count(:tool_name),
      unique_purls: ToolCall.where.not(purl: nil).distinct.count(:purl),
      unique_ips: ToolCall.where.not(ip_address: nil).distinct.count(:ip_address),
      calls_today: ToolCall.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count,
      failed_today: ToolCall.failed.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day).count,
      calls_this_week: ToolCall.where(created_at: 1.week.ago.beginning_of_day..Time.current).count,
      failed_this_week: ToolCall.failed.where(created_at: 1.week.ago.beginning_of_day..Time.current).count,
      top_error_types: ToolCall.failed.group(:error_type).count.sort_by(&:second).reverse.first(10)
    }

    respond_to do |format|
      format.html
      format.json { render json: { tool_calls: @tool_calls, failed_calls: @failed_calls, stats: @stats } }
    end
  end
end
