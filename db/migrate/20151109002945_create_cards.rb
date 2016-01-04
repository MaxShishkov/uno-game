class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|

      t.integer :game_id, null: false, :references => [:games, :id]
      t.integer :owner, null: false, default: 0, :references => [:users, :id]
      t.string :value
      t.string :color

      t.timestamps null: false
    end
  end
end
