http = require("http")
-- local urllib = assert(require "socket.url")
local spark = {}

spark.url = "https://downloads.apache.org/spark/"
spark.fallback = "https://archive.apache.org/dist/spark/"


local function pairsByKeys(t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  local i = 0             -- iterator variable
  local iter = function() -- iterator function
    i = i + 1
    if a[i] == nil then
      return nil
    else
      return a[i], t[a[i]]
    end
  end
  return iter
end


---comment
---@param tt table
---@param indent integer|nil
---@param done table|nil
---@return string
local function tableToString(tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairsByKeys(tt) do
      table.insert(sb, string.rep(" ", indent)) -- indent it
      if type(value) == "table" and not done[value] then
        done[value] = true
        table.insert(sb, key .. " = {\n");
        table.insert(sb, tableToString(value, indent + 2, done))
        table.insert(sb, string.rep(" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
          "%s = \"%s\"\n", tostring(key), tostring(value)))
      end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end


local function get_body(url)
  local resp, err = http.get({
    url = url,
    headers = {
      ['Host'] = "localhost"
    }
  })
  assert(err == nil)
  return resp.body, resp.status_code
end

---get_all_versions
---@return table
function spark:get_all_versions()
  local lts, lts_code = get_body(self.url)
  local archive, archive_code = get_body(self.fallback)
  if lts_code ~= 200 or archive_code ~= 200 then
    if lts_code ~= 200 then
      print("Failed to fetch LTS versions")
    elseif archive_code ~= 200 then
      print("Failed to fetch Archive versions")
    else
      error("Failed to fetch both LTS and Archive versions")
    end
  end
  local all_releases = {}
  for version in string.gmatch(archive, 'href="spark%-(%d.%d.%d)%/"') do
    all_releases[version] = {
      url = self.fallback,
      version = version,
      note = ""
    }
  end
  for version in string.gmatch(lts, 'href="spark%-(%d.%d.%d)%/"') do
    all_releases[version] = {
      url = self.url,
      version = version,
      note = "LTS"
    }
  end
  local function cmp(a, b) return a.version < b.version end
  table.sort(all_releases, cmp)
  -- print("All: " .. tableToString(all_releases))
  return all_releases
end

function spark:Download(version)
  local all_versions = self.get_all_versions(self)
  local details = all_versions[version]
  if not details then
    error("Failed to fetch versions")
  end
  if version then
    local file_name = version .. "-bin-hadoop3.tgz"
    local download_url = details.url .. version .. "/" .. file_name
    return {
      version = version,
      url = download_url,
      sha512 = file_name .. ".sha512",
    }
  end
  -- local parts = urllib.parse(url)
  -- local path = parts.path
  -- local file_name = string.match(path, "([^/]+)$")
  -- print("Downloading: " .. url .. " to test.jpg")
  -- print("Query: " .. utils:TableToSting(parts))
  -- print("File Name: " .. file_name)
  -- local body, code = http.request(url)
  -- if not body then error(code) end
  -- save the content to a file
  -- local f = assert(io.open(file_name, 'wb')) -- open in "binary" mode
  -- f:write(body)
  -- f:close()
end

spark:get_all_versions()

return spark
