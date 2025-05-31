require 'math'
require 'string'
local cpu = require 'conky_lua.cpu'
local utils = require 'conky_lua.utils'
local pid_margin = "${goto 172}"
local cpu_margin = "${goto 260}"
local mem_margin = "${goto 360}"

function conky_top(n, order_by)
  local top_procs = {}

  local top_file = io.popen(top_cmd(n, order_by))
  if not top_file then return "" end
  set_top_procs(top_procs, top_file)
  top_file:close()

  return formatted_procs(top_procs, order_by)
end

function top_cmd(n, order_by)
  if not order_by then return "" end

  local cmd = "top -b -o %"..
    tostring(order_by)..
    " -d 0.5 | head -n "..
    tostring(7+n)..
    " | tail -n "..tostring(n)

  return "script -q -c '"..utils.unquote(cmd).."' /dev/null"
end

function set_top_procs(top_procs, top_file)
  for top_proc in top_file:lines() do
    local idx = #top_procs+1

    if top_proc then top_procs[idx] = tostring(command_row(top_proc, idx)) end
  end
end

function formatted_procs(top_procs, order_by)
  local filtered_procs = {
    top_headers(order_by)
  }

  for _, proc in ipairs(top_procs) do
    if proc:match("%S")
      then
        table.insert(filtered_procs, proc)
    end
  end

  table.insert(filtered_procs, "\n")

  return table.concat(filtered_procs, "\n\t\t")
end

function top_headers(order_by)
  return "${color1}Top "..
    utils.unquote(order_by)..
    " usage\n\t\t${color1}Name"..
    pid_margin.."PID"..
    cpu_margin.."CPU"..
    mem_margin.."MEM"
end

function command_row(top_proc, idx)
  local colour = utils.striped_colour("color", "color2", idx)
  local top_row = utils.split(top_proc, " ")

  local name = command_name(top_row[12])
  if name == "" then return "" end

  local pid = top_row[1]
  local memory = top_row[10]
  local cpu = top_row[9] / cpu.number_of_cpus()
  local cpu_formatted = tonumber(string.format("%.2f", cpu))

  return colour..name..
    pid_margin..tostring(pid)..
    cpu_margin..tostring(cpu_formatted)..
    mem_margin..tostring(memory)
end

function command_name(name)
  local cmd_name = tostring(name:gsub("[%z\1-\31\127]", ""))

  if cmd_name:match("^%[%m")
    then
      return ""
  end

  return cmd_name
end
