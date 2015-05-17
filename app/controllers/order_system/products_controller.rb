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
    @product_id = ::OrderSystem::Product.find_by_name("车险比价").id
    @cities = ::UserSystem::UserInfo::CITY
    @city = @cities.at(0)
  end

  def search_price
    begin
      #1/0
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      ::UserSystem::UserInfo.create_user_info params.permit(:car_price, :city , :car_number, :phone, :product_id)
      render display_price_order_system_products_path
    rescue Exception => e
      @cities = ::UserSystem::UserInfo::CITY
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      @phone = e.to_s
      #dispose_exception e
      render compare_price_order_system_products_path
    end
  end

  def display_price

  end

end
