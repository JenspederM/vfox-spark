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
        for key, value in pairs(tt) do
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

--- Each SDK may have different environment variable configurations.
--- This allows plugins to define custom environment variables (including PATH settings)
--- Note: Be sure to distinguish between environment variable settings for different platforms!
--- @param ctx table Context information
function PLUGIN:EnvKeys(ctx)
    local mainSdkInfo = ctx
    print("Ctx: " .. tableToString(mainSdkInfo))
    -- /Users/jenspedermeldgaard/.version-fox/temp/1737759600-22869/spark
    local path = mainSdkInfo.path
    local rootPath = path or ""
    -- local path = ctx.sdkInfo["path"]
    -- print("Main: " .. mainSdkInfo["path"])
    -- print("Sdk: " .. path)
    local envTable = {
        {
            key = "SPARK_HOME",
            value = rootPath
        },
        {
            key = "PATH",
            value = rootPath .. "/bin"
        }
    }
    for _, v in pairs(envTable) do
        for k, v in pairs(v) do
            print(k, v)
        end
    end
    return envTable
end

PLUGIN:EnvKeys({})
