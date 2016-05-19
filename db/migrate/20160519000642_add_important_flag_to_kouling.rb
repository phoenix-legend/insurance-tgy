class AddImportantFlagToKouling < ActiveRecord::Migration
  def change
    add_column :kou_ling_car_user_infos, :vip_flg, :string, :default => 'normal'
  end
end
