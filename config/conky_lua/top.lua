require 'math'
require 'string'
local cpu = require 'conky_lua.cpu'
local utils = require 'conky_lua.utils'
local globals = require 'conky_lua.globals'
local pid_margin = "${goto 172}"
local cpu_margin = "${goto 260}"
local mem_margin = "${goto 360}"

function conky_top(n, order_by)
  local top_procs = {}

  local output = tostring(
    conky_parse(
      "${execi "..globals.interval().." "..top_cmd(n, order_by).." | column -t }"
    )
  )

  set_top_procs(top_procs, output)

  return formatted_procs(top_procs, order_by)
end

function top_cmd(n, order_by)
  if not order_by then return "" end

  local cmd = utils.unquote(
      "ps -eo comm,pid,%cpu,%mem --sort=-%"..
      string.lower(tostring(order_by))
    )..
    " | head -n "..tostring(n)..
    " | tail -n "..tostring(n)

  return cmd
end

function set_top_procs(top_procs, output)
  for idx, top_proc in ipairs(utils.split(output, "\n+")) do
    if top_proc and (idx ~= 1) then
      top_procs[idx] = tostring(command_row(top_proc, idx))
    end
  end
end

function formatted_procs(top_procs, order_by)
  local filtered_procs = {
    top_headers(order_by)
  }

  for idx, proc in pairs(top_procs) do
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

  local name = top_row[1]
  if (name == nil) or (name == "") then return "" end

  local pid = top_row[2]
  local memory = top_row[4]
  local cpu = tonumber(top_row[3]) / cpu.number_of_cpus()
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
