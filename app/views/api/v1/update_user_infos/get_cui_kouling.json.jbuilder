if not @cui.blank?
  json.kouling @cui.wuba_kouling
  json.id @cui.id
else
  json.kouling ''
  json.id ''
end

