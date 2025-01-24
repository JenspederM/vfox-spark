http = require("socket.http")
local utils = require("lib.utils")

--SimpleRelease
---@class SimpleRelease
---@field version string
---@field url string
---@field is_lts boolean
SimpleRelease = {}

--- Repository for Apache Spark
--- @class repository
local repository = {
  url = "https://www.apache.org/dist/spark",
  fallback = "https://archive.apache.org/dist/spark"
}


--- Get the download URL for a specific version of Apache Spark
--- @param version string
--- @return string
local function get_download_url(version)
  local default = string.format("%s/spark-%s", repository.url, version)
  local fallback = string.format("%s/spark-%s", repository.fallback, version)
  local code = http.request(default)
  if code ~= 200 then
    local code = http.request(fallback)
    if code == 404 then
      error("Version not found: " .. version)
    end
    return fallback
  end
  return default
end

local function get_versions(url)
  local body, code = http.request(url)
  if code ~= 200 then return {} end
  local releases = {}
  for match in string.gmatch(body, 'href="spark%-(%d%.%d%.%d)."') do
    local suburl = string.format("%s/spark-%s", url, match)
    local body, code = http.request(suburl)
    print(suburl, code)
    if code ~= 200 then
      error("Failed to fetch: " .. suburl)
    end
    -- print("body: " .. body)
    for file in string.gmatch(body, 'href=\"(spark%-.-)\"') do
      print("Found: " .. file)
      -- table.insert(releases, file)
    end
    -- table.insert(releases, match)
  end
  return releases
end

--- List all available versions of Apache Spark
--- @return table
function repository:List()
  local latest = get_versions(self.url)
  local archive = get_versions(self.fallback)
  for _, version in ipairs(archive) do
    if not utils:Contains(latest, version) then
      table.insert(latest, version)
    end
  end
  table.sort(latest)
  local releases = {}
  for _, version in ipairs(latest) do
    table.insert(releases, {
      name = "spark",
      version = version,
    })
  end
  print(utils:TableToString(releases))
  return releases
end

-- function utils:Download(version)
--     local url = utils:GetUrl(true, version)
--     if version then
--         local base = let_lts and LtsUrl or ArchiveUrl
--         local file_name = version .. "-bin-hadoop3-scala2.13.tgz"
--         local download_url = base .. version .. "/" .. file_name
--         return {
--             version = version,
--             url = download_url,
--             sha512 = file_name .. ".sha512",
--             addition = {
--                 {
--                     name = "spark",
--                     version = version,
--                     url = download_url,
--                 }
--             }
--         }
--     end
--     local parts = urllib.parse(url)
--     local path = parts.path
--     local file_name = string.match(path, "([^/]+)$")
--     print("Downloading: " .. url .. " to test.jpg")
--     print("Query: " .. PrintTable(parts))
--     print("File Name: " .. file_name)
--     local body, code = http.request(url)
--     if not body then error(code) end
--     -- save the content to a file
--     local f = assert(io.open(file_name, 'wb')) -- open in "binary" mode
--     f:write(body)
--     f:close()
-- end

repository:List()

return repository
