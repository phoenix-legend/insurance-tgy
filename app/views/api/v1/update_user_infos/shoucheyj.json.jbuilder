json.date @date

json.tijiao json.array!(@result[:push]){|r|
  json.qudao r.qudao
  json.count r.c
}

json.shangjia json.array!(@result[:shangjia]){|r|
  json.qudao r.qudao
  json.count r.c
}

json.chengjiao json.array!(@result[:chengjiao]){|r|
  json.qudao r.qudao
  json.count r.c
}