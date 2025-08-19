class AddErrorTrackingToToolCalls < ActiveRecord::Migration[8.0]
  def change
    add_column :tool_calls, :error_message, :text
    add_column :tool_calls, :error_type, :string
    add_column :tool_calls, :success, :boolean, default: true
    
    add_index :tool_calls, :success
    add_index :tool_calls, :error_type
  end
end
