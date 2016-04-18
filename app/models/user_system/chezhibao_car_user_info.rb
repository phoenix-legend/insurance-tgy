class UserSystem::ChezhibaoCarUserInfo < ActiveRecord::Base
  CITY = ["上海","常州","郑州","无锡","长沙","苏州","南京","重庆","武汉","青岛","北京","西安","成都","杭州","深圳"]

  TestUrl = 'http://open.jzl.mychebao.com/apiService.hs'
  ProcuctionUrl = 'http://open.mychebao.com/apiService.hs'
  KEY = 'jhcsvtjh'
  CLIENT = 'k78242T1'

  def self.create_czb_car_info options
    czb = UserSystem::ChezhibaoCarUserInfo.new options
    czb.save!
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
    u = ProcuctionUrl
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
    require 'openssl'
    require 'base64'
    alg = 'DES-EDE3-CBC'
    k = "jhcsvtjh"


    dk = "jhcsvtjh"
    # dk = '11451e1f'#Digest::MD5.hexdigest(k)#"k78242T1"
    #
    des = OpenSSL::Cipher::Cipher.new(alg)
    iv = des.random_iv
    des.pkcs5_keyivgen(k,iv)

    des.encrypt


    cipher = des.update(str)
    cipher << des.final
    pp cipher.length
    pp cipher.unpack('H*')[0]
    return Base64.encode64(cipher) #Base64编码，才能保存到数据库

    # des =  OpenSSL::Cipher::Cipher.new('des-ede3')
    # des.decrypt
    # des.key = k # this step is where i'm having problems at
    # cipher = des.update(encrypted) + des.final
    # return Base64.encode64(cipher)

    # des = OpenSSL::Cipher::Cipher.new("DES-ECB")
    # des.encrypt
    # des.key = k
    # result = des.update(str)
    # result << des.final
    #
    # return Base64.encode64(result)
  end
end
__END__
测试环境：key = jhsdhsrr, source = 458
生成环境：key=jhcsvtjh,source = 458