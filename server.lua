local selllocationKeys = {}
for k, _ in pairs(Config.sellLocations) do
    table.insert(selllocationKeys, k)
end

local robberStatus = {}
local bankStatus = {}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.blipUpdateDelay)
        for k, v in pairs(robberStatus) do
            v.location = GetEntityCoords(GetPlayerPed(k))
        end
        TriggerClientEvent("Robbery:updateblips", -1, robberStatus)
    end
end)

RegisterNetEvent("Robbery:trigger")
AddEventHandler("Robbery:trigger", function(name, bankData)
    if bankStatus[name] then
        TriggerClientEvent('okokNotify:Alert', source, 'Bank', name .. ' is on cooldown!', 3000, 'error', true)
        return
    end

    for _, player in ipairs(GetPlayers()) do
        if Player(player).state["gsrp:onDuty"] == "yes" then
            TriggerClientEvent('okokNotify:Alert', player, 'Bank Alarm', name .. ' at ' .. bankData.x .. ", " .. bankData.y .. ", " .. bankData.z .. " Is being robbed!!!", 3000, 'warning', true)
        end
    end

    SetPedComponentVariation(GetPlayerPed(source), 5, Config.duffelBags[math.random(#Config.duffelBags)], 0, 1)

    local sellLocation = Config.sellLocations[selllocationKeys[math.random(#selllocationKeys)]]
    robberStatus[source] = {location = GetEntityCoords(GetPlayerPed(source)), sellLocation = sellLocation}

    TriggerClientEvent("Robbery:createSellBlip", source, sellLocation)

    bankStatus[name] = true
    Citizen.CreateThread(function()
        Citizen.Wait(Config.RobberyCooldown * 1000)
        bankStatus[name] = nil
    end)
end)


RegisterNetEvent("Robbery:sell")
AddEventHandler("Robbery:sell", function()
    if not robberStatus[source] then
        TriggerClientEvent('okokNotify:Alert', source, 'Error', 'Come back when you have something for me!', 3000, 'error', true)
        print("Error: No robber status found for source!")
        return
    end

    local sellCoords = robberStatus[source].sellLocation
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    if not sellCoords then
        print("Error: No sell location coordinates found!")
        return
    end

    local dx = sellCoords.x - playerCoords.x
    local dy = sellCoords.y - playerCoords.y
    local dz = sellCoords.z - playerCoords.z

    local squaredDistance = dx * dx + dy * dy + dz * dz

    local distance = math.sqrt(squaredDistance)

    if distance > 5.0 then
        TriggerClientEvent('okokNotify:Alert', source, 'Error', 'You are too far from the correct sell location!', 3000, 'error', true)
        return
    end

    TriggerClientEvent('okokNotify:Alert', source, 'Sale Complete', 'You have successfully sold the stolen goods!', 3000, 'success', true)
    SetPedComponentVariation(GetPlayerPed(source), 5, 0, 0, 1)
    robberStatus[source] = nil
    TriggerClientEvent("Robbery:removeSellBlip", source)

    for _, player in ipairs(GetPlayers()) do
        if Player(player).state["gsrp:onDuty"] == "yes" then
            TriggerClientEvent('okokNotify:Alert', player, 'Bank Robbery', "Bank Robbery Suspect has gotten away", 3000, 'warning', true)
        end
    end
end)