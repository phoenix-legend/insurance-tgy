class JzgCarType < ActiveRecord::Base
  # JzgCarType.fetch_data
  def self.fetch_data
    #从首页抓取品牌数据

    url = "http://m.jingzhengu.com/getMakeModelStyleAll/getMakeList?isEst=1&produceStatus=0"
    response = RestClient.get url
    response = JSON.parse(response)

    response["list"].each do |brand|
      JzgCarType.create_brand brand: brand["makeName"],
                              jzg_id: brand["makeId"],
                              group_name: brand["groupName"]
    end


    type_number = 0
    JzgCarType.where("type_name = 'brand'").each do |brand|
      url = "http://m.jingzhengu.com/getMakeModelStyleAll/getModelList?isEst=1&produceStatus=0&makeId=#{brand.jzg_id}"
      response = RestClient.get url
      response = JSON.parse(response)
      response["list"].each do |type|
        JzgCarType.create_type type: type["modelName"],
                                jzg_id: type["modelId"],
                                group_name: type["groupName"],
                                parent_id: brand.id
        type_number += 1
      end
    end



    c = JzgCarType.where("type_name = 'type'").count
    pp "共有车系 #{type_number} 个。 数据库中车系 #{c}个"

    style_number = 0
    JzgCarType.where("type_name = 'type'").each do |type|
      url = "http://m.jingzhengu.com/getMakeModelStyleAll/getStyleList?isEst=1&produceStatus=0&modelId=#{type.jzg_id}"
      response = RestClient.get url
      response = JSON.parse(response)
      response["list"].each do |style|
        JzgCarType.create_style style: style["styleName"],
                               jzg_id: style["styleId"],
                               group_name: type.name,
                               parent_id: type.id,
                               displacement: style["displacement"],
                               style_year: style["styleYear"]

        style_number += 1
      end
    end

    c = JzgCarType.where("type_name = 'style'").count
    pp "共有车系 #{style_number} 个。 数据库中车系 #{c}个"

  end


  def self.create_style options
    type = JzgCarType.find_by_name_and_parent_id options[:style], options[:parent_id]
    return unless type.blank?

    type = JzgCarType.new type_name: :style,
                          name: options[:style],
                          jzg_id: options[:jzg_id],
                          group_name: options[:group_name],
                          parent_id: options[:parent_id],
                          displacement: options[:displacement],
                          style_year: options[:style_year]
    type.save!
  end

  def self.create_type options
    type = JzgCarType.find_by_name_and_parent_id options[:type], options[:parent_id]
    return unless type.blank?

    type = JzgCarType.new type_name: :type,
                          name: options[:type],
                          jzg_id: options[:jzg_id],
                          group_name: options[:group_name],
                          parent_id: options[:parent_id]
    type.save!
  end


  def self.create_brand options
    type = JzgCarType.find_by_name options[:brand]
    return unless type.blank?

    type = JzgCarType.new type_name: :brand,
                          name: options[:brand],
                          jzg_id: options[:jzg_id],
                          group_name: options[:group_name],
                          parent_id: 0
    type.save!
  end
end
