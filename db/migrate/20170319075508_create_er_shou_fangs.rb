class CreateErShouFangs < ActiveRecord::Migration
  def change
    create_table :er_shou_fangs do |t|

      t.string :lianjia_id
      t.string :province
      t.string :city
      t.string :districe
      t.string :districe_code
      t.string :town
      t.string :town_code
      t.string :title

      t.string :detail_url
      t.integer :last_price
      t.integer :area
      t.integer :hall_number
      t.integer :room_number
      t.string :mark
      t.string :xiaoqu_name
      t.integer :last_unit_price

      t.timestamps

      t.index :lianjia_id

    end
  end
end
