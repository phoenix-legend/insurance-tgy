class UserSystem::DeviceAccessLog < ActiveRecord::Base
  #记录终端最后一次请求
  def self.update_device_access devce_id
    return if devce_id.blank?
    return if devce_id.length < 5
    machine_name = devce_id[-3..-1]
    machine_name = 'unknow' if machine_name.blank?
    log = UserSystem::DeviceAccessLog.where(device_id: devce_id, machine_name: machine_name).first
    if log.blank?
      log = UserSystem::DeviceAccessLog.new device_id: devce_id,
                                            machine_name: machine_name,
                                            last_access_time: Time.now.chinese_format
      log.save!
    end

    if Time.now - log.last_access_time > 10
      log.last_access_time = Time.now.chinese_format
      log.save!
    end
  end


  # 目前有2台，分别是077， 094
  def self.need_restart machine_name
    device_access_count = UserSystem::DeviceAccessLog.where(machine_name: machine_name).
        where("last_access_time  > ?", (Time.now-3.minutes).chinese_format).count
    return true if device_access_count < 1
  end

end
