class Api::V1::UpdateUserInfosController < Api::V1::BaseController

  def update_user_by_xiecheyangche
    ::UserSystem::UserInfo.update_user_by_xieche params[:id]
  end

end