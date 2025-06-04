globals = {}

function conky_interval()
  return globals.interval()
end

function globals.interval()
  return 3000
end


return globals
