require("default.hypr.helpers")

local module_name = "omarchy.plugins.oma-key-trainer.hook"
local state_dir = (os.getenv("HOME") or "") .. "/.local/state/omarchy/oma-key-trainer"
local counts_path = state_dir .. "/counts.json"
local temporary_path = counts_path .. ".tmp"

local function decode_json_string(value)
  local escapes = {
    ['\\"'] = '"',
    ["\\\\"] = "\\",
    ["\\/"] = "/",
    ["\\b"] = "\b",
    ["\\f"] = "\f",
    ["\\n"] = "\n",
    ["\\r"] = "\r",
    ["\\t"] = "\t",
  }

  return (value:gsub('\\["\\/bfnrt]', escapes))
end

local function encode_json_string(value)
  return (tostring(value):gsub('[%z\1-\31\\"]', function(character)
    local escapes = {
      ['"'] = '\\"',
      ["\\"] = "\\\\",
      ["\b"] = "\\b",
      ["\f"] = "\\f",
      ["\n"] = "\\n",
      ["\r"] = "\\r",
      ["\t"] = "\\t",
    }

    return escapes[character] or string.format("\\u%04x", string.byte(character))
  end))
end

local function load_counts()
  local counts = {}
  local file = io.open(counts_path, "r")
  if not file then
    return counts
  end

  local raw = file:read("*a") or ""
  file:close()

  local object = raw:match('"counts"%s*:%s*{(.-)}') or ""
  for action, count in object:gmatch('"([^"]-)"%s*:%s*(%d+)') do
    counts[decode_json_string(action)] = tonumber(count)
  end

  return counts
end

local counts = load_counts()

local function write_counts()
  local actions = {}
  for action in pairs(counts) do
    actions[#actions + 1] = action
  end
  table.sort(actions)

  local entries = {}
  for _, action in ipairs(actions) do
    entries[#entries + 1] = string.format('"%s":%d', encode_json_string(action), counts[action])
  end

  local file, open_error = io.open(temporary_path, "w")
  if not file then
    error(open_error)
  end

  local ok, write_error = file:write('{"version":1,"counts":{', table.concat(entries, ","), '}}\n')
  if not ok then
    file:close()
    error(write_error)
  end

  file:flush()
  file:close()

  local renamed, rename_error = os.rename(temporary_path, counts_path)
  if not renamed then
    error(rename_error)
  end
end

local function record(description)
  counts[description] = (counts[description] or 0) + 1
  write_counts()
end

local function resolve_dispatcher(dispatcher, description)
  if type(dispatcher) == "table" then
    if dispatcher.omarchy then
      dispatcher = "omarchy-launch-" .. dispatcher.omarchy
    elseif dispatcher.focus and dispatcher.launch then
      dispatcher = o.launch_sole(dispatcher.focus, dispatcher.launch)
    elseif dispatcher.launch then
      dispatcher = o.launch(dispatcher.launch)
    elseif dispatcher.webapp then
      if dispatcher.focus then
        dispatcher = o.launch_webapp_sole(description, dispatcher.webapp)
      else
        dispatcher = o.launch_webapp(dispatcher.webapp)
      end
    elseif dispatcher.tui then
      if dispatcher.focus then
        dispatcher = "omarchy-launch-or-focus-tui " .. o.shell_quote(dispatcher.tui)
      else
        dispatcher = "omarchy-launch-tui " .. o.shell_quote(dispatcher.tui)
      end
    end
  end

  if type(dispatcher) == "string" then
    return hl.dsp.exec_cmd(dispatcher)
  end

  return dispatcher
end

os.execute("mkdir -p " .. o.shell_quote(state_dir))

local previous_hook = o._oma_key_trainer_hook
if previous_hook and o.bind == previous_hook.wrapper then
  o.bind = previous_hook.original
end

local original_bind = o.bind
local function tracked_bind(keys, description, dispatcher, options)
  local resolved_dispatcher = resolve_dispatcher(dispatcher, description)

  if type(resolved_dispatcher) ~= "function" and type(resolved_dispatcher) ~= "userdata" then
    original_bind(keys, description, dispatcher, options)
    return
  end

  local function run(...)
    if description then
      pcall(record, description)
    end

    if type(resolved_dispatcher) == "function" then
      return resolved_dispatcher(...)
    end

    return hl.dispatch(resolved_dispatcher)
  end

  original_bind(keys, description, run, options)
end

o.bind = tracked_bind
o._oma_key_trainer_hook = {
  original = original_bind,
  wrapper = tracked_bind,
}

package.loaded[module_name] = nil
return false
