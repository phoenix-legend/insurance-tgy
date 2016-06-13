class CreateAishiCarUserInfo < ActiveRecord::Migration
  def change
    create_table :aishi_car_user_infos do |t|
      t.string :name
      t.string :phone
      t.string :brand
      t.string :city_chinese
      t.integer :che_ling
      t.integer :car_user_info_id
      t.integer :milage
      t.string  :price
      t.string :site_name
      t.string :business_name
      t.datetime :aishi_yaoyue_time
      t.date :aishi_yaoyue_day
      t.boolean :is_real_cheshang
      t.boolean :is_city_match
      t.boolean :is_pachong
      t.boolean :is_repeat_one_month
      t.date :created_day
      t.string :aishi_upload_status
      t.string :aishi_upload_message
      t.integer :aishi_id
      t.text :aishi_yaoyue
      t.timestamps
      t.index :phone
      t.index :city_chinese
      t.index :car_user_info_id
      t.index :is_real_cheshang
      t.index :is_city_match
      t.index :is_pachong
      t.index :is_repeat_one_month
      t.index :aishi_id
      t.index :aishi_upload_status
      t.index :created_day

    end
  end
end
