class UserSystem::CarBusinessUserInfo < ActiveRecord::Base
  BusinessWords = ["诚信", '到店', '精品车', '车行', '第一车网', '车业', '信息编号', '本公司', '提档', '双保险', '可按揭', '该车为', '铲车', '首付', '全顺', '该车', '按揭', '热线', '瓜子']

  def self.init_business_user_info
    # 尝试获取车商电话
    cuis = UserSystem::CarUserInfo.all
    cuis.each do |cui|
      UserSystem::CarBusinessUserInfo.add_business_user_info_phone cui
    end
  end

  # 根据关键词判断是否为车商
  def self.add_business_user_info_phone car_user_info
    #
    is_cheshang = false

    if not car_user_info.note.blank?
      if is_cheshang == false
        UserSystem::CarBusinessUserInfo::BusinessWords.each do |word|
          if car_user_info.note.include? word
            is_cheshang = true
          end
        end
      end
    end


    if not car_user_info.name.blank?
      if is_cheshang == false
        ['经理', '总', '商家', '赶集', '瓜子','名车', '二手车', '黄牛', '销售', '顾问', '阳光车网', '客服', '车王', '看图', '看内容', '最多填写6字', '优车', '车置宝', '天天', '标题', '大爷'].each do |name_key|
          if car_user_info.name.include? name_key
            is_cheshang = true
          end
        end
      end
    end

    if not car_user_info.phone.blank?
      if is_cheshang == false
        if car_user_info.phone.match /^400/
          is_cheshang = true
        end
      end

      if is_cheshang == false
        if not car_user_info.phone.match /^[0-9]{11}$/
          is_cheshang = true
        end
      end

      # if is_cheshang == false
      #   ['1111','2222','3333','4444','5555','6666','7777','8888','9999','0000'].each do |cfxz|
      #     if  car_user_info.phone.include? cfxz
      #       is_cheshang = true
      #       break
      #     end
      #   end
      # end
    end




    if is_cheshang
      cbui = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
      if cbui.blank?
        cbui = UserSystem::CarBusinessUserInfo.new :phone => car_user_info.phone
        cbui.save!
      end
    end
  end


  def self.is_pachong car_user_info

    if not car_user_info.note.blank?
      ['第一车网', '信息编号', '瓜子'].each do |word|
        if car_user_info.note.include? word
          return true
        end
      end
    end

    if not car_user_info.phone.blank?
      ["400733009"].each do |p|
        if car_user_info.phone.include? p
          return true
        end
      end

      if car_user_info.phone.match /^400/
        return true
      end
    end

    if not car_user_info.che_xing.blank?
      ["第一车网"].each do |p|
        if car_user_info.che_xing.include? p
          return true
        end
      end
    end

    if not car_user_info.name.blank?
      if /^[a-z|A-Z|0-9|-|_]+$/.match car_user_info.name
        return true
      end

      if /[0-9]+/.match car_user_info.name
        return true
      end

      ['商家', '赶集', '瓜子', '销售', '百姓','车行','名车', '顾问', '阳光车网', 'QQ','qq','微信','Qq','图片','客服', '管家', '车王', '看图', '58', '五八', '之家', '内容', '最多填写6字', '优车', '车置宝', '天天', '标题', '大爷'].each do |name_key|
        if car_user_info.name.include? name_key
          return true
        end
      end
    end

    return false
  end
end
