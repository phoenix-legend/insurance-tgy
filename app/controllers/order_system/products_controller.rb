class OrderSystem::ProductsController < ActionController::Base
  def index

  end

  def new_appointment
    @product_id = ::OrderSystem::Product.find_by_name("1元洗车")
  end

  def create_appointment
    begin
      #1/0
      @car_number = params[:car_number]
      @phone = params[:phone]
      #::UserSystem::UserInfo.create_user_info params.permit(:car_number, :phone,:product_id)
        render appointment_success_order_system_products_path
    rescue Exception => e
      @car_number = params[:car_number]
      @phone = params[:phone]
      render new_appointment_order_system_products_path
    end
  end

  def appointment_success

  end

  def compare_price
    @product_id = ::OrderSystem::Product.find_by_name("车险比价")
    @cities = ['上海', '北京', '苏州']
    #@cities = ::UserSystem::UserInfo::CITY
    @city = '上海'
  end

  def search_price
    begin
      #1/0
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      #::UserSystem::UserInfo.create_user_info params.permit(:car_price, :city :car_number, :phone, :product_id) TODO
      render display_price_order_system_products_path
    rescue Exception => e
      @cities = {'上海' => '1', '北京' => '2', '苏州' => '3'}
      @car_price = params[:car_price]
      @city = params[:city]
      @car_number = params[:car_number]
      @phone = params[:phone]
      render compare_price_order_system_products_path
    end
  end

  def display_price

  end

end
