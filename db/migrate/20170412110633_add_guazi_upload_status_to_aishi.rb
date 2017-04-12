class AddGuaziUploadStatusToAishi < ActiveRecord::Migration
  def change
    add_column :aishi_car_user_infos, :gz_upload_status, :string
    add_column :aishi_car_user_infos, :yth_upload_status, :string
    add_column :aishi_car_user_infos, :yth_upload_time, :datetime

    add_index :aishi_car_user_infos, :gz_upload_status
    add_index :aishi_car_user_infos, :yth_upload_status
    add_index :aishi_car_user_infos, :yth_upload_time
  end
end
