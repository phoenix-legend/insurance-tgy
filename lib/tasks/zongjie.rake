namespace :zongjie do
	desc "每天更新班级状态  rake zongjie:all RAILS_ENV=production"
	task :all => :environment do
		jincheng = `ps -ef | grep zongjie`
		match_data = jincheng.split /\n/
		if match_data.length > 3
			pp '前一次未执行完毕，退出任务'
		else
			UploadTianTian.get_now_status true
		end

	end


	desc "每天更新班级状态  rake zongjie:all1 RAILS_ENV=production"
	task :all1 => :environment do
		UploadTianTian.get_now_status
	end
end