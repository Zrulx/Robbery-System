local blips = {}

RegisterNetEvent("Robbery:updateblips")
AddEventHandler("Robbery:updateblips", function(newBankStatus)
    for k, v in ipairs(blips) do
        if DoesBlipExist(v) then
            RemoveBlip(v)
            table.remove(blips, k)
        end
    end

    local myId = GetPlayerServerId(PlayerId())

    for k, v in pairs(newBankStatus) do
        if v ~= nil and LocalPlayer.state["gsrp:onDuty"] == "yes" then
            local blip = AddBlipForCoord(v.location)
            SetBlipSprite(blip, 272)
            SetBlipColour(blip, 2)
            SetBlipDisplay(blip, 6)
            SetBlipScale(blip, 1.5)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("TEST")
            EndTextCommandSetBlipName(blip)
            table.insert(blips, blip)
        end
    end
end)

for name, bank in pairs(Config.bankLocations) do
    print("Adding robbery zone for bank: " .. name .. " at coords: " .. bank.x .. ", " .. bank.y .. ", " .. bank.z)
    exports.ox_target:addBoxZone({
        coords = vec3(bank.x, bank.y, bank.z),
        size = vec3(3, 3, 3),
        options = {
            {
                name = 'robber_' .. name,
                label = 'Rob ' .. name,
                icon = 'fa-solid fa-sack-dollar',
                onSelect = function(data)
                    TriggerServerEvent("Robbery:trigger", name, bank)
                end
            }
        },
    })
end

for name, location in pairs(Config.sellLocations) do
    print("Adding sell location zone at coords: " .. location.x .. ", " .. location.y .. ", " .. location.z)
    exports.ox_target:addBoxZone({
        coords = vec3(location.x, location.y, location.z),
        size = vec3(3, 3, 3),
        options = {
            {
                name = 'sell_location_' .. name,
                label = 'Sell Cash',
                icon = 'fa-solid dollar-sign',
                onSelect = function(data)
                    TriggerServerEvent("Robbery:sell", location)
                end
            }
        },
    })
end

RegisterNetEvent("Robbery:createSellBlip")
AddEventHandler("Robbery:createSellBlip", function(sellLocation)
    -- Create a blip at the sell location coordinates
    local blip = AddBlipForCoord(sellLocation.x, sellLocation.y, sellLocation.z)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipRoute(blip, true)

    robberStatusBlip = blip
end)

RegisterNetEvent("Robbery:removeSellBlip")
AddEventHandler("Robbery:removeSellBlip", function()
    if robberStatusBlip then
        RemoveBlip(robberStatusBlip)
        robberStatusBlip = nil
    end
end)