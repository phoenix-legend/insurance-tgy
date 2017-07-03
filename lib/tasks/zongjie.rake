namespace :zongjie do
	desc "每天更新在天状态  rake zongjie:all RAILS_ENV=production"
  # 这个任务放长时间执行的任务: 查询天天拍1.0版本结果,  天天拍 2.0结果, 一体化结果, 朋友E车结果, 瓜子查询结果, 执行时间:24小时不间断执行。每逢整点20分执行
	task :all => :environment do
		jincheng = `ps -ef | grep zongjie:all`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'
		else
			UploadTianTian.get_now_status true
			UploadTianTian.query_order2
			# 去侍埃更新数据， 每天凌晨一点更新一次。
			UserSystem::AishiCarUserInfo.query_aishi
			# 更新朋友E车, 凌晨1点和下午9点后半个小时, 更新两次
			UserSystem::PengyoucheCarUserInfo.query_result
      #瓜子查询
      UserSystem::GuaziCarUserInfo.query_guazi
      # 瓜子成交查询
			UserSystem::GuaziCarUserInfo.query_guazi_chengjiao
		end
	end


	desc "回拢58遗漏数据,把手机端获取手机号失效的数据再回收，查询  rake zongjie:huilong RAILS_ENV=production"
  # 两分钟执行一次, 不再处理回笼,  处理数据异常监控。
	task :huilong => :environment do
		jincheng = `ps -ef | grep zongjie:huilong`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'
		else
			# UserSystem::KouLingCarUserInfo.hui_long

      #暂时不处理回笼, 这里利用每分钟执行的特点,来监控数据异常情况
			UserSystem::CarUserInfo.watch_qudao_exception
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
      #更新房产数据  早上7点整的任务
      ErShouFang.shanghai_run
			ErShouFang.beijing_run


      #每小时定时导出车置宝数据
      #目前车置宝可以自动上传到网页, 所以停掉。
			# UserSystem::YouyicheCarUserInfo.export_last_city_phones

			#更新又一车的数据, 又一车不再更新
			# UserSystem::YouyicheCarUserInfo.query_youyiche

      #瓜子网: 导出excel供测试用, 同时将24小时前的数据上传一体化。
      #以下方法不再导出瓜子的表格, 只延迟给胡磊。
			# UserSystem::AishiCarUserInfo.export_to_guazi_and_to_hulei

			# 去侍埃更新数据， 每天凌晨一点更新一次。
      # 移至zongjie::all 定时任务, 逢整点20分执行
      # UserSystem::AishiCarUserInfo.query_aishi
			# 上传数据给郭正
			# UserSystem::CarUserInfo.upload_guozheng
			# 上传数据给胡磊
			# UserSystem::CarUserInfo.upload_to_hulei
			# 更新U车数据
			# UserSystem::YoucheCarUserInfo.query_youche_status
      # 更新朋友E车, 凌晨1点和下午9点后半个小时, 更新两次
      # 移至zongjie::all定时任务, 逢整点20分运行一次
      # UserSystem::PengyoucheCarUserInfo.query_result
			# 上传数据到U车, 降低优车诚品上传优先级
			UserSystem::YoucheCarUserInfo.upload_to_youche
		end
	end




	desc "开机启动，永远循环  rake zongjie:refresh_ip_proxy RAILS_ENV=production"
	task :refresh_ip_proxy => :environment do
    sleep 60
		# RestClientProxy.refresh_proxy_ip
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
  # 天天拍车捡漏程序  成交查询   超级稀有的查询,  已经与车王无关, 每月28号凌晨1点查询
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