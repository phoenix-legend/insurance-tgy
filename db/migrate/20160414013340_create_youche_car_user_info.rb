class CreateYoucheCarUserInfo < ActiveRecord::Migration
  def change
    create_table :youche_car_user_infos do |t|
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
      t.string :youche_upload_status
      t.string :youche_id
      t.string :youche_yaoyue
      t.string :youche_jiance
      t.string :youche_chengjiao
      t.timestamps
      t.index :phone
      t.index :city_chinese
      t.index :phone_city
      t.index :car_user_info_id
      t.index :is_real_cheshang
      t.index :is_city_match
      t.index :is_pachong
      t.index :is_repeat_one_month
      t.index :youche_id
      t.index :youche_yaoyue
      t.index :youche_upload_status
    end


  end
end
