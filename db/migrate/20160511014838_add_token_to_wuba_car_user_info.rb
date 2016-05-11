class AddTokenToWubaCarUserInfo < ActiveRecord::Migration
  def change
    add_column :car_user_infos, :wuba_kouling, :string
    add_column :car_user_infos, :wuba_kouling_status, :string, :default => 'weitijiao' # 未提交， 已提交， 已返回
    add_column :car_user_infos, :wuba_kouling_tijiao_shouji_time, :datetime
    add_column :car_user_infos, :wuba_kouling_shouji_huilai_time, :datetime
    add_column :car_user_infos, :wuba_kouling_deviceid, :string

    add_index :car_user_infos, :wuba_kouling
    add_index :car_user_infos, :wuba_kouling_status

  end
end
