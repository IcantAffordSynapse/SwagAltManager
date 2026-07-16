--[[
Swag alt manager

this is not released, shit will not work
]]

local env = {}
local envPath = nil

local HttpService = game:GetService("HttpService")

local function GrabAcc(id, list)
    for i = #list, 1, -1 do
        if list[i].UserId == id then
            return list[i], i
        end
    end

    return false, "Not found"
end

function env:BuildEnv(envName, override)
    if isfolder(envName) then
        if not override then
            return false, "Already Exists"
        end
    end

    makefolder(envName)
    writefile(envName.."/accounts.json", "{}")
    writefile(envName.."/active.json", "{}")
    envPath = envName

    return true, "Created"
end

function env:CheckEnv(envName)
    local a = isfolder(envName)
    local b = isfile(envName.."/accounts.json")
    local c = isfile(envName.."/active.json")
    if a then envPath = envName end

    return {hasFolder = a, hasFile = b, hasActive = c}
end

function env:DeleteEnv(envName)
    if isfolder(envName) then
        delfolder(envName)
        envPath = nil
        return true, "Deleted"
    else
        return false, "Path doesn't exist"
    end
end

function env:AddAccount(data)
    if not envPath then return false, "Environment hasn't been set" end

    local accountsList = HttpService:JSONDecode(readfile(envPath.."/accounts.json"))
    table.insert(accountsList, data)

    local ok, err = pcall(writefile, envPath.."/accounts.json", HttpService:JSONEncode(accountsList))
    if not ok then return false, err end

    return true, "Added"

    --[[
    {
        UserId = userId,
        ExtraData = {
            ["Example"] = val
        }
    }
    ]]
end

function env:RemoveAccount(userId)
    if not envPath then return false, "Environment hasn't been set" end
    local accountsList = HttpService:JSONDecode(readfile(envPath.."/accounts.json"))

    local data, index = GrabAcc(userId, accountsList)
    if data then
        table.remove(accountsList, index)
    else
        return false, "Failed to find account"
    end

    local ok, err = pcall(writefile, envPath.."/accounts.json", HttpService:JSONEncode(accountsList))
    if not ok then return false, err end

    return true, "Removed"
end

function env:UpdateAccount(newData)
    if not envPath then return false, "Environment hasn't been set" end

    local accountsList = HttpService:JSONDecode(readfile(envPath.."/accounts.json"))

    local data, index = GrabAcc(newData.UserId, accountsList)
    if data then
        accountsList[index] = newData
    else
        return false, "Failed to find account"
    end

    local ok, err = pcall(writefile, envPath.."/accounts.json", HttpService:JSONEncode(accountsList))
    if not ok then return false, err end

    return true, "Updated"
    --[[
    {
        UserId = userId,
        ExtraData = {
            ["Example"] = val
        }
    }
    ]]
end

function env:GrabAccount(userId)
    if not envPath then return false, "Environment hasn't been set" end

    local accountsList = HttpService:JSONDecode(readfile(envPath.."/accounts.json"))

    local data, index = GrabAcc(userId, accountsList)
    if data then
        return true, data
    else
        return false, "Failed to find account"
    end
end

function env:GrabAllAccounts()
    if not envPath then return false, "Environment hasn't been set" end

    local accountsList = HttpService:JSONDecode(readfile(envPath.."/accounts.json"))

    return accountsList
end

return env
