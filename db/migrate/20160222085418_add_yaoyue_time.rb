class AddYaoyueTime < ActiveRecord::Migration
  def change
    add_column :car_user_infos, :tt_yaoyue_time, :datetime
  end
end
