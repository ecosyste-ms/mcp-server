class ToolCall < ApplicationRecord
  validates :tool_name, presence: true
  validates :created_at, presence: true

  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }
  scope :by_error_type, ->(error_type) { where(error_type: error_type) }

  def self.log_call(tool_name:, arguments: {}, purl: nil, user_agent: nil, request_id: nil, ip_address: nil, success: true, error_message: nil, error_type: nil)
    # Extract purl from arguments if not explicitly provided
    extracted_purl = purl || arguments[:purl] || arguments["purl"] || arguments[:repo_url] || arguments["repo_url"]
    create!(
      tool_name: tool_name,
      arguments: arguments.to_json,
      purl: extracted_purl,
      user_agent: user_agent,
      request_id: request_id,
      ip_address: ip_address,
      success: success,
      error_message: error_message,
      error_type: error_type,
      created_at: Time.current
    )
  rescue => e
    Rails.logger.error "Failed to log tool call: #{e.message}"
    nil
  end

  def self.log_success(tool_name:, arguments: {}, purl: nil, user_agent: nil, request_id: nil, ip_address: nil)
    log_call(
      tool_name: tool_name,
      arguments: arguments,
      purl: purl,
      user_agent: user_agent,
      request_id: request_id,
      ip_address: ip_address,
      success: true
    )
  end

  def self.log_error(tool_name:, arguments: {}, error:, purl: nil, user_agent: nil, request_id: nil, ip_address: nil)
    error_type = error.class.name
    error_message = error.message
    
    log_call(
      tool_name: tool_name,
      arguments: arguments,
      purl: purl,
      user_agent: user_agent,
      request_id: request_id,
      ip_address: ip_address,
      success: false,
      error_message: error_message,
      error_type: error_type
    )
  end
end
