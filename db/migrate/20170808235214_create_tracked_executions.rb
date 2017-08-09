class CreateTrackedExecutions < ActiveRecord::Migration
  def change
    create_table :tracked_executions do |t|
      t.string :title
      t.timestamp :start
      t.timestamp :end

      t.timestamps null: false
    end
  end
end
