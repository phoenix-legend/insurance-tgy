class Wz::OrderSystem::ProductsController < Wz::WangzhanController

  def index
    if params[:template_name].blank?
      @products = ::OrderSystem::Product.where(online: true).order(sort_by: :desc)
    else
      BusinessException.raise '渠道错误' if params[:qudao_name].blank?
      template = ::OrderSystem::Template.where real_name: params[:template_name]
      BusinessException.raise '渠道错误' if template[0].blank?
      @products = template[0].valid_template_products
      session[:qudao_name] = params[:qudao_name]
      session[:template_name] = params[:template_name]
      render 'index2'
    end
  end

  def new_appointment
    @city = if params[:city].blank?
              city = ::OrderSystem::IpRegion.get_city_name get_ip
              city.gsub!('市', '')
              city
            else
              params[:city]
            end
    @car_number = ::OrderSystem::Region.find_by_name(@city).car_number_prefix rescue ''
    @product = ::OrderSystem::Product.find_by_id params[:id]
    @descriptions = eval(@product.description) rescue nil
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
      if product.return_page == 'download_app'
        redirect_to "/wz/order_system/products/appointment_success?product_id=#{product.id}"
      else
        redirect_to "/wz/order_system/products/appointment_success2?product_id=#{product.id}"
      end
      return

    rescue Exception => e
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      @product = ::OrderSystem::Product.find_by_id(@product_id)
      @descriptions = eval(@product.description) rescue nil
      dispose_exception e
      @error_message = get_notice_str
      render :new_appointment
    end
  end

  def appointment_success
    @product = ::OrderSystem::Product.find_by_id params[:product_id].to_i
  end

  def appointment_success2
    @product = ::OrderSystem::Product.find_by_id params[:product_id].to_i
  end

  def compare_price
    @product_id = ::OrderSystem::Product.find_by_server_name("bijia").id
    @image_url = ::OrderSystem::Product.find_by_id(@product_id).detail_image rescue ''
    @ip = get_ip
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
      @car_price = params[:car_price].to_i
      if @car_price <= 2
        BusinessException.raise "车价不正确"
      elsif @car_price >= 100
        @car_price = 100
      end
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = ::OrderSystem::Product.find_by_server_name("bijia").id
      @ip = params[:ip]
      ::UserSystem::UserInfo.create_user_info params.permit(:month, :car_price, :city, :car_number, :phone, :ip).merge(:product_id => @product_id)
      redirect_to action: :display_price, city: params[:city], car_price: @car_price, product_id: @product_id
    rescue Exception => e
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = ::OrderSystem::Product.find_by_server_name("bijia").id
      @image_url = ::OrderSystem::Product.find_by_id(@product_id).detail_image rescue ''
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
    session[:car_number] = nil
  end

end
