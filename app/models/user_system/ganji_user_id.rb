class UserSystem::GanjiUserId < ActiveRecord::Base

  #从赶集网获取到userid以后, 放到数据库中。  使用当前机器生成的id, 就只在当前机器使用
  # UserSystem::GanjiUserId.get_userid
  def self.get_userid
    localip = RestClientProxy.get_local_ip
    guids = UserSystem::GanjiUserId.where("host_name = ? and status = 'yes'", localip).select(:userid).collect(&:userid)
    return guids
  end
end
