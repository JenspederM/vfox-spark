http = require("http")
html = require("html")
local utils = require("utils")

--SimpleRelease
---@class Release
---@field version string
---@field url string
---@field sha256 string
---@field sha512 string
SimpleRelease = {}

--- Repository for Apache Spark
--- @class repository
local repository = {
  url = "https://www.apache.org/dist/spark",
  fallback = "https://archive.apache.org/dist/spark"
}

local function get_versions(url)
  local response, err = http.get({ url = url })
  if err ~= nil then
    error("Failed to fetch versions from: " .. url .. " - " .. err)
  end
  local doc = html.parse(response.body)
  local text = doc:find("a"):text()
  local releases = {}
  for match in string.gmatch(text, 'spark%-(%d%.%d%.%d).') do
    table.insert(releases, match)
  end
  return releases
end

local function parse_sha(url)
  local response, err = http.get({ url = url })
  if err then
    error("Failed to fetch SHA from: " .. url .. " - " .. err)
  end
  return response.body:match("([a-f0-9]+)")
end

--- List all available versions of Apache Spark
--- @return table
function repository:List()
  local latest = get_versions(self.url)
  local archive = get_versions(self.fallback)
  local unique_versions = {}
  local releases = {}
  for _, version in ipairs(archive) do
    if not utils:Contains(unique_versions, version) then
      table.insert(unique_versions, version)
      if not utils:Contains(latest, version) then
        table.insert(releases, {
          name = "spark",
          version = version,
        })
      else
        table.insert(releases, {
          name = "spark",
          version = version,
          note = "LTS"
        })
      end
    end
  end
  table.sort(releases, function(a, b)
    return a.version > b.version
  end)
  return releases
end

--- Get the download URL for a specific version of Apache Spark
--- @param version string
--- @return Release
function repository:GetDownloadUrl(version)
  local url = string.format("%s/spark-%s", repository.url, version)
  local response, err = http.get({ url = url })
  if err then
    url = string.format("%s/spark-%s", repository.fallback, version)
    response, err = http.get({ url = url })
    if err then
      error("Error fetching from default URL: " .. err)
    end
  end
  local doc = html.parse(response.body)
  local links = {}
  doc:find("a"):each(function(_, anchor)
    local href = anchor:attr("href")
    if string.match(href, "^spark%-") and string.match(href, "%-hadoop3%.") then
      table.insert(links, string.format("%s/%s", url, href))
    end
  end)

  local downloadUrl
  local sha256
  local sha512
  for _, link in ipairs(links) do
    if string.match(link, ".tgz$") then
      downloadUrl = link
    elseif string.match(link, "%.sha256$") then
      sha256 = parse_sha(link)
    elseif string.match(link, "%.sha512$") then
      sha512 = parse_sha(link)
    end
  end
  print(utils:TableToString({
    version = version,
    url = downloadUrl,
    sha256 = sha256,
    sha512 = sha512,
  }))
  -- error("No valid download URL found for version: " .. version)

  return {
    version = version,
    url = downloadUrl,
    sha256 = sha256,
    sha512 = sha512,
  }
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
--     local body, code = http.get(url)
--     if not body then error(code) end
--     -- save the content to a file
--     local f = assert(io.open(file_name, 'wb')) -- open in "binary" mode
--     f:write(body)
--     f:close()
-- end

-- repository:List()

return repository
