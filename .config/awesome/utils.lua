local utils = {}

function utils.stringify(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or false
  depth = depth or 0

  local tmp = string.rep('  ', depth)

  if name then
    tmp = tmp .. name .. ' = '
  end

  if type(val) == 'table' then
    tmp = tmp .. '{' .. (not skipnewlines and '\n' or '')

    for k, v in pairs(val) do
      tmp = tmp .. utils.stringify(v, k, skipnewlines, depth + 1) .. ',' .. (not skipnewlines and '\n' or '')
    end

    tmp = tmp .. string.rep('  ', depth) .. '}'
  elseif type(val) == 'number' then
    tmp = tmp .. tostring(val)
  elseif type(val) == 'string' then
    tmp = tmp .. string.format('%q', val)
  elseif type(val) == 'boolean' then
    tmp = tmp .. (val and 'true' or 'false')
  else
    tmp = tmp .. '"[inserializeable datatype: ' .. type(val) .. ']"'
  end

  return tmp
end

function utils.strsplit(str, sep)
  sep = sep or ','
  local t = {}
  for field, s in string.gmatch(str, "([^" .. sep .. "]*)(" .. sep .. "?)") do
    table.insert(t,field)
    if s == "" then return t end
  end
end

function utils.table_pad_end(t, length, value)
  while #t < length do
    if type(value) == 'function' then
      table.insert(t, value(#t + 1))
    else
      table.insert(t, value)
    end
  end
  return t
end


function utils.table_pad_start(t, length, value)
  while #t < length do
    if type(value) == 'function' then
      table.insert(t, 1, value(#t + 1))
    else
      table.insert(t, value)
    end
  end
  return t
end

return utils
