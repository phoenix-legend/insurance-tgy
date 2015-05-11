class OrderSystem::ProductsController < ActionController::Base
  def index

  end

  def new_appointment
    @product_id = ::OrderSystem::Product.find_by_name('1元洗车').id
  end

  def create_appointment
    begin
      @car_number = params[:car_number]
      @phone = params[:phone]
      ::UserSystem::UserInfo.create_user_info params.permit(:car_number,:phone,:product_id)
      render appointment_success_order_system_products_path
    rescue Exception => e
      #@car_number = params[:car_number]
      @car_number = params[:car_number]
      @phone = params[:phone]
      @product_id = params[:product_id]
      #dispose_exception e
      render new_appointment_order_system_products_path
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
