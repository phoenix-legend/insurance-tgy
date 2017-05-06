class AddRefreshTimeToErshoufang < ActiveRecord::Migration
  def change
    add_column :er_shou_fangs, :refresh_day, :date
    add_index :er_shou_fangs, :refresh_day
  end
end
