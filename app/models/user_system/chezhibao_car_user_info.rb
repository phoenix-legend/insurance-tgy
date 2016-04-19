class UserSystem::ChezhibaoCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info, :class_name => 'UserSystem::CarUserInfo'
  CITY = ["上海","常州","郑州","无锡","长沙","苏州","南京","重庆","武汉","青岛","北京","西安","成都","杭州","深圳","镇江"]

  CITY_HASH = {"北京" => 1867, "重庆" => 1898, "青岛" => 1931, "郑州" => 1970, "武汉" => '2002', '长沙' => 2024,
  "深圳" => 2053, "南京" => 2072, "无锡" => 2073, "苏州" => 2076, "镇江" => 2082, "成都" => 2102, "杭州" => 2123, "西安" => 2176}

  TestUrl = 'http://open.jzl.mychebao.com/apiService.hs'
  ProcuctionUrl = 'http://open.mychebao.com/apiService.hs'
  KEY = 'jhcsvtjh'
  CLIENT = 'k78242T1'

  # 创建车置宝车主信息
  def self.create_czb_car_info options
    czb = UserSystem::ChezhibaoCarUserInfo.new options
    czb.save!
  end

  # 获取所有城市
  def self.get_citys
    response = RestClient.post TestUrl, { service: 'unify.data.load.city',
                                          client: CLIENT}
    response = JSON.parse response
  end



  def self.test
    require 'digest/md5'
    phone = '13472446647'
    encrypt_phone = encrypt phone
    brand = '别克'
    before_md5 = "phone=#{encrypt_phone}&brand=#{brand}&model=#{brand}&city=2072&source=458&key=#{KEY}"
    pp "签名前 #{before_md5}"
    after_md5 = Digest::MD5.hexdigest(before_md5)
    pp "签名后 #{after_md5}"
    response = RestClient.post TestUrl, {
                                          service: 'unify.data.query.car',
                                          client: CLIENT,
                                          phone: encrypt_phone,
                                          brand: brand,
                                          model: brand,
                                          city: 2072,
                                          source: 458,
                                          datasign: after_md5
                                      }
    response = JSON.parse response
    pp response
  end

  def self.test2
    u = TestUrl
    pp u
    response = RestClient.post ProcuctionUrl, {
                                          service: 'unify.data.query.car',
                                          client: CLIENT,
                                          carid: UserSystem::ChezhibaoCarUserInfo.encrypt('2013'),
                                          source: '458'
                                      }
    response = JSON.parse response
    pp response
  end

  def self.encrypt str
    response = `java -classpath #{Rails.root.to_s}/lib/a/commons-codec-1.10.jar:#{Rails.root.to_s}/lib a.Des #{str} #{KEY}`
    response = response.split("\n")[1]
    response = response.split("：")[1]
    response
  end
end
__END__
测试环境：key = jhsdhsrr, source = 458
生成环境：key=jhcsvtjh,source = 458