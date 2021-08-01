function conky_lans()
  lans = {}
  networks = io.popen("ls /sys/class/net/")

  for network in networks:lines() do
    local lan = "${if_match ${upspeedf "..tostring(network).."} <= 0.0}${else}${color1}"..tostring(network).." Up: $color${upspeed "..tostring(network).."} ${color1}Down:$color ${downspeed "..tostring(network).."}\n\t\t${endif}"

    lans[#lans+1] = lan
  end

  networks:close()
  return table.concat(lans, "")
end
