class CreatePlanets < ActiveRecord::Migration
  def change
    create_table :planets do |t|
      t.string :name
      t.integer :distance
      t.boolean :habitable, default: false

      t.timestamps null: false
    end
  end
end
