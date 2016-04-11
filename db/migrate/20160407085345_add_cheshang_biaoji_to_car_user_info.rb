class AddCheshangBiaojiToCarUserInfo < ActiveRecord::Migration
  def change
    add_column :car_user_infos, :is_real_cheshang, :boolean, :default => false
    add_column :car_user_infos, :is_city_match, :boolean, :default => true
    add_column :car_user_infos, :is_pachong, :boolean, :default => false
    add_column :car_user_infos, :phone_city, :string
  end
end

