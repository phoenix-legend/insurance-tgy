class CreateKouLingCarUserInfo < ActiveRecord::Migration
  def change
    create_table :kou_ling_car_user_infos do |t|
      t.integer :car_user_info_id
    end
  end
end
