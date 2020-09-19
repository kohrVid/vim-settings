--require 'cpu'
function split(s, delimiter)
  result = {};
  if s == nil then
    s = ""
  end

  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    if match ~= "" then
      table.insert(result, match);
    end
  end

  return result;
end

function conky_top(n)
  top_cmd = "top -o %CPU | head -n "..tostring(7+n).." | tail -n "..tostring(n)
  top_file = io.popen(top_cmd)
  top = {}
  for i = 1,n
  do
    top[i] = tostring(top_file:read())
  end
  print(top[1])
  --top_file:close()

  top_format = {}

  for i = 1,n
  do
    local top_row = split(top[i], " ")
    local pid = top_row[2]
    local name = top_row[13]
    local cpu = tonumber(top_row[10])-- / number_of_cpus()
    local memory = top_row[11]

    local colour = pick_colour(i)

    --print(table.concat(top_row, ","))
    top_format[i] = colour..tostring(name).."${goto 170}"..tostring(pid).."${goto 230}"..tostring(cpu).."${goto 310}"..tostring(memory)
  end

  --print(table.concat(top_format, "\n\t\t"))
  return table.concat(top_format, "\n\t\t")
end

function pick_colour(row_number)
  if row_number % 2 == 0 then
    return "${color2}"
  else
    return "${color}"
  end
end
