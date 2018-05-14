class GanjiUserId < ActiveRecord::Migration
  def change
    create_table :ganji_user_ids do |t|
      t.string :userid
      t.string :status, :default => 'yes'
      t.string :host_name
      t.timestamps
    end
  end
end
