class Wz::OrderSystem::ProductsController < Wz::WangzhanController

  def index
    @products = ::OrderSystem::Product.where(online: true).order(sort_by: :desc)
  end

  def new_appointment

    @city = if params[:city].blank?
              city = ::OrderSystem::IpRegion.get_city_name request.remote_ip
              city.gsub!('市', '')
              city
            else
              params[:city]
            end
    pp '....'
    pp @city
    @car_number = ::OrderSystem::Region.find_by_name(@city).car_number_prefix rescue ''
    pp @car_number
    @product_id = params[:id]
    product = ::OrderSystem::Product.find_by_id(@product_id)
    @image_url = product.detail_image
    @descriptions = eval(product.description) rescue nil
    @product_name = product.name
  end

  def create_appointment
    begin
      session[:car_number] = params[:car_number]
      session[:phone] = params[:phone]
      @car_number = params[:car_number]
      @phone = params[:phone]
      user = ::UserSystem::UserInfo.create_user_info params.permit(:car_number, :phone, :product_id)
      product = ::OrderSystem::Product.find_by_id params[:product_id].to_i
      if product.server_name.to_s == 'xieche'
        param = user.get_xieche_param
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
      @image_url = product.detail_image
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
    @image_url = ::OrderSystem::Product.find_by_id(@product_id).detail_image rescue ''
    @ip = request.remote_ip
    if params[:city].blank?
      @city = ::OrderSystem::IpRegion.get_city_name @ip
      @city.gsub!('市', '')
    else
      @city = params[:city]
    end
    @car_number = ::OrderSystem::Region.find_by_name(@city).car_number_prefix rescue ''
    @car_price = params[:car_price]
    @phone = params[:phone] unless params[:phone].blank?
  end

  def search_price
    begin
      session[:car_number] = params[:car_number]
      session[:phone] = params[:phone]
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      @ip = params[:ip]
      ::UserSystem::UserInfo.create_user_info params.permit(:car_price, :city, :car_number, :phone, :product_id, :ip)
      redirect_to action: :display_price, city: params[:city], car_price: params[:car_price], product_id: params[:product_id]
    rescue Exception => e
      # @cities = ::UserSystem::UserInfo::CITY
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      @ip = params[:ip]
      dispose_exception e
      @error_message = get_notice_str
      render :compare_price
    end
  end

  def display_price
    @car_insurance_prices = ::OrderSystem::CarInsurancePrice.get_price params
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
