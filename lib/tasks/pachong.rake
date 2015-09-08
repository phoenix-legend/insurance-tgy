namespace :pachongchong do
	desc "每天更新班级状态  rake pachongchong:che168 RAILS_ENV=production"
	task :che168 => :environment do
		UserSystem::CarUserInfo.update_che168_detail2
	end
end