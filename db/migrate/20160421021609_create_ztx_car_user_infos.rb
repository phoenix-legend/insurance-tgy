class CreateZtxCarUserInfos < ActiveRecord::Migration
  def change
    create_table :group_car_user_infos do |t|
      t.string :name # 组名，可以填文件名
      t.date :post_date # 提交的日期

      t.timestamps null: false
    end

    create_table :ztx_car_user_infos do |t|
      t.integer :group_car_user_info_id # 所属批次
      t.string :brand # 车辆品牌
      t.date :licensed_date # 上牌时间
      t.string :model_info # 车型
      t.string :owner_name # 车主
      t.string :owner_phone # 车主电话
      t.string :series   # 车系
      t.string :data_id # 提交后返回的线索id
      t.integer :post_status # 提交返回的状态
      t.string :post_error_msg # 提交后返回的信息
      t.integer :get_request_status # 查询返回的请求状态
      t.string :get_error_msg # 查询返回的信息
      t.integer :data_status # 数据状态

      t.timestamps null: false
    end
  end
end
