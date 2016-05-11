class UserSystem::KouLingCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info

  def self.create_kouling_car_user_info car_user_info_id
    klcui = UserSystem::KouLingCarUserInfo.new :car_user_info_id => car_user_info_id
    klcui.save!
  end

  #获取未提交口令
  def self.get_wei_tijiao_kouling deviceid = 'unknow'
    UserSystem::KouLingCarUserInfo.transaction do
      # return nil
      kouling_car_infos = UserSystem::KouLingCarUserInfo.order(id: :desc).limit(10)
      return nil if kouling_car_infos.blank?
      number = rand(kouling_car_infos.length)
      kouling = kouling_car_infos[number]
      cui = kouling.car_user_info
      if cui.blank?
        kouling.destroy
        return nil
      end

      # kouling.destroy
      cui.wuba_kouling_status = 'yitijiao'
      cui.wuba_kouling_tijiao_shouji_time = Time.now.chinese_format
      cui.wuba_kouling_deviceid = deviceid
      cui.save!
      return cui
    end


  end

end
__END__
***********备份的代码*******************

      unless car_user_info.note.blank?
        ["诚信", '到店', '精品车', '本公司', '五菱', '提档', '双保险', '可按揭', '该车为', '铲车', '首付', '全顺', '该车', '按揭', '热线', '依维柯'].each do |word|
          if car_user_info.note.include? word
            is_next = true
          end
        end
      end

      ["0000", "1111", "2222", "3333", "4444", "5555", "6666", "7777", "8888", "9999"].each do |p|
        if car_user_info.phone.include? p
          is_next = true
        end
      end

      ['经理', '总'].each do |name_key|
        is_next = true if car_user_info.name.include? name_key
      end



response = RestClient.get 'http://virtual.paipai.com/extinfo/GetMobileProductInfo?mobile=13472446647&amount=10000&callname=getPhoneNumInfoExtCallback'
ec = Encoding::Converter.new("gb18030", "UTF-8")
response = ec.convert response
matchs = response.match /cityname:'(.*)'/
cityname = matchs[1].to_s