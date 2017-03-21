class AddClomnToFangPrice < ActiveRecord::Migration
  def change
    add_column :fang_prices, :price_date, :date, default: Time.now
    add_column :fang_prices, :add_price, :integer, default: 0
    add_column :fang_prices, :add_unit_price, :integer, default: 0

    add_column :er_shou_fangs, :is_five, :boolean, default: false
    add_column :er_shou_fangs, :is_two, :boolean, default: false
    add_column :er_shou_fangs, :is_subway, :boolean, default: false
    add_column :er_shou_fangs, :is_key, :boolean, default: false

    add_index :fang_prices, :price_date
    add_index :fang_prices, :add_price
    add_index :fang_prices, :add_unit_price
  end
end
