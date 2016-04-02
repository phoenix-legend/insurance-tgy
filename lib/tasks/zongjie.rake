namespace :zongjie do
	desc "每天更新班级状态  rake zongjie:all RAILS_ENV=production"
	task :all => :environment do
		jincheng = `ps -ef | grep zongjie:all`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'
		else
			UploadTianTian.get_now_status true
		end

	end


	desc "每天更新班级状态  rake zongjie:all1 RAILS_ENV=production"
	task :all1 => :environment do
		UploadTianTian.get_now_status
	end

	desc "每天更新班级状态  rake zongjie:chewang RAILS_ENV=production"
	task :chewang => :environment do
		# 现在是每天下午更新车王
		UserSystem::CarUserInfo.get_info_to_chewang
		# 跑完车王以后，把之前失败的再跑一遍，用于捡漏
		UploadTianTian.query_order_shibai
	end


end