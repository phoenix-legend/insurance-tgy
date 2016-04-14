namespace :pachongfanwuyewuba do
	desc "rake pachongfanwuyewuba:all RAILS_ENV=production"
	task :all => :environment do
		jincheng = `ps -ef | grep pachongfanwuyewuba`
		match_data = jincheng.split /\n/
		if match_data.length > 4
			pp '前一次未执行完毕，退出任务'

		else
			pp '前一次已完成， GO RUN'
			begin
				Wuba.get_car_user_list 0
			rescue Exception => e
				pp e
			end
		end
	end


end