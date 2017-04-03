# 主要记录临时的，需要从APP获取的口令
class UserSystem::KouLingCarUserInfo < ActiveRecord::Base
  belongs_to :car_user_info

  #58客户端模拟器不再使用, 新的口令不再记录。
  #作废于 2017-04-02
  def self.create_kouling_car_user_info car_user_info_id
    return
    klcui = UserSystem::KouLingCarUserInfo.new :car_user_info_id => car_user_info_id
    klcui.save!
    if UserSystem::CarUserInfo::IMPRTANT_CITY.include? klcui.car_user_info.city_chinese
      klcui.vip_flg = 'vip'
      klcui.save!
    end
  end

  #获取未提交口令
  # 2017-04-02 已彻底废弃手机模拟器方式获取手机号码,故第一行直接提交
  def self.get_wei_tijiao_kouling deviceid = 'unknow'
    return
    UserSystem::DeviceAccessLog.update_device_access deviceid
    machine_name = deviceid[-3..-1]
    UserSystem::KouLingCarUserInfo.transaction do
      # return nil
      kouling_car_infos = UserSystem::KouLingCarUserInfo.where("vip_flg = ?", 'vip').order(id: :desc).limit(10)
      if not ['094'].include? machine_name #094 机器为重点城市预留
        kouling_car_infos = UserSystem::KouLingCarUserInfo.order(id: :desc).limit(10) if kouling_car_infos.blank?
      end
      return nil if kouling_car_infos.blank?
      number = rand(kouling_car_infos.length)
      kouling = kouling_car_infos[number]
      cui = kouling.car_user_info
      if cui.blank?
        kouling.destroy
        return nil
      end

      kouling.destroy
      cui.wuba_kouling_status = 'yitijiao'
      cui.wuba_kouling_tijiao_shouji_time = Time.now.chinese_format
      cui.wuba_kouling_deviceid = deviceid
      cui.email_status += 1
      cui.save!


      return cui
    end
  end


  # 异常数据回笼处理  有时手机端会出现get掉的数据不给post回来，这种情况下，就得重新放回来，分发给手机
  #58客户端不能使用,此函数暂停。 2017-04-02
  def self.hui_long
    return
    pp Time.now.chinese_format
    x = UserSystem::KouLingCarUserInfo.limit 1
    return unless x.blank?
    cuis = UserSystem::CarUserInfo.where("wuba_kouling_status = 'yitijiao' and wuba_kouling_shouji_huilai_time is null and wuba_kouling_tijiao_shouji_time < ? and created_at > ? and email_status < 15", (Time.now-40.seconds), (Time.now - 12.hours))
    cuis.each do |cui|
      UserSystem::KouLingCarUserInfo.create_kouling_car_user_info cui.id
    end
  end

  def self.XXX
    UserSystem::KouLingCarUserInfo.where("vip_flg = 'normal'").each do |k|
      cui = k.car_user_info
      if cui.blank?

        k.destroy!
        next
      end
      cui.wuba_kouling_status = 'butiqu'
      cui.save!
      k.destroy!
    end
  end


  #todo 给客服提取口令
  # 逻辑如下:
  #  1. 口令状态(wuba_kouling_status)默认为:未提交(weitijiao)
  #  2. 严格过滤商家,口令状态修改为:商家,不提交(shangjia-butijiao)
  #  3. 筛选出来的电话返回给客服:口令状态修改为: kf-yitijiao (口令==weitijiao & 网站==58)
  #  3.1 只呼叫24小时内提取的电话,指定城市不存在, 则查询所有热门城市
  #  4. 记录openid, 昵称, 提取时间
  #  5. 客服可以指定城市,不指定城市则从所有有城市中取,按时间顺序优先取最近的数据。
  #  6. 优先城市包含: 上海,杭州,深圳,广州,苏州, 成都,重庆,南京
  #  7. 收集微信信息,制作openid白名单,防止恶意骚扰
  #  8. 客服需人工识别车商

  # UserSystem::KouLingCarUserInfo.get_kouling_for_kefu '12333', 'xiaoqi', '上海'
  def self.get_kouling_for_kefu openid, nickname, city=''
    white_names = []
    kf_city = ["上海", "杭州", "深圳", "广州", "苏州", "成都", "重庆", "南京"]
    city = if city.blank?
             kf_city
           else
             [city]
           end
    cuis = UserSystem::CarUserInfo.where("site_name = '58' and phone is null and need_update = 0 and wuba_kouling_status = 'weitijiao' and created_at > ? and city_chinese in (?) and is_cheshang = 0 and is_real_cheshang = 0 and is_pachong = 0", Time.now - 24.hours, city).order(created_at: :desc).limit(60)

    if cuis.length == 0 and city.length == 1
      city = kf_city
      cuis = UserSystem::CarUserInfo.where("site_name = '58' and phone is null and need_update = 0 and wuba_kouling_status = 'weitijiao' and created_at > ? and city_chinese in (?) and is_cheshang = 0 and is_real_cheshang = 0 and is_pachong = 0", Time.now - 24.hours, city).order(created_at: :desc).limit(60)
    end

    cuis.each do |cui|
      UserSystem::CarUserInfo.che_shang_jiao_yan cui, true
      cui = cui.reload
      next if cui.is_cheshang == 1
      next if cui.is_real_cheshang == true
      next if cui.is_pachong == true
      cui.wuba_kouling_status = 'kf-yitijiao'
      cui.wuba_kouling_deviceid = openid
      cui.tt_message = nickname
      cui.save!

      kcuis = UserSystem::CarUserInfo.where("site_name = '58' and phone is null and need_update = 0 and wuba_kouling_status = 'weitijiao' and created_at > ? and wuba_kouling = ?", Time.now - 24.hours, cui.wuba_kouling)
      kcuis.each do |kcui|
        kcui.cui.wuba_kouling_status = '重复-不提交'
        kcui.save!
      end

      return cui
    end

    return nil
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