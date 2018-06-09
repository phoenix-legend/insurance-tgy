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
  # 2017-04-02 已彻底废弃手机客户端模拟器
  def self.need_restart machine_name
    return false
    device_access_count = UserSystem::DeviceAccessLog.where(machine_name: machine_name).
        where("last_access_time  > ?", (Time.now-10.minutes).chinese_format).count
    return true if device_access_count < 1
  end


  # UserSystem::DeviceAccessLog.set_machine_ip
  def self.set_machine_ip
    if Time.now > Time.parse("2018-06-10 06:00:00")
      return
    end

    out_ip = `curl http://members.3322.org/dyndns/getip`
    out_ip.gsub!("\n", "")
    return if out_ip.blank?
    sleep(rand(8))
    require 'socket'
    host_name = Socket.gethostname

    host = UserSystem::DeviceAccessLog.where("device_id = ?", host_name).first
    if host.blank?
      log = UserSystem::DeviceAccessLog.new device_id: host_name,
                                            machine_name: out_ip,
                                            last_access_time: Time.now
      log.save!
    else
      host.machine_name = out_ip
      host.last_access_time = Time.now
      host.save
    end
  end


  # UserSystem::DeviceAccessLog.reboot
  # update device_access_logs set machine_name = ''.
  def self.reboot
    pp `ssh root@47.92.101.43 '/root/gitpull.sh'`
    pp `echo 'aliyun pull over'`
    pp `ssh root@123.59.130.146 '/root/gitpull.sh'`
    pp `echo 'ucloud pull over'`
    UserSystem::DeviceAccessLog.all.each do |log|
      ip = log.machine_name
      if ip.match /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        `ssh root@#{ip} 'reboot'`
        pp ip
      end
    end

    # UserSystem::DeviceAccessLog.all.each do |log|
    #   ip = log.machine_name
    #   if ip.match /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
    #     pp `ssh root@#{ip} 'ls /data/'`
    #     pp ip
    #   end
    # end
  end

end
