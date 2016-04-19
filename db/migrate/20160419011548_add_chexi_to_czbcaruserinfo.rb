class AddChexiToCzbcaruserinfo < ActiveRecord::Migration
  def change
    add_column :car_user_infos, :cx , :string
    add_column :chezhibao_car_user_infos, :cx , :string
  end
end
