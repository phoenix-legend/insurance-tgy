class UserSystem::YoucheCarUserInfo < ActiveRecord::Base

  validates_format_of :phone, :with => EricTools::RegularConstants::MobilePhone, message: '手机号格式不正确', allow_blank: true, :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :name, message: '请填写姓名', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :brand, message: '请填写品牌', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :city_chinese, message: '请填写城市', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }



end
__END__
