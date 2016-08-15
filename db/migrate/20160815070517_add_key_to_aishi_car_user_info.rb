class AddKeyToAishiCarUserInfo < ActiveRecord::Migration
  def change
    add_column :aishi_car_user_infos, :numbers, :string, :default => ''
    add_column :aishi_car_user_infos, :k, :string, :default => ''
  end
end
