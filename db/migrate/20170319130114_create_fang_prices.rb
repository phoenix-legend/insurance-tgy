class CreateFangPrices < ActiveRecord::Migration
  def change
    create_table :fang_prices do |t|
      t.references :er_shou_fang, foreign_key: true
      t.integer :price
      t.integer :unit_price
      t.string :lianjia_id
      t.timestamps

      t.index :lianjia_id
      t.index :created_at
    end
  end
end
