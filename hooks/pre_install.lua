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
    local download = spark:Download(version)
    return download
end
