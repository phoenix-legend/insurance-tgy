class AddCreatedDayToYouche < ActiveRecord::Migration
  def change
    add_column :youche_car_user_infos, :site_name , :string
    add_column :youche_car_user_infos, :created_day, :date
    add_column :youche_car_user_infos, :yaoyue_time, :datetime
    add_column :youche_car_user_infos, :yaoyue_day, :date
    add_column :youche_car_user_infos, :yc_status, :integer
    add_column :youche_car_user_infos, :yc_status_message, :string

    add_index :youche_car_user_infos, :yc_status
    add_index :youche_car_user_infos, :created_day
    add_index :youche_car_user_infos, :yaoyue_day
  end
end
