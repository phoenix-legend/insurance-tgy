class UserSystem::CarBrand < ActiveRecord::Base
  require 'rest-client'
  require 'pp'
  has_many :car_types, :class_name => 'UserSystem::CarType'

  def self.xx
    phones = ''
    phones = phones.split("\n")
    phones.uniq!
    phones.length
  end




  def self.get_car_type
    UserSystem::CarBrand.all.each do |cb|
      response = RestClient.get "http://www.autohome.com.cn/ashx/AjaxIndexCarFind.ashx?type=3&value=#{cb.key_str}"
      ec = Encoding::Converter.new("gbk", "UTF-8")
      response = ec.convert(response.body)
      response = JSON.parse response
      response["result"]["factoryitems"].each do |factory|
        factory["seriesitems"].each do |series|
          next unless UserSystem::CarType.find_by_name(series["name"]).blank?
          ct = UserSystem::CarType.new :name => series["name"],
                                       :car_brand_id => cb.id

          ct.save!
        end
      end
    end
  end


end


#  123
