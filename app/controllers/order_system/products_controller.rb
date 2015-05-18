class OrderSystem::ProductsController < ApplicationController
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
      ::UserSystem::UserInfo.create_user_info params.permit(:car_number,:phone,:product_id)
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
    else
      @city = params[:city]
    end
    @car_price = params[:car_price]
    @car_number = params[:car_number_prefix] if params[:car_number].blank?
    @phone = params[:phone]
  end

  def search_price
    begin
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      ::UserSystem::UserInfo.create_user_info params.permit(:car_price, :city , :car_number, :phone, :product_id)
      render :display_price
    rescue Exception => e
      @cities = ::UserSystem::UserInfo::CITY
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      dispose_exception e
      @error_message = get_notice_str
      #dispose_exception e
      render :compare_price
    end
  end

  def display_price
    @car_insurance_prices = ::OrderSystem::CarInsurancePrice.where(city_name: params[:city],car_price: params[:car_price])
    @product_id = params[:product_id]
  end

  def get_city_name
    @cities = ::OrderSystem::Region.where(level: 2)
    @car_price = params[:car_price]
    @city = params[:city]
    @car_number = params[:car_number]
    @phone = params[:phone]
    @product_id = params[:product_id]
  end

end
