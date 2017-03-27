class Createjinzhengu < ActiveRecord::Migration

    def change

      create_table :jinzhengu_car_user_infos do |t|
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
        t.boolean :is_repeat_one_month
        t.string :jinzhengu_upload_status
        t.string :jinzhengu_id
        t.string :jinzhengu_yaoyue
        t.string :jinzhengu_jiance
        t.string :jinzhengu_chengjiao
        t.string :site_name
        t.date :created_day
        t.datetime :yaoyue_time
        t.date :yaoyue_day
        t.integer :jinzhengu_status
        t.string :jinzhengu_status_message
        t.timestamps

        t.index :jinzhengu_status
        t.index :created_day
        t.index :yaoyue_day
        t.index :phone
        t.index :city_chinese
        t.index :phone_city
        t.index :car_user_info_id
        t.index :is_real_cheshang
        t.index :is_city_match
        t.index :is_pachong
        t.index :is_repeat_one_month
        t.index :jinzhengu_id
        t.index :jinzhengu_yaoyue
        t.index :jinzhengu_upload_status
      end
    end




end
