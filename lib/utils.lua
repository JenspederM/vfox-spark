http = require("http")

local utils = {}

---PrintTable
---@param tt table
---@param indent integer|nil
---@param done table|nil
---@return string
function utils:TableToString(tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairs(tt) do
            table.insert(sb, string.rep(" ", indent)) -- indent it
            if type(value) == "table" and not done[value] then
                done[value] = true
                table.insert(sb, key .. " = {\n");
                table.insert(sb, utils:TableToString(value, indent + 2, done))
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

---PrintTable
---@param tab table
---@param val any
---@return boolean
function utils:Contains(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

return utils
