class CreateCarBusinessUserInfo < ActiveRecord::Migration
  def change
    create_table :car_business_user_infos do |t|
        t.string :phone
        t.integer :car_user_info_number, :default => 0
    end
    add_index :car_business_user_infos, :phone
  end
end
