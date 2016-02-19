class DeleteCarUserInfoClomns < ActiveRecord::Migration
  def change
    remove_column :car_user_infos, :tt_error
    remove_column :car_user_infos, :tt_result
    remove_column :car_user_infos, :upload_status
    remove_column :car_user_infos, :shibaiyuanyin
    remove_column :car_user_infos, :bookid
    remove_column :car_user_infos, :channel
    remove_column :car_user_infos, :city
    add_column :car_user_infos, :tt_id, :integer
    add_column :car_user_infos, :is_cheshang, :integer, :default => 0
  end
end
