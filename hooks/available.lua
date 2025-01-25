local spark = require("spark")

--- Return all available versions provided by this plugin
--- @param ctx table Empty table used as context, for future extension
--- @return table Descriptions of available versions and accompanying tool descriptions
function PLUGIN:Available(ctx)
    local all_versions = spark:get_all_versions()
    local available = {}
    for _, release in pairs(all_versions) do
        print(release)
        table.insert(available, release)
    end
    return available
end
