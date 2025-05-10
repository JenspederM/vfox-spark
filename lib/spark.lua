http = require("http")
-- local urllib = assert(require "socket.url")
local spark = {}

spark.url = "https://downloads.apache.org/spark/"
spark.fallback = "https://archive.apache.org/dist/spark/"

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
  return all_releases
end

---Download
---@param version string
---@return table
function spark:Download(version)
  local all_versions = self.get_all_versions(self)
  local details = all_versions[version]
  if not details then
    error("Failed to fetch version '" .. version .. "'")
  end
  local file_name = "spark-" .. version .. "-bin-hadoop3.tgz"
  local download_url = details.url .. "spark-" .. version .. "/" .. file_name
  local sha, sha_code = get_body(download_url .. ".sha512")
  if sha_code ~= 200 then
    error("Failed to fetch sha512 checksum")
  end
  sha = string.match(sha, "([0-9a-f]+)")
  return {
    version = version,
    url = download_url,
    sha512 = sha,
  }
end

return spark
