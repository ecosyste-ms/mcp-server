class ToolCall < ApplicationRecord
  validates :tool_name, presence: true
  validates :created_at, presence: true

  def self.log_call(tool_name:, arguments: {}, purl: nil, user_agent: nil, request_id: nil, ip_address: nil)
    create!(
      tool_name: tool_name,
      arguments: arguments.to_json,
      purl: purl,
      user_agent: user_agent,
      request_id: request_id,
      ip_address: ip_address,
      created_at: Time.current
    )
  rescue => e
    Rails.logger.error "Failed to log tool call: #{e.message}"
    nil
  end
end