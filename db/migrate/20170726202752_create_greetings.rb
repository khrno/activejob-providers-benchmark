class CreateGreetings < ActiveRecord::Migration
  def change
    create_table :greetings do |t|
      t.string :name
      t.string :queue_provider

      t.timestamps null: false
    end
  end
end
