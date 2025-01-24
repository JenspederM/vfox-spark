http = require("socket.http")

--- Repository for Apache Spark
--- @class Repository
--- @field Url string
--- @field ArchiveUrl string
local Repository = {
  Url = "https://downloads.apache.org/spark/",
  ArchiveUrl = "https://archive.apache.org/dist/spark/",
}

--- List all available versions of Apache Spark
--- @return table
function Repository:List()
  local archive_url = util:GetUrl(false)
  local lts_url = util:GetUrl(true)
  local archive = get_spark_releases(archive_url)
  local lts = get_spark_releases(lts_url)
  for k, v in pairs(lts) do archive[k] = v end
  local all_releases = {}
  for _, version in pairs(archive) do
    local release = {
      version = version,
      note = contains(lts, version) and "LTS" or nil,
      url = contains(lts, version) and lts_url or archive_url,
      addition = {
        {
          name = "spark",
          version = version,
        }
      }
    }
    table.insert(all_releases, release)
  end
  print("All: " .. table_print(all_releases))
  return all_releases
end

return Repository
