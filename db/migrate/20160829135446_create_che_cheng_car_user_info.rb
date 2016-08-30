class CreateCheChengCarUserInfo < ActiveRecord::Migration
  def change
    create_table :che_cheng_car_user_infos do |t|
      t.string :name
      t.string :phone
      t.string :brand
      t.string :city_chinese
      t.string :phone_city
      t.integer :che_ling
      t.integer :car_user_info_id
      t.integer :milage
      t.string  :price
      t.boolean :is_real_cheshang
      t.boolean :is_city_match
      t.boolean :is_pachong

      t.string :checheng_upload_status
      t.string :checheng_id
      t.string :checheng_yaoyue
      t.string :checheng_jiance
      t.string :checheng_chengjiao
      t.string :site_name
      t.date :created_day
      t.datetime :yaoyue_time
      t.date :yaoyue_day
      t.integer :checheng_status
      t.string :checheng_status_message
      t.timestamps

      t.index :checheng_status
      t.index :created_day
      t.index :yaoyue_day
      t.index :phone
      t.index :city_chinese
      t.index :phone_city
      t.index :car_user_info_id
      t.index :is_real_cheshang
      t.index :is_city_match
      t.index :is_pachong

      t.index :checheng_id
      t.index :checheng_yaoyue
      t.index :checheng_upload_status
    end
  end
end
