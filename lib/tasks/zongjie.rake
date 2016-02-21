namespace :zongjie do
	desc "每天更新班级状态  rake zongjie:all RAILS_ENV=production"
	task :all => :environment do
			UploadTianTian.get_now_status true
	end


end