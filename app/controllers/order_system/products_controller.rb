class OrderSystem::ProductsController < ActionController::Base
  def index

  end

  def new_appointment

  end

  def create_appointment
    begin
      #1/0
      @car_number = params[:car_number]
      @phone = params[:phone]
      #::UserSystem::UserInfo.create_user_info params.permit(:car_number, :phone,:prouduct_id)
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

  end

  def search_price

  end

  def display_price

  end

end
