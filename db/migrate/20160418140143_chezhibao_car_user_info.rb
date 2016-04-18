class ChezhibaoCarUserInfo < ActiveRecord::Migration
  def change
    create_table :chezhibao_car_user_infos do |t|
      t.string :name
      t.string :phone
      t.string :brand
      t.string :city_chinese
      t.integer :che_ling
      t.integer :car_user_info_id
      t.integer :milage
      t.string  :price
      t.boolean :is_real_cheshang
      t.boolean :is_city_match
      t.boolean :is_pachong
      t.boolean :is_repeat_one_month
      t.string :czb_upload_status
      t.string :czb_id
      t.string :czb_yaoyue
      t.string :czb_jiance
      t.string :czb_chengjiao
      t.timestamps
      t.index :phone
      t.index :city_chinese
      t.index :car_user_info_id
      t.index :is_real_cheshang
      t.index :is_city_match
      t.index :is_pachong
      t.index :is_repeat_one_month
      t.index :czb_id
      t.index :czb_yaoyue
      t.index :czb_upload_status
    end


  end
end
