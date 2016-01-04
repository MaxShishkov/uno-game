class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|

      t.string :name, null: false
      t.boolean :session, :default => false
      t.boolean :clockwise, :default => true
      t.integer :lastPlayedCard
      t.string :value
      t.string :color
      t.integer :user, array:true, default: []
      t.integer :whoseTurn

      t.timestamps null: false
    end
  end
end
