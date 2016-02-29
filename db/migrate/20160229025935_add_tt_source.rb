class AddTtSource < ActiveRecord::Migration
  def change
    add_column :car_user_infos, :tt_source, :string
    add_column :car_user_infos, :tt_created_day, :date
    add_column :car_user_infos, :tt_yaoyue_day, :date
  end
end
