class ErShouFang < ActiveRecord::Base

  has_many :fang_prices


  # ErShouFang.shanghai_run
  def self.shanghai_run


    qu_name = CGI::escape '浦东'
    qu_code = 310115

    pp zhen_codes.length


    max_page = 10
    zhen_codes.each do |zhen_code|
      zhen_code = zhen_code.to_s


      0.upto 200 do |page|


        url = "http://soa.dooioo.com/api/v4/online/house/ershoufang/search?access_token=7poanTTBCymmgE0FOn1oKp&bizcircle_id=#{zhen_code}&channel=ershoufang&cityCode=sh&client=wap&district_id=#{qu_code}&district_name=#{qu_name}&limit_count=2000&limit_offset=#{page*2000}"
        response = RestClient.get url, 'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'
        response= response.body
        response = JSON.parse(response)

        pp "#{zhen_code}  第#{page}页"
        if response["errno"] == 0
          pp "共#{response["data"]["list"].length}条"
          max_page = (response["data"]["total_count"]/2000)
        end
        if page == max_page+1
          break
        end

        if response["errno"] == 0
          next if response["data"]["list"].length == 0
          response["data"]["list"].each do |fangzi_detail|
            ErShouFang.create_ershoufang fangzi_detail, zhen_code
          end
        end

        ####

      end

    end
  end


  def self.create_ershoufang fangzi_detail, zhen_code
    ErShouFang.transaction do
      price = FangPrice.where(lianjia_id: fangzi_detail["houseSellId"]).order(created_at: :desc).first

      if price.blank?
        fang = ErShouFang.new lianjia_id: fangzi_detail["houseSellId"],
                              city: fangzi_detail["cityCode"],
                              districe: fangzi_detail["districtName"],
                              town: fangzi_detail["plateName"],
                              town_code: zhen_code,
                              title: fangzi_detail["title"],
                              last_price: fangzi_detail["showPrice"].to_i,
                              area: fangzi_detail["acreage"].to_i,
                              hall_number: fangzi_detail["hall"],
                              room_number: fangzi_detail["room"],
                              mark: fangzi_detail["tags"].join(','),
                              xiaoqu_name: fangzi_detail["propertyName"],
                              last_unit_price: fangzi_detail["unitPrice"].to_i
        fang.save!

        unless (fang.mark.match /is_five_year/).blank?
          fang.is_five = true
        end

        unless (fang.mark.match /is_subway_house/).blank?
          fang.is_subway = true
        end

        unless (fang.mark.match /is_two_year/).blank?
          fang.is_two = true
        end

        unless (fang.mark.match /is_key/).blank?
          fang.is_key = true
        end

        fang.save!

        price = FangPrice.new lianjia_id: fangzi_detail["houseSellId"],
                              er_shou_fang_id: fang.id,
                              price: fangzi_detail["showPrice"].to_i,
                              unit_price: fangzi_detail["unitPrice"].to_i,
                              price_date: Date.today

        price.save!


      else
        return if fangzi_detail["showPrice"].to_i == price.price
        fang = price.er_shou_fang
        fang.last_price = fangzi_detail["showPrice"].to_i
        fang.last_unit_price = fangzi_detail["unitPrice"].to_i
        fang.mark = fangzi_detail["tags"].join(','),
            fang.save!

        price = FangPrice.new lianjia_id: fangzi_detail["houseSellId"],
                              er_shou_fang_id: price.er_shou_fang_id,
                              price: fangzi_detail["showPrice"].to_i,
                              unit_price: fangzi_detail["unitPrice"].to_i,
                              price_date: Date.today
        price.save!

        last_price = FangPrice.where("id < ?", price.id).order(id: desc).first
        price.add_price = price.price - last_price.price
        price.add_unit_price = price.unit_price - last_price.unit_price
        price.save!

        unless (fang.mark.match /is_five_year/).blank?
          fang.is_five = true
        end

        unless (fang.mark.match /is_subway_house/).blank?
          fang.is_subway = true
        end

        unless (fang.mark.match /is_two_year/).blank?
          fang.is_two = true
        end

        unless (fang.mark.match /is_key/).blank?
          fang.is_key = true
        end

        fang.save!
      end

    end
  end


  def self.zhen_codes

    #浦东

    ['611900123', # 北蔡
     '613000290', # 碧云
     "613000291", # 曹路
     "613000292", # 川沙
     "613000293", # 大团镇
     "613000294", # 高东
     "613000295", # 高行
     "611900130", # 花木
     "613000296", # 航头
     "613000297", # 合庆
     "613000298", # 惠南
     "611900131", # 金桥
     "613000299", # 金杨
     "613000300", # 康桥
     "613000303", # 临港新城
     "613000301", # 老港镇
     "611900136", # 陆家嘴
     "613000302", # 联洋
     "613000305", # 泥城镇
     "613000304", # 南码头
     "611900139", # 世博
     "611900138", # 三林
     "613000307", # 书院
     "611900141", # 塘桥
     "613000308", # 唐镇
     "613000310", # 潍坊
     "611900143", # 外高桥
     "613000311", # 新场
     "613000309", # 万祥
     "613000312", # 宣桥
     "613000313", # 杨东
     "613000314", # 洋泾
     "611101108", # 御桥
     "613000315", # 源深
     "611900148", # 张江
     "613000316", # 周浦
     "613000317" # 祝桥
    ] +
        #闵行
        [
            "611900064", #春申
            "611900068", #古美
            "611100113", #华漕
            "611900069", #华航
            "611900071", #静安新城
            "611900067", #金汇
            "611100115", #金虹桥
            "611900073", #龙柏
            "611900065", #老闵行
            "611900070", #梅陇
            "611100116", #马桥
            "611100118", #浦江
            "611100119", #七宝
            "611100120", #吴泾
            "611100121", #莘庄
            "611100122", #颛桥

        ] +

        # 宝山
        [
            "613000245", # 大场镇
            "611100420", # 大华
            "613000247", # 顾村
            "611900008", # 共富
            "613000246", # 高境
            "613000246", # 高境
            "611900003", # 共康
            "613000248", # 罗店
            "613000249", # 罗泾
            "611100426", # 淞宝
            "613000250", # 上大
            "613000251", # 淞南
            "611900001", # 通河
            "613000252", # 杨行
            "613000253", # 月浦
            "613000254", # 张庙
        ]+
        # 徐汇
        [
            '613000342', # 漕河泾
            "611900103", # 长桥
            "611900104", # 华东理工
            "611100124", # 华泾
            "611900097", # 衡山路
            "611900099", # 建国西路
            '613000343', # 康健
            "611100125", # 龙华
            '613000344', # 上海南站
            "611100127", # 田林
            "611900100", # 万体馆
            "611100128", # 徐汇滨江
            '613000345', # 徐家汇
            "611900098", # 万体馆
            "611900102", # 植物园
        ]+
        #普陀
        [
            '613000319', # 长风
            '613000320', # 长寿路
            "611100369", # 曹杨
            "611100370", # 长征
            '613000318', # 甘泉宜川
            "611100415", # 光新
            "611100373", # 桃浦
            "611100375", # 万里
            "611100416", # 武宁
            '613000312', # 真光
            "611100371", # 真如
            "613000322", # 中远两湾城
        ]+
        #杨浦
        [
            "611900108", # 鞍山
            "611900106", # 东外滩
            "611900107", # 黄兴公园
            '613000346', # 控江
            "611900110", # 五角场
            "611900111", # 新江湾城
            "611900109", # 周家嘴路
            "611900112", # 中原
        ] +
        #长宁
        [
            "611900013", # 北新泾
            "611100407", # 古北
            "611100408", # 虹桥
            "611900011", # 天山
            "611100410", # 新华路
            "611100409", # 西郊
            '613000350', # 仙霞
            "611900014", # 镇宁路
            "611100411", # 中山公园
        ]+
        #松江
        [
            '613000332', # 车墩
            "611100449", # 九亭
            '613000333', # 泖港
            '613000333', # 泖港
            '613000335', # 石湖荡
            '613000336', # 泗泾
            '613000337', # 松江大学城
            '613000338', # 松江老城
            "611100452", # 松江新城
            "611100450", # 佘山
            '613000340', # 新浜
            '613000339', # 小昆山
            '613000334', # 莘闵别墅
            "611100454", # 新桥
            '613000341', # 叶榭
        ]+
        #嘉定
        [
            '613000267', # 安亭
            '613000268', # 丰庄
            '613000269', # 华亭
            '613000270', # 嘉定新城
            '613000271', # 嘉定老城
            '613000272', # 江桥
            '613000273', # 菊园新区
            '613000274', # 马陆
            '613000275', # 南翔
            '613000276', # 外冈
            '613000278', # 徐行
            '613000389', # 新成路
        ]+
        # 黄浦
        [
            "611900038", # 董家渡
            "611100441", # 打浦桥
            "611900062", # 淮海中路
            "613000265", # 黄浦滨江
            "611100456", # 老西门
            "611900036", # 南京东路
            "611900037", # 蓬莱公园
            "611100457", # 人民广场
            "611900063", # 世博滨江
            "611900061", # 五里桥
            "611900060", # 新天地
            "611900039", # 豫园
        ]+
        # 静安
        [

            "611100418", # 曹家渡
            "613000289", # 静安寺
            "611100417", # 江宁路
            "611100419", # 南京西路
        ]+
        # 闸北
        [
            "611900117", # 不夜城
            "611900116", # 大宁
            "611100430", # 江宁路
            "611900118", # 西藏北路
            "613000348", # 阳城
            "611900121", # 永和
            "613000349", # 闸北公园
        ]+
        # 虹口
        [
            "611900028", # 北外滩
            "613000263", # 江湾镇
            "611900029", # 凉城
            "611900031", # 临平路
            "613000264", # 鲁迅公园
            "611900033", # 曲阳
            "611900030", # 四川北路
        ]+
        # 青浦
        [
            "613000323", # 白鹤
            "613000330", # 重固
            "613000324", # 华新
            "1100000696", # 金泽
            "1100000693", # 练塘
            "613000326", # 香花桥
            "613000327", # 徐泾
            "613000325", # 夏阳
            "613000328", # 盈浦
            "613000331", # 朱家角
            "613000329", # 赵巷
        ]+
        # 奉贤
        [
            "613000256", # 奉城
            "613000255", # 奉贤金汇
            "613000257", # 海湾
            "613000258", # 南桥
            "613000259", # 青村
            "613000260", # 四团
            "611101107", # 西渡
            "613000262", # 庄行
            "613000261", # 柘林
        ]+
        # 金山
        [
            "613000279", # 漕泾
            "613000280", # 枫泾
            "613000281", # 金山
            "613000282", # 廊下
            "613000283", # 吕巷
            "613000285", # 石化
            "613000284", # 山阳
            "613000286", # 亭林
            "613000288", # 朱泾
            "613000287", # 张堰
        ]+
        # 崇明
        [
            "613000351", # 堡镇
            "613000357", # 陈家镇
            "613000358", # 崇明其它
            "613000359", # 崇明新城
            "613000360", # 长兴岛
            "1100000344", # 横沙岛
        ]


    # (611900090...611900290).to_a + (613000250...613000500).to_a
    #+
    # (611101000...611101999).to_a

  end

end
