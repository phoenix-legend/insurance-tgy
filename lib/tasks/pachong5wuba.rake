namespace :pachong5chongwuba do
	desc "每天更新班级状态  rake pachong5chongwuba:all RAILS_ENV=production"
	task :all => :environment do
		jincheng = `ps -ef | grep pachong5chongwuba`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '......'
			pp '前一次未执行完毕，退出任务'

		else
			pp '前一次已完成， GO RUN'
			UserSystem::CarUserInfo.run_58 2
		end
	end
end