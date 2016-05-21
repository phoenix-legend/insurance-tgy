namespace :pachong3chongbaixing do
	desc "每天更新班级状态  rake pachong3chongbaixing:all RAILS_ENV=production"
	task :all => :environment do
		jincheng = `ps -ef | grep pachong3chongbaixing`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'

		else
			pp '前一次已完成， GO RUN'
			UserSystem::CarUserInfo.run_baixing 2
		end
	end


end