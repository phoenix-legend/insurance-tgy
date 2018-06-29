class UserSystem::CarUserInfo < ActiveRecord::Base
  require 'rest-client'
  require 'redis'
  require 'pp'

  validates_format_of :phone, :with => EricTools::RegularConstants::MobilePhone, message: '手机号格式不正确', allow_blank: true, :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :name, message: '请填写姓名', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :brand, message: '请填写品牌', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }
  validates_presence_of :city_chinese, message: '请填写城市', :if => Proc.new { |cui| cui.site_name == 'zuoxi' }


  # CURRENT_ID = 171550  第一次导入
  CURRENT_ID = 2400000
  GANJIUPLOAD = 'ganjiupload'
  WUBAUPLOAD = 'wubaupload'
  YAOLIUBAUPLOAD = '168upload'
  BAIXINGUPLOAD = 'baixingupload'

  # UserSystem::CarUserInfo::CITY1 + UserSystem::CarUserInfo::CITY2 + UserSystem::CarUserInfo::CITY3



  CITY1 = ['上海', '成都', '杭州', '苏州', '福州', '合肥', "西安", "郑州", "长沙", "常州", "南宁", "济南", "太原", "青岛", "沈阳",
           '深圳', '南京', '广州', '武汉', '佛山', '天津', '东莞', '重庆', '厦门', '北京', "无锡", "宁波", "南昌", "昆明", "温州",
           "威海", "烟台", "潍坊", "兰州", "徐州", "南通", "扬州", "石家庄", "唐山", "洛阳", "南阳", "新乡", "湘潭",
           "株洲", "常德", "岳阳", "大连", "营口", "乌鲁木齐", "泉州", "长春", "哈尔滨", "大庆", "滁州", "芜湖", "惠州",
           "肇庆", "中山", "嘉兴", "贵阳", "呼和浩特", "绵阳", "襄阳", "宜昌", "大同", "临汾", "运城", "滨州", "德州", "东营",
           "济宁", "临沂", "日照", "泰安", "枣庄", "宿迁", "泰州", "盐城", "镇江", "自贡", "淄博", "资阳", "驻马店", "珠海",
           "长治", "漳州", "宜春", "宜宾", "许昌", "邢台", "信阳", "孝感", "台州", "遂宁", "松原", "十堰", "绍兴",
           "汕头", "曲靖", "衢州", "秦皇岛", "齐齐哈尔", "莆田", "内江", "南充", "眉山", "马鞍山", "泸州", "六安", "柳州", "辽阳",
           "乐山", "廊坊", "开封", "荆州", "锦州", "金华", "焦作", "江门", "佳木斯", "吉林", "吉安", "黄石", "淮安", "湖州", "衡水",
           "邯郸", "桂林", "广安", "赣州", "阜阳", "抚顺", "鄂尔多斯", "德阳", "达州", "承德", "沧州", "保定", "包头", "鞍山",
           "安阳", "安庆", "蚌埠", "咸阳", "银川", "菏泽", "铜陵", "黄冈", "连云港",
           "葫芦岛",  "赤峰", "西宁", "绥化", "铁岭","衡阳","张家口","商丘"]
  # CITY2 = ['深圳', '南京', '广州', '武汉', '佛山', '天津', '东莞', '重庆', '厦门', '北京', "无锡", "宁波", "南昌", "昆明", "常熟"]
  CITY2 = []


  # CITY3 = ["威海", "烟台", "潍坊", "兰州", "徐州", "南通", "扬州", "济南", "石家庄", "唐山", "宝鸡", "宿州", "洛阳",
  #          "南阳", "新乡", "湘潭", "株洲", "常德", "岳阳", "沈阳", "大连", "营口", "乌鲁木齐", "泉州", "长春", "哈尔滨", "大庆", "滁州", "芜湖", "惠州", "肇庆",
  #          "中山", "嘉兴", "贵阳", "遵义", "呼和浩特", "绵阳", "襄阳", "宜昌", "大同", "晋中", "临汾", "运城", "滨州", "德州", "东营", "济宁", "临沂", "日照", "泰安", "枣庄",
  #          "宿迁", "泰州", "盐城", "镇江", "自贡", "淄博", "资阳", "驻马店", "珠海", "长治", "漳州", "张家口", "玉林", "益阳", "义乌", "宜春", "宜宾", "延边", "雅安",
  #          "许昌", "邢台", "信阳", "孝感", "咸宁", "温州", "通辽", "铁岭", "台州", "遂宁", "随州", "松原", "四平", "十堰", "绍兴", "上饶", "商丘", "汕头", "三明", "曲靖", "衢州",
  #          "秦皇岛", "钦州", "齐齐哈尔", "莆田", "平顶山", "攀枝花", "宁德", "内江", "南充", "牡丹江", "眉山", "马鞍山", "漯河", "泸州", "龙岩", "六盘水", "六安", "柳州", "辽阳",
  #          "连云港", "乐山", "廊坊", "开封", "九江", "景德镇", "荆州", "荆门", "锦州", "金华", "焦作", "江门", "佳木斯", "吉林", "吉安", "黄石", "淮安", "湖州", "衡水",
  #          "邯郸", "桂林", "广元", "广安", "赣州", "阜阳", "抚州", "抚顺", "福州", "恩施", "鄂尔多斯", "德阳", "大理", "达州", "楚雄", "赤峰", "承德", "沧州", "北海", "保定",
  #          "包头", "百色", "巴中", "鞍山", "安阳", "安庆", "红河", "蚌埠", "丽水", "咸阳", "银川", "西宁", "菏泽", "铜陵", "黄冈", "鄂州", "阳泉"]

  #给city3瘦身, 清理多余城市, 减少44个城市
  CITY3 = []

  def self.get_city_hash all_hash, city_names
    new_hash = {}
    city_names.each do |city_name|
      code = all_hash.invert[city_name]
      next if code.blank?
      new_hash[code] = city_name
    end
    new_hash
  end


  EMAIL_STATUS = {0 => '待导', 1 => '已导', 2 => '不导入'}
  ALL_CITY = {
      # "310100" => "上海", "510100" => "成都", "440300" => "深圳", "320100" => "南京", "440100" => "广州", "420100" => "武汉",
      #         "120100" => "天津", "320500" => "苏州", "330100" => "杭州", "441900" => "东莞", "500100" => "重庆", "320200" => "无锡",
      #         "410100" => "郑州", "430100" => "长沙", "610100" => "西安", "370200" => "青岛", "440600" => "佛山", "371000" => '威海',
      #         "370600" => '烟台', "370700" => '潍坊', "320400" => '常州', "320300" => '徐州', "320600" => '南通', "321000" => '扬州',
      #         "370100" => "济南", "341300" => "宿州", "130100" => "石家庄", "130200" => "唐山", "140100" => "太原", "610400" => "咸阳", "610300" => "宝鸡", "410300" => "洛阳",
      #         "411300" => "南阳", "410700" => "新乡", "110100" => "北京", "430300" => "湘潭", "430200" => "株洲", "430700" => "常德", "430600" => "岳阳", "210100" => "沈阳", "210200" => "大连", "210800" => "营口",
      #         "350200" => "厦门", "350500" => "泉州", "220100" => "长春", "230100" => "哈尔滨", "230600" => "大庆", "340100" => "合肥",
      #         "340200" => "芜湖", "450100" => "南宁", "360100" => "南昌", "441300" => "惠州", "441200" => "肇庆", "442000" => "中山", "330400" => "嘉兴", "520100" => "贵阳", "520300" => "遵义",
      #         "150100" => "呼和浩特", "650100" => "乌鲁木齐", "510600" => "德阳", "510700" => "绵阳", "420600" => "襄阳", "420500" => "宜昌",
      #         "140200" => "大同", "140700" => "晋中", "141000" => "临汾", "140800" => "运城", "620100" => "兰州",
      #         "371600" => "滨州", "371400" => "德州", "370500" => "东营", "370800" => "济宁", "371300" => "临沂", "371100" => "日照",
      #         "370900" => "泰安", "370400" => "枣庄", "330200" => "宁波", "321300" => "宿迁", "321200" => "泰州", "320900" => "盐城", "321100" => "镇江",
      #         # 最后一大波，逐批开放，
      #         "440700" => "江门", "440500" => "汕头", "440400" => "珠海", "370300" => "淄博", "330500" => "湖州", "330700" => "金华",
      #         "331100" => "丽水", "330800" => "衢州", "330600" => "绍兴", "331000" => "台州", "330300" => "温州", "320800" => "淮安",
      #         "320700" => "连云港", "320900" => "盐城", "130600" => "保定",
      #         "130800" => "承德", "130900" => "沧州", "131100" => "衡水", "130400" => "邯郸", "131000" => "廊坊", "130300" => "秦皇岛",
      #         "130500" => "邢台", "130700" => "张家口", "410500" => "安阳", "410800" => "焦作", "410200" => "开封", "411100" => "漯河",
      #         "410400" => "平顶山", "411400" => "商丘", "411500" => "信阳",
      #         "411000" => "许昌", "411700" => "驻马店", "210300" => "鞍山", "210400" => "抚顺", "210700" => "锦州", "211000" => "辽阳",
      #         "211200" => "铁岭", "350100" => "福州", "350800" => "龙岩", "350900" => "宁德", "350300" => "莆田", "350400" => "三明",
      #         "350600" => "漳州", "450500" => "北海", "451000" => "百色",
      #         "450300" => "桂林", "450200" => "柳州", "450700" => "钦州", "450900" => "玉林", "520200" => "六盘水", "422800" => "恩施",
      #         "420200" => "黄石", "421000" => "荆州", "420800" => "荆门", "421300" => "随州", "420300" => "十堰", "421200" => "咸宁",
      #         "420900" => "孝感", "430900" => "益阳", "230800" => "佳木斯",
      #         "231000" => "牡丹江", "230200" => "齐齐哈尔", "361000" => "抚州", "360700" => "赣州", "360800" => "吉安", "360400" => "九江",
      #         "360200" => "景德镇", "361100" => "上饶", "360900" => "宜春", "220200" => "吉林", "220700" => "松原", "220300" => "四平",
      #         "222400" => "延边", "150200" => "包头", "150400" => "赤峰",
      #         "150600" => "鄂尔多斯", "150100" => "呼和浩特", "150500" => "通辽", "511900" => "巴中", "510600" => "德阳", "511700" => "达州",
      #         "511600" => "广安", "510800" => "广元", "510500" => "泸州", "511100" => "乐山", "511400" => "眉山", "511300" => "南充", "511000" => "内江", "510400" => "攀枝花", "510900" => "遂宁",
      #         "511800" => "雅安", "511500" => "宜宾", "512000" => "资阳", "510300" => "自贡", "140400" => "长治", "532300" => "楚雄",
      #         "532900" => "大理", "532500" => "红河", "530100" => "昆明", "530300" => "曲靖", "340800" => "安庆", "340300" => "蚌埠",
      #         "341200" => "阜阳", "341500" => "六安", "340500" => "马鞍山", "371700" => "菏泽", "420700" => "鄂州", "421100" => "黄冈", "640100" => "银川", "630100" => "西宁", "140300" => "阳泉", "340700" => "铜陵",
      #         "341100" => "滁州"

      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州",
      "dongguan" => "东莞", "chongqing" => "重庆", "lanzhou" => "兰州", "sz" => "宿州",
      "zhengzhou" => '郑州', 'changsha' => '长沙', 'xian' => '西安',
      "qingdao" => "青岛", "weihai" => '威海', "yantai" => '烟台', "weifang" => '潍坊', "wuxi" => "无锡",
      "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jinan" => "济南",
      "shijiazhuang" => "石家庄", "tangshan" => "唐山", "taiyuan" => "太原", "baoji" => "宝鸡", "foshan" => '佛山', "beijing" => "北京",
      "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",
      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
      "shenyang" => "沈阳", "dalian" => "大连", "yingkou" => "营口",
      "quanzhou" => "泉州", "changchun" => "长春", "haerbin" => "哈尔滨", "daqing" => "大庆", "hefei" => "合肥", "wuhu" => "芜湖", "nanning" => "南宁", "nanchang" => "南昌",
      "fuzhou" => "福州", "xiamen" => "厦门",
      "datong" => "大同", "jinzhong" => "晋中", "linfen" => "临汾", "yuncheng" => "运城",
      "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴", "guiyang" => "贵阳",
      "zunyi" => "遵义", #
      "huhehaote" => "呼和浩特", "wulumuqi" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xiangfan" => "襄阳", "yichang" => "宜昌",
      "binzhou" => "滨州", "dezhou" => "德州", "dongying" => "东营", "jining" => "济宁", "linyi" => "临沂", "rizhao" => "日照", "taian" => "泰安", "zaozhuang" => "枣庄", "ningbo" => "宁波", "suqian" => "宿迁", "taizhou" => "泰州", "yancheng" => "盐城", "zhenjiang" => "镇江",

      # 最后一大波，逐批开放，
      "zigong" => "自贡", "zibo" => "淄博", "ziyang" => "资阳", "zhumadian" => "驻马店", "zhuhai" => "珠海", "changzhi" => "长治", "zhangzhou" => "漳州", "zhangjiakou" => "张家口", "yulin" => "玉林", "yiyang" => "益阳", "yichun" => "宜春", "yibin" => "宜宾", "yancheng" => "盐城", "yanbian" => "延边",
      "yaan" => "雅安", "xuchang" => "许昌", "xingtai" => "邢台", "xinyang" => "信阳", "xiaogan" => "孝感", "xianning" => "咸宁", "wenzhou" => "温州", "tongliao" => "通辽", "tieling" => "铁岭", "tz" => "台州", "suining" => "遂宁", "suizhou" => "随州", "songyuan" => "松原", "siping" => "四平", "shiyan" => "十堰",
      "shaoxing" => "绍兴", "shangrao" => "上饶", "shangqiu" => "商丘", "shantou" => "汕头", "sanming" => "三明", "qujing" => "曲靖", "quzhou" => "衢州", "qinhuangdao" => "秦皇岛", "qinzhou" => "钦州", "qiqihaer" => "齐齐哈尔", "putian" => "莆田", "pingdingshan" => "平顶山", "panzhihua" => "攀枝花", "ningde" => "宁德",
      "neijiang" => "内江", "nanchong" => "南充", "mudanjiang" => "牡丹江", "meishan" => "眉山",
      "maanshan" => "马鞍山", "luohe" => "漯河", "luzhou" => "泸州", "longyan" => "龙岩", "liupanshui" => "六盘水", "luan" => "六安", "liuzhou" => "柳州", "liaoyang" => "辽阳", "lianyungang" => "连云港", "leshan" => "乐山",
      "langfang" => "廊坊", "kunming" => "昆明", "kaifeng" => "开封", "jiujiang" => "九江", "jingdezhen" => "景德镇", "jingzhou" => "荆州", "jingmen" => "荆门", "jinzhou" => "锦州", "jinhua" => "金华", "jiaozuo" => "焦作", "jiangmen" => "江门", "jiamusi" => "佳木斯", "jilin" => "吉林", "jian" => "吉安", "huangshi" => "黄石",
      "huaian" => "淮安", "huzhou" => "湖州", "huhehaote" => "呼和浩特", "hengshui" => "衡水", "handan" => "邯郸", "guilin" => "桂林", "guangyuan" => "广元", "guangan" => "广安", "ganzhou" => "赣州", "fuyang" => "阜阳", "jxfz" => "抚州", "fushun" => "抚顺", "fuzhou" => "福州", "enshi" => "恩施", "eerduosi" => "鄂尔多斯",
      "deyang" => "德阳", "dali" => "大理", "dazhou" => "达州", "chuxiong" => "楚雄", "chifeng" => "赤峰", "chengde" => "承德", "cangzhou" => "沧州", "beihai" => "北海", "baoding" => "保定", "baotou" => "包头", "baise" => "百色", "bazhong" => "巴中", "anshan" => "鞍山", "anyang" => "安阳", "anqing" => "安庆", "honghe" => "红河",
      "bengbu" => "蚌埠", "lishui" => "丽水",
      "xianyang" => "咸阳",
      "yinchuan" => "银川",
      "xining" => "西宁",
      "heze" => "菏泽",
      "tongling" => "铜陵",
      "huanggang" => "黄冈",
      "ezhou" => "鄂州",
      "yangquan" => "阳泉"
  }


  def self.get_che168_sub_cities sub_party = 0
    case sub_party
      when 0
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::ALL_CITY, UserSystem::CarUserInfo::CITY1
      when 1
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::ALL_CITY, UserSystem::CarUserInfo::CITY2
      else
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::ALL_CITY, UserSystem::CarUserInfo::CITY3
    end
  end


  #城市所对应的拼音。 主要用于从淘车网更新数据。
  # 淘车
  # PINYIN_CITY_RENREN_ALL = {
  PINYIN_CITY = {
      "shanghai" => "上海", "chengdu" => "成都", "shenzhen" => "深圳", "nanjing" => "南京",
      "guangzhou" => "广州", "wuhan" => "武汉", "tianjin" => "天津", "suzhou" => "苏州", "hangzhou" => "杭州",
      "dongguan" => "东莞", "chongqing" => "重庆", "lanzhou" => "兰州", "sz" => "宿州",
      "zhengzhou" => '郑州', 'changsha' => '长沙', 'xian' => '西安',
      "qingdao" => "青岛", "weihai" => '威海', "yantai" => '烟台', "weifang" => '潍坊', "wuxi" => "无锡",
      "changzhou" => "常州", "xuzhou" => '徐州', "nantong" => '南通', "yangzhou" => '扬州', "jinan" => "济南",
      "shijiazhuang" => "石家庄", "tangshan" => "唐山", "taiyuan" => "太原", "baoji" => "宝鸡", "foshan" => '佛山', "beijing" => "北京",
      "luoyang" => "洛阳", "nanyang" => "南阳", "xinxiang" => "新乡",
      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yueyang" => "岳阳",
      "shenyang" => "沈阳", "dalian" => "大连", "yingkou" => "营口",
      "quanzhou" => "泉州", "changchun" => "长春", "haerbin" => "哈尔滨", "daqing" => "大庆", "hefei" => "合肥", "wuhu" => "芜湖", "nanning" => "南宁", "nanchang" => "南昌",
      "fuzhou" => "福州", "xiamen" => "厦门",
      "datong" => "大同", "jinzhong" => "晋中", "linfen" => "临汾", "yuncheng" => "运城",
      "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴", "guiyang" => "贵阳",
      "zunyi" => "遵义", #
      "huhehaote" => "呼和浩特", "wulumuqi" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xiangfan" => "襄阳", "yichang" => "宜昌",
      "binzhou" => "滨州", "dezhou" => "德州", "dongying" => "东营", "jining" => "济宁", "linyi" => "临沂", "rizhao" => "日照", "taian" => "泰安", "zaozhuang" => "枣庄", "ningbo" => "宁波", "suqian" => "宿迁", "taizhou" => "泰州", "yancheng" => "盐城", "zhenjiang" => "镇江",

      # 最后一大波，逐批开放，
      "zigong" => "自贡", "zibo" => "淄博", "ziyang" => "资阳", "zhumadian" => "驻马店", "zhuhai" => "珠海", "changzhi" => "长治", "zhangzhou" => "漳州", "zhangjiakou" => "张家口", "yulin" => "玉林", "yiyang" => "益阳", "yichun" => "宜春", "yibin" => "宜宾", "yancheng" => "盐城", "yanbian" => "延边",
      "yaan" => "雅安", "xuchang" => "许昌", "xingtai" => "邢台", "xinyang" => "信阳", "xiaogan" => "孝感", "xianning" => "咸宁", "wenzhou" => "温州", "tongliao" => "通辽", "tieling" => "铁岭", "tz" => "台州", "suining" => "遂宁", "suizhou" => "随州", "songyuan" => "松原", "siping" => "四平", "shiyan" => "十堰",
      "shaoxing" => "绍兴", "shangrao" => "上饶", "shangqiu" => "商丘", "shantou" => "汕头", "sanming" => "三明", "qujing" => "曲靖", "quzhou" => "衢州", "qinhuangdao" => "秦皇岛", "qinzhou" => "钦州", "qiqihaer" => "齐齐哈尔", "putian" => "莆田", "pingdingshan" => "平顶山", "panzhihua" => "攀枝花", "ningde" => "宁德",
      "neijiang" => "内江", "nanchong" => "南充", "mudanjiang" => "牡丹江", "meishan" => "眉山",
      "maanshan" => "马鞍山", "luohe" => "漯河", "luzhou" => "泸州", "longyan" => "龙岩", "liupanshui" => "六盘水", "luan" => "六安", "liuzhou" => "柳州", "liaoyang" => "辽阳", "lianyungang" => "连云港", "leshan" => "乐山",
      "langfang" => "廊坊", "kunming" => "昆明", "kaifeng" => "开封", "jiujiang" => "九江", "jingdezhen" => "景德镇", "jingzhou" => "荆州", "jingmen" => "荆门", "jinzhou" => "锦州", "jinhua" => "金华", "jiaozuo" => "焦作", "jiangmen" => "江门", "jiamusi" => "佳木斯", "jilin" => "吉林", "jian" => "吉安", "huangshi" => "黄石",
      "huaian" => "淮安", "huzhou" => "湖州", "huhehaote" => "呼和浩特", "hengshui" => "衡水", "handan" => "邯郸", "guilin" => "桂林", "guangyuan" => "广元", "guangan" => "广安", "ganzhou" => "赣州", "fuyang" => "阜阳", "jxfz" => "抚州", "fushun" => "抚顺", "fuzhou" => "福州", "enshi" => "恩施", "eerduosi" => "鄂尔多斯",
      "deyang" => "德阳", "dali" => "大理", "dazhou" => "达州", "chuxiong" => "楚雄", "chifeng" => "赤峰", "chengde" => "承德", "cangzhou" => "沧州", "beihai" => "北海", "baoding" => "保定", "baotou" => "包头", "baise" => "百色", "bazhong" => "巴中", "anshan" => "鞍山", "anyang" => "安阳", "anqing" => "安庆", "honghe" => "红河",
      "bengbu" => "蚌埠", "lishui" => "丽水",
      "xianyang" => "咸阳",
      "yinchuan" => "银川",
      "xining" => "西宁",
      "heze" => "菏泽",
      "tongling" => "铜陵",
      "huanggang" => "黄冈",
      "ezhou" => "鄂州",
      "yangquan" => "阳泉"
  }


  IMPRTANT_CITY = ["上海", "成都", "深圳", "南京", "广州", "武汉", "天津", "苏州", "杭州", "佛山", "东莞", "重庆", "北京", "福州", "厦门", "合肥"]


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
      "shenyang" => "沈阳", "dalian" => "大连", "yingkou" => "营口", "sz" => "宿州",
      "fuzhou" => "福州", "xiamen" => "厦门", "quanzhou" => "泉州",
      "changchun" => "长春", "haerbin" => "哈尔滨", "daqing" => "大庆", "hefei" => "合肥", "wuhu" => "芜湖", "nanning" => "南宁", "nanchang" => "南昌",
      "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴",
      "guiyang" => "贵阳", "zunyi" => "遵义", "huhehaote" => "呼和浩特", "wulumuqi" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xiangfan" => "襄阳", "yichang" => "宜昌", "beijing" => "北京",
      "datong" => "大同", "jinzhong" => "晋中", "linfen" => "临汾", "yuncheng" => "运城",
      "lanzhou" => "兰州", "changshu" => "常熟",
      "binzhou" => "滨州", "dezhou" => "德州", "dongying" => "东营", "jining" => "济宁", "linyi" => "临沂", "rizhao" => "日照", "taian" => "泰安", "zaozhuang" => "枣庄", "ningbo" => "宁波", "suqian" => "宿迁", "tz" => "泰州", "yancheng" => "盐城", "zhenjiang" => "镇江",


      "zigong" => "自贡", "zibo" => "淄博", "ziyang" => "资阳", "zhumadian" => "驻马店", "zhuhai" => "珠海", "changzhi" => "长治", "zhangzhou" => "漳州", "zhangjiakou" => "张家口", "yl" => "玉林", "yiyang" => "益阳", "yc" => "宜春", "yibin" => "宜宾", "yancheng" => "盐城", "yanbian" => "延边", "yaan" => "雅安",
      "xuchang" => "许昌", "xingtai" => "邢台", "xinyang" => "信阳", "xiaogan" => "孝感", "xianning" => "咸宁", "wenzhou" => "温州", "tongliao" => "通辽", "tieling" => "铁岭", "taizhou" => "台州", "suining" => "遂宁", "suizhou" => "随州", "songyuan" => "松原", "siping" => "四平", "shiyan" => "十堰",
      "shaoxing" => "绍兴", "shangrao" => "上饶", "shangqiu" => "商丘", "shantou" => "汕头", "sanming" => "三明", "qujing" => "曲靖", "quzhou" => "衢州", "qinhuangdao" => "秦皇岛", "qinzhou" => "钦州", "qiqihaer" => "齐齐哈尔", "putian" => "莆田", "pingdingshan" => "平顶山", "panzhihua" => "攀枝花",
      "ningde" => "宁德", "neijiang" => "内江", "nanchong" => "南充", "mudanjiang" => "牡丹江", "meishan" => "眉山", "maanshan" => "马鞍山", "luohe" => "漯河", "luzhou" => "泸州", "longyan" => "龙岩", "liupanshui" => "六盘水", "luan" => "六安", "liuzhou" => "柳州", "liaoyang" => "辽阳", "lianyungang" => "连云港",
      "leshan" => "乐山", "langfang" => "廊坊", "kunming" => "昆明", "kaifeng" => "开封", "jiujiang" => "九江", "jingdezhen" => "景德镇", "jingzhou" => "荆州", "jingmen" => "荆门", "jinzhou" => "锦州", "jinhua" => "金华", "jiaozuo" => "焦作", "jiangmen" => "江门", "jiamusi" => "佳木斯", "jilin" => "吉林",
      "jian" => "吉安", "huangshi" => "黄石", "huaian" => "淮安", "huzhou" => "湖州", "huhehaote" => "呼和浩特", "hengshui" => "衡水", "handan" => "邯郸", "guilin" => "桂林", "guangyuan" => "广元", "guangan" => "广安", "ganzhou" => "赣州", "fuyang" => "阜阳", "fz" => "抚州", "fushun" => "抚顺",
      "fuzhou" => "福州", "enshi" => "恩施", "eerduosi" => "鄂尔多斯", "deyang" => "德阳", "dali" => "大理", "dazhou" => "达州", "chuxiong" => "楚雄", "chifeng" => "赤峰", "chengde" => "承德", "cangzhou" => "沧州", "beihai" => "北海", "baoding" => "保定", "baotou" => "包头", "bose" => "百色", "bazhong" => "巴中",
      "anshan" => "鞍山", "anyang" => "安阳", "anqing" => "安庆", "honghe" => "红河", "bengbu" => "蚌埠", "lishui" => "丽水",
      "xianyang" => "咸阳",
      "yinchuan" => "银川",
      "xining" => "西宁",
      "heze" => "菏泽",
      "tongling" => "铜陵",
      "huanggang" => "黄冈",
      "ezhou" => "鄂州",
      "yangquan" => "阳泉", "滁州" => "chuzhou"

  }


  def self.get_baixing_sub_cities sub_party = 0
    case sub_party
      when 0
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::BAIXING_PINYIN_CITY, UserSystem::CarUserInfo::CITY1
      when 1
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::BAIXING_PINYIN_CITY, UserSystem::CarUserInfo::CITY2
      else
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::BAIXING_PINYIN_CITY, UserSystem::CarUserInfo::CITY3
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
      "sy" => "沈阳", "dl" => "大连", "yingkou" => "营口", "changshu" => "常熟",
      "fz" => "福州", "xm" => "厦门", "quanzhou" => "泉州", "ahsuzhou" => "宿州",
      "cc" => "长春", "hrb" => "哈尔滨", "daqing" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
      "huizhou" => "惠州", "zhaoqing" => "肇庆", "zhongshan" => "中山", "jiaxing" => "嘉兴",
      "gy" => "贵阳", "zunyi" => "遵义", "nmg" => "呼和浩特", "xj" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xiangyang" => "襄阳", "yichang" => "宜昌", "bj" => "北京",
      "datong" => "大同", "jinzhong" => "晋中", "linfen" => "临汾", "yuncheng" => "运城", "lz" => "兰州",
      "binzhou" => "滨州", "dezhou" => "德州", "dongying" => "东营", "jining" => "济宁", "linyi" => "临沂", "rizhao" => "日照", "taian" => "泰安", "zaozhuang" => "枣庄", "nb" => "宁波", "suqian" => "宿迁", "jstaizhou" => "泰州", "yancheng" => "盐城", "zhenjiang" => "镇江",

      "zigong" => "自贡", "zibo" => "淄博", "ziyang" => "资阳", "zhumadian" => "驻马店", "zhuhai" => "珠海", "changzhi" => "长治", "zhangzhou" => "漳州", "zhangjiakou" => "张家口", "gxyulin" => "玉林", "yiyang" => "益阳", "yiwu" => "义乌", "jxyichun" => "宜春", "yibin" => "宜宾", "yancheng" => "盐城",
      "yanbian" => "延边", "yaan" => "雅安", "xuchang" => "许昌", "xingtai" => "邢台", "xinyang" => "信阳", "xiaogan" => "孝感", "xianning" => "咸宁", "wenzhou" => "温州", "tongliao" => "通辽", "tieling" => "铁岭", "zjtaizhou" => "台州", "suining" => "遂宁", "suizhou" => "随州", "songyuan" => "松原",
      "siping" => "四平", "shiyan" => "十堰", "shaoxing" => "绍兴", "shangrao" => "上饶", "shangqiu" => "商丘", "shantou" => "汕头", "sanming" => "三明", "qujing" => "曲靖", "quzhou" => "衢州", "qinhuangdao" => "秦皇岛", "qinzhou" => "钦州", "qiqihaer" => "齐齐哈尔", "putian" => "莆田", "pingdingshan" => "平顶山",
      "panzhihua" => "攀枝花", "ningde" => "宁德", "neijiang" => "内江", "nanchong" => "南充", "mudanjiang" => "牡丹江", "meishan" => "眉山", "maanshan" => "马鞍山", "luohe" => "漯河", "luzhou" => "泸州", "longyan" => "龙岩", "liupanshui" => "六盘水", "luan" => "六安", "liuzhou" => "柳州", "liaoyang" => "辽阳",
      "lianyungang" => "连云港", "leshan" => "乐山", "langfang" => "廊坊", "km" => "昆明", "kaifeng" => "开封", "jiujiang" => "九江", "jingdezhen" => "景德镇", "jingzhou" => "荆州", "jingmen" => "荆门", "jinzhou" => "锦州", "jinhua" => "金华", "jiaozuo" => "焦作", "jiangmen" => "江门", "jiamusi" => "佳木斯",
      "jilin" => "吉林", "jian" => "吉安", "huangshi" => "黄石", "huaian" => "淮安", "huzhou" => "湖州", "nmg" => "呼和浩特", "hengshui" => "衡水", "handan" => "邯郸", "gl" => "桂林", "guangyuan" => "广元", "guangan" => "广安", "ganzhou" => "赣州", "fuyang" => "阜阳", "jxfuzhou" => "抚州", "fushun" => "抚顺",
      "fz" => "福州", "enshi" => "恩施", "eerduosi" => "鄂尔多斯", "deyang" => "德阳", "dali" => "大理", "dazhou" => "达州", "chuxiong" => "楚雄", "chifeng" => "赤峰", "chengde" => "承德", "cangzhou" => "沧州", "beihai" => "北海", "baoding" => "保定", "baotou" => "包头", "baise" => "百色", "bazhong" => "巴中",
      "anshan" => "鞍山", "anyang" => "安阳", "anqing" => "安庆", "honghe" => "红河", "bengbu" => "蚌埠", "lishui" => "丽水",
      "xianyang" => "咸阳",
      "yc" => "银川",
      "xn" => "西宁",
      "heze" => "菏泽", "滁州" => "chuzhou",
      "tongling" => "铜陵",
      "huanggang" => "黄冈",
      "ezhou" => "鄂州",
      "yangquan" => "阳泉"
  }


  GANJI_CITY_API = {
      '上海' => '100', '北京' => '0', '成都' => '500', "深圳" => '401', '南京' => '900',
      "广州" => '400', "武汉" => '2500', "天津" => '200', "苏州" => '901', "杭州" => '600',
      "东莞" => '402', "重庆" => '300', "无锡" => '902', '佛山' => '405',
      '郑州' => '1200', '长沙' => '2600', '西安' => '2300', '青岛' => '1501', '镇江' => '910',
      '威海' => '1502', '烟台' => '1506', '潍坊' => '1507',
      "常州" => '904', '徐州' => '903', '南通' => '905', '扬州' => '906', "济南" => '1500',
      "石家庄" => '1100', "唐山" => '1101', "太原" => '2000', "福州" => '1000', "合肥" => '1600',
      "南宁" => "1700", "沈阳" => '800', '厦门' => '1001', "宁波" => "601", "南昌" => "2700",
      "昆明" => '2800', "温州" => '602', "兰州" => "2200", "洛阳" => "1201", "南阳" => "1207",
      "新乡" => "1205", "湘潭" => "2602", "珠州" => "2601", "常德" => "2606", "岳阳" => "2605",
      "大连" => "801", "营口" => "806", "乌鲁木齐" => "2900", "泉州" => "1004", "长春" => "1300",
      "哈尔滨" => "1400", "大庆" => "1405", "滁州" => "1605", "芜湖" => "1601", "惠州" => "408",
      "肇庆" => "412", "中山" => "407", "嘉兴" => "603",
      "贵阳" => "700", "呼和浩特" => "1900", "绵阳" => "504", "襄阳" => "2502", "宜昌" => "2505",
      "大同" => "2001", "临汾" => "2009", "运城" => "2007",
      "滨州" => "1509", "德州" => "1514", "东营" => "1505", "济宁" => "1510",
      "临沂" => "1513", "日照" => '1512', "泰安" => '1511', "枣庄" => '1504', "宿迁" => '912', "泰州" => '911', "盐城" => '908',
      "自贡" => '501', "淄博" => '1503', "资阳" => '518', "驻马店" => '1217', "珠海" => '403', "长治" => '2003', "漳州" => '1005',
      "宜春" => '2710', "宜宾" => '509', "许昌" => '1212', "邢台" => '1103', "信阳" => '1215',
      "孝感" => '2510', "台州" => '609', "遂宁" => '512', "松原" => '1306', "十堰" => '2503', "绍兴" => '605',
      "汕头" => '404', "曲靖" => '2801', "衢州" => '607', "秦皇岛" => '1109', "齐齐哈尔" => '1401', "内江" => '513',
      "南充" => '505', "眉山" => '515', "马鞍山" => '1603', "泸州" => '502', "六安" => '1609', "柳州" => "1702",
      "辽阳" => "807", "乐山" => '507', "廊坊" => '1108', "开封" => '1210', "荆州" => '2506', "锦州" => '805', "金华" => '606',
      "焦作" => '1203', "江门" => '406', "佳木斯" => '1407', "吉林" => '1301', "吉安" => '2708', "黄石" => '2501', "淮安" => '907',
      "湖州" => '604', "衡水" => '1110', "邯郸" => '1102', "桂林" => '1701', "广安" => '514', "赣州" => '2706',
      "阜阳" => '1606', "抚顺" => '803', "鄂尔多斯" => '1905', "德阳" => '503', "达州" => '508', "承德" => '1106',
      "沧州" => '1107', "保定" => '1104', "包头" => '1901', "鞍山" => '802', "安阳" => '1206', "安庆" => '1604', "蚌埠" => '1602',
      "咸阳" => '2303', "银川" => '2100', "菏泽" => '1516', "铜陵" => '1612', "黄冈" => '2511', "连云港" => '906'
  }


  def self.get_ganji_sub_cities sub_party = 0, cities = []
    cities = nil if cities.blank?
    case sub_party
      when 0
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::GANJI_CITY, cities||UserSystem::CarUserInfo::CITY1
      when 1
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::GANJI_CITY, cities||UserSystem::CarUserInfo::CITY2
      else
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::GANJI_CITY, cities||UserSystem::CarUserInfo::CITY3
    end
  end


  WUBA_CITY = {
      "sh" => '上海', "cd" => '成都', "sz" => "深圳", 'nj' => '南京', "gz" => "广州", "wh" => "武汉", "fs" => '佛山',
      "tj" => "天津", "su" => "苏州", "hz" => "杭州", "dg" => "东莞", "wx" => "无锡", "cq" => "重庆",
      'zz' => '郑州', 'cs' => '长沙', 'xa' => '西安', 'qd' => '青岛', 'zj' => '镇江', "weihai" => '威海', "yt" => '烟台', "wf" => '潍坊',
      "cz" => "常州", 'xz' => '徐州', "nt" => '南通', "yz" => '扬州', "jn" => "济南", "sjz" => "石家庄", "ts" => "唐山", "ty" => "太原",
      "xianyang" => "咸阳", "baoji" => "宝鸡", "luoyang" => "洛阳", "ny" => "南阳", "xx" => "新乡",
      "xiangtan" => "湘潭", "zhuzhou" => "株洲", "changde" => "常德", "yy" => "岳阳",
      "sy" => "沈阳", "dl" => "大连", "yk" => "营口", "bj" => "北京",
      "fz" => "福州", "xm" => "厦门", "qz" => "泉州", "suzhou" => "宿州",
      "cc" => "长春", "hrb" => "哈尔滨", "dq" => "大庆", "hf" => "合肥", "wuhu" => "芜湖", "nn" => "南宁", "nc" => "南昌",
      "huizhou" => "惠州", "zq" => "肇庆", "zs" => "中山", "jx" => "嘉兴",
      "gy" => "贵阳", "zunyi" => "遵义", "hu" => "呼和浩特", "xj" => "乌鲁木齐", "deyang" => "德阳",
      "mianyang" => "绵阳", "xf" => "襄阳", "yc" => "宜昌",
      "dt" => "大同", "jz" => "晋中", "linfen" => "临汾", "yuncheng" => "运城", "lz" => "兰州",
      "bz" => "滨州", "dz" => "德州", "dy" => "东营", "jining" => "济宁", "linyi" => "临沂", "rizhao" => "日照", "ta" => "泰安", "zaozhuang" => "枣庄", "nb" => "宁波", "suqian" => "宿迁", "taizhou" => "泰州", "yancheng" => "盐城", "zj" => "镇江",

      "zg" => "自贡", "zb" => "淄博", "zy" => "资阳", "zmd" => "驻马店", "zh" => "珠海", "changzhi" => "长治", "zhangzhou" => "漳州", "zjk" => "张家口", "yulin" => "玉林", "yiyang" => "益阳", "yiwu" => "义乌", "yichun" => "宜春", "yb" => "宜宾", "yancheng" => "盐城",
      "yanbian" => "延边", "ya" => "雅安", "xc" => "许昌", "xt" => "邢台", "xy" => "信阳", "xiaogan" => "孝感", "xianning" => "咸宁", "wz" => "温州", "tongliao" => "通辽", "tl" => "铁岭", "tz" => "台州", "suining" => "遂宁", "suizhou" => "随州", "songyuan" => "松原",
      "sp" => "四平", "shiyan" => "十堰", "sx" => "绍兴", "sr" => "上饶", "sq" => "商丘", "st" => "汕头", "sm" => "三明", "qj" => "曲靖", "quzhou" => "衢州", "qhd" => "秦皇岛", "qinzhou" => "钦州", "qqhr" => "齐齐哈尔", "pt" => "莆田", "pds" => "平顶山", "panzhihua" => "攀枝花",
      "nd" => "宁德", "scnj" => "内江", "nanchong" => "南充", "mdj" => "牡丹江", "ms" => "眉山", "mas" => "马鞍山", "luohe" => "漯河", "luzhou" => "泸州", "ly" => "龙岩", "lps" => "六盘水", "la" => "六安", "liuzhou" => "柳州", "liaoyang" => "辽阳", "lyg" => "连云港", "ls" => "乐山",
      "lf" => "廊坊", "km" => "昆明", "kaifeng" => "开封", "jj" => "九江", "jdz" => "景德镇", "jingzhou" => "荆州", "jingmen" => "荆门", "jinzhou" => "锦州", "jh" => "金华", "jiaozuo" => "焦作", "jm" => "江门", "jms" => "佳木斯", "jl" => "吉林", "ja" => "吉安", "hshi" => "黄石",
      "ha" => "淮安", "huzhou" => "湖州", "hu" => "呼和浩特", "hs" => "衡水", "hd" => "邯郸", "gl" => "桂林", "guangyuan" => "广元", "ga" => "广安", "ganzhou" => "赣州", "fy" => "阜阳", "fuzhou" => "抚州", "fushun" => "抚顺", "fz" => "福州", "es" => "恩施", "erds" => "鄂尔多斯",
      "deyang" => "德阳", "dali" => "大理", "dazhou" => "达州", "cx" => "楚雄", "chifeng" => "赤峰", "chengde" => "承德", "cangzhou" => "沧州", "bh" => "北海", "bd" => "保定", "bt" => "包头", "baise" => "百色", "bazhong" => "巴中", "as" => "鞍山", "ay" => "安阳", "anqing" => "安庆",
      "honghe" => "红河", "bengbu" => "蚌埠", "lishui" => "丽水",
      "xianyang" => "咸阳",
      "yinchuan" => "银川",
      "xn" => "西宁",
      "heze" => "菏泽",
      "tongling" => "铜陵",
      "hg" => "黄冈",
      "ez" => "鄂州", "滁州" => "chuzhou",
      "yq" => "阳泉"
  }


  def self.get_58_sub_cities sub_party = 0
    case sub_party
      when 0
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::WUBA_CITY, UserSystem::CarUserInfo::CITY1
      when 1
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::WUBA_CITY, UserSystem::CarUserInfo::CITY2
      else
        UserSystem::CarUserInfo.get_city_hash UserSystem::CarUserInfo::WUBA_CITY, UserSystem::CarUserInfo::CITY3.shuffle
    end
  end


  def self.create_car_user_info options

    redis = Redis.current
    begin
      if redis[options[:detail_url]] == 'y'
        return 1
      end
    rescue Exception => e
    end


    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]

    if user_infos.length > 0
      redis[options[:detail_url]] = 'y'
      redis.expire options[:detail_url], 7*24*60*60
      return 1
    end


    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.name.gsub!(/\r|\n|\t/, '') unless car_user_info.name.blank?
    car_user_info.save!
    redis[options[:detail_url]] = 'y'
    redis.expire options[:detail_url], 7*24*60*60
    return 0
  end

  def self.create_car_user_info2 options

    redis = Redis.current
    begin
      if redis[options[:detail_url]] == 'y'
        return nil
      end
    rescue Exception => e
    end


    user_infos = UserSystem::CarUserInfo.where detail_url: options[:detail_url]
    if user_infos.length > 0
      redis[options[:detail_url]] = 'y'
      redis.expire options[:detail_url], 7*24*60*60
      return nil
    end


    car_user_info = UserSystem::CarUserInfo.new options
    car_user_info.name.gsub!(/\r|\n|\t/, '') unless car_user_info.name.blank?
    car_user_info.save!

    # if ["温州", "宁波", "厦门", "南京"].include? car_user_info.city_chinese and ["baixing"].include? car_user_info.site_name and /^17/.match car_user_info.phone
    #   return nil
    # end

    redis[options[:detail_url]] = 'y'
    redis.expire options[:detail_url], 7*24*60*60


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
    car_user_info =  UserSystem::CarUserInfo.find params[:id]

    #更新数据模块
    car_user_info.name = params[:name].gsub('联系TA', '先生女士') unless params[:name].blank?

    car_user_info.name.gsub!(/\r|\n|\t|\s|\(个人\)|（个人）/, '') unless car_user_info.name.blank?

    car_user_info.name.gsub!('为保护用户隐私该电话3分钟后失效，请快速拨打哦~', '') unless car_user_info.name.blank?
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
      # pp '更新品牌失败，已删除'
      # return
    end

    #专门针对赶集历史数据做校验
    # reg = Regexp.new Time.now.strftime("%m-%d")
    # reg2 = Regexp.new (Time.now-1.days).strftime("%m-%d")
    # reg3 = Regexp.new (Time.now-2.days).strftime("%m-%d")
    # reg4 = Regexp.new (Time.now-3.days).strftime("%m-%d")
    # reg5 = Regexp.new (Time.now-4.days).strftime("%m-%d")
    # reg6 = Regexp.new (Time.now-5.days).strftime("%m-%d")
    # reg7 = Regexp.new (Time.now-6.days).strftime("%m-%d")


    # if car_user_info.site_name == 'ganji' and car_user_info.fabushijian.blank?
    #   car_user_info.tt_upload_status = '没有发布时间'
    #   car_user_info.save!
    #   return
    # end

    # if car_user_info.site_name == 'ganji' and !(car_user_info.fabushijian.to_s.match(reg) || car_user_info.fabushijian.to_s.match(reg2) || car_user_info.fabushijian.to_s.match(reg3)|| car_user_info.fabushijian.to_s.match(reg4)|| car_user_info.fabushijian.to_s.match(reg5)|| car_user_info.fabushijian.to_s.match(reg6)|| car_user_info.fabushijian.to_s.match(reg7))
    #   car_user_info.tt_yaoyue = '历史遗留数据'
    #   car_user_info.save!
    #   return
    # end

    # unless UserSystem::CarUserInfo.is_upload car_user_info.site_name
    #   car_user_info.tt_upload_status = '数据超限'
    #   car_user_info.save!
    #   return
    # end

    # 屏蔽掉百姓网的17号
    if ["baixing"].include? car_user_info.site_name and /^17/.match car_user_info.phone
      car_user_info.tt_upload_status = '疑似百姓诈骗电话'
      car_user_info.save!
      return nil
    end

    # cuis = UserSystem::CarUserInfo.where("site_name = 'ganji'").order(id: :desc).limit(10000)
    # cuis.each do |car_user_info|
    #   reg = Regexp.new Time.now.strftime("%m-%d")
    #   unless (car_user_info.site_name == 'ganji' and !(car_user_info.fabushijian.to_s.match reg))
    #
    #     pp car_user_info.fabushijian
    #     pp reg
    #     pp (car_user_info.site_name == 'ganji' and !(car_user_info.fabushijian.to_s.match reg))
    #   end
    # end

    # 58数据先不上传，等待手机端提交过来
    # 2016-07-21 现在采用接口和口令两种并存
    UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info, true
    return if car_user_info.site_name == '58' and car_user_info.phone.blank?
    car_user_info = car_user_info.reload
    pp "准备单个上传#{car_user_info.phone}~~#{car_user_info.name}"


    UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info, true

    system_name = Personal::Role.system_name


    #先推人人车
    # UserSystem::RenRenCarUserInfo.create_user_info_from_car_user_info car_user_info


    # if rand(10) < 3
    #   begin
    #     UserSystem::JinzhenguCarUserInfo.create_user_info_from_car_user_info car_user_info
    #   rescue Exception => e
    #     pp e
    #   end
    # end

    # UploadTianTian.upload_one_tt car_user_info
    #同步至又一车/车置宝
    UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info car_user_info #if system_name != 'ali'



    #朋友E车
    UserSystem::PengyoucheCarUserInfo.create_user_info_from_car_user_info car_user_info


    #传给瓜子
    # UserSystem::GuaziCarUserInfo.create_user_info_from_car_user_info car_user_info


    return if system_name == 'ali' #阿里平台不提交以下几个B端。

    # 同步至车置宝  车置宝作废
    # UserSystem::ChezhibaoCarUserInfo.create_info_from_car_user_info car_user_info


    # 同步至4A
    # UserSystem::AishiCarUserInfo.create_user_info_from_car_user_info car_user_info


    #同步至优车
    # UserSystem::YoucheCarUserInfo.create_user_info_from_car_user_info car_user_info

    #同步至车城   车城作废
    # UserSystem::CheChengCarUserInfo.create_user_info_from_car_user_info car_user_info

    #先临时把一部分数据传给金针菇, 为提高优先级,先临时放到这里。测试通过后,再移回去
    # if rand(10)<2
    #   UserSystem::JinzhenguCarUserInfo.create_user_info_from_car_user_info car_user_info
    # end


  end

  #用于网站调用
  def self.update_58_phone_detail params


    car_user_info = UserSystem::CarUserInfo.find params[:id]
    return if not car_user_info.phone.blank?
    phone = params[:phone]
    phone.gsub!('-', '')
    phone = phone.match(/\d{11}$/).to_s
    car_user_info.phone = phone
    car_user_info.wuba_kouling_shouji_huilai_time = Time.now.chinese_format
    car_user_info.save!

    UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info, false
    car_user_info = car_user_info.reload
    pp "准备单个上传#{car_user_info.phone}~~#{car_user_info.name}"


    # UploadTianTian.upload_one_tt car_user_info

    #先临时把一部分数据传给金针菇, 为提高优先级,先临时放到这里。测试通过后,再移回去
    # if rand(10)< 2
    # UserSystem::JinzhenguCarUserInfo.create_user_info_from_car_user_info car_user_info
    # end

    # 同步至又一车
    UserSystem::YouyicheCarUserInfo.create_user_info_from_car_user_info car_user_info

    # 同步给人人车
    # UserSystem::RenRenCarUserInfo.create_user_info_from_car_user_info car_user_info


    UserSystem::CarUserInfo.che_shang_jiao_yan car_user_info, true

    #朋友E车
    UserSystem::PengyoucheCarUserInfo.create_user_info_from_car_user_info car_user_info

    #传给瓜子
    # UserSystem::GuaziCarUserInfo.create_user_info_from_car_user_info car_user_info

    # 同步至a s
    # UserSystem::AishiCarUserInfo.create_user_info_from_car_user_info car_user_info

    # 同步至优车
    # UserSystem::YoucheCarUserInfo.create_user_info_from_car_user_info car_user_info

    #同步至车城  车城作废
    # UserSystem::CheChengCarUserInfo.create_user_info_from_car_user_info car_user_info

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

    # unless car_user_info.phone.blank?
    #   phone_number_one_month = UserSystem::CarUserInfo.where("phone = ? and created_at > ? and tt_id is not null", car_user_info.phone, (Time.now.months_ago 1).chinese_format).count
    #   car_user_info.is_repeat_one_month = phone_number_one_month > 1
    #   car_user_info.save!
    # end
  end


  def self.run_che168 sub_city_party = 0

    begin
      (1..20).each do |i|
        # Che168.get_car_user_list sub_city_party
        Che168.test
      end

    rescue Exception => e
      pp e
    end
    pp '168再来一遍。。。'
    pp "168现在时间 #{Time.now.chinese_format}"


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
      # TaoChe.update_detail
    rescue Exception => e
      pp e
    end
  end

  def self.run_58 sub_city_party = 0

    begin
      # Wuba.get_car_user_list 20, sub_city_party
      Wuba.test  #58不再区分重点城市
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

  def self.run_ganji party = 0

    begin
      (1..10).each do |i|
        # Ganji.get_car_user_list party
        Ganji.test  #赶集不再区分是否重点城市。
      end
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

  def self.run_baixing party = 0, from = 'system'
    begin
      # Baixing.get_car_user_list party, from
      Baixing.test party, from
    rescue Exception => e
      pp e
      $@.to_logger
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
    need_cities = ['滁州', '顺德', '都江堰', '绍兴', '中山', '珠海']
    provinces = {"440000" => "广东", "370000" => "山东", "330000" => "浙江", "320000" => "江苏", "130000" => "河北",
                 "410000" => "河南", "110000" => "北京", "210000" => "辽宁", "310000" => "上海", "500000" => "重庆",
                 "350000" => "福建", "450000" => "广西", "520000" => "贵州", "460000" => "海南", "620000" => "甘肃",
                 "420000" => "湖北", "430000" => "湖南", "230000" => "黑龙江", "360000" => "江西", "220000" => "吉林",
                 "150000" => "内蒙古", "640000" => "宁夏", "630000" => "青海", "610000" => "陕西", "510000" => "四川",
                 "140000" => "山西", "120000" => "天津", "650000" => "新疆", "540000" => "西藏", "530000" => "云南",
                 "340000" => "安徽"}
    # provinces = { "320000" => "江苏"}
    # provinces = {"130000" => "河北"}
    # provinces = {"440000" => "广东", "330000" => "浙江", "520000" => "贵州", "150000" => "内蒙古", "650000" => "新疆", "510000" => "四川", "420000" => "湖北"}
    # provinces = {"370000" => "山东", "330000" => "浙江", "320000" => "江苏"}

    city_hash = {}
    provinces.each_pair do |key, v|
      city_content = RestClient.get("http://m.che168.com/Handler/GetArea.ashx?pid=#{key}")
      # pp 'xxx'
      pp city_content.body
      city_content = JSON.parse city_content.body
      # pp city_content
      #
      city_content["item"].each do |city|
        areaid, areaname = city["id"], city["value"]

        if need_cities.include? areaname
          city_hash[areaid] = areaname
        end
      end
    end

    pp "che168获取城市列表为："
    pp city_hash

    #淘车网的城市简称
    taoche_cities = {"北京" => "beijing", "上海" => "shanghai", "广州" => "guangzhou", "深圳" => "shenzhen", "成都" => "chengdu", "沈阳" => "shenyang", "宁波" => "ningbo", "天津" => "tianjin", "唐山" => "tangshan", "济南" => "jinan", "青岛" => "qingdao", "西安" => "xian", "临沂" => "linyi", "太原" => "taiyuan", "大连" => "dalian", "杭州" => "hangzhou", "苏州" => "suzhou", "南京" => "nanjing", "无锡" => "wuxi", "合肥" => "hefei", "东莞" => "dongguan", "佛山" => "foshan", "武汉" => "wuhan", "昆明" => "kunming", "长沙" => "changsha", "郑州" => "zhengzhou", "福州" => "fuzhou", "重庆" => "chongqing", "石家庄" => "shijiazhuang", "邢台" => "xingtai", "秦皇岛" => "qinhuangdao", "廊坊" => "langfang", "邯郸" => "handan", "衡水" => "hengshui", "沧州" => "cangzhou", "保定" => "baoding", "张家口" => "zhangjiakou", "承德" => "chengde", "呼和浩特" => "huhehaote", "包头" => "baotou", "赤峰" => "chifeng", "通辽" => "tongliao", "乌海" => "wuhai", "鄂尔多斯" => "eerduosi", "巴彦淖尔" => "bayannaoer", "乌兰察布" => "wulanchabu", "锡林郭勒" => "xilinguolemeng", "呼伦贝尔" => "hulunbeier", "兴安盟" => "xinganmeng", "阿拉善盟" => "alashanmeng", "大同" => "datong", "晋城" => "jincheng", "临汾" => "linfen", "长治" => "changzhi", "运城" => "yuncheng", "忻州" => "xinzhou", "朔州" => "shuozhou", "吕梁" => "lvliang", "晋中" => "jinzhong", "阳泉" => "yangquan", "安庆" => "anqing", "蚌埠" => "bengbu", "巢湖" => "chaohu", "池州" => "chizhou", "阜阳" => "fuyang", "淮南" => "huainan", "六安" => "luan", "马鞍山" => "maanshan", "铜陵" => "tongling", "芜湖" => "wuhu", "宣城" => "xuancheng", "滁州" => "chuzhou", "宿州" => "sz", "亳州" => "bozhou", "淮北" => "huaibei", "黄山" => "huangshan", "厦门" => "xiamen", "龙岩" => "longyan", "漳州" => "zhangzhou", "莆田" => "putian", "泉州" => "quanzhou", "南平" => "nanping", "宁德" => "ningde", "三明" => "sanming", "常州" => "changzhou", "淮安" => "huaian", "连云港" => "lianyungang", "南通" => "nantong", "盐城" => "yancheng", "扬州" => "yangzhou", "镇江" => "zhenjiang", "泰州" => "taizhou", "徐州" => "xuzhou", "宿迁" => "suqian", "德州" => "dezhou", "烟台" => "yantai", "威海" => "weihai", "潍坊" => "weifang", "泰安" => "taian", "枣庄" => "zaozhuang", "淄博" => "zibo", "东营" => "dongying", "菏泽" => "heze", "滨州" => "binzhou", "聊城" => "liaocheng", "济宁" => "jining", "日照" => "rizhao", "莱芜" => "laiwu", "温州" => "wenzhou", "嘉兴" => "jiaxing", "金华" => "jinhua", "丽水" => "lishui", "湖州" => "huzhou", "衢州" => "quzhou", "台州" => "tz", "绍兴" => "shaoxing", "舟山" => "zhoushan", "洛阳" => "luoyang", "周口" => "zhoukou", "信阳" => "xinyang", "新乡" => "xinxiang", "商丘" => "shangqiu", "三门峡" => "sanmenxia", "濮阳" => "puyang", "南阳" => "nanyang", "漯河" => "luohe", "焦作" => "jiaozuo", "开封" => "kaifeng", "安阳" => "anyang", "鹤壁" => "hebi", "平顶山" => "pingdingshan", "驻马店" => "zhumadian", "许昌" => "xuchang", "河南直辖" => "henanzhixiaxian", "十堰" => "shiyan", "襄阳" => "xiangfan", "随州" => "suizhou", "宜昌" => "yichang", "黄石" => "huangshi", "荆门" => "jingmen", "荆州" => "jingzhou", "鄂州" => "ezhou", "咸宁" => "xianning", "孝感" => "xiaogan", "黄冈" => "huanggang", "恩施" => "enshi", "湖北直辖" => "hubeizhixiaxian", "郴州" => "chenzhou", "常德" => "changde", "衡阳" => "hengyang", "怀化" => "huaihua", "娄底" => "loudi", "株洲" => "zhuzhou", "岳阳" => "yueyang", "湘潭" => "xiangtan", "邵阳" => "shaoyang", "永州" => "yongzhou", "益阳" => "yiyang", "张家界" => "zhangjiajie", "湘西" => "xiangxi", "珠海" => "zhuhai", "中山" => "zhongshan", "汕头" => "shantou", "韶关" => "shaoguan", "肇庆" => "zhaoqing", "茂名" => "maoming", "惠州" => "huizhou", "江门" => "jiangmen", "清远" => "qingyuan", "潮州" => "chaozhou", "湛江" => "zhanjiang", "梅州" => "meizhou", "揭阳" => "jieyang", "云浮" => "yunfu", "阳江" => "yangjiang", "河源" => "heyuan", "汕尾" => "shanwei", "南宁" => "nanning", "柳州" => "liuzhou", "桂林" => "guilin", "北海" => "beihai", "百色" => "baise", "贺州" => "hezhou", "河池" => "hechi", "贵港" => "guigang", "玉林" => "yulin", "钦州" => "qinzhou", "梧州" => "wuzhou", "防城港" => "fangchenggang", "来宾" => "laibin", "崇左" => "chongzuo", "海口" => "haikou", "三亚" => "sanya", "琼北" => "qiongbeidiqu", "琼南" => "qiongnandiqu", "南昌" => "nanchang", "上饶" => "shangrao", "萍乡" => "pingxiang", "新余" => "xinyu", "宜春" => "yichun", "九江" => "jiujiang", "赣州" => "ganzhou", "吉安" => "jian", "景德镇" => "jingdezhen", "抚州" => "jxfz", "鹰潭" => "yingtan", "咸阳" => "xianyang", "渭南" => "weinan", "榆林" => "yl", "宝鸡" => "baoji", "汉中" => "hanzhong", "延安" => "yanan", "铜川" => "tongchuan", "商洛" => "shangluo", "安康" => "ankang", "兰州" => "lanzhou", "定西" => "dingxi", "平凉" => "pingliang", " 酒泉" => "jiuquan", "庆阳" => "qingyang", "白银" => "baiyin", "张掖" => "zhangye", "武威" => "wuwei", "天水" => "tianshui", "嘉峪关" => "jiayuguan", "金昌" => "jinchang", "临夏" => "linxia", "陇南" => "longnan", "甘南" => "gannan", "银川" => "yinchuan", "中卫" => "zhongwei", "吴忠" => "wuzhong", "固原" => "guyuan", "石嘴山" => "shizuishan", "西宁" => "xining", "海北" => "haibei", "黄南" => "huangnan", "果洛" => "guoluo", "玉树" => "yushu", "海西" => "haixi", "海东" => "haidongdiqu", "海南" => "hainanzangzuzizhizho", "乌鲁木齐" => "wulumuqi", "克拉玛依" => "kelamayi", "巴音郭楞" => "bazhou", "伊犁" => "yili", "喀什" => "kashidiqu", "阿克苏" => "akesudiqu", "和田" => "hetiandiqu", "塔城" => "tachengdiqu", "吐鲁番" => "tulufandiqu", "哈密" => "hamidiqu", "阿勒泰" => "aletaidiqu", "新疆克州" => "xinjiangkezhou", "昌吉" => "changji", "新疆直辖" => "xinjiangzhixiaxian", "贵阳" => "guiyang", "遵义" => "zunyi", "安顺" => "anshun", "六盘水" => "liupanshui", "铜仁" => "tongrendiqu", "黔东南" => "qiandongnan", "黔南" => "qiannan", "毕节" => "bijiediqu", "黔西南" => "qianxinan", "绵阳" => "mianyang", "遂宁" => "suining", "攀枝花" => "panzhihua", "宜宾" => "yibin", "自贡" => "zigong", "资阳" => "ziyang", "德阳" => "deyang", "乐山" => "leshan", "南充" => "nanchong", "眉山" => "meishan", "巴中" => "bazhong", "泸州" => "luzhou", "内江" => "neijiang", "达州" => "dazhou", "雅安" => "yaan", "广元" => "guangyuan", "广安" => "guangan", "阿坝" => "aba", "甘孜" => "ganzi", "凉山" => "liangshan", "曲靖" => "qujing", "保山" => "baoshan", "西双版纳" => "xishuangbanna", "红河" => "honghe", "大理" => "dali", "玉溪" => "yuxi", "临沧" => "lincang", "文山" => "wenshan", "昭通" => "zhaotong", "丽江" => "lijiang", "德宏" => "dehong", "怒江" => "nujiang", "迪庆" => "diqing", "普洱" => "puer", "楚雄" => "chuxiong", "拉萨" => "lasa", "日喀则" => "rikazediqu", "山南" => "shannan", "哈尔滨" => "haerbin", "大庆" => "daqing", "齐齐哈尔" => "qiqihaer", "佳木斯" => "jiamusi", "牡丹江" => "mudanjiang", "鸡西" => "jixi", "七台河" => "qitaihe", "伊春" => "yc", "黑河" => "heihe", "双鸭山" => "shuangyashan", "绥化" => "suihua", "大兴安岭" => "daxinganlingdiqu", "长春" => "changchun", "吉林" => "jilin", "通化" => "tonghua", "辽源" => "liaoyuan", "松原" => "songyuan", "延边" => "yanbian", "四平" => "siping", "白山" => "baishan", "白城" => "baicheng", "丹东" => "dandong", "抚顺" => "fushun", "阜新" => "fuxin", "葫芦岛" => "huludao", "朝阳" => "chaoyang", "本溪" => "benxi", "鞍山" => "anshan", "锦州" => "jinzhou", "辽阳" => "liaoyang", "营口" => "yingkou", "盘锦" => "panjin", "铁岭" => "tieling"}
    need_taoche_cities = {}
    need_cities.each do |cityname|
      need_taoche_cities[taoche_cities[cityname]] = cityname
    end
    pp "淘车获取城市列表为："
    pp need_taoche_cities


    #百姓网的城市简称
    baixing_cities = {"上海" => "shanghai", "北京" => "beijing", "广州" => "guangzhou", "深圳" => "shenzhen", "成都" => "chengdu", "杭州" => "hangzhou", "南京" => "nanjing", "天津" => "tianjin", "武汉" => "wuhan", "重庆" => "chongqing", "邯郸" => "handan", "石家庄" => "shijiazhuang", "保定" => "baoding", "张家口" => "zhangjiakou", "承德" => "chengde", "唐山" => "tangshan", "廊坊" => "langfang", "沧州" => "cangzhou", "衡水" => "hengshui", "邢台" => "xingtai", "秦皇岛" => "qinhuangdao", "朔州" => "shuozhou", "忻州" => "xinzhou", "太原" => "taiyuan", "大同" => "datong", "阳泉" => "yangquan", "晋中" => "jinzhong", "长治" => "changzhi", "晋城" => "jincheng", "临汾" => "linfen", "吕梁" => "lvliang", "运城" => "yuncheng", "呼伦贝尔" => "hulunbeier", "呼和浩特" => "huhehaote", "包头" => "baotou", "乌海" => "wuhai", "乌兰察布" => "wulanchabu", "通辽" => "tongliao", "赤峰" => "chifeng", "鄂尔多斯" => "eerduosi", "巴彦淖尔" => "bayannaoer", "锡林郭勒" => "xilinguole", "兴安" => "xingan", "阿拉善" => "alashan", "沈阳" => "shenyang", "铁岭" => "tieling", "大连" => "dalian", "鞍山" => "anshan", "抚顺" => "fushun", "本溪" => "benxi", "丹东" => "dandong", "锦州" => "jinzhou", "营口" => "yingkou", "阜新" => "fuxin", "辽阳" => "liaoyang", "朝阳" => "chaoyang", "盘锦" => "panjin", "葫芦岛" => "huludao", "长春" => "changchun", "吉林" => "jilin", "延边" => "yanbian", "四平" => "siping", "通化" => "tonghua", "白城" => "baicheng", "辽源" => "liaoyuan", "松原" => "songyuan", "白山" => "baishan", "鸡西" => "jixi", "七台河" => "qitaihe", "鹤岗" => "hegang", "双鸭山" => "shuangyashan", "伊春" => "yichun", "哈尔滨" => "haerbin", "齐齐哈尔" => "qiqihaer", "牡丹江" => "mudanjiang", "佳木斯" => "jiamusi", "黑河" => "heihe", "绥化" => "suihua", "大庆" => "daqing", "大兴安岭" => "daxinganling", "无锡" => "wuxi", "镇江" => "zhenjiang", "苏州" => "suzhou", "南通" => "nantong", "扬州" => "yangzhou", "盐城" => "yancheng", "徐州" => "xuzhou", "淮安" => "huaian", "连云港" => "lianyungang", "常州" => "changzhou", "泰州" => "tz", "宿迁" => "suqian", "昆山" => "kunshan", "常熟" => "changshu", "张家港" => "zhangjiagang", "太仓" => "taicang", "衢州" => "quzhou", "湖州" => "huzhou", "嘉兴" => "jiaxing", "宁波" => "ningbo", "绍兴" => "shaoxing", "台州" => "taizhou", "温州" => "wenzhou", "丽水" => "lishui", "金华" => "jinhua", "舟山" => "zhoushan", "滁州" => "chuzhou", "阜阳" => "fuyang", "合肥" => "hefei", "蚌埠" => "bengbu", "芜湖" => "wuhu", "淮南" => "huainan", "马鞍山" => "maanshan", "安庆" => "anqing", "宿州" => "sz", "亳州" => "bozhou", "黄山" => "huangshan", "淮北" => "huaibei", "铜陵" => "tongling", "宣城" => "xuancheng", "六安" => "luan", "巢湖" => "chaohu", "池州" => "chizhou", "泰安" => "taian", "菏泽" => "heze", "济南" => "jinan", "青岛" => "qingdao", "淄博" => "zibo", "德州" => "dezhou", "烟台" => "yantai", "潍坊" => "weifang", "济宁" => "jining", "威海" => "weihai", "临沂" => "linyi", "滨州" => "binzhou", "东营" => "dongying", "枣庄" => "zaozhuang", "日照" => "rizhao", "莱芜" => "laiwu", "聊城" => "liaocheng", "商丘" => "shangqiu", "郑州" => "zhengzhou", "安阳" => "anyang", "新乡" => "xinxiang", "许昌" => "xuchang", "平顶山" => "pingdingshan", "信阳" => "xinyang", "南阳" => "nanyang", "开封" => "kaifeng", "洛阳" => "luoyang", "焦作" => "jiaozuo", "鹤壁" => "hebi", "濮阳" => "puyang", "周口" => "zhoukou", "漯河" => "luohe", "驻马店" => "zhumadian", "三门峡" => "sanmenxia", "济源" => "jiyuan", "岳阳" => "yueyang", "长沙" => "changsha", "湘潭" => "xiangtan", "株洲" => "zhuzhou", "衡阳" => "hengyang", "郴州" => "chenzhou", "常德" => "changde", "益阳" => "yiyang", "娄底" => "loudi", "邵阳" => "shaoyang", "湘西" => "xiangxi", "张家界" => "zhangjiajie", "怀化" => "huaihua", "永州" => "yongzhou", "仙桃" => "xiantao", "天门" => "tianmen", "潜江" => "qianjiang", "襄阳" => "xiangfan", "鄂州" => "ezhou", "孝感" => "xiaogan", "黄冈" => "huanggang", "黄石" => "huangshi", "咸宁" => "xianning", "荆州" => "jingzhou", "宜昌" => "yichang", "十堰" => "shiyan", "随州" => "suizhou", "荆门" => "jingmen", "恩施" => "enshi", "神农架" => "shennongjia", "鹰潭" => "yingtan", "新余" => "xinyu", "南昌" => "nanchang", "九江" => "jiujiang", "上饶" => "shangrao", "抚州" => "fz", "宜春" => "yc", "吉安" => "jian", "赣州" => "ganzhou", "景德镇" => "jingdezhen", "萍乡" => "pingxiang", "福州" => "fuzhou", "厦门" => "xiamen", "宁德" => "ningde", "莆田" => "putian", "泉州" => "quanzhou", "漳州" => "zhangzhou", "龙岩" => "longyan", "三明" => "sanming", "南平" => "nanping", "汕尾" => "shanwei", "阳江" => "yangjiang", "揭阳" => "jieyang", "茂名" => "maoming", "江门" => "jiangmen", "韶关" => "shaoguan", "惠州" => "huizhou", "梅州" => "meizhou", "汕头" => "shantou", "珠海" => "zhuhai", "佛山" => "foshan", "肇庆" => "zhaoqing", "湛江" => "zhanjiang", "中山" => "zhongshan", "河源" => "heyuan", "清远" => "qingyuan", "云浮" => "yunfu", "潮州" => "chaozhou", "东莞" => "dongguan", "来宾" => "laibin", "贺州" => "hezhou", "崇左" => "chongzuo", "玉林" => "yl", "防城港" => "fangchenggang", "南宁" => "nanning", "柳州" => "liuzhou", "桂林" => "guilin", "梧州" => "wuzhou", "贵港" => "guigang", "百色" => "bose", "钦州" => "qinzhou", "河池" => "hechi", "北海" => "beihai", "三亚" => "sanya", "儋州" => "danzhou", "东方" => "dongfang", "文昌" => "wenchang", "琼海" => "qionghai", "五指山" => "wuzhishan", "万宁" => "wanning", "海口" => "haikou", "白沙" => "baisha", "三沙" => "sansha", "保亭" => "baoting", "昌江" => "changjiang", "澄迈" => "chengmai", "定安" => "dingan", "乐东" => "ledong", "临高" => "lingao", "陵水" => "lingshui", "琼中" => "qiongzhong", "屯昌" => "tunchang", "眉山" => "meishan", "资阳" => "ziyang", "攀枝花" => "panzhihua", "自贡" => "zigong", "绵阳" => "mianyang", "南充" => "nanchong", "达州" => "dazhou", "遂宁" => "suining", "广安" => "guangan", "巴中" => "bazhong", "泸州" => "luzhou", "宜宾" => "yibin", "内江" => "neijiang", "乐山" => "leshan", "凉山" => "liangshan", "雅安" => "yaan", "甘孜" => "ganzi", "阿坝" => "aba", "德阳" => "deyang", "广元" => "guangyuan", "贵阳" => "guiyang", "遵义" => "zunyi", "安顺" => "anshun", "黔南" => "qiannan", "黔东南" => "qiandongnan", "铜仁" => "tongren", "毕节" => "bijie", "六盘水" => "liupanshui", "黔西南" => "qianxinan", "西双版纳" => "xishuangbanna", "德宏" => "dehong", "昭通" => "zhaotong", "昆明" => "kunming", "大理" => "dali", "红河" => "honghe", "曲靖" => "qujing", "保山" => "baoshan", "文山" => "wenshan", "玉溪" => "yuxi", "楚雄" => "chuxiong", "普洱" => "puer", "临沧" => "lincang", "怒江" => "nujiang", "迪庆" => "diqing", "丽江" => "lijiang", "拉萨" => "lasa", "日喀则" => "rikaze", "山南" => "shannan", "林芝" => "linzhi", "昌都" => "changdu", "那曲" => "naqu", "阿里" => "ali", "西安" => "xian", "咸阳" => "xianyang", "延安" => "yanan", "榆林" => "yulin", "渭南" => "weinan", "商洛" => "shangluo", "安康" => "ankang", "汉中" => "hanzhong", "宝鸡" => "baoji", "铜川" => "tongchuan", "陇南" => "longnan", "武威" => "wuwei", "嘉峪关" => "jiayuguan", "临夏" => "linxia", "兰州" => "lanzhou", "定西" => "dingxi", "平凉" => "pingliang", "庆阳" => "qingyang", "金昌" => "jinchang", "张掖" => "zhangye", "酒泉" => "jiuquan", "天水" => "tianshui", "甘南" => "gannan", "白银" => "baiyin", "海北" => "haibei", "西宁" => "xining", "海东" => "haidong", "黄南" => "huangnan", "果洛" => "guoluo", "玉树" => "yushu", "海西" => "haixi", "海南" => "hainan", "中卫" => "zhongwei", "银川" => "yinchuan", "石嘴山" => "shizuishan", "吴忠" => "wuzhong", "固原" => "guyuan", "伊犁" => "yili", "塔城" => "tacheng", "哈密" => "hami", "和田" => "hetian", "阿勒泰" => "aletai", "博尔塔拉" => "boertala", "克拉玛依" => "kelamayi", "乌鲁木齐" => "wulumuqi", "石河子" => "shihezi", "昌吉" => "changji", "吐鲁番" => "tulufan", "巴音郭楞" => "bayinguoleng", "阿克苏" => "akesu", "喀什" => "kashi", "克孜勒苏" => "kezilesu", "阿拉尔" => "alaer", "五家渠" => "wujiaqu", "图木舒克" => "tumushuke"}
    need_baixing_cities = {}
    need_cities.each do |cityname|
      need_baixing_cities[baixing_cities[cityname]] = cityname
    end
    pp "百姓获取城市列表为："
    pp need_baixing_cities


    #赶集网的城市简称
    ganji_cities = {"北京" => "bj", "上海" => "sh", "广州" => "gz", "深圳" => "sz", "武汉" => "wh", "南京" => "nj", "天津" => "tj", "杭州" => "hz", "鞍山" => "anshan", "安阳" => "anyang", "安庆" => "anqing", "安康" => "ankang", "阿克苏" => "akesu", "安顺" => "anshun", "阿勒泰" => "aletai", "阿拉善" => "alashan", "阿坝" => "aba", "阿里" => "ali", "阿拉尔" => "alaer", "澳门" => "aomen", "保定" => "baoding", "滨州" => "binzhou", "包头" => "baotou", "宝鸡" => "baoji", "本溪" => "benxi", "蚌埠" => "bengbu", "北海" => "beihai", "巴彦淖尔" => "bayannaoer", "白城" => "baicheng", "白山" => "baishan", "亳州" => "bozhou", "巴中" => "bazhong", "白银" => "baiyin", "百色" => "baise", "毕节" => "bijie", "巴音郭楞" => "bayinguoleng", "保山" => "baoshan", "博尔塔拉" => "boertala", "成都" => "cd", "重庆" => "cq", "长沙" => "cs", "长春" => "cc", "常州" => "changzhou", "沧州" => "cangzhou", "赤峰" => "chifeng", "承德" => "chengde", "常德" => "changde", "长治" => "changzhi", "郴州" => "chenzhou", "滁州" => "chuzhou", "巢湖" => "chaohu", "潮州" => "chaozhou", "昌吉" => "changji", "池州" => "chizhou", "楚雄" => "chuxiong", "崇左" => "chongzuo", "昌都" => "changdu", "朝阳" => "chaoyang", "常熟" => "changshu", "慈溪" => "cixi", "大连" => "dl", "东莞" => "dg", "德州" => "dezhou", "东营" => "dongying", "大庆" => "daqing", "大同" => "datong", "丹东" => "dandong", "儋州" => "danzhou", "德阳" => "deyang", "达州" => "dazhou", "大理" => "dali", "大兴安岭" => "daxinganling", "定西" => "dingxi", "德宏" => "dehong", "迪庆" => "diqing", "钓鱼岛" => "diaoyudao", "鄂尔多斯" => "eerduosi", "恩施" => "enshi", "鄂州" => "ezhou", "福州" => "fz", "佛山" => "foshan", "抚顺" => "fushun", "阜阳" => "fuyang", "阜新" => "fuxin", "抚州" => "jxfuzhou", "防城港" => "fangchenggang", "贵阳" => "gy", "桂林" => "gl", "赣州" => "ganzhou", "广元" => "guangyuan", "广安" => "guangan", "贵港" => "guigang", "固原" => "guyuan", "甘南" => "gannan", "甘孜" => "ganzi", "果洛" => "guoluo", "惠州" => "huizhou", "哈尔滨" => "hrb", "合肥" => "hf", "呼和浩特" => "nmg", "海口" => "hn", "邯郸" => "handan", "菏泽" => "heze", "衡水" => "hengshui", "淮安" => "huaian", "衡阳" => "hengyang", "葫芦岛" => "huludao", "淮南" => "huainan", "汉中" => "hanzhong", "怀化" => "huaihua", "淮北" => "huaibei", "黄冈" => "huanggang", "湖州" => "huzhou", "黄石" => "huangshi", "呼伦贝尔" => "hulunbeier", "河源" => "heyuan", "鹤壁" => "hebi", "鹤岗" => "hegang", "黄山" => "huangshan", "红河" => "honghe", "河池" => "hechi", "哈密" => "hami", "黑河" => "heihe", "贺州" => "hezhou", "海西" => "haixi", "和田" => "hetian", "海北" => "haibei", "海东" => "haidong", "黄南" => "huangnan", "济南" => "jn", "济宁" => "jining", "吉林" => "jilin", "锦州" => "jinzhou", "金华" => "jinhua", "嘉兴" => "jiaxing", "江门" => "jiangmen", "荆州" => "jingzhou", "焦作" => "jiaozuo", "晋中" => "jinzhong", "佳木斯" => "jiamusi", "九江" => "jiujiang", "晋城" => "jincheng", "荆门" => "jingmen", "鸡西" => "jixi", "吉安" => "jian", "揭阳" => "jieyang", "景德镇" => "jingdezhen", "济源" => "jiyuan", "酒泉" => "jiuquan", "金昌" => "jinchang", "嘉峪关" => "jiayuguan", "胶州" => "jiaozhou", "即墨" => "jimo", "昆明" => "km", "开封" => "kaifeng", "喀什" => "kashi", "克拉玛依" => "kelamayi", "库尔勒" => "kuerle", "克孜勒苏" => "kezilesu", "昆山" => "kunshan", "兰州" => "lz", "拉萨" => "xz", "廊坊" => "langfang", "临沂" => "linyi", "洛阳" => "luoyang", "聊城" => "liaocheng", "柳州" => "liuzhou", "连云港" => "lianyungang", "临汾" => "linfen", "漯河" => "luohe", "辽阳" => "liaoyang", "乐山" => "leshan", "泸州" => "luzhou", "六安" => "luan", "娄底" => "loudi", "莱芜" => "laiwu", "龙岩" => "longyan", "吕梁" => "lvliang", "丽水" => "lishui", "凉山" => "liangshan", "丽江" => "lijiang", "六盘水" => "liupanshui", "辽源" => "liaoyuan", "来宾" => "laibin", "临沧" => "lincang", "陇南" => "longnan", "临夏" => "linxia", "林芝" => "linzhi", "绵阳" => "mianyang", "牡丹江" => "mudanjiang", "茂名" => "maoming", "梅州" => "meizhou", "马鞍山" => "maanshan", "眉山" => "meishan", "宁波" => "nb", "南宁" => "nn", "南昌" => "nc", "南通" => "nantong", "南阳" => "nanyang", "南充" => "nanchong", "内江" => "neijiang", "南平" => "nanping", "宁德" => "ningde", "怒江" => "nujiang", "那曲" => "naqu", "平顶山" => "pingdingshan", "濮阳" => "puyang", "盘锦" => "panjin", "莆田" => "putian", "攀枝花" => "panzhihua", "萍乡" => "pingxiang", "平凉" => "pingliang", "普洱" => "puer", "郫县" => "pixian", "青岛" => "qd", "琼海" => "qh", "秦皇岛" => "qinhuangdao", "泉州" => "quanzhou", "齐齐哈尔" => "qiqihaer", "清远" => "qingyuan", "曲靖" => "qujing", "衢州" => "quzhou", "庆阳" => "qingyang", "七台河" => "qitaihe", "钦州" => "qinzhou", "潜江" => "qianjiang", "黔东南" => "qiandongnan", "黔南" => "qiannan", "黔西南" => "qianxinan", "日照" => "rizhao", "日喀则" => "rikaze", "沈阳" => "sy", "石家庄" => "sjz", "苏州" => "su", "汕头" => "shantou", "商丘" => "shangqiu", "三亚" => "sanya", "宿迁" => "suqian", "绍兴" => "shaoxing", "十堰" => "shiyan", "四平" => "siping", "三门峡" => "sanmenxia", "邵阳" => "shaoyang", "上饶" => "shangrao", "遂宁" => "suining", "三明" => "sanming", "绥化" => "suihua", "石河子" => "shihezi", "宿州" => "ahsuzhou", "韶关" => "shaoguan", "松原" => "songyuan", "随州" => "suizhou", "汕尾" => "shanwei", "双鸭山" => "shuangyashan", "朔州" => "shuozhou", "石嘴山" => "shizuishan", "商洛" => "shangluo", "神农架" => "shennongjia", "山南" => "shannan", "双流" => "shuangliu", "太原" => "ty", "唐山" => "tangshan", "泰安" => "taian", "台州" => "zjtaizhou", "泰州" => "jstaizhou", "铁岭" => "tieling", "通辽" => "tongliao", "通化" => "tonghua", "天水" => "tianshui", "铜陵" => "tongling", "铜川" => "tongchuan", "铜仁" => "tongren", "天门" => "tianmen", "塔城" => "tacheng", "吐鲁番" => "tulufan", "图木舒克" => "tumushuke", "无锡" => "wx", "乌鲁木齐" => "xj", "威海" => "wei", "潍坊" => "weifang", "温州" => "wenzhou", "芜湖" => "wuhu", "渭南" => "weinan", "乌海" => "wuhai", "梧州" => "wuzhou", "乌兰察布" => "wulanchabu", "武威" => "wuwei", "文山" => "wenshan", "吴忠" => "wuzhong", "五家渠" => "wujiaqu", "五指山" => "wuzhishan", "西安" => "xa", "厦门" => "xm", "西宁" => "xn", "徐州" => "xuzhou", "咸阳" => "xianyang", "邢台" => "xingtai", "襄阳" => "xiangyang", "新乡" => "xinxiang", "湘潭" => "xiangtan", "许昌" => "xuchang", "信阳" => "xinyang", "孝感" => "xiaogan", "忻州" => "xinzhou", "咸宁" => "xianning", "新余" => "xinyu", "宣城" => "xuancheng", "仙桃" => "xiantao", "锡林郭勒" => "xilinguole", "湘西" => "xiangxi", "兴安" => "xingan", "西双版纳" => "xishuangbanna", "香港" => "xianggang", "银川" => "yc", "宜昌" => "yichang", "烟台" => "yantai", "扬州" => "yangzhou", "盐城" => "yancheng", "营口" => "yingkou", "岳阳" => "yueyang", "运城" => "yuncheng", "榆林" => "sxyulin", "宜宾" => "yibin", "阳泉" => "yangquan", "延安" => "yanan", "益阳" => "yiyang", "永州" => "yongzhou", "玉林" => "gxyulin", "宜春" => "jxyichun", "阳江" => "yangjiang", "延边" => "yanbian", "玉溪" => "yuxi", "伊犁" => "yili", "云浮" => "yunfu", "伊春" => "hljyichun", "雅安" => "yaan", "鹰潭" => "yingtan", "玉树" => "yushu", "义乌" => "yiwu", "郑州" => "zz", "珠海" => "zhuhai", "淄博" => "zibo", "中山" => "zhongshan", "枣庄" => "zaozhuang", "张家口" => "zhangjiakou", "株洲" => "zhuzhou", "镇江" => "zhenjiang", "周口" => "zhoukou", "湛江" => "zhanjiang", "驻马店" => "zhumadian", "肇庆" => "zhaoqing", "自贡" => "zigong", "遵义" => "zunyi", "漳州" => "zhangzhou", "舟山" => "zhoushan", "张掖" => "zhangye", "资阳" => "ziyang", "张家界" => "zhangjiajie", "昭通" => "zhaotong", "中卫" => "zhongwei"}
    need_ganji_cities = {}
    need_cities.each do |cityname|
      need_ganji_cities[ganji_cities[cityname]] = cityname
    end
    pp "赶集获取城市列表为："
    pp need_ganji_cities

    #58的城市简称
    wuba_cities = {"北京" => "bj", "上海" => "sh", "广州" => "gz", "深圳" => "sz", "成都" => "cd", "杭州" => "hz", "南京" => "nj", "天津" => "tj", "武汉" => "wh", "重庆" => "cq", "青岛" => "qd", "济南" => "jn", "烟台" => "yt", "潍坊" => "wf", "临沂" => "linyi", "淄博" => "zb", "济宁" => "jining", "泰安" => "ta", "聊城" => "lc", "威海" => "weihai", "枣庄" => "zaozhuang", "德州" => "dz", "日照" => "rizhao", "东营" => "dy", "菏泽" => "heze", "滨州" => "bz", "莱芜" => "lw", "章丘" => "zhangqiu", "垦利" => "kl", "诸城" => "zc", "寿光" => "shouguang", "苏州" => "su", "无锡" => "wx", "常州" => "cz", "徐州" => "xz", "南通" => "nt", "扬州" => "yz", "盐城" => "yancheng", "淮安" => "ha", "连云港" => "lyg", "泰州" => "taizhou", "宿迁" => "suqian", "镇江" => "zj", "沭阳" => "shuyang", "大丰" => "dafeng", "如皋" => "rugao", "启东" => "qidong", "溧阳" => "liyang", "海门" => "haimen", "东海" => "donghai", "扬中" => "yangzhong", "兴化" => "xinghuashi", "新沂" => "xinyishi", "泰兴" => "taixing", "如东" => "rudong", "邳州" => "pizhou", "沛县" => "xzpeixian", "靖江" => "jingjiang", "建湖" => "jianhu", "海安" => "haian", "东台" => "dongtai", "丹阳" => "danyang", "宁波" => "nb", "温州" => "wz", "金华" => "jh", "嘉兴" => "jx", "台州" => "tz", "绍兴" => "sx", "湖州" => "huzhou", "丽水" => "lishui", "衢州" => "quzhou", "舟山" => "zhoushan", "乐清" => "yueqingcity", "瑞安" => "ruiancity", "义乌" => "yiwu", "余姚" => "yuyao", "诸暨" => "zhuji", "象山" => "xiangshanxian", "温岭" => "wenling", "桐乡" => "tongxiang", "慈溪" => "cixi", "长兴" => "changxing", "嘉善" => "jiashanx", "海宁" => "haining", "德清" => "deqing", "合肥" => "hf", "芜湖" => "wuhu", "蚌埠" => "bengbu", "阜阳" => "fy", "淮南" => "hn", "安庆" => "anqing", "宿州" => "suzhou", "六安" => "la", "淮北" => "huaibei", "滁州" => "chuzhou", "马鞍山" => "mas", "铜陵" => "tongling", "宣城" => "xuancheng", "亳州" => "bozhou", "黄山" => "huangshan", "池州" => "chizhou", "巢湖" => "ch", "和县" => "hexian", "霍邱" => "hq", "桐城" => "tongcheng", "宁国" => "ningguo", "天长" => "tianchang", "东莞" => "dg", "佛山" => "fs", "中山" => "zs", "珠海" => "zh", "惠州" => "huizhou", "江门" => "jm", "汕头" => "st", "湛江" => "zhanjiang", "肇庆" => "zq", "茂名" => "mm", "揭阳" => "jy", "梅州" => "mz", "清远" => "qingyuan", "阳江" => "yj", "韶关" => "sg", "河源" => "heyuan", "云浮" => "yf", "汕尾" => "sw", "潮州" => "chaozhou", "台山" => "taishan", "阳春" => "yangchun", "顺德" => "sd", "惠东" => "huidong", "博罗" => "boluo", "福州" => "fz", "厦门" => "xm", "泉州" => "qz", "莆田" => "pt", "漳州" => "zhangzhou", "宁德" => "nd", "三明" => "sm", "南平" => "np", "龙岩" => "ly", "武夷山" => "wuyishan", "石狮" => "shishi", "晋江" => "jinjiangshi", "南安" => "nananshi", "南宁" => "nn", "柳州" => "liuzhou", "桂林" => "gl", "玉林" => "yulin", "梧州" => "wuzhou", "北海" => "bh", "贵港" => "gg", "钦州" => "qinzhou", "百色" => "baise", "河池" => "hc", "来宾" => "lb", "贺州" => "hezhou", "防城港" => "fcg", "崇左" => "chongzuo", "海口" => "haikou", "三亚" => "sanya", "五指山" => "wzs", "三沙" => "sansha", "琼海" => "qh", "文昌" => "wenchang", "万宁" => "wanning", "屯昌" => "tunchang", "琼中" => "qiongzhong", "陵水" => "lingshui", "东方" => "df", "定安" => "da", "澄迈" => "cm", "保亭" => "baoting", "白沙" => "baish", "儋州" => "danzhou", "郑州" => "zz", "洛阳" => "luoyang", "新乡" => "xx", "南阳" => "ny", "许昌" => "xc", "平顶山" => "pds", "安阳" => "ay", "焦作" => "jiaozuo", "商丘" => "sq", "开封" => "kaifeng", "濮阳" => "puyang", "周口" => "zk", "信阳" => "xy", "驻马店" => "zmd", "漯河" => "luohe", "三门峡" => "smx", "鹤壁" => "hb", "济源" => "jiyuan", "明港" => "mg", "鄢陵" => "yanling", "禹州" => "yuzhou", "长葛" => "changge", "宜昌" => "yc", "襄阳" => "xf", "荆州" => "jingzhou", "十堰" => "shiyan", "黄石" => "hshi", "孝感" => "xiaogan", "黄冈" => "hg", "恩施" => "es", "荆门" => "jingmen", "咸宁" => "xianning", "鄂州" => "ez", "随州" => "suizhou", "潜江" => "qianjiang", "天门" => "tm", "仙桃" => "xiantao", "神农架" => "snj", "宜都" => "yidou", "长沙" => "cs", "株洲" => "zhuzhou", "益阳" => "yiyang", "常德" => "changde", "衡阳" => "hy", "湘潭" => "xiangtan", "岳阳" => "yy", "郴州" => "chenzhou", "邵阳" => "shaoyang", "怀化" => "hh", "永州" => "yongzhou", "娄底" => "ld", "湘西" => "xiangxi", "张家界" => "zjj", "南昌" => "nc", "赣州" => "ganzhou", "九江" => "jj", "宜春" => "yichun", "吉安" => "ja", "上饶" => "sr", "萍乡" => "px", "抚州" => "fuzhou", "景德镇" => "jdz", "新余" => "xinyu", "鹰潭" => "yingtan", "永新" => "yxx", "沈阳" => "sy", "大连" => "dl", "鞍山" => "as", "锦州" => "jinzhou", "抚顺" => "fushun", "营口" => "yk", "盘锦" => "pj", "朝阳" => "cy", "丹东" => "dandong", "辽阳" => "liaoyang", "本溪" => "benxi", "葫芦岛" => "hld", "铁岭" => "tl", "阜新" => "fx", "庄河" => "pld", "瓦房店" => "wfd", "哈尔滨" => "hrb", "大庆" => "dq", "齐齐哈尔" => "qqhr", "牡丹江" => "mdj", "绥化" => "suihua", "佳木斯" => "jms", "鸡西" => "jixi", "双鸭山" => "sys", "鹤岗" => "hegang", "黑河" => "heihe", "伊春" => "yich", "七台河" => "qth", "大兴安岭" => "dxal", "长春" => "cc", "吉林" => "jl", "四平" => "sp", "延边" => "yanbian", "松原" => "songyuan", "白城" => "bc", "通化" => "th", "白山" => "baishan", "辽源" => "liaoyuan", "绵阳" => "mianyang", "德阳" => "deyang", "南充" => "nanchong", "宜宾" => "yb", "自贡" => "zg", "乐山" => "ls", "泸州" => "luzhou", "达州" => "dazhou", "内江" => "scnj", "遂宁" => "suining", "攀枝花" => "panzhihua", "眉山" => "ms", "广安" => "ga", "资阳" => "zy", "凉山" => "liangshan", "广元" => "guangyuan", "雅安" => "ya", "巴中" => "bazhong", "阿坝" => "ab", "甘孜" => "ganzi", "昆明" => "km", "曲靖" => "qj", "大理" => "dali", "红河" => "honghe", "玉溪" => "yx", "丽江" => "lj", "文山" => "ws", "楚雄" => "cx", "西双版纳" => "bn", "昭通" => "zt", "德宏" => "dh", "普洱" => "pe", "保山" => "bs", "临沧" => "lincang", "迪庆" => "diqing", "怒江" => "nujiang", "贵阳" => "gy", "遵义" => "zunyi", "黔东南" => "qdn", "黔南" => "qn", "六盘水" => "lps", "毕节" => "bijie", "铜仁" => "tr", "安顺" => "anshun", "黔西南" => "qxn", "拉萨" => "lasa", "日喀则" => "rkz", "山南" => "sn", "林芝" => "linzhi", "昌都" => "changdu", "那曲" => "nq", "阿里" => "al", "日土" => "rituxian", "改则" => "gaizexian", "石家庄" => "sjz", "保定" => "bd", "唐山" => "ts", "廊坊" => "lf", "邯郸" => "hd", "秦皇岛" => "qhd", "沧州" => "cangzhou", "邢台" => "xt", "衡水" => "hs", "张家口" => "zjk", "承德" => "chengde", "定州" => "dingzhou", "馆陶" => "gt", "张北" => "zhangbei", "赵县" => "zx", "正定" => "zd", "太原" => "ty", "临汾" => "linfen", "大同" => "dt", "运城" => "yuncheng", "晋中" => "jz", "长治" => "changzhi", "晋城" => "jincheng", "阳泉" => "yq", "吕梁" => "lvliang", "忻州" => "xinzhou", "朔州" => "shuozhou", "临猗" => "linyixian", "清徐" => "qingxu", "呼和浩特" => "hu", "包头" => "bt", "赤峰" => "chifeng", "鄂尔多斯" => "erds", "通辽" => "tongliao", "呼伦贝尔" => "hlbe", "巴彦淖尔市" => "bycem", "乌兰察布" => "wlcb", "锡林郭勒" => "xl", "兴安盟" => "xam", "乌海" => "wuhai", "阿拉善盟" => "alsm", "海拉尔" => "hlr", "西安" => "xa", "咸阳" => "xianyang", "宝鸡" => "baoji", "渭南" => "wn", "汉中" => "hanzhong", "榆林" => "yl", "延安" => "yanan", "安康" => "ankang", "商洛" => "sl", "铜川" => "tc", "乌鲁木齐" => "xj", "昌吉" => "changji", "巴音郭楞" => "bygl", "伊犁" => "yili", "阿克苏" => "aks", "喀什" => "ks", "哈密" => "hami", "克拉玛依" => "klmy", "博尔塔拉" => "betl", "吐鲁番" => "tlf", "和田" => "ht", "石河子" => "shz", "克孜勒苏" => "kzls", "阿拉尔" => "ale", "五家渠" => "wjq", "图木舒克" => "tmsk", "库尔勒" => "kel", "阿勒泰" => "alt", "塔城" => "tac", "兰州" => "lz", "天水" => "tianshui", "白银" => "by", "庆阳" => "qingyang", "平凉" => "pl", "酒泉" => "jq", "张掖" => "zhangye", "武威" => "wuwei", "定西" => "dx", "金昌" => "jinchang", "陇南" => "ln", "临夏" => "linxia", "嘉峪关" => "jyg", "甘南" => "gn", "银川" => "yinchuan", "吴忠" => "wuzhong", "石嘴山" => "szs", "中卫" => "zw", "固原" => "guyuan", "西宁" => "xn", "海西" => "hx", "海北" => "haibei", "果洛" => "guoluo", "海东" => "haidong", "黄南" => "huangnan", "玉树" => "ys", "海南" => "hainan", "香港" => "hk", "澳门" => "am", "台湾" => "tw"}
    need_wuba_cities = {}
    need_cities.each do |cityname|
      need_wuba_cities[wuba_cities[cityname]] = cityname
    end
    pp "五八获取城市列表为："
    pp need_wuba_cities


    #58网城市简称,下面抄的百姓的代码，变量也没换，不过这样就可以用。为啥要换呢
    # baixing_cities = {}
    # response = RestClient.get 'http://www.58.com/'
    # response = response.body
    # response = Nokogiri::HTML(response)
    # response.css('#clist a').each do |x|
    #   city_code = x.attributes["href"].value
    #   city_code.gsub!('http://','')
    #   city_code.gsub!('.58.com/','')
    #   baixing_cities[x.text] = city_code
    # end
    # pp baixing_cities


    #赶集网的城市简称,下面抄的百姓的代码，变量也没换，不过这样就可以用。为啥要换呢
    # baixing_cities = {}
    # response = RestClient.get 'http://www.ganji.com/index.htm'
    # response = response.body
    # response = Nokogiri::HTML(response)
    # response.css('.all-city a').each do |x|
    #   city_code = x.attributes["href"].value
    #   city_code.gsub!('http://','')
    #   city_code.gsub!('.ganji.com/','')
    #   baixing_cities[x.text] = city_code
    # end
    # pp baixing_cities
    #


    #百姓网城市简称的获取方式
    # baixing_cities = {}
    # response = RestClient.get 'http://www.baixing.com/?changeLocation=yes&return=%2F'
    # response = response.body
    # response = Nokogiri::HTML(response)
    # response.css('.wrapper a').each do |x|
    #   city_code = x.attributes["href"].value
    #   city_code.gsub!('http://','')
    #   city_code.gsub!('.baixing.com/','')
    #   baixing_cities[x.text] = city_code
    # end
    # pp baixing_cities


    #以下是taoche_cities的获取方式
    # taoche_cities = {}
    # response = RestClient.get 'http://huhehaote.taoche.com/'
    # response = response.body
    # response.gsub!('ritcit_main clearfix','shengfenxxxxx')
    # response.gsub!('ritcit_main','shengfenxxxxx')
    # content = Nokogiri::HTML(response)
    # content.css('.shengfenxxxxx a').each do |xx|
    #   city_pinyin = xx.attributes["href"].value
    #
    #   city_pinyin.gsub!('http://','')
    #   city_pinyin.gsub!('.taoche.com/','')
    #
    #   taoche_cities[xx.text] = city_pinyin
    # end
    # taoche_cities
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
    return if self.che_xing.blank?

    UserSystem::CarType.all.each do |t|
      # simple_type = t.name.gsub(t.car_brand.name, '')
      # simple_type.strip!
      if self.che_xing.match Regexp.new(t.name, true) #or self.che_xing.match Regexp.new(simple_type, true)
        self.brand = t.car_brand.name
        self.cx = t.name
        self.save!
        break
      end
    end

    return unless self.brand.blank?

    UserSystem::CarBrand.all.each do |brand|
      if self.che_xing.match Regexp.new(brand.name, true)
        self.brand = brand.name
        self.save!


        brand.car_types.all.each do |t|
          simple_type = t.name.gsub(t.car_brand.name, '')
          simple_type.strip!
          if self.che_xing.match Regexp.new(t.name, true) or self.che_xing.match Regexp.new(simple_type, true)
            # self.brand = t.car_brand.name
            self.cx = t.name
            self.save!
            break
          end
        end

        break
      end
    end

  end

  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 为开新临时导出上海的成功数据，导前一天的数据, 邮件给KK， OO 和我。  业务现已停止
  # UserSystem::CarUserInfo.get_kaixin_info
  # def self.get_kaixin_info
  #   cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = '上海' and tt_yaoyue = '成功' and tt_yaoyue_day = ? and tt_chengjiao is null", Date.today)
  #   return if cuis.length == 0
  #   Spreadsheet.client_encoding = 'UTF-8'
  #   book = Spreadsheet::Workbook.new
  #   in_center = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin
  #   center_gray = Spreadsheet::Format.new horizontal_align: :center, vertical_align: :center, border: :thin, color: :gray
  #   sheet1 = book.create_worksheet name: '车主信息数据'
  #   ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
  #     sheet1.row(0)[i] = content
  #   end
  #   current_row = 1
  #   i = 0
  #   cuis.each do |car_user_info|
  #     [car_user_info.name, car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|
  #       sheet1.row(current_row)[i] = content
  #     end
  #     i = i+1
  #     current_row += 1
  #     car_user_info.tt_chengjiao = 'kaixin'
  #     car_user_info.save!
  #   end
  #   dir = Rails.root.join('public', 'downloads')
  #   Dir.mkdir dir unless Dir.exist? dir
  #   file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}上海信息数据.xls")
  #   book.write file_path
  #   file_path
  #
  #   MailSend.send_car_user_infos('37020447@qq.com;yoyolt3@163.com',
  #                                '13472446647@163.com',
  #                                i,
  #                                "最新数据-#{Time.now.chinese_format}",
  #                                [file_path]
  #   ).deliver
  #
  # end


  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 导出数据给车王。
  # 现在只要天津和上海数据。每天下午3点定时导出前一天下午3点到今天下午3点的数据。
  # UserSystem::CarUserInfo.get_info_to_chewang
  # def self.get_info_to_chewang
  #   Spreadsheet.client_encoding = 'UTF-8'
  #   book = Spreadsheet::Workbook.new
  #   record_number = 0
  #   ['天津', '上海'].each do |city|
  #     sheet1 = book.create_worksheet name: "#{city}数据"
  #     ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
  #       sheet1.row(0)[i] = content
  #     end
  #     row = 0
  #     cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = ? and milage < 9 and  tt_upload_status = '已上传' and tt_code in (0,1) and created_at > ? and created_at < ?", city, "#{Date.yesterday.chinese_format_day} 15:00:00", "#{Date.today.chinese_format_day} 15:00:00")
  #     cuis.each_with_index do |car_user_info, current_row|
  #       next if car_user_info.is_repeat_one_month
  #       if car_user_info.city_chinese == '上海'
  #         unless ['别克', '福特', 'MG', '荣威', '雪佛兰'].include? car_user_info.brand
  #           next
  #         end
  #       end
  #       record_number = record_number+1
  #       row = row+1
  #       [car_user_info.name.gsub('(个人)', ''), car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|
  #         sheet1.row(row)[i] = content
  #       end
  #     end
  #   end
  #
  #
  #   dir = Rails.root.join('public', 'downloads')
  #   Dir.mkdir dir unless Dir.exist? dir
  #   file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}车王信息数据.xls")
  #   book.write file_path
  #   file_path
  #
  #   MailSend.send_car_user_infos('37020447@qq.com;yoyolt3@163.com',
  #                                '13472446647@163.com',
  #                                record_number,
  #                                "车王最新数据-#{Time.now.chinese_format}",
  #                                [file_path]
  #   ).deliver
  #
  # end

  # UserSystem::CarUserInfo.get_info_for_zhenteng_lianyungang
  def self.get_info_for_zhenteng_lianyungang
    return unless Time.now.hour == 7
    return unless Time.now.min >= 50
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    record_number = 0
    ['连云港'].each do |city|
      sheet1 = book.create_worksheet name: "#{city}数据"
      ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
        sheet1.row(0)[i] = content
      end
      row = 0
      cuis = UserSystem::CarUserInfo.where("id > 4500000 and city_chinese = ? and created_at > ? and created_at < ?", city, "#{Date.yesterday.chinese_format_day} 01:00:00", "#{Date.today.chinese_format_day} 01:00:00")
      cuis.each_with_index do |car_user_info, current_row|
        next if car_user_info.name.blank?
        record_number = record_number+1

        row = row+1

        [car_user_info.name.gsub('(个人)', ''), car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|
          sheet1.row(row)[i] = content
        end
      end
    end


    dir = Rails.root.join('public', 'downloads')
    Dir.mkdir dir unless Dir.exist? dir
    file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}连云港信息数据.xls")
    book.write file_path
    file_path

    MailSend.send_car_user_infos('727973281@qq.com',
                                 '',
                                 record_number,
                                 "连云港最新数据-#{Time.now.chinese_format}",
                                 [file_path]
    ).deliver

    if false
      RestClient.post 'http://www.baixing.com/api/mobile/ershouqiche/ad?apiFormatter=AdList&suggestOn=0&AF_adList=category&structure=umbrella&src2listing=firstCategoryCheliang&area=m30&from=0&size=30', {
          "__trackId" => "147952348938128"
      }
    end
  end


  # 导出数据给晓玥。
  # 一次一个城市
  # UserSystem::CarUserInfo.get_info_to_xiaoyue
  # def self.get_info_to_xiaoyue
  #   id_hash = {
  #       "上海" => 2388481
  #   }
  #   Spreadsheet.client_encoding = 'UTF-8'
  #   book = Spreadsheet::Workbook.new
  #
  #   city = '上海'
  #   phones = []
  #   sheet1 = book.create_worksheet name: "#{city}数据"
  #   ['姓名', '电话'].each_with_index do |content, i|
  #     sheet1.row(0)[i] = content
  #   end
  #   row = 0
  #   cuis = UserSystem::CarUserInfo.where("id > #{id_hash[city]} and city_chinese = ?", city).select("id", "name", "phone")
  #   cuis.find_each do |car_user_info|
  #     next if phones.include? car_user_info.phone
  #     next if car_user_info.phone.blank?
  #     next unless car_user_info.phone.match /\d{11}/
  #     phones << car_user_info.phone
  #
  #     row = row+1
  #     [car_user_info.name, car_user_info.phone].each_with_index do |content, i|
  #       sheet1.row(row)[i] = content
  #     end
  #     if row == 50000
  #       pp car_user_info.id
  #       break
  #     end
  #   end
  #
  #
  #   dir = Rails.root.join('public', 'downloads')
  #   Dir.mkdir dir unless Dir.exist? dir
  #   file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}导出#{city}数据.xls")
  #   book.write file_path
  #   file_path
  #   #
  #   # MailSend.send_car_user_infos('',
  #   #                              '13472446647@163.com',
  #   #                              record_number,
  #   #                              "车王最新数据-#{Time.now.chinese_format}",
  #   #                              [file_path]
  #   # ).deliver
  #
  # end


  # class UserSystem::CarUserInfo < ActiveRecord::Base
  # 导出北京数据
  # UserSystem::CarUserInfo.get_info_to_chewang
  # def self.get_info_to_youche
  #
  #   Spreadsheet.client_encoding = 'UTF-8'
  #   book = Spreadsheet::Workbook.new
  #   phones = []
  #   record_number = 0
  #   ['北京', '天津'].each do |city|
  #     sheet1 = book.create_worksheet name: "#{city}数据"
  #     ['姓名', '电话', '品牌', '城市'].each_with_index do |content, i|
  #       sheet1.row(0)[i] = content
  #     end
  #     row = 0
  #     cuis = UserSystem::CarUserInfo.where("id > 172006 and city_chinese = ? and created_at > ? and created_at < ?", city, "#{Date.yesterday.chinese_format_day} 18:00:00", "#{Date.today.chinese_format_day} 18:00:00")
  #     cuis.each_with_index do |car_user_info, current_row|
  #       # car_user_info.name = car_user_info.name.gsub('联系TA','先生女士')
  #       # car_user_info.save!
  #
  #
  #       cbui = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
  #       unless cbui.blank?
  #         next
  #       end
  #
  #       next if car_user_info.phone.blank?
  #       next if car_user_info.name.blank?
  #       next if car_user_info.brand.blank?
  #
  #       next if phones.include? car_user_info.phone
  #       phones << car_user_info.phone
  #
  #       record_number = record_number+1
  #       row = row+1
  #       [car_user_info.name.gsub('(个人)', '').gsub('联系TA', '先生女士'), car_user_info.phone, car_user_info.brand, car_user_info.city_chinese].each_with_index do |content, i|
  #
  #         sheet1.row(row)[i] = content
  #
  #       end
  #
  #     end
  #   end
  #
  #
  #   dir = Rails.root.join('public', 'downloads')
  #   Dir.mkdir dir unless Dir.exist? dir
  #   file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}UC信息数据.xls")
  #   book.write file_path
  #   file_path
  #
  #   MailSend.send_car_user_infos('13472446647@163.com',
  #                                '',
  #                                record_number,
  #                                "UC最新数据-#{Time.now.chinese_format}",
  #                                [file_path]
  #   ).deliver
  #
  # end


  # UserSystem::CarUserInfo.get_info_to_renren
  # def self.get_info_to_renren
  #
  #   # 人人车优化笔记
  #   # 1. 车龄在08年以前的， 12万公里以内，才从手机端获取数据。其它不获取数据。    对于58
  #   # 1.1 带总、经理，老板 一律不获取手机号
  #   # 2. 根据描述可以判断是车商的， 不再获取手机号      对于58
  #   # 3. 小城市群分成四个组，再开2台服务器，用于快速抓取数据  对于58
  #   # 4. 对于赶集， 小城市群分成四个组，再开1台服务器，用于快速抓取数据。  对于赶集
  #   # 5. 对于百姓， 现在4台机器在跑， 把数据分成6个小组， 每台机器跑一组。 对于百姓    Done， 分成三组
  #   # 6. 对于百姓， 严格获取车龄和里程    Done
  #   # 7. 对于整体， 所有手机号过滤一遍，手机号重复率> 10 的， 全部进入车商库。  Done
  #   # 8. 对于整体， 只要在车商库中存在的，一律不提交  Done
  #   # 9. 对于没有车龄，里程数据的，一律不提交  Done
  #   # 10. 手机号异地，一律不提交   Done
  #   # 11. 出现在车商信息中的，一律不提交    Done
  #   # #
  #
  #   phones = []
  #   cities_all = ["深圳", "广州", "南京", "成都", "东莞", "重庆", "苏州", "上海", "郑州", "威海", "石家庄", "武汉", "沈阳", "西安", "青岛", "长沙", "哈尔滨", "长春", "杭州", "潍坊", "厦门", "佛山", "大连", "合肥", "天津", "绵阳", "徐州", "无锡", "湘潭", "株洲", "宜昌", "肇庆", "洛阳 ", "济南 ", "贵阳 ", "南宁 ", "福州", "咸阳", "南阳", "惠州", "太原", "常德", "泉州", "襄阳", "宝鸡", "中山", "德阳", "常州", "南通", "扬州", "新乡", "烟台", "嘉兴", "大庆", "营口", "呼和浩特", "芜湖", "唐山", "遵义", "乌鲁木齐", "南昌", "岳阳"]
  #   Spreadsheet.client_encoding = 'UTF-8'
  #   book = Spreadsheet::Workbook.new
  #   phones = []
  #   record_number = 0
  #   a, b, c, d, e, f, g, h, ii, jj = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  #   bcui_number = 0
  #   sheet1 = book.create_worksheet name: "人人车测试数据"
  #   ['姓名', '电话', '品牌', '车系', '城市', "里程", "车龄"].each_with_index do |content, i|
  #     sheet1.row(0)[i] = content
  #   end
  #   row = 0
  #   # cuis = UserSystem::CarUserInfo.where("id > 1003334 and phone is not null")
  #   cuis = UserSystem::CarUserInfo.where("created_at > ? and created_at < ? and phone is not null", "#{(Time.now-1.days).chinese_format_day} 10:00:00", "#{(Time.now).chinese_format} 10:00:00")
  #
  #
  #   cuis.each_with_index do |car_user_info, current_row|
  #     car_user_info.note.gsub!('联系我时，请说是在易车二手车上看到的，谢谢！', '')
  #     car_user_info.note.gsub!('打电话给我时，请一定说明在手机百姓网看到的，谢谢！', '')
  #     car_user_info.save!
  #
  #     UserSystem::CarBusinessUserInfo.add_business_user_info_phone car_user_info
  #     car_user_info = car_user_info.reload
  #     if car_user_info.phone.blank?
  #       a += 1
  #       next
  #     end
  #     if car_user_info.name.blank?
  #       b += 1
  #       next
  #     end
  #
  #     chexing_guolv = false
  #     ['电话', '联系', '精品', '处理', '过户', '包你'].each do |kw|
  #       if car_user_info.che_xing.include? kw
  #         chexing_guolv = true
  #         break
  #       end
  #     end
  #     next if chexing_guolv
  #
  #     if car_user_info.note.blank?
  #       next
  #     end
  #
  #     if car_user_info.milage.to_i > 10
  #       next
  #     end
  #
  #
  #     if ['金杯', '五菱汽车', "五菱", '五十铃', '昌河', '奥迪', '宝马', '宾利', '奔驰', '路虎', '保时捷', '江淮', '东风小康', '依维柯', '长安商用', '福田', '东风风神', '东风', '一汽'].include? car_user_info.brand
  #       next
  #     end
  #
  #
  #     # 本车   私家车  手机号  心动  包你满意    一个螺丝
  #     aaa = false
  #     ['QQ', '求购', '牌照', '批发', '私家一手车', '一手私家车', '身份', '身 份', '身~份', '个体经商', '过不了户', '帮朋友', '外地',
  #      '贷款', '女士一手', '包过户', '原漆', '原版漆', '当天开走', '美女', '车辆说明', '车辆概述', '选购', '一个螺丝',
  #      '精品', '驾驶证', '驾-驶-证', '车况原版', '随时过户', '来电有惊喜', '值得拥有', '包提档过户',
  #      '车源', '神州', '分期', '分 期', '必须过户', '抵押', '原车主', '店内服务', '选购', '微信', 'wx', '微 信',
  #      '威信', '加微', '评估师点评', '车主自述', "溦 信", '电话量大', '包你满意', '刷卡', '办理', '纯正', '抢购', '心动', '本车', '送豪礼'].each do |kw|
  #       if car_user_info.note.include? kw
  #         aaa = true
  #         break
  #       end
  #     end
  #     next if aaa
  #
  #     # 描述中不需要电话号码
  #     next if car_user_info.note.match /\d{11}/
  #
  #
  #     aaa = false
  #     #名字有特殊意思的
  #     ['图', '照片', '哥', '旗舰', '汽车', '短信', '威信', '微信', '店', '薇'].each do |kw|
  #       if car_user_info.name.include? kw
  #         aaa = true
  #         break
  #       end
  #     end
  #     next if aaa
  #
  #
  #     config_key_words = 0
  #     ["天窗", "导航", "倒车雷达", "电动调节座椅", "后视镜加热", "后视镜电动调节", "多功能方向盘", "轮毂", "dvd",
  #      "行车记录", "影像", "蓝牙", "CD", "日行灯", "一键升降窗", "中控锁", "防盗断油装置", "全车LED灯", "电动后视镜",
  #      "电动门窗", "DVD，", "真皮", "原车旅行架", "脚垫", "气囊", "一键启动", "无钥匙", "四轮碟刹", "空调",
  #      "倒镜", "后视镜", "GPS", "电子手刹", "换挡拨片", "巡航定速", "一分钱"].each do |kw|
  #       config_key_words+=1 if car_user_info.note.include? kw
  #     end
  #     # 过多配置描述，一般车商
  #     next if config_key_words > 6
  #
  #     # 名字是小字开头的，都是车商
  #     if car_user_info.name.match /^小/ and car_user_info.name.length == 2
  #       next
  #     end
  #
  #
  #     #特殊名字一般是做走私车，不能使用。
  #     if /^[a-z|A-Z|0-9|-|_]+$/.match car_user_info.name
  #       next
  #     end
  #
  #     #还有用手机号，QQ号做名字的。
  #     if /[0-9]+/.match car_user_info.name
  #       next
  #     end
  #
  #     #车型是数字+点的，一律不要
  #
  #
  #     # 车商口气
  #     next if car_user_info.note.match /^出售/
  #
  #     # 08年之前的车不要
  #     next if car_user_info.che_ling.to_i < 2008
  #
  #     #没有品牌数据的不要
  #     next if car_user_info.brand.blank?
  #
  #     # 车型中有[]的一律认为是车商
  #     if not car_user_info.che_xing.blank?
  #       next if car_user_info.che_xing.match /QQ|电话|不准|低价|私家车|外观|咨询|一手车|精品|业务|打折|货车/
  #       next if car_user_info.note.match /\d{11}/ # 车型中不能出现电话
  #       # 车型中以数字标号开头的，一律不要  这是赶集数据
  #       # next if car_user_info.che_xing.match /^\d{1,2}\./
  #     end
  #
  #     if not car_user_info.che_xing.blank?
  #       next if car_user_info.che_xing.match /\[/ and car_user_info.che_xing.match /\]/
  #       next if car_user_info.che_xing.match /【/ and car_user_info.che_xing.match /】/
  #     end
  #
  #     #去重复
  #     next if phones.include? car_user_info.phone
  #
  #     # 初步判断去车商
  #     next if car_user_info.is_cheshang == 1
  #
  #     # 初步判断去车商
  #     next if car_user_info.is_real_cheshang
  #
  #     # 去爬虫
  #     next if car_user_info.is_pachong
  #
  #     # 城市需要匹配
  #     next unless car_user_info.is_city_match
  #
  #     #只要业务范围内城市
  #     next unless cities_all.include? car_user_info.city_chinese # 判断城市是否包含
  #
  #     #最要这个手机号出现过一次，就不导入
  #     cuis = UserSystem::CarUserInfo.where("id < ? and phone = ?", car_user_info.id, car_user_info.phone)
  #     next if cuis.length > 0
  #
  #     # 车商库中再查询一遍
  #     cbuis = UserSystem::CarBusinessUserInfo.find_by_phone car_user_info.phone
  #     next unless cbuis.blank?
  #
  #     bcui_number = 0
  #     bcui = UserSystem::BusinessCarUserInfo.find_by_phone car_user_info.phone
  #     unless bcui.blank?
  #       bcui_number += 1
  #       next
  #     end
  #
  #
  #     #不要外地手机号
  #     car_user_info.phone_city = UserSystem::YoucheCarUserInfo.get_city_name(car_user_info.phone)
  #     car_user_info.save!
  #     next unless car_user_info.phone_city == car_user_info.phone_city
  #
  #     #车型，备注，去掉特殊字符后，再做一次校验，电话，微信，手机号关键字。
  #     tmp_chexing = car_user_info.che_xing.gsub(/\s|\.|~|-|_/, '')
  #     tmp_note = car_user_info.note.gsub(/\s|\.|~|-|_/, '')
  #     next if tmp_chexing.match /\d{11}|身份证|驾驶证/
  #     next if tmp_note.match /\d{11}|身份证|驾驶证/
  #
  #
  #     jj+=1
  #     record_number = record_number+1
  #     row = row+1
  #     phones << car_user_info.phone
  #     [car_user_info.name.gsub('(个人)', '').gsub('联系TA', '先生女士'), car_user_info.phone, car_user_info.brand, car_user_info.cx, car_user_info.city_chinese, car_user_info.milage, car_user_info.che_ling, car_user_info.note, car_user_info.che_xing, car_user_info.detail_url].each_with_index do |content, i|
  #       sheet1.row(row)[i] = content
  #     end
  #   end
  #
  #
  #   dir = Rails.root.join('public', 'downloads')
  #   Dir.mkdir dir unless Dir.exist? dir
  #   file_path = File.join(dir, "#{Time.now.strftime("%Y%m%dT%H%M%S")}RenRen信息数据.xls")
  #   book.write file_path
  #   file_path
  #   pp a, b, c, d, e, f, g, h, ii, jj
  #   pp "商车库中重复数为： #{bcui_number}"
  #
  #   # MailSend.send_car_user_infos('13472446647@163.com',
  #   #                              '',
  #   #                              record_number,
  #   #                              "RenRen最新数据-#{Time.now.chinese_format}",
  #   #                              [file_path]
  #   # ).deliver
  #
  # end

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
  # def self.upload_guozheng
  #   return unless (Time.now.hour > 9 and Time.now.hour < 22)
  #   return unless Time.now.min > 30
  #
  #   # s = '261d684f6b7d9af996a5691e7106075e'
  #   s = 'f01e6a7630788097d7cb0c180d500330'
  #   cuis = UserSystem::CarUserInfo.where("tt_source in ('2-474','2-474-602','2-474-602') and tt_id is not null and id > 3001992 and created_at > '2016-10-01'")
  #   cuis.find_each do |cui|
  #     # cui = UserSystem::CarUserInfo.find 1181521
  #     next if cui.tt_chengjiao == '已提交GZ'
  #     name = cui.name.gsub('(个人)', '')
  #     response = RestClient.post 'http://api3.wejing365.cn/index.php?r=apisa/save_car', {name: name,
  #                                                                                        mobile: cui.phone,
  #                                                                                        city: cui.city_chinese,
  #                                                                                        brand: cui.brand,
  #                                                                                        source: cui.tt_source,
  #                                                                                        response_id: cui.tt_id,
  #                                                                                        # number: 'PRO103',
  #                                                                                        number: 'kk',
  #                                                                                        sign: Digest::MD5.hexdigest("#{cui.phone}#{s}")
  #     }
  #     response = JSON.parse response.body
  #     pp response
  #     if response["error"] == "false"
  #       cui.tt_chengjiao = '已提交GZ'
  #       cui.save!
  #     end
  #
  #     if response["error"] == "true" and response["message"] = '该手机号已经报名'
  #       cui.tt_chengjiao = '已提交GZ'
  #       cui.save!
  #     end
  #   end
  # end

  # UserSystem::CarUserInfo.upload_to_hulei
  # def self.upload_to_hulei
  #   return unless (Time.now.hour > 9 and Time.now.hour < 22)
  #   return unless Time.now.min > 30
  #
  #   # key = "033bd94b1168d7e4f0d644c3c95e35bf" #测试
  #   # number = "4S-10009" #测试
  #   # url = 'http://api.test.4scenter.com/index.php?r=apicar/save_car'
  #
  #   key = "098f6bcd4621d373cade4e832627b4f6" #正式
  #   number = "4SA-1011" #正式
  #   url = 'http://api.formal.4scenter.com/index.php?r=apicar/save_car'
  #
  #   cuis = UserSystem::CarUserInfo.where("tt_source in ('23-23-5','23-23-4','23-23-1') and tt_id is not null and created_at > ?", Time.now - 3.days)
  #   cuis.find_each do |cui|
  #
  #     next if cui.tt_chengjiao == '已提交GZ'
  #     next if cui.tt_chengjiao == '已提交HL'
  #     pp cui.id
  #     name = cui.name.gsub('(个人)', '')
  #     response = RestClient.post url, {mobile: cui.phone,
  #                                      name: name,
  #                                      city: "#{cui.city_chinese}市",
  #                                      brand: cui.brand,
  #                                      number: number,
  #                                      source: cui.tt_source,
  #                                      sign: Digest::MD5.hexdigest("#{cui.phone}#{key}"),
  #                                      response_id: cui.tt_id,
  #     }
  #     response = JSON.parse response.body
  #
  #     pp response
  #     if response["error"] == "false"
  #       cui.tt_chengjiao = '已提交HL'
  #       cui.save!
  #     end
  #
  #     if response["error"] == "true" and response["message"] = '该手机号已经报名'
  #       cui.tt_chengjiao = '已提交HL'
  #       cui.save!
  #     end
  #   end
  #
  #
  # end


  #上海企业黄页
  # UserSystem::CarUserInfo.huangye
  def self.huangye
    num = 0
    821.upto 8321 do |i|
      pp "现在第#{i}页"
      sleep rand(10)
      response = RestClient.get "http://www.88152.com/shanghai/list#{i}.html"

      ec = Encoding::Converter.new("gbk", "UTF-8")
      response = ec.convert(response.body)
      detail_content = response
      detail_content = Nokogiri::HTML(detail_content)

      detail_content.css(".company a").each do |a|
        begin

          new_url = a.attributes["href"].value
          sleep rand(9)
          sub_response = RestClient.get new_url
          sub_response = ec.convert(sub_response.body)
          sub_response.gsub!('contact px14', 'eric')
          sub_response = Nokogiri::HTML(sub_response)
          companyname = sub_response.css(".companyname h1")[0].text
          sub_response.css(".eric ul li").each do |li|
            if li.text.match /邮箱/
              next if li.text == '电子邮箱：'
              num += 1

              pp "#{num} ~ #{companyname} ~ #{li.text}"
            end
          end
        rescue Exception => e
        end
      end

    end

  end


  #用于在自己机器上临时跑百姓网
  # UserSystem::CarUserInfo.pao_baixing
  def self.pao_baixing
    while true
      # UserSystem::CarUserInfo.run_baixing 0
      # sleep 1
      # UserSystem::CarUserInfo.run_baixing 1
      #
      # sleep 1
      # UserSystem::CarUserInfo.run_baixing 0
      # sleep 1
      # UserSystem::CarUserInfo.run_baixing 1
      # sleep 1
      UserSystem::CarUserInfo.run_baixing 2
      # sleep 1

    end
  end


  #查询是否可以上传数据,根据不同的数据渠道
  def self.is_upload qudao
    redis = Redis.current
    result = case qudao
               when 'ganji'
                 redis[GANJIUPLOAD]
               when '58'
                 redis[WUBAUPLOAD]
               when 'che168'
                 redis[YAOLIUBAUPLOAD]
               when 'baixing'
                 redis[BAIXINGUPLOAD]
               else
                 '' #坐席或其它平台过来, 默认都可以
             end
    #值为YES字符串或者为空, 都表示可以上传,其它值不可以上传
    if result == 'YES' || result.blank?
      return true
    else
      return false
    end

  end

  #查询是否可以上传数据,根据不同的数据渠道
  def self.set_not_upload qudao
    redis = Redis.current
    case qudao
      when 'ganji'
        redis[GANJIUPLOAD] = 'NO'
      when '58'
        redis[WUBAUPLOAD]= 'NO'
      when 'che168'
        redis[YAOLIUBAUPLOAD]= 'NO'
      when 'baixing'
        redis[BAIXINGUPLOAD]= 'NO'
      else
        '' #坐席或其它平台过来, 默认都可以
    end
  end

  #查询是否可以上传数据,根据不同的数据渠道
  # UserSystem::CarUserInfo.set_upload 'ganji'
  def self.set_upload qudao
    redis = Redis.current
    case qudao
      when 'ganji'
        redis[GANJIUPLOAD] = 'YES'
      when '58'
        redis[WUBAUPLOAD]= 'YES'
      when 'che168'
        redis[YAOLIUBAUPLOAD]= 'YES'
      when 'baixing'
        redis[BAIXINGUPLOAD]= 'YES'
      else
        '' #坐席或其它平台过来, 默认都可以
    end
  end


  # UserSystem::CarUserInfo.watch_qudao_exception
  def self.watch_qudao_exception
    ['58', 'ganji', 'baixing', 'che168'].each do |site_name|
      num = UserSystem::CarUserInfo.where("created_at > ? and created_at < ? and tt_id is not null and site_name = ?", Time.now - 5.minutes, Time.now, site_name).count
      if num > 40
        set_not_upload site_name
        MailSend.send_content('xiaoqi.liu@uguoyuan.cn',
                              '379576382@qq.com',
                              "不得了了, #{site_name} 不好用了,暂停进数据",
                              "不得了了, #{site_name} 不好用了,暂停进数据, 处理完以后记得手动开启"

        ).deliver
      else
        pp '正常'
      end

    end
  end


  # wuba_kouling 这里存放渠道号
  # params 里需要有   手机号, 城市名, 渠道号包含"k92kiHeu23KiAZP"

  # 接口说明:  以post形式提交数据到接口,
  # 参数接收
  # phone  手机号,
  # city   城市名称,不包含"市",
  # time  unix时间戳,
  # sign  渠道名称+unix时间戳+手机号+password  对这个字符串进行md5
  # qudao  渠道号
  # 返回值说明:
  #   {"error"=>"手机号码为空", "message"=>"手机号码为空", "code"=>1, "data"=>{}}
  # code = 0  接口正常
  # code = 1  异常
  # 无视data这个节点
  # url为:  che.uguoyuan.cn/shouche/gz
  #
  #

  def self.shouche_guazi params
    password = 'i8293lUFopW#ksi(&%$FJK'
    BusinessException.raise '手机号码为空' if params[:phone].blank?
    BusinessException.raise '城市为空' if params[:city].blank?
    BusinessException.raise '渠道号不正确' if params[:qudao].blank?
    sign = Digest::MD5.hexdigest("#{params[:qudao]}#{params[:time]}#{params[:phone]}#{password}")
    BusinessException.raise '签名不正确' unless sign == params[:sign]

    # BusinessException.raise '渠道号不正确' unless params[:wuba_kouling].match(/k92kiHeu23KiAZP/)
    param = {}

    param[:name] = if params[:name].blank?
                     '先生女士'
                   else
                     params[:name]
                   end
    param[:phone] = params[:phone]
    if params[:brand].blank?
      param[:che_xing] = '未知'
    else
      param[:che_xing] = params[:brand]
    end
    param[:site_name] = 'guazi_shouche'
    param[:city_chinese] = params[:city]
    param[:wuba_kouling] = params[:qudao]
    param[:detail_url] = "http://m.guazishouche.com/#{Time.now.chinese_format}"
    param[:milage] = '8'
    param[:fabushijian] = Time.now.chinese_format_day


    self.transaction do
      car_user_info = UserSystem::CarUserInfo.new param
      car_user_info.name.gsub!(/\r|\n|\t/, '') unless car_user_info.name.blank?
      car_user_info.save!


      UserSystem::CarUserInfo.update_detail phone: param[:phone],
                                            note: 'kong',
                                            che_ling: '2014',
                                            milage: '8',
                                            id: car_user_info.id
    end

    # if false
    #   RestClient.post 'http://che.uguoyuan.cn/shouche/gz', {"qudao"=>"12345678", "phone"=>"13472446647", "city"=>"南通", "sign"=>"cbras/Eq6pZd59dNI2x/vw==", "time"=>1494484440}
    # end


  end


  #从小朋系统同步数据
  #  chexing   cheling  detail_url  phone city_chinese site_name(58,ganji,baixing) price
  def self.shouche_xiaopeng params, number = 0

    return if params[:phone].blank?
    return if params[:city_chinese].blank?
    return if params[:site_name].blank?
    return if params[:detail_url].blank?

    param = {}
    param[:wuba_kouling] = 'cxp'
    param[:milage] = '8'
    param[:fabushijian] = Time.now.chinese_format_day


    # self.transaction do
      cui_id = UserSystem::CarUserInfo.create_car_user_info2 che_xing: params[:chexing]||"",
                                                             che_ling: params[:cheling],
                                                             milage: param[:milage],
                                                             detail_url: params[:detail_url],
                                                             city_chinese: params[:city_chinese],
                                                             price: params[:price],
                                                             site_name: params[:site_name],
                                                             is_cheshang: false


       if  cui_id.blank? and number == 0
         cuis = UserSystem::CarUserInfo.where('detail_url = ?', params[:detail_url])
         if cuis.blank?
           redis = Redis.current
           redis[params[:detail_url]] = 'n'
           redis.expire params[:detail_url], 7*24*60*60
           return UserSystem::CarUserInfo.shouche_xiaopeng params, 1

         else
           phone = ''
           cuis.each do |cui|
             phone = cui.phone unless cui.phone.blank?
           end
           if phone.blank?
             cuis.each do |cui|
               cui.destroy!
             end
             redis = Redis.current
             redis[params[:detail_url]] = 'n'
             redis.expire params[:detail_url], 7*24*60*60
             return UserSystem::CarUserInfo.shouche_xiaopeng params, 1

           end
         end



       end
      UserSystem::CarUserInfo.update_detail id: cui_id,
                                            name: params[:name] || '车主',
                                            phone: params['phone'],
                                            note: 'kong',
                                            fabushijian: Time.now.chinese_format

      return  cui_id

    # end


  end

  # UserSystem::CarUserInfo.shouche_guazi name: 'eric',
  #                                       phone: '13472446647',
  #                                       city_chinese: '上海',
  #                                       wuba_kouling: 'k92kiHeu23KiAZPcsb'

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