class CreateRobots < ActiveRecord::Migration[5.0]
  def change
    create_table :robots do |t|
      t.integer :x_position
      t.integer :y_position
      t.string :facing
      t.timestamps
    end
  end
end
