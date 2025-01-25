local utils = {}

local function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0             -- iterator variable
    local iter = function() -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end


---comment
---@param tt table
---@param indent integer|nil
---@param done table|nil
---@return string
function utils:tableToString(tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairsByKeys(tt) do
            table.insert(sb, string.rep(" ", indent)) -- indent it
            if type(value) == "table" and not done[value] then
                done[value] = true
                table.insert(sb, key .. " = {\n");
                table.insert(sb, utils:tableToString(value, indent + 2, done))
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
---@param tab table
---@param val any
---@return boolean
function utils:contains(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

return utils
