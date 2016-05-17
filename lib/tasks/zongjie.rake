namespace :zongjie do
	desc "每天更新在天状态  rake zongjie:all RAILS_ENV=production"
	task :all => :environment do
		jincheng = `ps -ef | grep zongjie:all`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'
		else
			UploadTianTian.get_now_status true
		end
	end


	desc "回拢58遗漏数据,把手机端获取手机号失效的数据再回收，查询  rake zongjie:huilong RAILS_ENV=production"
	task :huilong => :environment do
		jincheng = `ps -ef | grep zongjie:huilong`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'
		else
			UserSystem::KouLingCarUserInfo.hui_long
		end
	end


	desc "把数据上传到优车，目前频率10分钟/次  rake zongjie:uploadyouche RAILS_ENV=production"
	task :uploadyouche => :environment do
		jincheng = `ps -ef | grep zongjie:uploadyouche`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'
		else
			UserSystem::YoucheCarUserInfo.upload_to_youche
			UserSystem::YoucheCarUserInfo.query_youche_status
		end
	end






	desc "每天晚新天天数据状态  rake zongjie:all1 RAILS_ENV=production"
	task :all1 => :environment do
		UploadTianTian.get_now_status
	end

	desc "每天下午3点跑车王的数据  rake zongjie:chewang RAILS_ENV=production"
	task :chewang => :environment do
		# 现在是每天下午更新车王
		UserSystem::CarUserInfo.get_info_to_chewang
		# 跑完车王以后，把之前失败的再跑一遍，用于捡漏
		UploadTianTian.query_order_shibai
	end


	desc "每天晚上8点刷新车置宝数据  rake zongjie:chezhibao RAILS_ENV=production"
	task :chezhibao => :environment do
		# 车置宝数据状态查询
		UserSystem::ChezhibaoCarUserInfo.query_data
	end


end