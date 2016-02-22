namespace :zongjie do
	desc "每天更新班级状态  rake zongjie:all RAILS_ENV=production"
	task :all => :environment do
			UploadTianTian.get_now_status true
	end


	desc "每天更新班级状态  rake zongjie:all1 RAILS_ENV=production"
	task :all1 => :environment do
		UploadTianTian.get_now_status
	end
end