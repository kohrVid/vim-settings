function conky_lans()
  local lans = {}
  local networks = io.popen("ls /sys/class/net/")

  for network in networks:lines() do
    local lan = "${if_match ${upspeedf "..
      tostring(network).."} <= 0.0}${else}${color1}"..
      tostring(network).." Up: $color${upspeed "..
      tostring(network)..
      "} ${color1}Down:$color ${downspeed "..
      tostring(network)..
      "}\n\t\t${endif}"

    if not lan then
      lans[#lans+1]= ""
    else
      lans[#lans+1] = lan
    end
  end

  networks:close()

  return table.concat(lans, "")
end
