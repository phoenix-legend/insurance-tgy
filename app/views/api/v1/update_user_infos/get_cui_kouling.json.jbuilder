if not @cui.blank?
  json.kouling begin (@cui.wuba_kouling).gsub('https','http') rescue '' end
  json.id @cui.id
else
  json.kouling ''
  json.id ''
end

