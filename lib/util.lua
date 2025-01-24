http = require("socket.http")
local urllib = assert(require "socket.url")


local util = {}



---comment
---@param tt table
---@param indent integer|nil
---@param done table|nil
---@return string
local function table_print(tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairs(tt) do
            table.insert(sb, string.rep(" ", indent)) -- indent it
            if type(value) == "table" and not done[value] then
                done[value] = true
                table.insert(sb, key .. " = {\n");
                table.insert(sb, table_print(value, indent + 2, done))
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

---comment
---@param url string
---@return table
local function get_spark_releases(url)
    local body, code = http.request(url)
    if code ~= 200 then
        return {}
    end

    local result = {}
    for version in string.gmatch(body, 'href="spark--([^"]+)/"') do
        table.insert(result, {
            url = url,
            version = version
        })
    end
    return result
end

---comment
---@param tab table
---@param val any
---@return boolean
local function contains(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

---comment
---@return table
function util:GetReleases()
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

--- GetUrl
--- @param let_lts boolean
--- @return string
function util:GetUrl(let_lts)
    local ArchiveUrl = "https://archive.apache.org/dist/spark/"
    local LtsUrl = "https://downloads.apache.org/spark/"
    return let_lts and LtsUrl or ArchiveUrl
end

function util:Download(version)
    local url = util:GetUrl(true, version)
    if version then
        local base = let_lts and LtsUrl or ArchiveUrl
        local file_name = version .. "-bin-hadoop3-scala2.13.tgz"
        local download_url = base .. version .. "/" .. file_name
        return {
            version = version,
            url = download_url,
            sha512 = file_name .. ".sha512",
            addition = {
                {
                    name = "spark",
                    version = version,
                    url = download_url,
                }
            }
        }
    end
    local parts = urllib.parse(url)
    local path = parts.path
    local file_name = string.match(path, "([^/]+)$")
    print("Downloading: " .. url .. " to test.jpg")
    print("Query: " .. table_print(parts))
    print("File Name: " .. file_name)
    local body, code = http.request(url)
    if not body then error(code) end
    -- save the content to a file
    local f = assert(io.open(file_name, 'wb')) -- open in "binary" mode
    f:write(body)
    f:close()
end

print(util:GetUrl(false))
print(util:GetUrl(true, "spark-3.4.5"))

-- Download("spark-3.4.4")
return util
