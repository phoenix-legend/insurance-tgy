class Wz::WangzhanController < ApplicationController

  around_filter :round

  def round
    
yield
  end

  def current_user
    return nil if session[:employee_id].blank?
    ::Personal::Employee.find(session[:employee_id])
  end


  alias  current_employee current_user


  def need_login
    redirect_to '/cms/employee_validate/functions/login' if current_user.blank?
    return
  end
end
