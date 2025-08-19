class CreateToolCalls < ActiveRecord::Migration[8.0]
  def change
    create_table :tool_calls do |t|
      t.string :tool_name
      t.text :arguments
      t.string :purl
      t.string :user_agent
      t.string :request_id
      t.string :ip_address

      t.timestamps
    end

    add_index :tool_calls, :tool_name
    add_index :tool_calls, :purl
    add_index :tool_calls, :created_at
    add_index :tool_calls, :ip_address
  end
end
