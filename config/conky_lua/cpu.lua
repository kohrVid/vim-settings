cpu = {}

function conky_cpus()
  local listcpus = {}

  for i = 1, cpu.number_of_cpus() do
    if not i
      then
      lisstcpus[i] = ""
    else
      listcpus[i] = "${color1}CPU"..
        tostring(i)..
        " Usage: $color${cpu cpu"..
        tostring(i)..
        "}% ${cpubar cpu"..
        tostring(i).." 7}"
    end
  end

  return table.concat(listcpus, "\n\t\t")
end

function cpu.number_of_cpus()
  local file = io.popen("grep -c processor /proc/cpuinfo", "r")
  numcpus = file:read("*n")
  file:close()

  return numcpus
end

return cpu
