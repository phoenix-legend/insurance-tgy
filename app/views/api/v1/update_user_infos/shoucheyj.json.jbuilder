json.date @date

json.array!(@result[:push]){|r|
  json.qudao r.qudao
  json.count r.c
  json.data_type 'tijiao'
}

json.array!(@result[:shangjia]){|r|
  json.qudao r.qudao
  json.count r.c
  json.data_type 'shangjia'
}

json.array!(@result[:chengjiao]){|r|
  json.qudao r.qudao
  json.count r.c
  json.data_type 'chengjiao'
}