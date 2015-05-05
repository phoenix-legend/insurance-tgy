module ApplicationHelper
  def get_notice
    str = session[:notice]
    session[:notice] = nil
    str
  end


  def get_notice_str is_all=true
    if session[:notice].class == String
      str = session[:notice]
      session[:notice] = nil
      str
    end
    if is_all
      return str if not str.blank?
      h = get_notice_hash
      if h.values.length>0
        return h.values[0]
      end
    else
      return str
    end
  end

  def get_notice_hash
    if session[:notice].class == Hash
      str = session[:notice]
      session[:notice] = nil
      str
    else
      Hash.new('')
    end
  end


  def get_really_user_id id
    return id if id.class == Fixnum
    return id if id.match /^(\d)*$/
    member_info = MemberInfo.find_by_member_id id
    member_info.id
  end

  def get_really_member_id id
    if id.class == Fixnum
      member_info = MemberInfo.find id
      return member_info.member_id
    end
    if id.match /^(\d)*$/
      member_info = MemberInfo.find id.to_i
      return member_info.member_id
    end
    return id
  end

  def week_days
    [["周一",1], ["周二", 2], ["周三", 3], ["周四", 4], ["周五", 5], ["周六", 6], ["周日", 7]]
  end
end
