utils = {}

function utils.split(s, delimiter)
  local result = {};
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

return utils
