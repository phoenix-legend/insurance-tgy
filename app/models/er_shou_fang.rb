class ErShouFang < ActiveRecord::Base

  has_many :fang_prices

  def self.restclient_client_proxy_request url, time
    pp time
    pp "xx"*8
    return '' if time > 50
    proxy_ip = RestClientProxy.get_proxy_ip
    RestClient.proxy = proxy_ip
    response = begin
      response = RestClient::Request.execute(:url => url, :method => :get, :verify_ssl => false,
                                             :headers => {
                                                 'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1'
                                             })
      response = response.body
    rescue Exception => e
      pp e
      sleep 4
      ''
    end
    if response.blank?
     return ErShouFang.restclient_client_proxy_request url , time+1
    end
    return response
  end

  # ErShouFang.beijing_run
  def self.beijing_run
    return unless Time.now.hour == 10
    return unless Time.now.min >= 0
    return unless Time.now.min < 10
    ErShouFang.beijing_zhen_codes.each do |town_code|
      pp town_code

      1.upto 2000 do |page_number|
        sleep rand(2)
        url = "https://m.lianjia.com/bj/ershoufang/#{town_code}/pg#{page_number}/?_t=1"

        response = restclient_client_proxy_request url, 1

        next if response.blank?

        RestClient.proxy = nil

        # pp response
        response = response.force_encoding('UTF-8')
        response.gsub!('item_main', 'itemmain')
        response.gsub!('a_mask', 'akkmask')
        response.gsub!('price_total', 'pricekktotal')
        response.gsub!('unit_price', 'unitkdfprice')
        response.gsub!('item_other text_cut', 'itemhahaotherhahatexthahacut')
        response = Nokogiri.HTML(response)
        fangs = response.css('.pictext')
        break if fangs.length == 0
        begin
          fangs.each do |fang|

            title = fang.css(".itemmain").text
            link = fang.css(".akkmask")[0].attributes["href"].value
            lianjiaid = link.match /\/bj\/ershoufang\/(\d+)\.html/
            lianjiaid = lianjiaid[1].to_s
            price = fang.css('.pricekktotal em').text.to_i
            unitprice = fang.css('.unitkdfprice').text.to_i

            infos = fang.css('.itemhahaotherhahatexthahacut').text
            infos = infos.split('/')
            area = infos[1].to_i
            xiaoquname = infos[3].to_s
            hall_room_number= infos[0].match /(\d)室(\d)厅/
            hall_number = hall_room_number[1].to_i
            room_number = hall_room_number[2].to_i

            mark = []
            fang_tos = fang.to_s
            mark << 'is_five_year' if fang_tos.match /满五年/
            mark << 'is_two_year' if fang_tos.match /满两年/
            mark << 'is_key' if fang_tos.match /随时看房/
            mark << 'is_new_house' if fang_tos.match /新上/
            mark << 'is_dianti' if fang_tos.match /有电梯/


            districe_name, town_name = ErShouFang.get_beijing_quname_and_zhenname town_code
            k = {
                "title" => title,
                "houseSellId" => "bj#{lianjiaid}",
                "cityCode" => 'bj',
                "districtName" => districe_name,
                "plateName" => town_name,
                "showPrice" => price,
                "unitPrice" => unitprice,
                "acreage" => area,
                "propertyName" => xiaoquname,
                "hall" => hall_number,
                "room" => room_number,
                "tags" => mark
            }

            ErShouFang.create_ershoufang k, town_code unless lianjiaid.blank?

          end

        rescue Exception => e
          pp e
        end
      end
    end
  end


  # ErShouFang.shanghai_run
  def self.shanghai_run

    return unless Time.now.hour == 7
    return unless Time.now.min >= 0
    return unless Time.now.min < 10


    qu_name = CGI::escape '浦东'
    qu_code = 310115

    pp zhen_codes.length


    max_page = 10
    zhen_codes.each do |zhen_code|
      zhen_code = zhen_code.to_s


      0.upto 200 do |page|

        sleep 1
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

    #出报告
    new_prices = FangPrice.where('price_date = ? and add_price = 0', Date.today)
    total_new_price = 0
    new_prices.collect { |new_price| total_new_price += new_price.unit_price }

    up_prices = FangPrice.where('price_date = ? and add_price > 0', Date.today)
    total_up_price = 0
    up_prices.collect { |up_price| total_up_price += up_price.add_unit_price }
    total_up_unit_price = 0
    up_prices.collect { |up_price| total_up_unit_price += up_price.unit_price }

    down_prices = FangPrice.where('price_date = ? and add_price < 0', Date.today)
    total_down_price = 0
    down_prices.collect { |down_price| total_down_price += down_price.add_unit_price }
    total_down_unit_price = 0
    down_prices.collect { |down_price| total_down_unit_price += down_price.unit_price }
    MailSend.send_content('xiaoqi.liu@uguoyuan.cn',
                          '',
                          "#{Date.today} 房价变动",
                          "今日新增房源#{new_prices.length}套,均单价#{total_new_price/new_prices.length}
房价上调#{up_prices.length}套,均价单价上调#{total_up_price/up_prices.length}元, 均单价#{total_up_unit_price/up_prices.length}元
房价下调#{down_prices.length}套,均价单价下调#{-1*total_down_price/down_prices.length}元,均单价#{total_down_unit_price/down_prices.length}元
"

    ).deliver
  end


  def self.create_ershoufang fangzi_detail, zhen_code
    # pp fangzi_detail
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
                              last_unit_price: fangzi_detail["unitPrice"].to_i,
                              refresh_day: Date.today
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

        fang = price.er_shou_fang
        fang.refresh_day = Date.today
        fang.save!
        return if fangzi_detail["showPrice"].to_i == price.price

        fang.last_price = fangzi_detail["showPrice"].to_i
        fang.last_unit_price = fangzi_detail["unitPrice"].to_i
        fang.mark = fangzi_detail["tags"].join(',')
        fang.save!

        price = FangPrice.new lianjia_id: fangzi_detail["houseSellId"],
                              er_shou_fang_id: price.er_shou_fang_id,
                              price: fangzi_detail["showPrice"].to_i,
                              unit_price: fangzi_detail["unitPrice"].to_i,
                              price_date: Date.today
        price.save!

        last_price = FangPrice.where("id < ? and er_shou_fang_id  = ?", price.id, price.er_shou_fang_id).order(id: :desc).first
        price.add_price = price.price.to_i - last_price.price.to_i
        price.add_unit_price = price.unit_price.to_i - last_price.unit_price.to_i
        price.save!

        unless (fang.mark.to_s.match /is_five_year/).blank?
          fang.is_five = true
        end

        unless (fang.mark.to_s.match /is_subway_house/).blank?
          fang.is_subway = true
        end

        unless (fang.mark.to_s.match /is_two_year/).blank?
          fang.is_two = true
        end

        unless (fang.mark.to_s.match /is_key/).blank?
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

  # ErShouFang.beijing_zhen_codes
  def self.beijing_zhen_codes
    codes2 = []
    codes = ErShouFang.beijing_zhen_code_meta_info
    codes.each_value do |zhencodes|
      zhencodes.each do |zhencode|
        codes2 << zhencode.split('&')[1].split('=')[1]
      end
    end
    return codes2
  end


  def self.get_beijing_quname_and_zhenname zhencode
    codes = ErShouFang.beijing_zhen_code_meta_info
    codes.each_pair do |k, v|
      v.each do |vv|
        if vv.match Regexp.new(zhencode)
          return [k, vv.split('&')[2].split('=')[1]]
        else
          next
        end
      end
    end
  end


  def self.beijing_zhen_code_meta_info
    {"东城" => ["id=18335647&res=andingmen&name=安定门",
              "id=18335704&res=anzhen1&name=安贞",
              "id=611100445&res=chaoyangmennei1&name=朝阳门内",
              "id=611100448&res=chaoyangmenwai1&name=朝阳门外",
              "id=18335662&res=chongwenmen&name=崇文门",
              "id=611100442&res=dengshikou&name=灯市口",
              "id=611100336&res=dianmen&name=地安门",
              "id=18335645&res=dongdan&name=东单",
              "id=611100338&res=donghuashi&name=东花市",
              "id=611100444&res=dongsi1&name=东四",
              "id=18335644&res=dongzhimen&name=东直门",
              "id=18335779&res=gongti&name=工体",
              "id=18335666&res=guangqumen&name=广渠门",
              "id=18335641&res=hepingli&name=和平里",
              "id=611100447&res=jianguomennei&name=建国门内",
              "id=611100446&res=jianguomenwai&name=建国门外",
              "id=611100335&res=jiaodaokou&name=交道口",
              "id=611100443&res=jinbaojie&name=金宝街",
              "id=611100339&res=liupukang&name=六铺炕",
              "id=611100341&res=puhuangyu&name=蒲黄榆",
              "id=18335673&res=qianmen&name=前门",
              "id=611100334&res=taoranting1&name=陶然亭",
              "id=18335665&res=tiantan&name=天坛",
              "id=18335661&res=xidan&name=西单",
              "id=611100337&res=xiluoyuan&name=西罗园",
              "id=18335667&res=yongdingmen&name=永定门",
              "id=611100331&res=zuoanmen1&name=左安门"],
     "西城" => ["id=18335671&res=baizhifang1&name=白纸坊",
              "id=18335680&res=caihuying&name=菜户营",
              "id=18335672&res=changchunjie&name=长椿街",
              "id=18335657&res=chegongzhuang1&name=车公庄",
              "id=18335662&res=chongwenmen&name=崇文门",
              "id=18335652&res=deshengmen&name=德胜门",
              "id=611100336&res=dianmen&name=地安门",
              "id=18335656&res=fuchengmen&name=阜成门",
              "id=18335669&res=guanganmen&name=广安门",
              "id=18335658&res=guanyuan&name=官园",
              "id=611100342&res=jinrongjie&name=金融街",
              "id=611100339&res=liupukang&name=六铺炕",
              "id=611100601&res=madian1&name=马甸",
              "id=18335670&res=maliandao1&name=马连道",
              "id=611100359&res=muxidi1&name=木樨地",
              "id=18335674&res=niujie&name=牛街",
              "id=611100334&res=taoranting1&name=陶然亭",
              "id=611100597&res=tianningsi1&name=天宁寺",
              "id=18335661&res=xidan&name=西单",
              "id=18335653&res=xinjiekou2&name=新街口",
              "id=611100340&res=xisi1&name=西四",
              "id=18335654&res=xizhimen1&name=西直门",
              "id=18335675&res=xuanwumen12&name=宣武门",
              "id=611100432&res=youanmennei11&name=右安门内",
              "id=18335655&res=yuetan&name=月坛"],
     "朝阳" => ["id=18335704&res=anzhen1&name=安贞",
              "id=611100323&res=aolinpikegongyuan11&name=奥林匹克公园",
              "id=18335715&res=baiziwan&name=百子湾",
              "id=611100330&res=beigongda&name=北工大",
              "id=611100412&res=beiyuan2&name=北苑",
              "id=18335735&res=cbd&name=CBD",
              "id=611100328&res=changying&name=常营",
              "id=18335729&res=chaoqing&name=朝青",
              "id=18335739&res=chaoyanggongyuan&name=朝阳公园",
              "id=611100448&res=chaoyangmenwai1&name=朝阳门外",
              "id=611100332&res=chengshousi1&name=成寿寺",
              "id=611100320&res=dashanzi&name=大山子",
              "id=611100329&res=dawanglu&name=大望路",
              "id=18335724&res=dingfuzhuang&name=定福庄",
              "id=18335780&res=dongba&name=东坝",
              "id=611100326&res=dongdaqiao&name=东大桥",
              "id=18335644&res=dongzhimen&name=东直门",
              "id=18335713&res=dougezhuang&name=豆各庄",
              "id=18335676&res=fangzhuang1&name=方庄",
              "id=611100322&res=fatou&name=垡头",
              "id=18335726&res=ganluyuan&name=甘露园",
              "id=611100325&res=gaobeidian&name=高碑店",
              "id=18335779&res=gongti&name=工体",
              "id=18335666&res=guangqumen&name=广渠门",
              "id=18335723&res=guanzhuang&name=管庄",
              "id=18335734&res=guozhan1&name=国展",
              "id=18335641&res=hepingli&name=和平里",
              "id=18335743&res=hongmiao&name=红庙",
              "id=611100333&res=huanlegu&name=欢乐谷",
              "id=18335718&res=huaweiqiao&name=华威桥",
              "id=611100324&res=huixinxijie&name=惠新西街",
              "id=611100446&res=jianguomenwai&name=建国门外",
              "id=611100481&res=jianxiangqiao1&name=健翔桥",
              "id=18335737&res=jinsong&name=劲松",
              "id=18335710&res=jiuxianqiao&name=酒仙桥",
              "id=18335744&res=lishuiqiao1&name=立水桥",
              "id=611100601&res=madian1&name=马甸",
              "id=611100318&res=nanshatan1&name=南沙滩",
              "id=611100327&res=nongzhanguan&name=农展馆",
              "id=611100368&res=panjiayuan1&name=潘家园",
              "id=611100698&res=sanlitun&name=三里屯",
              "id=18335709&res=sanyuanqiao&name=三元桥",
              "id=18335707&res=shaoyaoju&name=芍药居",
              "id=18335716&res=shibalidian1&name=十八里店",
              "id=18335728&res=shifoying&name=石佛营",
              "id=18335741&res=shilibao&name=十里堡",
              "id=18335717&res=shilihe&name=十里河",
              "id=18335738&res=shoudoujichang1&name=首都机场",
              "id=611100316&res=shuangjing&name=双井",
              "id=18335714&res=shuangqiao&name=双桥",
              "id=18335727&res=sihui&name=四惠",
              "id=18335740&res=taiyanggong&name=太阳宫",
              "id=611100319&res=tianshuiyuan&name=甜水园",
              "id=18335699&res=tongzhoubeiyuan&name=通州北苑",
              "id=18335730&res=tuanjiehu&name=团结湖",
              "id=18335711&res=wangjing&name=望京",
              "id=611100321&res=xibahe&name=西坝河",
              "id=18335722&res=yansha1&name=燕莎",
              "id=18335706&res=yayuncun&name=亚运村",
              "id=611100315&res=yayuncunxiaoying&name=亚运村小营",
              "id=613000370&res=zhaoyangqita&name=朝阳其它",
              "id=18335770&res=zhongyangbieshuqu1&name=中央别墅区",],
     "海淀" => ["id=611100466&res=anningzhuang1&name=安宁庄",
              "id=611100323&res=aolinpikegongyuan11&name=奥林匹克公园",
              "id=18335761&res=baishiqiao1&name=白石桥",
              "id=18335632&res=beitaipingzhuang&name=北太平庄",
              "id=18335760&res=changwa&name=厂洼",
              "id=18335634&res=dinghuisi&name=定慧寺",
              "id=18335757&res=erlizhuang&name=二里庄",
              "id=611100353&res=ganjiakou&name=甘家口",
              "id=18335624&res=gongzhufen&name=公主坟",
              "id=611100537&res=haidianbeibuxinqu1&name=海淀北部新区",
              "id=611100398&res=haidianqita1&name=海淀其它",
              "id=18335640&res=junbo1&name=军博",
              "id=18335679&res=liuliqiao1&name=六里桥",
              "id=611100601&res=madian1&name=马甸",
              "id=611100356&res=malianwa&name=马连洼",
              "id=18335768&res=mudanyuan&name=牡丹园",
              "id=18335631&res=qinghe11&name=清河",
              "id=18335633&res=shangdi1&name=上地",
              "id=18335628&res=shijicheng&name=世纪城",
              "id=611100355&res=shuangyushu&name=双榆树",
              "id=611100358&res=sijiqing&name=四季青",
              "id=18335766&res=suzhouqiao&name=苏州桥",
              "id=611100357&res=tiancun1&name=田村",
              "id=18335629&res=wanliu&name=万柳",
              "id=611100529&res=wanshoulu1&name=万寿路",
              "id=18335758&res=weigongcun&name=魏公村",
              "id=18335636&res=wudaokou&name=五道口",
              "id=18335630&res=wukesong1&name=五棵松",
              "id=18335754&res=xiaoxitian1&name=小西天",
              "id=611100535&res=xibeiwang&name=西北旺",
              "id=611100314&res=xierqi1&name=西二旗",
              "id=18335653&res=xinjiekou2&name=新街口",
              "id=18335746&res=xisanqi1&name=西三旗",
              "id=18335762&res=xishan21&name=西山",
              "id=18335654&res=xizhimen1&name=西直门",
              "id=18335627&res=xueyuanlu1&name=学院路",
              "id=18335695&res=yangzhuang1&name=杨庄",
              "id=611100699&res=yiheyuan&name=颐和园",
              "id=611100354&res=yuanmingyuan&name=圆明园",
              "id=18335691&res=yuquanlu11&name=玉泉路",
              "id=18335767&res=zaojunmiao&name=皂君庙",
              'id=18335639&res=zhichunlu&name=知春路',
              "id=18335623&res=zhongguancun&name=中关村",
              "id=18335625&res=zizhuqiao&name=紫竹桥"],
     "丰台" => ["id=611100347&res=beidadi&name=北大地",
              "id=611100596&res=beijingnanzhan1&name=北京南站",
              "id=18335680&res=caihuying&name=菜户营",
              "id=611100351&res=caoqiao&name=草桥",
              "id=611100332&res=chengshousi1&name=成寿寺",
              "id=18335681&res=dahongmen&name=大红门",
              "id=18335676&res=fangzhuang1&name=方庄",
              "id=611100397&res=fengtaiqita1&name=丰台其它",
              "id=18335669&res=guanganmen&name=广安门",
              "id=611100345&res=heyi&name=和义",
              "id=611100352&res=huaxiang&name=花乡",
              "id=611100547&res=jiaomen&name=角门",
              "id=18335749&res=jiugong1&name=旧宫",
              "id=18335782&res=kandanqiao&name=看丹桥",
              "id=611100343&res=kejiyuanqu&name=科技园区",
              "id=611100349&res=liujiayao&name=刘家窑",
              "id=18335679&res=liuliqiao1&name=六里桥",
              "id=611100348&res=lize&name=丽泽",
              "id=18335683&res=lugouqiao1&name=卢沟桥",
              "id=18335682&res=majiabao&name=马家堡",
              "id=18335670&res=maliandao1&name=马连道",
              "id=18335684&res=muxiyuan1&name=木樨园",
              "id=611100341&res=puhuangyu&name=蒲黄榆",
              "id=611100573&res=qilizhuang&name=七里庄",
              "id=18335685&res=qingta1&name=青塔",
              "id=18335717&res=shilihe&name=十里河",
              "id=611100350&res=songjiazhuang&name=宋家庄",
              "id=18335686&res=taipingqiao1&name=太平桥",
              "id=18335773&res=wulidian&name=五里店",
              "id=18335751&res=xihongmen&name=西红门",
              "id=611100337&res=xiluoyuan&name=西罗园",
              "id=611100609&res=xingong&name=新宫",
              "id=18335678&res=yangqiao1&name=洋桥",
              "id=611100431&res=youanmenwai&name=右安门外",
              "id=18335687&res=yuegezhuang&name=岳各庄",
              "id=18335689&res=yuquanying&name=玉泉营",
              "id=611100344&res=zhaogongkou&name=赵公口"
     ],
     "石景山" => ["id=18335692&res=bajiao1&name=八角",
               "id=611100710&res=chengzi&name=城子",
               "id=18335693&res=gucheng&name=古城",
               "id=18335698&res=laoshan1&name=老山",
               "id=18335694&res=lugu1&name=鲁谷",
               "id=18335696&res=pingguoyuan1&name=苹果园",
               "id=611100403&res=shijingshanqita1&name=石景山其它",
               "id=18335695&res=yangzhuang1&name=杨庄",
               "id=18335691&res=yuquanlu11&name=玉泉路",
     ],
     "通州" => ["id=611100366&res=beiguan&name=北关",
              "id=18335701&res=guoyuan1&name=果园",
              "id=611100531&res=jiukeshu12&name=九棵树(家乐福)",
              "id=611100346&res=linheli&name=临河里",
              "id=18335700&res=liyuan&name=梨园",
              "id=611100365&res=luyuan&name=潞苑",
              "id=18335778&res=majuqiao1&name=马驹桥",
              "id=611100367&res=qiaozhuang&name=乔庄",
              "id=18335738&res=shoudoujichang1&name=首都机场",
              "id=18335699&res=tongzhoubeiyuan&name=通州北苑",
              "id=611100405&res=tongzhouqita11&name=通州其它",
              "id=18335703&res=wuyihuayuan&name=武夷花园",
              "id=18335702&res=xinhuadajie&name=新华大街",
              "id=18335750&res=yizhuang1&name=亦庄",
              "id=611100536&res=yuqiao&name=玉桥"
     ],
     "昌平" => ["id=611100466&res=anningzhuang1&name=安宁庄",
              "id=611100323&res=aolinpikegongyuan11&name=奥林匹克公园",
              "id=611100798&res=baishanzhen&name=百善镇",
              "id=611100308&res=beiqijia&name=北七家",
              "id=611100392&res=changpingqita1&name=昌平其它",
              "id=611100800&res=dongguan&name=东关",
              "id=611100797&res=guloudajie&name=鼓楼大街",
              "id=611100537&res=haidianbeibuxinqu1&name=海淀北部新区",
              "id=18335745&res=huilongguan2&name=回龙观",
              "id=611100310&res=huoying&name=霍营",
              "id=18335744&res=lishuiqiao1&name=立水桥",
              "id=611100799&res=nankou&name=南口",
              "id=611100801&res=nanshao&name=南邵",
              "id=611100309&res=shahe2&name=沙河",
              "id=18335747&res=tiantongyuan1&name=天通苑",
              "id=611100313&res=xiaotangshan1&name=小汤山",
              "id=611100796&res=xiguanhuandao&name=西关环岛",
              "id=18335746&res=xisanqi1&name=西三旗"
     ],
     "大兴" => ["id=611100395&res=daxingqita11&name=大兴其它",
              "id=611100614&res=guanyinsi&name=观音寺",
              "id=611100345&res=heyi&name=和义",
              "id=611100613&res=huangcunbei&name=黄村北",
              "id=611100612&res=huangcunhuochezhan&name=黄村火车站",
              "id=611100611&res=huangcunzhong&name=黄村中",
              "id=18335749&res=jiugong1&name=旧宫",
              "id=611100343&res=kejiyuanqu&name=科技园区",
              "id=611100610&res=tiangongyuan&name=天宫院",
              "id=18335751&res=xihongmen&name=西红门",
              "id=18335750&res=yizhuang1&name=亦庄",
              "id=611100608&res=zaoyuan&name=枣园"
     ],
     "顺义" => ["id=611100364&res=houshayu1&name=后沙峪",
              "id=611100361&res=liqiao1&name=李桥",
              "id=611100362&res=mapo&name=马坡",
              "id=18335738&res=shoudoujichang1&name=首都机场",
              "id=611100360&res=shunyicheng&name=顺义城",
              "id=611100404&res=shunyiqita1&name=顺义其它",
              "id=611100363&res=tianzhu1&name=天竺",
              "id=18335770&res=zhongyangbieshuqu1&name=中央别墅区"
     ],


     "房山" => ["id=611100697&res=changyang1&name=长阳",
              "id=611100715&res=chengguan&name=城关",
              "id=611100712&res=doudian&name=窦店",
              "id=611100396&res=fangshanqita&name=房山其它",
              "id=611100714&res=hancunhe1&name=韩村河",
              "id=611100696&res=liangxiang&name=良乡",
              "id=611100713&res=liulihe&name=琉璃河",
              "id=611100711&res=yancun&name=阎村",
              "id=611100709&res=yanshan&name=燕山"
     ],


     "门头沟" => ["id=611100717&res=binhexiqu1&name=滨河西区",
               "id=611100710&res=chengzi&name=城子",
               "id=611100716&res=dayu&name=大峪",
               "id=611100718&res=fengcun&name=冯村",
               "id=611100400&res=mentougouqita1&name=门头沟其它",
               "id=611100719&res=shimenying&name=石门营"],


     "平谷" => ["id=611100402&res=pingguqita1&name=平谷其它"],

     "怀柔" => ["id=18335774&res=huairouchengqu1&name=怀柔",
              "id=611100399&res=huairouqita1&name=怀柔其它"],

     "密云" => ["id=611100401&res=miyunqita11&name=密云其它"],
     "延庆" => ["id=611100406&res=yanqingqita1&name=延庆其它"]
    }
  end


  def self.test_xiatiao
    up_ids = []
    down_ids = []
    ErShouFang.where("city = 'sh'").find_each do |fang|
      prices = fang.fang_prices
      next if prices.length < 3
      #只研究房价变动超过2次的房子
      is_all_up = true
      is_all_down = true
      prices.each do |price|
        is_all_down = false & is_all_down if price.add_price > 0
        is_all_up = false & is_all_up if price.add_price < 0
      end
      up_ids << fang.id if is_all_up
      down_ids << fang.id if is_all_down

    end
    pp '*up'*10
    pp up_ids

    pp '*down'*10
    pp down_ids
  end


end

# 上海二手房数据研究日报(2013-03-21)
# 在10万套挂牌二手房基础上,"3月21日房价变化:
# 145套二手房上调挂牌价格,"均价上调2078元:
# 396套二手房下调挂牌价格,"均价下调1704元:
# 二手房新增514套
# 对此数据敏感的朋友点赞Mark一下,并尝试提出你所感兴趣的数据,我尝试加以分析

# 每日指标  1. 城市指标    2. 区指标    3.板块指标
# 1. 新上房源数量, 均价XX
# 2. 降价房源数量, 均价XX
# 3. 涨价房源数量, 均价XX
# 4. 摘牌房源数量
# 5. 房价上涨指数:  涨价房源/降价房源*价格因子
# 6. 总挂牌数量
# 7.
