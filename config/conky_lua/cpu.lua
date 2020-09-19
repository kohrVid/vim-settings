function number_of_cpus()
  local file = io.popen("grep -c processor /proc/cpuinfo", "r")
  return file:read("*n")
  --file:close()
end

function conky_mycpus()
  local file = io.popen("grep -c processor /proc/cpuinfo", "r")
  numcpus = file:read("*n")
  --numcpus = number_of_cpus
  file:close()

  listcpus = {}

  for i = 1,numcpus
  do
    listcpus[i] = "${color1}CPU"..tostring(i).." Usage: $color${cpu cpu"..tostring(i).."}% ${cpubar cpu"..tostring(i).." 7}"
  end

  return table.concat(listcpus, "\n\t\t")
end
