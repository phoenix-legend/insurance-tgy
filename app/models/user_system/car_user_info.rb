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
  # ALL_CITY = {"441900" => "东莞", "440600" => "佛山", "440100" => "广州",
  #             "440300" => "深圳", "370100" => "济南", "370200" => "青岛",
  #             "330100" => "杭州", "330200" => "宁波", "330300" => "温州",
  #             "320100" => "南京", "320500" => "苏州", "320200" => "无锡",
  #             "130100" => "石家庄", "130200" => "唐山", "410100" => "郑州",
  #             "110100" => "北京", "210200" => "大连", "210100" => "沈阳",
  #             "310100" => "上海", "500100" => "重庆", "350100" => "福州",
  #             "350200" => "厦门", "420100" => "武汉", "430100" => "长沙",
  #             "230100" => "哈尔滨", "610100" => "西安", "510100" => "成都",
  #             "140100" => "太原", "120100" => "天津", "340100" => '合肥'}

  ALL_CITY_RENREN_ALL = {"310100" => "上海", "510100" => "成都", "440300" => "深圳", "320100" => "南京", "440100" => "广州", "420100" => "武汉",
              "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡",
              "410100" => "郑州", "430100" => "长沙", "610100" => "西安", "370200" => "青岛", "440600" => "佛山", "371000" => '威海',
              "370600" => '烟台', "370700" => '潍坊', "320400" => '常州', "320300" => '徐州', "320600" => '南通', "321000" => '扬州', "370100" => "济南",
              "130100" => "石家庄", "130200" => "唐山", "140100" => "太原", "610400" => "咸阳", "610300" => "宝鸡",
              "410300" => "洛阳", "411300" => "南阳", "410700" => "新乡",
              "430300" => "湘潭", "430200" => "株洲", "430700" => "常德", "430600" => "岳阳",
              "210100" => "沈阳", "210200" => "大连", "210800" => "营口",
              "350100" => "福州", "350200" => "厦门", "350500" => "泉州",
              "220100" => "长春", "230100" => "哈尔滨", "230600" => "大庆", "340100" => "合肥", "340200" => "芜湖", "450100" => "南宁", "360100" => "南昌",
              "441300" => "惠州", "441200" => "肇庆", "442000" => "中山", "330400" => "嘉兴", "520100" => "贵阳", "520300" => "遵义", "150100" => "呼和浩特", "650100" => "乌鲁木齐", "510600" => "德阳", "510700" => "绵阳", "420600" => "襄阳", "420500" => "宜昌"
  } #,

  ALL_CITY = {"310100" => "上海", "510100" => "成都", "440300" => "深圳", "320100" => "南京", "440100" => "广州", "420100" => "武汉",
                         "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡", "440600" => "佛山"
  }

  def self.get_che168_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "310100" => "上海", "510100" => "成都", "440300" => "深圳", "320100" => "南京", "440100" => "广州", "420100" => "武汉", "440600" => "佛山"
        }
      when 1
        {
            "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡"
        }
      else
        {
            "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡"

            # 人人车把以下打开
            # "410100" => "郑州", "430100" => "长沙", "610100" => "西安", "370200" => "青岛", "371000" => '威海', "370600" => '烟台', "370700" => '潍坊',
            # "320400" => '常州', "320300" => '徐州', "320600" => '南通', "321000" => '扬州', "370100" => "济南",
            # "130100" => "石家庄", "130200" => "唐山", "140100" => "太原", "610400" => "咸阳", "610300" => "宝鸡", "410300" => "洛阳", "411300" => "南阳", "410700" => "新乡",
            # "430300" => "湘潭", "430200" => "株洲", "430700" => "常德", "430600" => "岳阳",
            # "210100" => "沈阳", "210200" => "大连", "210800" => "营口",
            # "350100" => "福州", "350200" => "厦门", "350500" => "泉州",
            # "220100" => "长春", "230100" => "哈尔滨", "230600" => "大庆", "340100" => "合肥", "340200" => "芜湖", "450100" => "南宁", "360100" => "南昌",
            # "441300" => "惠州", "441200" => "肇庆", "442000" => "中山", "330400" => "嘉兴", "520100" => "贵阳", "520300" => "遵义", "150100" => "呼和浩特", "650100" => "乌鲁木齐",
            # "510600" => "德阳", "510700" => "绵阳", "420600" => "襄阳", "420500" => "宜昌"
        }
    end
  end


  #城市所对应的拼音。 主要用于从淘车网更新数据。
  # 淘车
  PINYIN_CITY_RENREN_ALL = {
      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州",
      "dongguan" => "东莞", "chongqing" => "重庆", "beijing" => "北京", "zhengzhou" => '郑州', 'changsha' => '长沙',
      'xian' => '西安', "qingdao" => "青岛", 'zhenjiang' => '镇江', "wuxi" => "无锡", "foshan" => '佛山', "weihai" => '威海', "yantai" => '烟台', "weifang" => '潍坊',
      "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jinan" => "济南", "shijiazhuang" => "石家庄", "tangshan" => "唐山", "taiyuan" => "太原",
      "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",
      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
      "shenyang" => "沈阳", "dalian" => "大连", "yingkou" => "营口",
      "fuzhou" => "福州", "xiamen" => "厦门", "quanzhou" => "泉州",
      "changchun" => "长春", "haerbin" => "哈尔滨", "daqing" => "大庆", "hefei" => "合肥", "wuhu" => "芜湖", "nanning" => "南宁", "nanchang" => "南昌",
      "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴",
      "guiyang" => "贵阳", "zunyi" => "遵义", "huhehaote" => "呼和浩特", "wulumuqi" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xiangfan" => "襄阳", "yichang" => "宜昌"
  }

  IMPRTANT_CITY = ["上海", "成都", "深圳", "南京", "广州","武汉","天津", "苏州", "杭州", "佛山" ,"东莞", "重庆","无锡"]

  # 淘车
  PINYIN_CITY = {
      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州","foshan" => '佛山',
      "dongguan" => "东莞", "chongqing" => "重庆","wuxi" => "无锡"
  }


  #百姓人人车+天天拍
  BAIXING_PINYIN_CITY_RENREN_ALL = {
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
      "mianyang" => "绵阳", "xiangfan" => "襄阳", "yichang" => "宜昌"
  }

  # 百姓天天拍
  BAIXING_PINYIN_CITY = {
      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州",
      "dongguan" => "东莞", "chongqing" => "重庆", "wuxi" => "无锡", "foshan" => '佛山'
  }


  #赶集人人车+天天拍
  GANJI_CITY_RENREN_ALL = {
    "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉",
        "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "cq" => "重庆", "wx" => "无锡",'foshan' => '佛山',
        'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zhenjiang' => '镇江',  "wei" => '威海', "yantai" => '烟台', "weifang" => '潍坊',
        "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jn" => "济南", "sjz" => "石家庄", "tangshan" => "唐山", "ty" => "太原",
        "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",
        "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
        "sy" => "沈阳", "dl" => "大连", "yingkou" => "营口",
        "fz" => "福州", "xm" => "厦门", "quanzhou" => "泉州",
        "cc" => "长春", "hrb" => "哈尔滨", "daqing" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
        "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴",
        "gy" => "贵阳", "zunyi" => "遵义", "nmg" => "呼和浩特", "xj" => "乌鲁木齐", "deyang" => "德阳",
        "mianyang" => "绵阳", "xiangyang" => "襄阳", "yichang" => "宜昌"

  }
  #赶集天天拍
  GANJI_CITY =  {
      "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉",
      "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "cq" => "重庆", "wx" => "无锡",
      'foshan' => '佛山'
  }


  def self.get_ganji_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉"
        }
      when 1
        {
            "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "cq" => "重庆", "wx" => "无锡", 'foshan' => '佛山'
        }
      else
        {

            "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "cq" => "重庆", "wx" => "无锡", 'foshan' => '佛山'


            # 人人车把以下放开
            # 'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zhenjiang' => '镇江', "wei" => '威海', "yantai" => '烟台', "weifang" => '潍坊',
            # "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jn" => "济南", "sjz" => "石家庄", "tangshan" => "唐山",
            # "ty" => "太原", "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",
            # "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
            # "sy" => "沈阳", "dl" => "大连", "yingkou" => "营口",
            # "fz" => "福州", "xm" => "厦门", "quanzhou" => "泉州",
            # "cc" => "长春", "hrb" => "哈尔滨", "daqing" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
            # "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴",
            # "gy" => "贵阳", "zunyi" => "遵义", "nmg" => "呼和浩特", "xj" => "乌鲁木齐", "deyang" => "德阳",
            # "mianyang" => "绵阳", "xiangyang" => "襄阳", "yichang" => "宜昌"
        }
    end
  end


  #需要人人车的时候，用这个
  WUBA_CITY_RENREN_ALL = {
      "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉", "fs" => '佛山',
      "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "wx" => "无锡", "cq" => "重庆",
      'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zj' => '镇江', "weihai" => '威海', "yt" => '烟台', "wf" => '潍坊',
      "cz" => "常州", 'xz' => '徐州', "nt" => '南通', "yz" => '扬州', "jn" => "济南", "sjz" => "石家庄", "ts" => "唐山", "ty" => "太原",
      "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "ny" => "南阳", "xx" => "新乡",
      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yy" => "岳阳",
      "sy" => "沈阳", "dl" => "大连", "yk" => "营口",
      "fz" => "福州", "xm" => "厦门", "qz" => "泉州",
      "cc" => "长春", "hrb" => "哈尔滨", "dq" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
      "huizhou" => "惠州", "zq" => "肇庆", "zs" => "中山", "jx" => "嘉兴",
      "gy" => "贵阳", "zunyi" => "遵义", "hu" => "呼和浩特", "xj" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xf" => "襄阳", "yc" => "宜昌"
  }

  #不需要人人车的时候，用这个
  WUBA_CITY = {
      "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉", "fs" => '佛山',
      "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "wx" => "无锡", "cq" => "重庆"
  }

  def self.get_58_sub_cities sub_party = 0
    case sub_party
      when 0
        {
            "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉", "fs" => '佛山'
        }
      when 1
        {
            "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "wx" => "无锡", "cq" => "重庆"
        }
      else
        {
            "cq" => "重庆"
            # 需要人人车的时候，把重庆注释掉，把以下放开就好了，
            # 'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zj' => '镇江', "weihai" => '威海', "yt" => '烟台', "wf" => '潍坊',
            # "cz" => "常州", 'xz' => '徐州', "nt" => '南通', "yz" => '扬州', "jn" => "济南", "sjz" => "石家庄", "ts" => "唐山", "ty" => "太原",
            # "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "ny" => "南阳", "xx" => "新乡",
            # "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yy" => "岳阳",
            # "sy" => "沈阳", "dl" => "大连", "yk" => "营口",
            # "fz" => "福州", "xm" => "厦门", "qz" => "泉州",
            # "cc" => "长春", "hrb" => "哈尔滨", "dq" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
            # "huizhou" => "惠州", "zq" => "肇庆", "zs" => "中山", "jx" => "嘉兴",
            # "gy" => "贵阳", "zunyi" => "遵义", "hu" => "呼和浩特", "xj" => "乌鲁木齐", "deyang" => "德阳",
            # "mianyang" => "绵阳", "xf" => "襄阳", "yc" => "宜昌"
        }
    end
  end

  def tmp_renrenche
    # cities_all = ["深圳","广州","南京","成都","东莞","重庆","苏州","郑州","上海","威海","石家庄","武汉","沈阳","西安青岛","长沙","哈尔滨","长春","杭州","潍坊","厦门","佛山","大连","合肥","天津","绵阳","徐州","无锡","湘潭","株洲","宜昌","肇庆","洛阳 ","济南 ","贵阳 ","南宁 ","福州","咸阳","南阳","惠州","太原","常德","泉州","襄阳","宝鸡","中山","德阳","常州","南通扬州","新乡","烟台 ","嘉兴","大庆","营口呼和浩特","芜湖","唐山","遵义","乌鲁木齐","南昌","岳阳"]
    # 以下是测试数据
    cities_all = ["深圳", "广州", "南京", "成都", "东莞", "重庆", "苏州","上海", "郑州", "威海", "石家庄", "武汉", "沈阳", "西安", "青岛", "长沙", "哈尔滨", "长春", "杭州", "潍坊", "厦门", "佛山", "大连", "合肥", "天津", "绵阳", "徐州", "无锡", "湘潭", "株洲", "宜昌", "肇庆", "洛阳 ", "济南 ", "贵阳 ", "南宁 ", "福州", "咸阳", "南阳", "惠州", "太原", "常德", "泉州", "襄阳", "宝鸡", "中山", "德阳", "常州", "南通", "扬州", "新乡", "烟台", "嘉兴", "大庆", "营口", "呼和浩特", "芜湖", "唐山", "遵义", "乌鲁木齐", "南昌", "岳阳"]
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
    car_user_info.need_update = false
    car_user_info.save!


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
    if car_user_info.site_name != '58'
      UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info
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


    return if car_user_info.site_name == '58' # 58数据先不上传，等待手机端提交过来
    car_user_info = car_user_info.reload
    pp "准备单个上传#{car_user_info.phone}~~#{car_user_info.name}"
    UploadTianTian.upload_one_tt car_user_info
    # 同步至车置宝  车置宝作废
    # UserSystem::ChezhibaoCarUserInfo.create_info_from_car_user_info car_user_info
    #同步至优车
    UserSystem::YoucheCarUserInfo.create_user_info_from_car_user_info car_user_info
  end

  def self.update_58_phone_detail params
    UserSystem::CarUserInfo.transaction do
      car_user_info = UserSystem::CarUserInfo.find params[:id]
      phone = params[:phone]
      phone.gsub!('-', '')
      phone = phone.match(/\d{11}$/).to_s
      car_user_info.phone = phone
      car_user_info.wuba_kouling_shouji_huilai_time = Time.now.chinese_format
      car_user_info.save!

      UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info
      car_user_info = car_user_info.reload
      pp "准备单个上传#{car_user_info.phone}~~#{car_user_info.name}"
      UploadTianTian.upload_one_tt car_user_info
      UserSystem::YoucheCarUserInfo.create_user_info_from_car_user_info car_user_info
    end

  end

  # 车商检验流程
  def self.che_shang_jiao_yan car_user_info
    begin
      UserSystem::CarBusinessUserInfo.add_business_user_info_phone car_user_info
    rescue Exception => e
      pp '更新商家电话号码出错'
      pp e
    end

    #如果在car_business_user中出现，就算作车商
    cbui = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
    unless cbui.blank?
      car_user_info.is_cheshang = 1
      car_user_info.is_real_cheshang = true
      car_user_info.need_update = false
      car_user_info.save!
    end

    is_pachong = UserSystem::CarBusinessUserInfo.is_pachong car_user_info
    if is_pachong
      car_user_info.is_pachong = true
      car_user_info.save!
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

  def self.run_baixing
    begin
      Baixing.get_car_user_list
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
                 "350000" => "福建", "450000" => "广西", "520000" => "贵州", "620000" => "甘肃", "460000" => "海南",
                 "420000" => "湖北", "430000" => "湖南", "230000" => "黑龙江", "360000" => "江西", "220000" => "吉林",
                 "150000" => "内蒙古", "640000" => "宁夏", "630000" => "青海", "610000" => "陕西", "510000" => "四川",
                 "140000" => "山西", "120000" => "天津", "650000" => "新疆", "540000" => "西藏", "530000" => "云南", "34000" => "安徽"}
    # provinces = { "320000" => "江苏"}
    # provinces = {"130000" => "河北"}
    provinces = {"440000" => "广东", "330000" => "浙江", "520000" => "贵州", "150000" => "内蒙古", "650000" => "新疆", "510000" => "四川", "420000" => "湖北"}

    city_hash = {}
    provinces.each_pair do |key, v|
      city_content = RestClient.get("http://m.che168.com/Handler/GetArea.ashx?pid=#{key}")
      pp 'xxx'
      city_content = JSON.parse city_content.body
      pp city_content
      #
      city_content["item"].each do |city|
        areaid, areaname = city["id"], city["value"]

        if ["绵阳", "德阳", "宜昌", "襄阳", "肇庆", "惠州", "中山", "贵阳", "遵义", "嘉兴", "呼和浩特", "乌鲁木齐"].include? areaname
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
    # 2. 根据描述可以判断是车商的， 不再获取手机号      对于58
    # 3. 小城市群分成四个组，再开2台服务器，用于快速抓取数据  对于58
    # 4. 对于赶集， 小城市群分成四个组，再开1台服务器，用于快速抓取数据。  对于赶集
    # 5. 对于百姓， 现在4台机器在跑， 把数据分成6个小组， 每台机器跑一组。 对于百姓
    # 6. 对于百姓， 严格获取车龄和里程
    # 7. 对于整体， 所有手机号过滤一遍，手机号重复率> 10 的， 全部进入车商库。
    # 8. 对于整体， 只要在车商库中存在的，一律不提交
    # 9. 对于没有车龄，里程数据的，一律不提交
    # #

    cities_all = ["深圳", "广州", "南京", "成都", "东莞", "重庆", "苏州","上海", "郑州", "威海", "石家庄", "武汉", "沈阳", "西安", "青岛", "长沙", "哈尔滨", "长春", "杭州", "潍坊", "厦门", "佛山", "大连", "合肥", "天津", "绵阳", "徐州", "无锡", "湘潭", "株洲", "宜昌", "肇庆", "洛阳 ", "济南 ", "贵阳 ", "南宁 ", "福州", "咸阳", "南阳", "惠州", "太原", "常德", "泉州", "襄阳", "宝鸡", "中山", "德阳", "常州", "南通", "扬州", "新乡", "烟台", "嘉兴", "大庆", "营口", "呼和浩特", "芜湖", "唐山", "遵义", "乌鲁木齐", "南昌", "岳阳"]
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    phones = []
    record_number = 0
    a,b,c,d,e,f,g,h,ii,jj = 0,0,0,0,0,0,0,0,0,0
    sheet1 = book.create_worksheet name: "人人车测试数据"
    ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
      sheet1.row(0)[i] = content
    end
    row = 0
    cuis = UserSystem::CarUserInfo.where("id > 910000 and phone is not null")

    cuis.each_with_index do |car_user_info, current_row|
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

      if car_user_info.milage.to_i > 10
        next
      end

      if car_user_info.che_ling.to_i < 2008
        next
      end

      if car_user_info.brand.blank?
        c+=1
        next
      end
      if car_user_info.is_cheshang == 1
        d+=1
        next
      end
      if car_user_info.is_real_cheshang
        e+=1
        next
      end
      if car_user_info.is_pachong
        f += 1
        next
      end
      unless  car_user_info.is_city_match
        g +=1
        next
      end
      unless cities_all.include? car_user_info.city_chinese # 判断城市是否包含
        h += 1
        next
      end

      #最要这个手机号出现过一次，就不导入
      cuis = UserSystem::CarUserInfo.where("id < ? and phone = ?", car_user_info.id, car_user_info.phone)
      if cuis.length > 0
        ii+=1
        next
      end

      jj+=1
      record_number = record_number+1
      row = row+1
      [car_user_info.name.gsub('(个人)', '').gsub('联系TA', '先生女士'), car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|
        sheet1.row(row)[i] = content
      end
    end


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}RenRen信息数据.xls")
    book.write file_path
    file_path
    pp a,b,c,d,e,f,g,h,ii,jj

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