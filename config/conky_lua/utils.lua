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

function utils.striped_colour(colour1, colour2, row_number)
  if (row_number % 2 == 0) then
    return "${"..utils.unquote(colour2).."}"
  end

  return "${"..utils.unquote(colour1).."}"
end

function utils.unquote(str)
  return tostring(str):gsub("\"", "")
end

return utils
