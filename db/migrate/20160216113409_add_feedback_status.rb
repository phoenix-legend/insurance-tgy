class AddFeedbackStatus < ActiveRecord::Migration
  def change
    add_column :car_user_infos, :tt_yaoyue, :string
    add_column :car_user_infos, :tt_jiance, :string
    add_column :car_user_infos, :tt_chengjiao, :string
  end
end
