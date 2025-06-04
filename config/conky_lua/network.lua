local globals = require 'conky_lua.globals'

local cache = {
  last_update = 0,
  current_ip = "",
  current_country = "",
}

function conky_ip()
  return "${color1}IP Address: $color${lua_parse get_ip } ${color1}Country: $color${lua_parse get_country }"
end

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
      "}${endif}"

    if not lan then
      lans[#lans+1]= ""
    else
      lans[#lans+1] = lan
    end
  end

  networks:close()

  return table.concat(lans, "\n\t\t")
end

function conky_get_ip()
  conky_update_api_cache()

  return cache.current_ip
end

function conky_get_country()
  conky_update_api_cache()

  return cache.current_country
end

function conky_update_api_cache()
  local now = os.time()

  if now - cache.last_update >= globals.interval() then
    -- Run wgets asynchronously
    os.execute("wget -qO- https://ipinfo.io/ip > /tmp/conky_current_ip &")
    os.execute("wget -qO- https://ipinfo.io/country > /tmp/conky_current_country &")
    cache.last_update = now
  end

  local f = io.open("/tmp/conky_current_ip", "r")
  if f then
    cache.current_ip = f:read("*a") or ""
    f:close()
  end

  f = io.open("/tmp/conky_current_country", "r")
  if f then
    cache.current_country = f:read("*a") or ""
    f:close()
  end
end
