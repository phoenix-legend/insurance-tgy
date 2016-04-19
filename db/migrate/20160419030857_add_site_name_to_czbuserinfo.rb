class AddSiteNameToCzbuserinfo < ActiveRecord::Migration
  def change
    add_column :chezhibao_car_user_infos, :site_name , :string
  end
end
