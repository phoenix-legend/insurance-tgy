class UserSystem::CarType < ActiveRecord::Base

  belongs_to :car_brand, :class_name => 'UserSystem::CarBrand'

  # UserSystem::CarType.qichefenpei
  def self.qichefenpei
    #采购量
    caigouliang = {
        "车好多" => {"白" => 15, "红" => 10},
        "瓜子" => {"白" => 15, "红" => 10}
    }

    #需求量
    xuqiuliang = '
    白,东莞
    白,东莞
    白,南宁
    白,武汉
    白,长沙
    白,东莞
    白,东莞
    红,东莞
    白,东莞
    红,东莞
    白,东莞
    白,武汉
    白,东莞
    白,东莞
    红,南宁
    红,东莞
    红,南京
    红,南京
    红,东莞
    白,南京
    白,东莞
    白,东莞
    白,东莞
    白,合肥
    白,东莞
    红,济南
    红,长沙
    红,东莞
    红,长沙
    红,重庆
    白,南通
    红,东莞
    红,潍坊
    白,昆明
    白,武汉
    白,石家庄
    红,石家庄
    红,长沙
    白,南京
    红,重庆
    白,成都
    红,苏州
    红,南京
    红,东莞
    白,南京
    红,东莞
    红,沈阳
    白,南京
    红,南京
    白,东莞
    红,西安
    白,南京
    红,南京
    红,南京
    红,苏州
    红,东莞
    红,东莞
    红,东莞
    白,东莞    
'


    cityies = {
        "成都" => "车好多",
        "东莞" => "车好多",

        "西安" => "车好多",
        "南宁" => "车好多",
        "长春" => "车好多",
        "重庆" => "车好多",
        "石家庄" => "车好多",
        "南京" => "车好多",

        "南昌" => "瓜子",
        "福州" => "瓜子",
        "厦门" => "瓜子",
        "苏州" => "瓜子",
        "南通" => "瓜子",
        "昆明" => "瓜子",
        "合肥" => "瓜子",
        "青岛" => "瓜子",
        "沈阳" => "瓜子",
        "哈尔滨" => "瓜子",
        "潍坊" => "瓜子",
        "大连" => "瓜子",
        "济南" => "瓜子",
        "太原" => "瓜子",
        "常州" => "瓜子",
        "宁波" => "瓜子",
        "长沙" => "瓜子",

        "武汉" => "天津武清",
        "郑州" => "天津武清"
    }


    #开始处理需求,使其规整
    xuqiu_cars = []
    xuqiuliang.split("\n").each do |xuqiu|
      xuqiu.strip!
      next if xuqiu.blank?
      color = xuqiu.split(',')[0]
      city = xuqiu.split(',')[1]
      xuqiu_cars << [color, city]
    end

    #已处理掉的需求,即:有车可以对应
    yichulixuqiu = []

    #未处理掉的需求,即:没有车可以对应
    weichulixuqiu = []

    xuqiu_cars.each do |xuqiu_car|
      city = xuqiu_car[1]
      color = xuqiu_car[0]

      #根据城市获取公司名称
      gongsiming = cityies[city]
      # 如果当前公司未采购, 则需求处理不了
      if not caigouliang.keys.include? gongsiming
        weichulixuqiu << xuqiu_car
        next
      end

      if caigouliang[gongsiming][color].to_i==0
        weichulixuqiu << xuqiu_car
        next
      end

      if caigouliang[gongsiming][color].to_i > 0
        caigouliang[gongsiming][color] -= 1
        yichulixuqiu << xuqiu_car
      end
    end

    # pp "采购车辆剩余情况如下:"
    # pp caigouliang

    # pp "需求满足情况如下:"
    # pp yichulixuqiu

    # pp "需求未满足情况如下:"
    # pp weichulixuqiu

    #需采购
    xucaigou = {"车好多" => 0, "瓜子" => 0, "天津武清" => 0}
    weichulixuqiu.each do |xuqiu|
      #pp xuqiu
      xucaigou[cityies[xuqiu[1]]] += 1
    end


    pp "本批采购剩余车辆"
    caigouliang.each_pair do |k, v|
      v.each_pair do |kk, vv|
        next if vv == 0
        pp "#{k} #{kk} #{vv}"
      end
    end

    pp "采购建议:"
    xucaigou.each_pair do |k, v|
      pp "#{k} 还需采购 #{v}"
    end
    huizong_yichuli = {}
    yichulixuqiu.each do |xq|

        key = "#{xq[1]} #{xq[0]}"
        huizong_yichuli[key] = 0 if huizong_yichuli[key].blank?
        huizong_yichuli[key] += 1

    end

    pp "已处理的需求"
    chulixuqiu_zongliang = 0
    huizong_yichuli.each_pair do |k,v|
      pp "#{k}, #{v}"
      chulixuqiu_zongliang += v.to_i
    end
    pp "总计匹配到#{chulixuqiu_zongliang}台车"

    return


  end
end
__END__
