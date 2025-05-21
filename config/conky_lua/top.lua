local cpu = require 'conky_lua.cpu'
local utils = require 'conky_lua.utils'
local pid_margin = "${goto 172}"
local cpu_margin = "${goto 260}"
local mem_margin = "${goto 360}"

function conky_top(n)
  local top_cmd = "top -b -o %MEM -d 0.5 -U $USER | head -n "..
    tostring(7+n)..
    " | tail -n "..tostring(n)

  local top_procs = {}
  local top_file = io.popen(
    "script -q -c '"..tostring(top_cmd).."' /dev/null"
  )

  if not top_file then return "" end

  for top_proc in top_file:lines() do
    local idx = #top_procs+1

    if top_proc then top_procs[idx] = tostring(command_row(top_proc, idx)) end
  end

  top_file:close()

  local filtered_procs = {
    "${color1}Name"..pid_margin.."PID"..
      cpu_margin.."CPU"..
      mem_margin.."%MEM"
  }

  for _, proc in ipairs(top_procs) do
    if proc:match("%S")
      then
        table.insert(filtered_procs, proc)
    end
  end

  return table.concat(filtered_procs, "\n\t\t")
end

function command_name(name)
  local cmd_name = tostring(name:gsub("[%z\1-\31\127]", ""))

  if cmd_name:match("^%[%m")
    then
      return ""
  else
      return cmd_name
  end
end

function command_row(top_proc, idx)
  local colour = striped_colour(idx)
  local top_row = utils.split(top_proc, " ")

  local name = command_name(top_row[12])
  if name == "" then return "" end

  local pid = top_row[1]
  local memory = top_row[10]
  local cpu = top_row[9] / cpu.number_of_cpus()

  return colour..name..
    pid_margin..tostring(pid)..
    cpu_margin..tostring(cpu)..
    mem_margin..tostring(memory)
end

function striped_colour(row_number)
  if row_number % 2 == 0 then
    return "${color2}"
  else
    return "${color}"
  end
end
