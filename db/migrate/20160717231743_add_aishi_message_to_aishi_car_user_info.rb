class AddAishiMessageToAishiCarUserInfo < ActiveRecord::Migration
  def change
    add_column :aishi_car_user_infos, :shiai_message, :string, :default => nil
    add_column :aishi_car_user_infos, :business1_status, :string
    add_column :aishi_car_user_infos, :business2_status, :string
    add_column :aishi_car_user_infos, :business1_name, :string
    add_column :aishi_car_user_infos, :business2_name, :string
  end
end
