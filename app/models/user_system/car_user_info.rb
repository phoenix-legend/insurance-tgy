class UserSystem::CarUserInfo < ActiveRecord::Base
  require 'rest-client'
  require 'pp'

  validates_format_of :phone, :with => EricTools::RegularConstants::MobilePhone, message: '手机号格式不正确', allow_blank: true, :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :name, message: '请填写姓名', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :brand, message: '请填写品牌', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :city_chinese, message: '请填写城市', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }


  # CURRENT_ID = 171550  第一次导入
  CURRENT_ID = 539767

  EMAIL_STATUS = {0 => '待导', 1 => '已导', 2 => '不导入'}
  ALL_CITY = {"310100" => "上海", "510100" => "成都", "440300" => "深圳", "320100" => "南京", "440100" => "广州", "420100" => "武汉",
              "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡",
              "410100" => "郑州", "430100" => "长沙", "610100" => "西安", "370200" => "青岛", "440600" => "佛山", "371000" => '威海',
              "370600" => '烟台', "370700" => '潍坊', "320400" => '常州', "320300" => '徐州', "320600" => '南通', "321000" => '扬州', "370100" => "济南",
              "130100" => "石家庄", "130200" => "唐山", "140100" => "太原", "610400" => "咸阳", "610300" => "宝鸡",
              "410300" => "洛阳", "411300" => "南阳", "410700" => "新乡","110100" => "北京",
              "430300" => "湘潭", "430200" => "株洲", "430700" => "常德", "430600" => "岳阳",
              "210100" => "沈阳", "210200" => "大连", "210800" => "营口",
              "350100" => "福州", "350200" => "厦门", "350500" => "泉州",
              "220100" => "长春", "230100" => "哈尔滨", "230600" => "大庆", "340100" => "合肥", "340200" => "芜湖", "450100" => "南宁", "360100" => "南昌",
              "441300" => "惠州", "441200" => "肇庆", "442000" => "中山", "330400" => "嘉兴", "520100" => "贵阳", "520300" => "遵义", "150100" => "呼和浩特",
              "650100" => "乌鲁木齐", "510600" => "德阳", "510700" => "绵阳", "420600" => "襄阳", "420500" => "宜昌",
              "140200"=>"大同", "140700"=>"晋中", "141000"=>"临汾", "140800"=>"运城",
              "620100"=>"兰州",


  }


  def self.get_che168_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "310100" => "上海", "510100" => "成都", "440300" => "深圳", "320100" => "南京", "440100" => "广州", "420100" => "武汉", "440600" => "佛山",
            "140100" => "太原","620100"=>"兰州"
        }
      when 1
        {
            "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡","110100" => "北京",
            "410100" => "郑州","430100" => "长沙","150100"=>"呼和浩特"
        }
      else
        {
              "610100" => "西安",
            "370200" => "青岛", "371000" => '威海', "370600" => '烟台', "370700" => '潍坊',
            "320400" => '常州', "320300" => '徐州', "320600" => '南通', "321000" => '扬州', "370100" => "济南",

            "130100" => "石家庄", "130200" => "唐山", "610300" => "宝鸡",
            "410300" => "洛阳", "411300" => "南阳", "410700" => "新乡",

            #  "610400" => "咸阳",,
            "430300" => "湘潭", "430200" => "株洲", "430700" => "常德", "430600" => "岳阳",
            "210100" => "沈阳", "210200" => "大连", "210800" => "营口",
            "350100" => "福州", "350200" => "厦门",
            "350500" => "泉州","220100" => "长春", "230100" => "哈尔滨", "230600" => "大庆", "340100" => "合肥", "340200" => "芜湖", "450100" => "南宁", "360100" => "南昌",
            "140200"=>"大同", "140700"=>"晋中", "141000"=>"临汾", "140800"=>"运城",
            "441300" => "惠州", "441200" => "肇庆", "442000" => "中山", "330400" => "嘉兴", "520100" => "贵阳",
            "520300" => "遵义",
        #, "650100" => "乌鲁木齐",
            # "510600" => "德阳",
            "510700" => "绵阳", "420600" => "襄阳", "420500" => "宜昌"
        }
    end
  end


  #城市所对应的拼音。 主要用于从淘车网更新数据。
  # 淘车
  # PINYIN_CITY_RENREN_ALL = {
  PINYIN_CITY = {
      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州",
      "dongguan" => "东莞", "chongqing" => "重庆","lanzhou"=>"兰州",
      "zhengzhou" => '郑州', 'changsha' => '长沙', 'xian' => '西安',
      "qingdao" => "青岛", "weihai" => '威海', "yantai" => '烟台', "weifang" => '潍坊', "wuxi" => "无锡",
      "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jinan" => "济南",

      "shijiazhuang" => "石家庄", "tangshan" => "唐山", "taiyuan" => "太原", "baoji" => "宝鸡","foshan" => '佛山',"beijing" => "北京",
      "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",



      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
      "shenyang" => "沈阳", "dalian" => "大连", "yingkou" => "营口",


      "quanzhou" => "泉州","changchun" => "长春", "haerbin" => "哈尔滨", "daqing" => "大庆", "hefei" => "合肥", "wuhu" => "芜湖", "nanning" => "南宁", "nanchang" => "南昌",
      #  'zhenjiang' => '镇江',# "xianyang" => "咸阳",,
      "fuzhou" => "福州", "xiamen" => "厦门",
      "datong"=>"大同", "jinzhong"=>"晋中", "linfen"=>"临汾", "yuncheng"=>"运城",



      "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴", "guiyang" => "贵阳",
      "zunyi" => "遵义", #
      "huhehaote" => "呼和浩特",# "wulumuqi" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xiangfan" => "襄阳", "yichang" => "宜昌"
  }

  IMPRTANT_CITY = ["上海", "成都", "深圳", "南京", "广州", "武汉", "天津", "苏州", "杭州", "佛山", "东莞", "重庆", "无锡","北京","太原","郑州"]




  #百姓人人车+天天拍
  # BAIXING_PINYIN_CITY_RENREN_ALL = {
  BAIXING_PINYIN_CITY = {
      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州",
      "dongguan" => "东莞", "chongqing" => "重庆", "wuxi" => "无锡", "foshan" => '佛山', #,
      "zhengzhou" => '郑州', 'changsha' => '长沙', 'xian' => '西安', "qingdao" => "青岛", 'zhenjiang' => '镇江', "weihai" => '威海', "yantai" => '烟台', "weifang" => '潍坊',
      "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jinan" => "济南", "shijiazhuang" => "石家庄", "tangshan" => "唐山", "taiyuan" => "太原",
      "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",
      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
      "shenyang" => "沈阳", "dalian" => "大连", "yingkou" => "营口",
      "fuzhou" => "福州", "xiamen" => "厦门", "quanzhou" => "泉州",
      "changchun" => "长春", "haerbin" => "哈尔滨", "daqing" => "大庆", "hefei" => "合肥", "wuhu" => "芜湖", "nanning" => "南宁", "nanchang" => "南昌",
      "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴",
      "guiyang" => "贵阳", "zunyi" => "遵义", "huhehaote" => "呼和浩特", "wulumuqi" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xiangfan" => "襄阳", "yichang" => "宜昌", "beijing"=>"北京",
      "datong"=>"大同", "jinzhong"=>"晋中", "linfen"=>"临汾", "yuncheng"=>"运城",
      "lanzhou"=>"兰州",
  }



  def self.get_baixing_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "zhengzhou" => '郑州', "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州",
            "lanzhou"=>"兰州",
        }
      when 1
        {
            "taiyuan" => "太原",'changsha' => '长沙',  "guangzhou" => "广州", "hangzhou" => "杭州", "dongguan" => "东莞", "chongqing" => "重庆", "wuxi" => "无锡", "foshan" => '佛山', "beijing"=>"北京","fuzhou" => "福州", "xiamen" => "厦门",
            "huhehaote"=>"呼和浩特",
        }
      else
        {
            'xian' => '西安',
            "qingdao" => "青岛", "weihai" => '威海', "yantai" => '烟台', "weifang" => '潍坊',
            "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jinan" => "济南",

            "shijiazhuang" => "石家庄", "tangshan" => "唐山", "baoji" => "宝鸡",
            "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",

            #  'zhenjiang' => '镇江',
            #  "shijiazhuang" => "石家庄", "tangshan" => "唐山",
            # "xianyang" => "咸阳", ,

            "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
            "shenyang" => "沈阳", "dalian" => "大连", "yingkou" => "营口",


            "quanzhou" => "泉州","changchun" => "长春", "haerbin" => "哈尔滨", "daqing" => "大庆", "hefei" => "合肥",
            "wuhu" => "芜湖", "nanning" => "南宁", "nanchang" => "南昌",
            "datong"=>"大同", "jinzhong"=>"晋中", "linfen"=>"临汾", "yuncheng"=>"运城",

            "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴", "guiyang" => "贵阳",
            "zunyi" => "遵义", #"huhehaote" => "呼和浩特", "wulumuqi" => "乌鲁木齐", "deyang" => "德阳",
            "mianyang" => "绵阳", "xiangfan" => "襄阳", "yichang" => "宜昌"

        }
    end
  end


  #赶集人人车+天天拍
  # GANJI_CITY_RENREN_ALL = {
  GANJI_CITY = {
      "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉",
      "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "cq" => "重庆", "wx" => "无锡", 'foshan' => '佛山',
      'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zhenjiang' => '镇江', "wei" => '威海', "yantai" => '烟台', "weifang" => '潍坊',
      "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jn" => "济南", "sjz" => "石家庄", "tangshan" => "唐山", "ty" => "太原",
      "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",
      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
      "sy" => "沈阳", "dl" => "大连", "yingkou" => "营口",
      "fz" => "福州", "xm" => "厦门", "quanzhou" => "泉州",
      "cc" => "长春", "hrb" => "哈尔滨", "daqing" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
      "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴",
      "gy" => "贵阳", "zunyi" => "遵义", "nmg" => "呼和浩特", "xj" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xiangyang" => "襄阳", "yichang" => "宜昌","bj" => "北京",
      "datong"=>"大同", "jinzhong"=>"晋中", "linfen"=>"临汾", "yuncheng"=>"运城","lz"=>"兰州",
  }



  def self.get_ganji_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            'zz' => '郑州',  "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉","fz" => "福州","lz"=>"兰州",
        }
      when 1
        {
            "ty" => "太原",'cs' => '长沙', "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "cq" => "重庆", 'foshan' => '佛山',"bj" => "北京", "xm" => "厦门"
        }
      else
        {

            'xa' => '西安',
            'qd' => '青岛', "wei" => '威海', "yantai" => '烟台', "weifang" => '潍坊', "wx" => "无锡",
            "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jn" => "济南",

            "sjz" => "石家庄", "tangshan" => "唐山","baoji" => "宝鸡",
            "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",

            # 人人车把以下放开
            #  'zhenjiang' => '镇江'  , "xianyang" => "咸阳",

            "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
            "sy" => "沈阳", "dl" => "大连", "yingkou" => "营口",

            "quanzhou" => "泉州","cc" => "长春", "hrb" => "哈尔滨", "daqing" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
            "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴", "gy" => "贵阳",
            "zunyi" => "遵义",
            "nmg" => "呼和浩特",#, "xj" => "乌鲁木齐", "deyang" => "德阳","wx" => "无锡",
            "mianyang" => "绵阳", "xiangyang" => "襄阳", "yichang" => "宜昌",
            "datong"=>"大同", "jinzhong"=>"晋中", "linfen"=>"临汾", "yuncheng"=>"运城",
        }
    end
  end


  #需要人人车的时候，用这个
  # WUBA_CITY_RENREN_ALL = {
  WUBA_CITY = {
      "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉", "fs" => '佛山',
      "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "wx" => "无锡", "cq" => "重庆",
      'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zj' => '镇江', "weihai" => '威海', "yt" => '烟台', "wf" => '潍坊',
      "cz" => "常州", 'xz' => '徐州', "nt" => '南通', "yz" => '扬州', "jn" => "济南", "sjz" => "石家庄", "ts" => "唐山", "ty" => "太原",
      "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "ny" => "南阳", "xx" => "新乡",
      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yy" => "岳阳",
      "sy" => "沈阳", "dl" => "大连", "yk" => "营口","bj" => "北京",
      "fz" => "福州", "xm" => "厦门", "qz" => "泉州",
      "cc" => "长春", "hrb" => "哈尔滨", "dq" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",

      "huizhou" => "惠州", "zq" => "肇庆", "zs" => "中山", "jx" => "嘉兴",
      "gy" => "贵阳", "zunyi" => "遵义", "hu" => "呼和浩特", "xj" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xf" => "襄阳", "yc" => "宜昌",
      "dt"=>"大同", "jz"=>"晋中", "linfen"=>"临汾", "yuncheng"=>"运城","lz"=>"兰州",
  }

  #不需要人人车的时候，用这个
  # WUBA_CITY = {
  #     "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉", "fs" => '佛山',
  #     "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "wx" => "无锡", "cq" => "重庆"
  # }

  def self.get_58_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "ty" => "太原",'zz' => '郑州', "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉", "fs" => '佛山'
        }
      when 1
        {
            'cs' => '长沙',"tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞",  "cq" => "重庆","bj" => "北京","lz"=>"兰州",
        }
      else
        {
              'xa' => '西安',
            'qd' => '青岛', "weihai" => '威海', "yt" => '烟台', "wf" => '潍坊',"wx" => "无锡",
            "cz" => "常州", 'xz' => '徐州', "nt" => '南通', "yz" => '扬州', "jn" => "济南",

            "sjz" => "石家庄", "ts" => "唐山",  "baoji" => "宝鸡",
            "luoyang" => "洛阳", "ny" => "南阳", "xx" => "新乡",


            # 需要人人车的时候，把重庆注释掉，把以下放开就好了，
            # 'zj' => '镇江', "xianyang" => "咸阳",

            "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yy" => "岳阳", "sy" => "沈阳", "dl" => "大连", "yk" => "营口",
            "qz" => "泉州","cc" => "长春", "hrb" => "哈尔滨", "dq" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
            "huizhou" => "惠州", "zq" => "肇庆", "zs" => "中山", "jx" => "嘉兴", "gy" => "贵阳",
            "zunyi" => "遵义",
            "hu" => "呼和浩特", #"xj" => "乌鲁木齐", "deyang" => "德阳",
            "mianyang" => "绵阳", "xf" => "襄阳", "yc" => "宜昌",
            "fz" => "福州","xm" => "厦门",
            "dt"=>"大同", "jz"=>"晋中", "linfen"=>"临汾", "yuncheng"=>"运城",
        }
    end
  end





  def self.create_car_user_info options
    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]
    return 1 if user_infos.length > 0

    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.save!
    return 0
  end

  def self.create_car_user_info2 options
    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]
    return nil if user_infos.length > 0

    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.save!
    car_user_info.id
  end

  def self.create_car_user_info_and_return_id options
    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]
    return user_infos.first if user_infos.length > 0
    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.save!
    return car_user_info
  end

  def self.update_detail params
    pp params
    car_user_info = UserSystem::CarUserInfo.find params[:id]

    #更新数据模块
    car_user_info.name = params[:name].gsub('联系TA', '先生女士') unless params[:name].blank?
    car_user_info.phone = params[:phone]
    car_user_info.note = params[:note]
    car_user_info.fabushijian = params[:fabushijian] unless params[:fabushijian].blank?
    if not params[:licheng].blank?
      car_user_info.milage = params[:licheng].gsub('万公里', '')
    end
    if not params[:price].blank?
      car_user_info.price = params[:price]
    end
    if not params[:wuba_kouling].blank?
      car_user_info.wuba_kouling = params[:wuba_kouling]
    end

    if not params[:brand].blank?
      car_user_info.brand = params[:brand]
    end

    if not params[:che_xing].blank?
      car_user_info.che_xing = params[:che_xing]
    end

    if not params[:che_ling].blank?
      car_user_info.che_ling = params[:che_ling]
    end

    if params[:is_cheshang]=="1"
      car_user_info.is_cheshang = 1
      car_user_info.is_real_cheshang = true
    end
    car_user_info.need_update = false
    car_user_info.save!


    # 针对58做城市匹配性校验
    if car_user_info.site_name == '58'
      # 针对58， 做城市校验，因为此时还没有电话号码，所以不用校验重复等。
      invert_wuba_city = UserSystem::CarUserInfo::WUBA_CITY.invert
      sx = invert_wuba_city[car_user_info.city_chinese]
      zhengze = "http://#{sx}.58.com"
      url_sx = car_user_info.detail_url.match Regexp.new zhengze
      unless url_sx
        car_user_info.is_cheshang = 2
        car_user_info.is_city_match = false
        car_user_info.save!
      end
    end

    # 针对非58 更新车商库
    # 2016-07-21 现在采用接口方式，58数据过来一并提交，此时58有电话号码，所以可以统一校验车商
    unless (car_user_info.site_name == '58' and car_user_info.phone.blank?)
      UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info, false
    end




    car_user_info = car_user_info.reload

    pp "准备更新品牌#{car_user_info.phone}~~#{car_user_info.name}"
    begin
      car_user_info.update_brand
    rescue Exception => e
      # car_user_info.destroy
      pp '更新品牌失败，已删除'
      return
    end


    # 58数据先不上传，等待手机端提交过来
    # 2016-07-21 现在采用接口和口令两种并存
    return if car_user_info.site_name == '58' and car_user_info.phone.blank?
    car_user_info = car_user_info.reload
    pp "准备单个上传#{car_user_info.phone}~~#{car_user_info.name}"
    UploadTianTian.upload_one_tt car_user_info
    # 同步至车置宝  车置宝作废
    # UserSystem::ChezhibaoCarUserInfo.create_info_from_car_user_info car_user_info
    UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info, true
    #同步至又一车
    UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info car_user_info
    #同步至优车
    UserSystem::YoucheCarUserInfo.create_user_info_from_car_user_info car_user_info
    # 同步至4A
    UserSystem::AishiCarUserInfo.create_user_info_from_car_user_info car_user_info
  end

  #用于网站调用
  def self.update_58_phone_detail params

    car_user_info = UserSystem::CarUserInfo.find params[:id]
    phone = params[:phone]
    phone.gsub!('-', '')
    phone = phone.match(/\d{11}$/).to_s
    car_user_info.phone = phone
    car_user_info.wuba_kouling_shouji_huilai_time = Time.now.chinese_format
    car_user_info.save!

    UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info, false
    car_user_info = car_user_info.reload
    pp "准备单个上传#{car_user_info.phone}~~#{car_user_info.name}"
    UploadTianTian.upload_one_tt car_user_info
    # 同步至又一车
    UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info, true
    UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info car_user_info
    # 同步至优车
    UserSystem::YoucheCarUserInfo.create_user_info_from_car_user_info car_user_info
    # 同步至a s
    UserSystem::AishiCarUserInfo.create_user_info_from_car_user_info car_user_info


  end

  # 车商检验流程
  def self.che_shang_jiao_yan car_user_info, is_fenxi = false
    begin
      UserSystem::CarBusinessUserInfo.add_business_user_info_phone car_user_info if is_fenxi
    rescue Exception => e
      pp '更新商家电话号码出错'
      pp e
    end

    #如果在car_business_user中出现，就算作车商
    unless car_user_info.phone.blank?
      cbui = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
      unless cbui.blank?
        car_user_info.is_cheshang = 1
        car_user_info.is_real_cheshang = true
        car_user_info.need_update = false
        car_user_info.save!
        return
      end
    end

    # 凌晨带有[]上传的，就认为是车商
    if car_user_info.created_at.hour >0 and car_user_info.created_at.hour < 6
      if not car_user_info.che_xing.blank?
        if car_user_info.che_xing.match /\[/ and car_user_info.che_xing.match /\]/
          car_user_info.is_cheshang = 1
          car_user_info.is_real_cheshang = true
          car_user_info.is_pachong = true
        end
        if car_user_info.che_xing.match /【/ and car_user_info.che_xing.match /】/
          car_user_info.is_cheshang = 1
          car_user_info.is_real_cheshang = true
          car_user_info.is_pachong = true
        end
        car_user_info.save!
        return
      end
    end

    #避免在车型中添加手机号，微信号
    unless car_user_info.che_xing.blank?
      tmp_chexing = car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
      if tmp_chexing.match /\d{11}|身份证|驾驶证/
        car_user_info.is_cheshang = 1
        car_user_info.is_real_cheshang = true
        car_user_info.is_pachong = true
        car_user_info.save!
        return
      end
    end

    unless car_user_info.note.blank?
      tmp_note = car_user_info.note.gsub(/\s|\.|~|-|_/, '')
      if tmp_note.match /\d{11}|身份证|驾驶证/
        car_user_info.is_cheshang = 1
        car_user_info.is_real_cheshang = true
        car_user_info.is_pachong = true
        car_user_info.save!
        return
      end
    end


    is_pachong = UserSystem::CarBusinessUserInfo.is_pachong car_user_info
    if is_pachong
      car_user_info.is_pachong = true
      car_user_info.save!
      return
    end

    unless car_user_info.phone.blank?
      phone_number_one_month = UserSystem::CarUserInfo.where("phone = ? and created_at > ? and tt_id is not null", car_user_info.phone, (Time.now.months_ago 1).chinese_format).count
      car_user_info.is_repeat_one_month = phone_number_one_month > 1
      car_user_info.save!
    end
  end


  def self.run_che168 sub_city_party = 0
    [1..1000].each do |i|
      begin
        Che168.get_car_user_list sub_city_party
      rescue Exception => e
        pp e
      end
      pp '168再来一遍。。。'
      pp "168现在时间 #{Time.now.chinese_format}"
    end


    # begin
    #   # Che168.update_detail
    # rescue Exception => e
    #   pp e
    # end
  end

  def self.run_taoche
    begin
      TaoChe.get_car_user_list
    rescue Exception => e
      pp e
    end

    begin
      TaoChe.update_detail
    rescue Exception => e
      pp e
    end
  end

  def self.run_58 sub_city_party = 0
    [1..1000].each do |i|
      begin
        Wuba.get_car_user_list 20, sub_city_party
      rescue Exception => e
        pp e
      end

      begin
        #Wuba.update_detail
      rescue Exception => e
        pp e
      end
      pp '58再来一遍。。。'
      pp "58现在时间 #{Time.now.chinese_format}"
    end
  end

  def self.run_ganji party = 0
    [1..1000].each do |i|
      begin
        Ganji.get_car_user_list party
      rescue Exception => e
        pp e
      end

      begin
        # Ganji.update_detail
      rescue Exception => e
        pp e
      end
      pp '赶集再来一遍。。。'
      pp "现在赶集时间 #{Time.now.chinese_format}"
    end
  end

  def self.run_baixing party = 0
    begin
      Baixing.get_car_user_list party
    rescue Exception => e
      pp e
    end

    begin
      # Baixing.update_detail
    rescue Exception => e
      pp e
    end
  end


  #UserSystem::CarUserInfo.run_men true
  def self.run_men run_list = true

    if run_list
      begin
        Che168.get_car_user_list
      rescue Exception => e
        pp e
      end
    end

    begin
      Che168.update_detail
    rescue Exception => e
      pp e
    end

    if run_list
      begin
        TaoChe.get_car_user_list
      rescue Exception => e
        pp e
      end
    end
    pp '.........淘车列表跑完'


    begin
      TaoChe.update_detail
    rescue Exception => e
      pp e
    end
    pp '.........淘车明细更新完成'

    # begin
    #   UserSystem::CarUserInfo.update_all_brand
    #   pp '更新品牌结束'
    # rescue Exception => e
    #   pp e
    # end

    begin
      UploadTianTian.upload_tt
    rescue Exception => e
      pp e
    end
    #
    #
    # begin
    #   UserSystem::CarUserInfo.send_email
    #   pp Time.now.chinese_format
    # rescue Exception => e
    #   pp e
    # end
  end


  #获取20个城市的代码及名称, 针对che168网站
  # UserSystem::CarUserInfo.get_city_code_name
  def self.get_city_code_name
    provinces = {"440000" => "广东", "370000" => "山东", "330000" => "浙江", "320000" => "江苏", "130000" => "河北",
                 "410000" => "河南", "110000" => "北京", "210000" => "辽宁", "310000" => "上海", "500000" => "重庆",
                 "350000" => "福建", "450000" => "广西", "520000" => "贵州",  "460000" => "海南","620000" => "甘肃",
                 "420000" => "湖北", "430000" => "湖南", "230000" => "黑龙江", "360000" => "江西", "220000" => "吉林",
                 "150000" => "内蒙古", "640000" => "宁夏", "630000" => "青海", "610000" => "陕西", "510000" => "四川",
                 "140000" => "山西", "120000" => "天津", "650000" => "新疆", "540000" => "西藏", "530000" => "云南", "34000" => "安徽"}
    # provinces = { "320000" => "江苏"}
    # provinces = {"130000" => "河北"}
    # provinces = {"440000" => "广东", "330000" => "浙江", "520000" => "贵州", "150000" => "内蒙古", "650000" => "新疆", "510000" => "四川", "420000" => "湖北"}
    provinces = {"620000" => "甘肃","150000" => "内蒙古"}
    city_hash = {}
    provinces.each_pair do |key, v|
      city_content = RestClient.get("http://m.che168.com/Handler/GetArea.ashx?pid=#{key}")
      pp 'xxx'
      city_content = JSON.parse city_content.body
      pp city_content
      #
      city_content["item"].each do |city|
        areaid, areaname = city["id"], city["value"]

        if ['兰州', '呼和浩特'].include? areaname
          city_hash[areaid] = areaname
        end
      end
    end
  end


  # 生成每小时xls
  def self.generate_xls_of_car_user_info car_user_infos
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    center_gray = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin, color: :gray
    sheet1 = book.create_worksheet name: '车主信息数据'
    ['姓名', '电话', '车型', '车龄', '价格', '城市', '备注', '里程', '发布时间', '保存时间', '数据来源', '导入状态', '渠道'].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end
    current_row = 1
    car_user_infos.each do |car_user_info|
      upload_zhuangtai = case car_user_info.upload_status
                           when 'success'
                             '成功'
                           when 'yicunzai'
                             if car_user_info.bookid.blank?
                               '已存在'
                             else
                               '成功'
                             end
                           when 'shibai'
                             "失败--#{car_user_info.shibaiyuanyin}"
                           else
                             '不导入'
                         end

      [car_user_info.name, car_user_info.phone, car_user_info.che_xing, ("#{(Time.now.year-car_user_info.che_ling.to_i) rescue ''}年"), car_user_info.price, car_user_info.city_chinese, car_user_info.note, "#{car_user_info.milage}万公里", car_user_info.fabushijian, (car_user_info.created_at.chinese_format rescue ''), car_user_info.site_name, upload_zhuangtai, car_user_info.channel].each_with_index do |content, i|
        sheet1.row(current_row)[i] = content
      end
      current_row += 1
    end
    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}车主信息数据.xls")
    book.write file_path
    file_path
  end

  # class UserSystem::CarUserInfo < ActiveRecord::Base
  def self.update_all_brand
    # cui = UserSystem::CarUserInfo.where("brand is not null").order(id: :desc).first
    # cuis = UserSystem::CarUserInfo.where("id > #{cui.id} and brand is  null and phone is not null")
    cuis = UserSystem::CarUserInfo.where("id > 172006 and brand is  null and phone is not null")
    cuis.each_with_index do |cui, i|
      begin
        cui.update_brand
      rescue Exception
        cui.update_brand
      end
      pp "完成 #{i}/#{cuis.length}"
    end
  end

  # end

  def update_brand
    return unless self.brand.blank?

    UserSystem::CarType.all.each do |t|
      if self.che_xing.match Regexp.new(t.name)
        self.brand = t.car_brand.name
        self.cx = t.name
        self.save!
        break
      end
    end

    return unless self.brand.blank?

    UserSystem::CarBrand.all.each do |brand|
      if self.che_xing.match Regexp.new(brand.name)
        self.brand = brand.name
        self.save!
        break
      end
    end

  end

  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 为开新临时导出上海的成功数据，导前一天的数据, 邮件给KK， OO 和我。  业务现已停止
  # UserSystem::CarUserInfo.get_kaixin_info
  def self.get_kaixin_info
    cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = '上海' and tt_yaoyue = '成功' and tt_yaoyue_day = ? and tt_chengjiao is null", Date.today)
    return if cuis.length == 0
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
    center_gray = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin, color: :gray
    sheet1 = book.create_worksheet name: '车主信息数据'
    ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end
    current_row = 1
    i = 0
    cuis.each do |car_user_info|
      [car_user_info.name, car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|
        sheet1.row(current_row)[i] = content
      end
      i = i+1
      current_row += 1
      car_user_info.tt_chengjiao = 'kaixin'
      car_user_info.save!
    end
    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}上海信息数据.xls")
    book.write file_path
    file_path

    MailSend.send_car_user_infos('37020447@qq.com;yoyolt3@163.com',
                                 '13472446647@163.com',
                                 i,
                                 "最新数据-#{Time.now.chinese_format}",
                                 [file_path]
    ).deliver

  end


  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 导出数据给车王。
  # 现在只要天津和上海数据。每天下午3点定时导出前一天下午3点到今天下午3点的数据。
  # UserSystem::CarUserInfo.get_info_to_chewang
  def self.get_info_to_chewang
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    record_number = 0
    ['天津', '上海'].each do |city|
      sheet1 = book.create_worksheet name: "#{city}数据"
      ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
        sheet1.row(0)[i] = content
      end
      row = 0
      cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = ? and milage < 9 and  tt_upload_status = '已上传' and tt_code in (0,1) and created_at > ? and created_at < ?", city, "#{Date.yesterday.chinese_format_day} 15:00:00", "#{Date.today.chinese_format_day} 15:00:00")
      cuis.each_with_index do |car_user_info, current_row|
        next if car_user_info.is_repeat_one_month
        if car_user_info.city_chinese == '上海'
          unless ['别克', '福特', 'MG', '荣威', '雪佛兰'].include? car_user_info.brand
            next
          end
        end
        record_number = record_number+1
        row = row+1
        [car_user_info.name.gsub('(个人)', ''), car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|
          sheet1.row(row)[i] = content
        end
      end
    end


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}车王信息数据.xls")
    book.write file_path
    file_path

    MailSend.send_car_user_infos('37020447@qq.com;yoyolt3@163.com',
                                 '13472446647@163.com',
                                 record_number,
                                 "车王最新数据-#{Time.now.chinese_format}",
                                 [file_path]
    ).deliver

  end


  # 导出数据给晓玥。
  # 一次一个城市
  # UserSystem::CarUserInfo.get_info_to_xiaoyue
  def self.get_info_to_xiaoyue
    id_hash = {
        "上海" => 1161102
    }
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new

    city = '上海'
    phones = []
    sheet1 = book.create_worksheet name: "#{city}数据"
    ['姓名', '电话'].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end
    row = 0
    cuis = UserSystem::CarUserInfo.where("id > #{id_hash[city]} and city_chinese = ?", city).select("id", "name", "phone")
    cuis.find_each do |car_user_info|
      next if phones.include? car_user_info.phone
      next if car_user_info.phone.blank?
      next unless car_user_info.phone.match /\d{11}/
      phones << car_user_info.phone

      row = row+1
      [car_user_info.name, car_user_info.phone].each_with_index do |content, i|
        sheet1.row(row)[i] = content
      end
      if row == 50000
        pp car_user_info.id
        break
      end
    end


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}导出#{city}数据.xls")
    book.write file_path
    file_path
    #
    # MailSend.send_car_user_infos('',
    #                              '13472446647@163.com',
    #                              record_number,
    #                              "车王最新数据-#{Time.now.chinese_format}",
    #                              [file_path]
    # ).deliver

  end


  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 导出北京数据
  # UserSystem::CarUserInfo.get_info_to_chewang
  def self.get_info_to_youche

    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    phones = []
    record_number = 0
    ['北京', '天津'].each do |city|
      sheet1 = book.create_worksheet name: "#{city}数据"
      ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
        sheet1.row(0)[i] = content
      end
      row = 0
      cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = ? and created_at > ? and created_at < ?", city, "#{Date.yesterday.chinese_format_day} 18:00:00", "#{Date.today.chinese_format_day} 18:00:00")
      cuis.each_with_index do |car_user_info, current_row|
        # car_user_info.name = car_user_info.name.gsub('联系TA','先生女士')
        # car_user_info.save!


        cbui = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
        unless cbui.blank?
          next
        end

        next if car_user_info.phone.blank?
        next if car_user_info.name.blank?
        next if car_user_info.brand.blank?

        next if phones.include? car_user_info.phone
        phones << car_user_info.phone

        record_number = record_number+1
        row = row+1
        [car_user_info.name.gsub('(个人)', '').gsub('联系TA', '先生女士'), car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|

          sheet1.row(row)[i] = content

        end

      end
    end


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}UC信息数据.xls")
    book.write file_path
    file_path

    MailSend.send_car_user_infos('13472446647@163.com',
                                 '',
                                 record_number,
                                 "UC最新数据-#{Time.now.chinese_format}",
                                 [file_path]
    ).deliver

  end


  # UserSystem::CarUserInfo.get_info_to_renren
  def self.get_info_to_renren

    # 人人车优化笔记
    # 1. 车龄在08年以前的， 12万公里以内，才从手机端获取数据。其它不获取数据。    对于58
    # 1.1 带总、经理，老板 一律不获取手机号
    # 2. 根据描述可以判断是车商的， 不再获取手机号      对于58
    # 3. 小城市群分成四个组，再开2台服务器，用于快速抓取数据  对于58
    # 4. 对于赶集， 小城市群分成四个组，再开1台服务器，用于快速抓取数据。  对于赶集
    # 5. 对于百姓， 现在4台机器在跑， 把数据分成6个小组， 每台机器跑一组。 对于百姓    Done， 分成三组
    # 6. 对于百姓， 严格获取车龄和里程    Done
    # 7. 对于整体， 所有手机号过滤一遍，手机号重复率> 10 的， 全部进入车商库。  Done
    # 8. 对于整体， 只要在车商库中存在的，一律不提交  Done
    # 9. 对于没有车龄，里程数据的，一律不提交  Done
    # 10. 手机号异地，一律不提交   Done
    # 11. 出现在车商信息中的，一律不提交    Done
    # #

    phones = []
    cities_all = ["深圳", "广州", "南京", "成都", "东莞", "重庆", "苏州", "上海", "郑州", "威海", "石家庄", "武汉", "沈阳", "西安", "青岛", "长沙", "哈尔滨", "长春", "杭州", "潍坊", "厦门", "佛山", "大连", "合肥", "天津", "绵阳", "徐州", "无锡", "湘潭", "株洲", "宜昌", "肇庆", "洛阳 ", "济南 ", "贵阳 ", "南宁 ", "福州", "咸阳", "南阳", "惠州", "太原", "常德", "泉州", "襄阳", "宝鸡", "中山", "德阳", "常州", "南通", "扬州", "新乡", "烟台", "嘉兴", "大庆", "营口", "呼和浩特", "芜湖", "唐山", "遵义", "乌鲁木齐", "南昌", "岳阳"]
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    phones = []
    record_number = 0
    a, b, c, d, e, f, g, h, ii, jj = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    bcui_number = 0
    sheet1 = book.create_worksheet name: "人人车测试数据"
    ['姓名', '电话', '品牌', '车系', '城市', "里程", "车龄"].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end
    row = 0
    # cuis = UserSystem::CarUserInfo.where("id > 1003334 and phone is not null")
    cuis = UserSystem::CarUserInfo.where("created_at > ? and created_at < ? and phone is not null", "#{(Time.now-1.days).chinese_format_day} 10:00:00", "#{(Time.now).chinese_format} 10:00:00")


    cuis.each_with_index do |car_user_info, current_row|
      car_user_info.note.gsub!('联系我时，请说是在易车二手车上看到的，谢谢！', '')
      car_user_info.note.gsub!('打电话给我时，请一定说明在手机百姓网看到的，谢谢！', '')
      car_user_info.save!

      UserSystem::CarBusinessUserInfo.add_business_user_info_phone car_user_info
      car_user_info = car_user_info.reload
      if car_user_info.phone.blank?
        a += 1
        next
      end
      if car_user_info.name.blank?
        b += 1
        next
      end

      chexing_guolv = false
      ['电话', '联系', '精品', '处理', '过户', '包你'].each do |kw|
        if car_user_info.che_xing.include? kw
          chexing_guolv = true
          break
        end
      end
      next if chexing_guolv

      if car_user_info.note.blank?
        next
      end

      if car_user_info.milage.to_i > 10
        next
      end


      if ['金杯', '五菱汽车', "五菱", '五十铃', '昌河', '奥迪', '宝马', '宾利', '奔驰', '路虎', '保时捷', '江淮', '东风小康', '依维柯', '长安商用', '福田', '东风风神', '东风', '一汽'].include? car_user_info.brand
        next
      end


      # 本车   私家车  手机号  心动  包你满意    一个螺丝
      aaa = false
      ['QQ', '求购', '牌照', '批发', '私家一手车', '一手私家车', '身份', '身 份', '身~份', '个体经商', '过不了户', '帮朋友', '外地',
       '贷款', '女士一手', '包过户', '原漆', '原版漆', '当天开走', '美女', '车辆说明', '车辆概述', '选购', '一个螺丝',
       '精品', '驾驶证', '驾-驶-证', '车况原版', '随时过户', '来电有惊喜', '值得拥有', '包提档过户',
       '车源', '神州', '分期', '分 期', '必须过户', '抵押', '原车主', '店内服务', '选购', '微信', 'wx', '微 信',
       '威信', '加微', '评估师点评', '车主自述', "溦 信", '电话量大', '包你满意', '刷卡', '办理', '纯正', '抢购', '心动', '本车', '送豪礼'].each do |kw|
        if car_user_info.note.include? kw
          aaa = true
          break
        end
      end
      next if aaa

      # 描述中不需要电话号码
      next if car_user_info.note.match /\d{11}/


      aaa = false
      #名字有特殊意思的
      ['图', '照片', '哥', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇'].each do |kw|
        if car_user_info.name.include? kw
          aaa = true
          break
        end
      end
      next if aaa


      config_key_words = 0
      ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd",
       "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜",
       "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "空调",
       "倒镜", "后视镜", "GPS", "电子手刹", "换挡拨片", "巡航定速", "一分钱"].each do |kw|
        config_key_words+=1 if car_user_info.note.include? kw
      end
      # 过多配置描述，一般车商
      next if config_key_words > 6

      # 名字是小字开头的，都是车商
      if car_user_info.name.match /^小/ and car_user_info.name.length == 2
        next
      end


      #特殊名字一般是做走私车，不能使用。
      if /^[a-z|A-Z|0-9|-|_]+$/.match car_user_info.name
        next
      end

      #还有用手机号，QQ号做名字的。
      if /[0-9]+/.match car_user_info.name
        next
      end

      #车型是数字+点的，一律不要


      # 车商口气
      next if car_user_info.note.match /^出售/

      # 08年之前的车不要
      next if car_user_info.che_ling.to_i < 2008

      #没有品牌数据的不要
      next if car_user_info.brand.blank?

      # 车型中有[]的一律认为是车商
      if not car_user_info.che_xing.blank?
        next if car_user_info.che_xing.match /QQ|电话|不准|低价|私家车|外观|咨询|一手车|精品|业务|打折|货车/
        next if car_user_info.note.match /\d{11}/ # 车型中不能出现电话
        # 车型中以数字标号开头的，一律不要  这是赶集数据
        # next if car_user_info.che_xing.match /^\d{1,2}\./
      end

      if not car_user_info.che_xing.blank?
        next if car_user_info.che_xing.match /\[/ and car_user_info.che_xing.match /\]/
        next if car_user_info.che_xing.match /【/ and car_user_info.che_xing.match /】/
      end

      #去重复
      next if phones.include? car_user_info.phone

      # 初步判断去车商
      next if car_user_info.is_cheshang == 1

      # 初步判断去车商
      next if car_user_info.is_real_cheshang

      # 去爬虫
      next if car_user_info.is_pachong

      # 城市需要匹配
      next unless car_user_info.is_city_match

      #只要业务范围内城市
      next unless cities_all.include? car_user_info.city_chinese # 判断城市是否包含

      #最要这个手机号出现过一次，就不导入
      cuis = UserSystem::CarUserInfo.where("id < ? and phone = ?", car_user_info.id, car_user_info.phone)
      next if cuis.length > 0

      # 车商库中再查询一遍
      cbuis = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
      next unless cbuis.blank?

      bcui_number = 0
      bcui = UserSystem::BusinessCarUserInfo.find_by_phone car_user_info.phone
      unless bcui.blank?
        bcui_number += 1
        next
      end


      #不要外地手机号
      car_user_info.phone_city = UserSystem::YoucheCarUserInfo.get_city_name(car_user_info.phone)
      car_user_info.save!
      next unless car_user_info.phone_city == car_user_info.phone_city

      #车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
      tmp_chexing = car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
      tmp_note = car_user_info.note.gsub(/\s|\.|~|-|_/, '')
      next if tmp_chexing.match /\d{11}|身份证|驾驶证/
      next if tmp_note.match /\d{11}|身份证|驾驶证/


      jj+=1
      record_number = record_number+1
      row = row+1
      phones << car_user_info.phone
      [car_user_info.name.gsub('(个人)', '').gsub('联系TA', '先生女士'), car_user_info.phone, car_user_info.brand, car_user_info.cx, car_user_info.city_chinese, car_user_info.milage, car_user_info.che_ling, car_user_info.note, car_user_info.che_xing, car_user_info.detail_url].each_with_index do |content, i|
        sheet1.row(row)[i] = content
      end
    end


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}RenRen信息数据.xls")
    book.write file_path
    file_path
    pp a, b, c, d, e, f, g, h, ii, jj
    pp "商车库中重复数为： #{bcui_number}"

    # MailSend.send_car_user_infos('13472446647@163.com',
    #                              '',
    #                              record_number,
    #                              "RenRen最新数据-#{Time.now.chinese_format}",
    #                              [file_path]
    # ).deliver

  end

  #获取手机号对应的城市 ， 废弃
  def self.phone_city

    UserSystem::CarUserInfo.where("phone_city is null and id > 500000 and phone is not null and tt_code is not null").order(id: :desc).find_each do |cui|
      begin
        cityname = UserSystem::YoucheCarUserInfo.get_city_name cui.phone
        cui.phone_city = cityname
        cui.save!
      rescue Exception => e
      end
    end


  end

  def test
    ids = []
    UserSystem::CarUserInfo.where("1=1").find_each do |k|
      next if k.note.blank?
      i = 0
      ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd", "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜", "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "自动空调，", "倒镜自动收", "GPS", "电子手刹", "换挡拨片", "巡航定速"].each do |kw|
        i+=1 if k.note.include? kw
      end
      ids << k.id if i > 6
    end

    phones = []
    ids.each do |id|
      cui = UserSystem::CarUserInfo.find id
      next if phones.include? cui.phone
      phones << cui.phone
    end

    phones.each do |phone|
      p = UserSystem::CarBusinessUserInfo.where("phone = ?", phone)
      next unless p.blank?
      kk = UserSystem::CarBusinessUserInfo.new :phone => phone
      kk.save
    end
  end

  #UserSystem::CarUserInfo.upload_guozheng
  def self.upload_guozheng
    return unless (Time.now.hour > 9 and Time.now.hour < 22)
    return unless Time.now.min > 30
    qudao = '2-306-314'
    s = '261d684f6b7d9af996a5691e7106075e'
    cuis = UserSystem::CarUserInfo.where("tt_source = '#{qudao}' and tt_id is not null and id > 2001992")
    cuis.find_each do |cui|
      # cui = UserSystem::CarUserInfo.find 1181521
      next if cui.tt_chengjiao == '已提交GZ'
      name = cui.name.gsub('(个人)', '')
      response = RestClient.post 'http://api3.wejing365.cn/index.php?r=apisa/save_car', {name: name,
                                                                                         mobile: cui.phone,
                                                                                         city: cui.city_chinese,
                                                                                         brand: cui.brand,
                                                                                         source: qudao,
                                                                                         response_id: cui.tt_id,
                                                                                         number: 'PRO103',
                                                                                         sign: Digest::MD5.hexdigest("#{cui.phone}#{s}")
                                                                                      }
      response = JSON.parse response.body
      pp response
      if response["error"] == "false"
        cui.tt_chengjiao = '已提交GZ'
        cui.save!
      end

      if response["error"] == "true" and response["message"] = '该手机号已经报名'
        cui.tt_chengjiao = '已提交GZ'
        cui.save!
      end
    end
  end

  # UserSystem::CarUserInfo.upload_to_hulei
  def self.upload_to_hulei
    return unless (Time.now.hour > 9 and Time.now.hour < 22)
    return unless Time.now.min > 30

    # key = "033bd94b1168d7e4f0d644c3c95e35bf" #测试
    # number = "4S-10009" #测试
    # url = 'http://api.test.4scenter.com/index.php?r=apicar/save_car'

    key = "098f6bcd4621d373cade4e832627b4f6" #正式
    number = "4SA-1011" #正式
    url = 'http://api.formal.4scenter.com/index.php?r=apicar/save_car'

    cuis = UserSystem::CarUserInfo.where("tt_source in ('23-23-5','23-23-4','23-23-1') and tt_id is not null and created_at > '2016-08-10'")
    cuis.find_each do |cui|

      next if cui.tt_chengjiao == '已提交GZ'
      next if cui.tt_chengjiao == '已提交HL'
      pp cui.id
      name = cui.name.gsub('(个人)', '')
      response = RestClient.post url, {mobile: cui.phone,
                                       name: name,
                                       city: "#{cui.city_chinese}市",
                                       brand: cui.brand,
                                       number: number,
                                       source: cui.tt_source,
                                       sign: Digest::MD5.hexdigest("#{cui.phone}#{key}"),
                                       response_id: cui.tt_id,
                                    }
      response = JSON.parse response.body

      pp response
      if response["error"] == "false"
        cui.tt_chengjiao = '已提交HL'
        cui.save!
      end

      if response["error"] == "true" and response["message"] = '该手机号已经报名'
        cui.tt_chengjiao = '已提交HL'
        cui.save!
      end
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