module UploadTianTian
  CITY = ["上海","成都","深圳","北京","南京", "广州", "武汉", "天津","苏州","杭州","东莞","重庆", "佛山"]
  def self.upload_tt
    car_user_infos = UserSystem::CarUserInfo.where "tt_upload_status = 'weishangchuan' and id > 230776 "
    car_user_infos.each do |car_user_info|
      next if car_user_info.phone.blank?
      is_next = false
      unless car_user_info.note.blank?
        ["诚信", '到店', '精品车', '本公司', '五菱', '提档', '双保险', '可按揭', '该车为', '铲车', '首付', '全顺', '该车', '按揭', '热线', '依维柯'].each do |word|
          if car_user_info.note.include? word
            is_next = true
          end
        end
      end

      unless UploadTianTian::CITY.include? car_user_info.city_chinese
        is_next = true
      end

      ["0000", "1111", "2222", "3333", "4444", "5555", "6666", "7777", "8888", "9999"].each do |p|
        if car_user_info.phone.include? p
          is_next = true
        end
      end

      ['经理', '总'].each do |name_key|
        is_next = true if car_user_info.name.include? name_key
      end

      # 车价小于1万的，跳过
      unless car_user_info.price.blank?
        car_user_info.price.gsub!('万', '')
        is_next = true if car_user_info.price.to_f <= 1.0
      end
      # 车年龄大于10年的，跳过
      unless car_user_info.che_ling.blank?
        che_ling = car_user_info.che_ling.to_i
        is_next = true if Time.now.year-che_ling>=10
      end

      next if is_next

             
      url = "http://www.ttpai.cn/signup/ttp"
      para = {
          :name => CGI::escape(car_user_info.name),
          :mobile => car_user_info.phone,
          :city => CGI::escape(car_user_info.city_chinese),
          :brand => CGI::escape(car_user_info.che_xing),
          :source => '5-89-659',
          :utmSource => 'txnews',
          :utmMedium => 'ttCPA',
          :utmCampaign => 1,
          :utmContent => '',
          :utmTerm => '',
          :joinHmcActivity => 0,
          :_ => "#{Time.now.to_i}#{rand(1000)}"
      }

      response = RestClient.get url, para
      pp response

      response_json = JSON.parse response.body
      car_user_info.tt_code = response_json["code"]
      car_user_info.tt_error = response_json["error"]
      car_user_info.tt_message = response_json["message"]
      car_user_info.tt_result = response_json["result"]

      if car_user_info.tt_code == '200' and car_user_info.tt_error == false
        car_user_info.tt_upload_status = 'success'
      end
      car_user_info.save!
    end
  end

end
