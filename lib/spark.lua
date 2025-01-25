http = require("socket.http")
-- local urllib = assert(require "socket.url")
-- local utils = require("lib/util")
local spark = {}

spark.url = "https://downloads.apache.org/spark/"
spark.fallback = "https://archive.apache.org/dist/spark/"

function spark:get_all_versions()
  local lts, lts_code = http.request(self.url)
  local archive, archive_code = http.request(self.fallback)
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
  table.sort(all_releases)
  -- print("All: " .. utils:TableToSting(all_releases))
  return all_releases
end

-- function spark:Download(version)
--   local url = self.get_all_versions(self)
--   if not url then
--     error("Failed to fetch versions")
--   end
--   if version then
--     local base = let_lts and self.url or self.fallback
--     local file_name = version .. "-bin-hadoop3-scala2.13.tgz"
--     local download_url = base .. version .. "/" .. file_name
--     return {
--       version = version,
--       url = download_url,
--       sha512 = file_name .. ".sha512",
--       addition = {
--         {
--           name = "spark",
--           version = version,
--           url = download_url,
--         }
--       }
--     }
--   end
--   local parts = urllib.parse(url)
--   local path = parts.path
--   local file_name = string.match(path, "([^/]+)$")
--   print("Downloading: " .. url .. " to test.jpg")
--   print("Query: " .. utils:TableToSting(parts))
--   print("File Name: " .. file_name)
--   local body, code = http.request(url)
--   if not body then error(code) end
--   -- save the content to a file
--   local f = assert(io.open(file_name, 'wb')) -- open in "binary" mode
--   f:write(body)
--   f:close()
-- end

spark:get_all_versions()

return spark
