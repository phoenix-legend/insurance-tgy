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
          max_page = (response["data"]["total_count"]/2000)+1
        end
        if page == max_page
          break
        end

        if response["errno"] == 0
          next if response["data"]["list"].length == 0
          pp response["data"]["list"][0]
          response["data"]["list"].each do |fangzi_detail|
            ErShouFang.transaction do
              price = FangPrice.where(lianjia_id: fangzi_detail["houseSellId"]).order(created_at: :desc).first

              if price.blank?
                house = ErShouFang.new lianjia_id: fangzi_detail["houseSellId"],
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
                house.save

                price = FangPrice.new lianjia_id: fangzi_detail["houseSellId"],
                                      er_shou_fang_id: house.id,
                                      price: fangzi_detail["showPrice"].to_i,
                                      unit_price: fangzi_detail["unitPrice"].to_i
                price.save
              else
                next if fangzi_detail["showPrice"].to_i == price.price
                fang = price.er_shou_fang
                fang.last_price = fangzi_detail["showPrice"].to_i
                fang.last_unit_price = fangzi_detail["unitPrice"].to_i
                fang.save!
                price = FangPrice.new lianjia_id: fangzi_detail["houseSellId"],
                                      er_shou_fang_id: price.er_shou_fang_id,
                                      price: fangzi_detail["showPrice"].to_i,
                                      unit_price: fangzi_detail["unitPrice"].to_i
                price.save
              end

            end
          end
        end
      end

      ####

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
        ]

    # (611900090...611900290).to_a + (613000250...613000500).to_a
    #+
    # (611101000...611101999).to_a

  end

end
