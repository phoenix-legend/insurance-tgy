namespace :zongjie do
	desc "每天更新在天状态  rake zongjie:all RAILS_ENV=production"
	task :all => :environment do
		jincheng = `ps -ef | grep zongjie:all`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'
		else
			UploadTianTian.get_now_status true
			UploadTianTian.query_order2
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


	# 把数据传到优车
	# 查询优车数据状态
	# 查询又一车数据状态
	desc "把数据上传到优车，目前频率10分钟/次  rake zongjie:uploadyouche RAILS_ENV=production"
	task :uploadyouche => :environment do
		jincheng = `ps -ef | grep zongjie:uploadyouche`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'
		else
			#把连云港数据给振腾  早上7点50的任务
			UserSystem::CarUserInfo.get_info_for_zhenteng_lianyungang
      #更新房产数据  早上7点20的任务
      ErShouFang.shanghai_run
			# 上传数据到U车
			UserSystem::YoucheCarUserInfo.upload_to_youche
			#更新又一车的数据
			UserSystem::YouyicheCarUserInfo.query_youyiche
			# 去侍埃更新数据， 程序内控制18点40分,20点40分再更新一次
			UserSystem::AishiCarUserInfo.query_aishi
			# 上传数据给郭正
			# UserSystem::CarUserInfo.upload_guozheng
			# 上传数据给胡磊
			# UserSystem::CarUserInfo.upload_to_hulei
			# 更新U车数据
			# UserSystem::YoucheCarUserInfo.query_youche_status
      #更新朋友E车, 凌晨1点和下午9点后半个小时, 更新两次
			UserSystem::PengyoucheCarUserInfo.query_result
		end
	end




	desc "开机启动，永远循环  rake zongjie:refresh_ip_proxy RAILS_ENV=production"
	task :refresh_ip_proxy => :environment do
		RestClientProxy.refresh_proxy_ip
  end

	desc "百姓网VPS跑起来  rake zongjie:vps_baixing RAILS_ENV=production"
	task :vps_baixing => :environment do
    continue = ENV['continue'] || 'true'
    party = (ENV['party'] || '0').to_i
    pp continue, party
		Baixing.get_car_user_list_for_vps party, continue
	end





	desc "每天晚新天天数据状态  rake zongjie:all1 RAILS_ENV=production"
	task :all1 => :environment do
		UploadTianTian.get_now_status
		# UploadTianTian.query_order2
	end

	desc "每天下午3点跑车王的数据  rake zongjie:chewang RAILS_ENV=production"
	task :chewang => :environment do
		# 天天拍车捡漏程序
		UploadTianTian.query_order_shibai

		# 一体化平台瓜子成交查询
		UserSystem::AishiCarUserInfo.query_chengjiao
	end


	desc "每天晚上8点刷新车置宝数据  rake zongjie:chezhibao RAILS_ENV=production"
	task :chezhibao => :environment do
		# 车置宝数据状态查询
		# UserSystem::ChezhibaoCarUserInfo.query_data
	end


end