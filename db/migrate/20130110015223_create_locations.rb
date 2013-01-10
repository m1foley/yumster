class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :description
      t.float :latitude
      t.float :longitude
      t.timestamp :created_at

      t.timestamps
    end
  end
end
