local spark = require("spark")

--- Returns some pre-installed information, such as version number, download address, local files, etc.
--- If checksum is provided, vfox will automatically check it for you.
--- @param ctx table
--- @return table Version information
function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    local all_versions = spark:get_all_versions()
    if not all_versions then
        error("Failed to get all versions")
    end
    local details = all_versions[version]
    if not details then
        error("Version not found")
    end
    local file_name = "spark-" .. version .. "-bin-hadoop3.tgz"
    local download_url = details.url .. "spark-" .. version .. "/" .. file_name
    -- https://archive.apache.org/dist/spark/spark-3.5.2/spark-3.5.2-bin-hadoop3.tgz
    -- https://archive.apache.org/dist/spark/spark-3.5.2/3.5.2-bin-hadoop3.tgz
    print("Download URL: " .. download_url)
    return {
        version = version,
        url = download_url,
        -- sha512 = file_name .. ".sha512",
    }
end
