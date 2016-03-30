class UserSystem::CarBusinessUserInfo < ActiveRecord::Base
  BusinessWords = ["诚信", '到店', '精品车', '车行', '第一车网', '车业', '信息编号', '本公司', '提档', '双保险', '可按揭', '该车为', '铲车', '首付', '全顺', '该车', '按揭', '热线']

  def self.init_business_user_info
    # 尝试获取车商电话
    cuis = UserSystem::CarUserInfo.all
    cuis.each do |cui|
      UserSystem::CarBusinessUserInfo.add_business_user_info_phone cui
    end
  end

  # 根据关键词判断是否为车商
  def self.add_business_user_info_phone car_user_info
    is_cheshang = false
    if is_cheshang == false
      UserSystem::CarBusinessUserInfo::BusinessWords.each do |word|
        if car_user_info.note.include? word
          is_cheshang = true
        end
      end
    end

    if is_cheshang == false
      ["0000", "1111", "2222", "3333", "4444", "5555", "6666", "7777", "8888", "9999"].each do |p|
        if car_user_info.phone.include? p
          is_cheshang = true
        end
      end
    end

    if is_cheshang == false
      ['经理', '总', '商家', '赶集', '瓜子', '二手车', '黄牛', '销售', '顾问'].each do |name_key|
        if car_user_info.name.include? name_key
          is_cheshang = true
        end
      end
    end

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

    if is_cheshang
      cbui = UserSystem::CarBusinessUserInfo.find_by_phone cbui.phone
      if cbui.blank?
        cbui = UserSystem::CarBusinessUserInfo.new :phone => cbui.phone
        cbui.save!
      end
    end
  end
end
