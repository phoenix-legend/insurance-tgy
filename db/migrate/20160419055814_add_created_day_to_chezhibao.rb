class AddCreatedDayToChezhibao < ActiveRecord::Migration
  def change
    add_column :chezhibao_car_user_infos, :created_day, :date
    add_column :chezhibao_car_user_infos, :yaoyue_time, :datetime
    add_column :chezhibao_car_user_infos, :yaoyue_day, :date
    add_column :chezhibao_car_user_infos, :czb_status, :integer
    add_column :chezhibao_car_user_infos, :czb_status_message, :string

    add_index :chezhibao_car_user_infos, :czb_status
    add_index :chezhibao_car_user_infos, :created_day
    add_index :chezhibao_car_user_infos, :yaoyue_day

  end
end
