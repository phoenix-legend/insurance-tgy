class AddIsRepeatOneMonth < ActiveRecord::Migration
  def change
      add_column :car_user_infos, :is_repeat_one_month, :boolean, :default => false
  end
end
