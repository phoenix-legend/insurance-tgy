class ErShouFang < ActiveRecord::Base

  has_many :fang_prices

  def self.shanghai_quyu
    [

        {
            'qu_name' => '浦东',
            'qu_code' => '310115',
            'zhens' => [

                {"zhen_code" => '611900124', 'zhen_name' => '碧云'},
                {"zhen_code" => '611900125', 'zhen_name' => '碧云'},
                {"zhen_code" => '611900126', 'zhen_name' => '碧云'},
                {"zhen_code" => '611900127', 'zhen_name' => '碧云'},
                {"zhen_code" => '611900128', 'zhen_name' => '碧云'},
                {"zhen_code" => '611900129', 'zhen_name' => '碧云'},
                {"zhen_code" => '611900130', 'zhen_name' => '花木'},
                {"zhen_code" => '611900131', 'zhen_name' => '花木'},
                {"zhen_code" => '611900132', 'zhen_name' => '花木'},
                {"zhen_code" => '611900133', 'zhen_name' => '花木'},
                {"zhen_code" => '611900134', 'zhen_name' => '花木'},
                {"zhen_code" => '611900135', 'zhen_name' => '花木'},
                {"zhen_code" => '611900136', 'zhen_name' => '花木'},
                {"zhen_code" => '611900137', 'zhen_name' => '花木'},
                {"zhen_code" => '611900138', 'zhen_name' => '花木'},
                {"zhen_code" => '611900139', 'zhen_name' => '花木'},
                {"zhen_code" => '611900140', 'zhen_name' => '花木'},
                {"zhen_code" => '611900141', 'zhen_name' => '花木'},
                {"zhen_code" => '611900142', 'zhen_name' => '花木'},
                {"zhen_code" => '611900143', 'zhen_name' => '花木'},


                {"zhen_code" => '613000290', 'zhen_name' => '碧云'},
                {"zhen_code" => '611900123', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000291', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000292', 'zhen_name' => '川沙'},
                {"zhen_code" => '613000293', 'zhen_name' => '大团镇'},
                {"zhen_code" => '613000294', 'zhen_name' => '高东'},
                {"zhen_code" => '613000295', 'zhen_name' => '高行'},
                {"zhen_code" => '613000296', 'zhen_name' => '航头'},
                {"zhen_code" => '613000297', 'zhen_name' => '合庆'},
                {"zhen_code" => '613000298', 'zhen_name' => '惠南'},
                {"zhen_code" => '613000299', 'zhen_name' => '金杨'},
                {"zhen_code" => '613000300', 'zhen_name' => '康桥'},
                {"zhen_code" => '613000301', 'zhen_name' => '老港镇'},
                {"zhen_code" => '613000302', 'zhen_name' => '联洋'},
                {"zhen_code" => '613000303', 'zhen_name' => '临港新城'},
                {"zhen_code" => '613000304', 'zhen_name' => '南码头'},
                {"zhen_code" => '613000305', 'zhen_name' => '泥城镇'},
                {"zhen_code" => '613000306', 'zhen_name' => '周浦'},
                {"zhen_code" => '613000307', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000308', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000309', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000310', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000311', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000312', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000313', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000314', 'zhen_name' => '曹路'},


                #普陀
                {"zhen_code" => '613000315', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000316', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000317', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000318', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000319', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000320', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000321', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000322', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000323', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000324', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000325', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000326', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000327', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000328', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000329', 'zhen_name' => '曹路'},
                {"zhen_code" => '613000330', 'zhen_name' => '曹路'},
            ]
        },
        {
            'qu_name' => '奉贤',
            'qu_code' => '310120',
            'zhens' => [
                {"zhen_code" => '613000255', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000256', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000257', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000258', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000259', 'zhen_name' => '北蔡'},
                {"zhen_code" => '611101107', 'zhen_name' => '北蔡'},


            ]
        },

        {
            'qu_name' => "嘉定",
            'qu_code' => '310114',
            'zhens' => [
                {"zhen_code" => '613000267', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000268', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000269', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000270', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000271', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000272', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000273', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000274', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000275', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000276', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000277', 'zhen_name' => '北蔡'},
                {"zhen_code" => '613000278', 'zhen_name' => '徐行'},


            ]
        }


    ]
  end

  def self.zhen_codes
    (611900090...611900290).to_a + (613000250...613000500).to_a
    #+
    # (611101000...611101999).to_a

  end

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
        pp response
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

end
