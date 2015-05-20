class Wz::OrderSystem::ProductsController < Wz::WangzhanController

  def index
    @products = ::OrderSystem::Product.where(online: true).order(sort_by: :desc)
  end

  def new_appointment
    @product_id = params[:id]
    product = ::OrderSystem::Product.find_by_id(@product_id)
    @image_url = product.cover_image
    @descriptions = eval(product.description) rescue nil
    @product_name = product.name
  end

  def create_appointment
    begin
      @car_number = params[:car_number]
      @phone = params[:phone]
      user = ::UserSystem::UserInfo.create_user_info params.permit(:car_number, :phone, :product_id)
      product = ::OrderSystem::Product.find_by_id params[:product_id].to_i
      if product.server_name.to_s == 'xieche'
        param = {
            "mobile" => user.phone,
            "licenseplate_type" => user.car_number[0],
            "licenseplate" => user.car_number[1..-1],
            "pingan_id" => user.id

        }.to_json
        pp param
        redirect_to "http://www.xieche.com.cn/mobilecar-carservice?param=#{CGI.escape param}"
        return
      end
      render :appointment_success
    rescue Exception => e
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      product = ::OrderSystem::Product.find_by_id(@product_id)
      @product_name = product.name
      @image_url = product.cover_image
      @descriptions = eval(product.description) rescue nil
      dispose_exception e
      @error_message = get_notice_str
      render :new_appointment
    end
  end

  def appointment_success

  end

  def compare_price
    if params[:product_id].blank?
      @product_id = ::OrderSystem::Product.find_by_name("车险比价").id
    else
      @product_id = params[:product_id]
    end
    @ip = request.remote_ip
    if params[:city].blank?
      @city = ::OrderSystem::IpRegion.get_city_name @ip
      @city.gsub!('市', '')
    else
      @city = params[:city]
    end
    @car_price = params[:car_price]
    @car_number = params[:car_number]
    @phone = params[:phone]
  end

  def search_price
    begin
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      @ip = params[:ip]
      ::UserSystem::UserInfo.create_user_info params.permit(:car_price, :city, :car_number, :phone, :product_id, :ip)
      redirect_to action: :display_price, city: params[:city], car_price: params[:car_price], product_id: params[:product_id]
    rescue Exception => e
      @cities = ::UserSystem::UserInfo::CITY
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      @ip = params[:ip]
      dispose_exception e
      @error_message = get_notice_str
      #dispose_exception e
      render :compare_price
    end
  end

  def display_price
    @car_insurance_prices = ::OrderSystem::CarInsurancePrice.where(city_name: params[:city], car_price: params[:car_price])
    @product_id = params[:product_id]
    @car_price = params[:car_price]
    @city = params[:city]
  end

  def get_city_name
    @cities = ::OrderSystem::Region.where(level: 2).order("first_letter asc")
    @car_price = params[:car_price]
    @city = params[:city]
    @car_number = params[:car_number]
    @phone = params[:phone]
    @product_id = params[:product_id]
    @ip = params[:ip]
  end

end
