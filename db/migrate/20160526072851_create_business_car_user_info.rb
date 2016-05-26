class CreateBusinessCarUserInfo < ActiveRecord::Migration
  def change
    create_table :business_car_user_infos do |t|
      t.string :name
      t.string :phone
      t.string :detail_url
      t.string :che_xing
      t.string :che_ling
      t.string :city_chinese
      t.string :note
      t.string :site_name
      t.string :fabushijian
      t.string :price
      t.string :brand
      t.string :cx
      t.timestamps
    end
  end
end
