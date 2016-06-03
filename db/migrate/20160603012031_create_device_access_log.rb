class CreateDeviceAccessLog < ActiveRecord::Migration
  def change
    create_table :device_access_logs do |t|
      t.string :device_id
      t.string :machine_name
      t.datetime :last_access_time
    end
  end
end
