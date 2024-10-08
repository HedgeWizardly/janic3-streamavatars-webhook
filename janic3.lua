local json = {}
socket = 'janic3_socket'; --just storing the title in a global variable...
channelId = 'YOURIDHERE'
endpoint = 'wss://janic3-bot.herokuapp.com/'

-- Internal functions.

local function kind_of(obj)
  if type(obj) ~= 'table' then return type(obj) end
  local i = 1
  for _ in pairs(obj) do
    if obj[i] ~= nil then i = i + 1 else return 'table' end
  end
  if i == 1 then return 'table' else return 'array' end
end

local function escape_str(s)
  local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
  local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
  for i, c in ipairs(in_char) do
    s = s:gsub(c, '\\' .. out_char[i])
  end
  return s
end

local function skip_delim(str, pos, delim, err_if_missing)
  pos = pos + #str:match('^%s*', pos)
  if str:sub(pos, pos) ~= delim then
    if err_if_missing then
      error('Expected ' .. delim .. ' near position ' .. pos)
    end
    return pos, false
  end
  return pos + 1, true
end

local function parse_str_val(str, pos, val)
  val = val or ''
  local early_end_error = 'End of input found while parsing string.'
  if pos > #str then error(early_end_error) end
  local c = str:sub(pos, pos)
  if c == '"'  then return val, pos + 1 end
  if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
  -- We must have a \ character.
  local esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}
  local nextc = str:sub(pos + 1, pos + 1)
  if not nextc then error(early_end_error) end
  return parse_str_val(str, pos + 2, val .. (esc_map[nextc] or nextc))
end

local function parse_num_val(str, pos)
  local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
  local val = tonumber(num_str)
  if not val then error('Error parsing number at position ' .. pos .. '.') end
  return val, pos + #num_str
end

function json.stringify(obj, as_key)
  local s = {}  -- We'll build the string as an array of strings to be concatenated.
  local kind = kind_of(obj)  -- This is 'array' if it's an array or type(obj) otherwise.
  if kind == 'array' then
    if as_key then error('Can\'t encode array as key.') end
    s[#s + 1] = '['
    for i, val in ipairs(obj) do
      if i > 1 then s[#s + 1] = ', ' end
      s[#s + 1] = json.stringify(val)
    end
    s[#s + 1] = ']'
  elseif kind == 'table' then
    if as_key then error('Can\'t encode table as key.') end
    s[#s + 1] = '{'
    for k, v in pairs(obj) do
      if #s > 1 then s[#s + 1] = ', ' end
      s[#s + 1] = json.stringify(k, true)
      s[#s + 1] = ':'
      s[#s + 1] = json.stringify(v)
    end
    s[#s + 1] = '}'
  elseif kind == 'string' then
    return '"' .. escape_str(obj) .. '"'
  elseif kind == 'number' then
    if as_key then return '"' .. tostring(obj) .. '"' end
    return tostring(obj)
  elseif kind == 'boolean' then
    return tostring(obj)
  elseif kind == 'nil' then
    return 'null'
  else
    error('Unjsonifiable type: ' .. kind .. '.')
  end
  return table.concat(s)
end

json.null = {}  -- This is a one-off table to represent the null value.

function json.parse(str, pos, end_delim)
  pos = pos or 1
  if pos > #str then error('Reached unexpected end of input.') end
  local pos = pos + #str:match('^%s*', pos)  -- Skip whitespace.
  local first = str:sub(pos, pos)
  if first == '{' then  -- Parse an object.
    local obj, key, delim_found = {}, true, true
    pos = pos + 1
    while true do
      key, pos = json.parse(str, pos, '}')
      if key == nil then return obj, pos end
      if not delim_found then error('Comma missing between object items.') end
      pos = skip_delim(str, pos, ':', true)  -- true -> error if missing.
      obj[key], pos = json.parse(str, pos)
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '[' then  -- Parse an array.
    local arr, val, delim_found = {}, true, true
    pos = pos + 1
    while true do
      val, pos = json.parse(str, pos, ']')
      if val == nil then return arr, pos end
      if not delim_found then error('Comma missing between array items.') end
      arr[#arr + 1] = val
      pos, delim_found = skip_delim(str, pos, ',')
    end
  elseif first == '"' then  -- Parse a string.
    return parse_str_val(str, pos + 1)
  elseif first == '-' or first:match('%d') then  -- Parse a number.
    return parse_num_val(str, pos)
  elseif first == end_delim then  -- End of an object or array.
    return nil, pos + 1
  else  -- Parse true, false, or null.
    local literals = {['true'] = true, ['false'] = false, ['null'] = json.null}
    for lit_str, lit_val in pairs(literals) do
      local lit_end = pos + #lit_str - 1
      if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
    end
    local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
    error('Invalid json syntax starting at ' .. pos_info_str)
  end
end



function grantCurrency(user, amount)
log('Grant user: ' .. user .. ' amount: ' .. amount)
    local findUser = getUser(user);
    if findUser ~= nil then
      local success, newBalance = addCurrency(findUser, amount); 
      return newBalance
  else
      error('could not find target user');
  end
end

data = {}


function connect()
    local mData = get('data');

  if mData.connectionAttempt < 10 then
    mData.connectionAttempt = mData.connectionAttempt + 1;
    set('data', mData);
    save()
    wait(5*mData.connectionAttempt)
    log('Connection Attempt: ' .. mData.connectionAttempt)
    local app = getApp();
    app.removeWebSocket(socket);  --remove old existing websocket just incase...
    wait(1); --give it time to remove the old one
    addEvent('websocket', 'yourEvent'); --subscribe to all websockets that exist...
    local protocols = {  channelId  }; 
    app.createWebsocket(socket, endpoint, protocols); --title a websoscket and connect to a server...
    wait(2); --give it time to connect
    app.sendWebsocketMessage(socket, 'Client Connected!');
    wait(2);
    
  end
end

function yourEvent(title, type, message, code)
    if title ~= socket then --make sure we're using the socket title we want!
        return; --otherwise exit out early :)
    end
    local mData = get('data');
    setProperty(mData, 'grantedTransactions', {})

    if type == 'OnMessage' then
        request = json.parse(message)
        log('receiving message: ' .. request["docId"] .. " - REQUEST: []" .. request["type"] .. "] - " .. request["value"]);
          target = request["targetName"]

          if request["type"] == "currency" and mData.grantedTransactions[request["docId"]]~=true then
            log('Process currency request')
            mData.grantedTransactions[request["docId"]] = true
            set('data', mData);
            save()
            local ok, res = pcall(grantCurrency, target, request['value'])  -- res is the new balance
            if not ok then
              log('Error with transaction for ' .. request['docId'])
            else
              log('Confirm ' .. request['docId'] .. ' with server')
              local app = getApp();
              responseObject = {};
              responseObject["docId"] = request["docId"];
              app.sendWebsocketMessage(socket, json.stringify(responseObject));
            end
          else
            log('already processed')
        end
        
    end
    if type == 'OnOpen' then
        --the socket opened!!
        log('Socket opened!');
        local mData = get('data');
        mData.connectionAttempt = 0;
        set('data', mData)
        save()

    end
    if type == 'OnClose' or type == 'OnError' then --if the message type is OnClose or OnError, let's clean up the socket...
        local app = getApp();
        app.removeWebSocket(socket);
        log('Socket closed!');
        connect()  
    end
end

return function()
  local mData = get('data');
  setProperty(mData, 'connectionAttempt', 0)
  mData.connectionAttempt = 0;
  set('data', mData)
  save()

  connect();
  keepAlive();
end


