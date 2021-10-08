local onBike, timerMinutesEnabled, timerMinutes, timerSeconds, counter      = false, false, nil, nil, false
local QBCore = exports['qb-core']:GetCoreObject()

	
Citizen.CreateThread(function()
	for k,v in pairs(Config.RentPlaces) do
		for i = 1, #v.Rental, 1 do
            blip = AddBlipForCoord(v.Rental[i].x, v.Rental[i].y, v.Rental[i].z)
            SetBlipSprite(blip, Config.BlipAndMarker.blipId)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.BlipAndMarker.blipSize)
            SetBlipColour(blip, Config.BlipAndMarker.blipColour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.BlipAndMarker.blipName)
            EndTextCommandSetBlipName(blip)
        end
	end
end)

Citizen.CreateThread(function()
    while true do
        if onBike == false then
            for k,v in pairs(Config.RentPlaces) do
                for i = 1, #v.Rental, 1 do
                    local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
                    local distance = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, v.Rental[i].x, v.Rental[i].y, v.Rental[i].z)

                    if distance < Config.BlipAndMarker.markerDistance then
                        DrawMarker(Config.BlipAndMarker.markerType, v.Rental[i].x, v.Rental[i].y, v.Rental[i].z, 0, 0, 0, 0, 0, 0, Config.BlipAndMarker.markerSize.x, Config.BlipAndMarker.markerSize.y, Config.BlipAndMarker.markerSize.z, Config.BlipAndMarker.markerColour.r, Config.BlipAndMarker.markerColour.g, Config.BlipAndMarker.markerColour.b, Config.BlipAndMarker.markerColour.a, Config.BlipAndMarker.markerBounce, Config.BlipAndMarker.markerFacing, 0, Config.BlipAndMarker.markerRotate)
                    end
                    if distance <= 0.5 then
                        hintToDisplay('Press ~INPUT_CONTEXT~ to ~b~rent~s~ a bike')
                        
                        if IsControlJustPressed(0, 38) then
                            OpenBikeMenu()
                        end			
                    end
                end
            end
        end
        Wait(0)
    end
end)

RegisterNetEvent('arp_bikerental:getBike')
AddEventHandler('arp_bikerental:getBike', function(vehicleType, rentalTime)
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player, false)
    local playerHeading = GetEntityHeading(player, false)

    QBCore.Functions.SpawnVehicle(vehicleType, function(bike)
        SetEntityHeading(bike, playerHeading)
        TaskWarpPedIntoVehicle(player, bike, -1)
        if (IsEntityAMissionEntity(bike) == false) then
            SetEntityAsMissionEntity(bike, true, true)
        end
        timerSeconds = 60
        timerMinutes = timer
        timer = timer * 60
        if timer > 60 then
            timerMinutesEnabled = true
        end
        onBike = true
        Wait(rentalTime * 60000)
        onBike = false
        if IsPedInVehicle(player, bike, true) then
            FreezeEntityPosition(bike, true)

            QB.Screen.Notification(
                Config.NotificationSettings.title,
                Config.NotificationSettings.message,
                Config.NotificationSettings.icon,
                1000,
                "blue"
            );
            TaskLeaveVehicle(player, bike, 1)
            Wait(1000)
            DeleteVehicle(bike)
        else
            QB.Screen.Notification(
                Config.NotificationSettings.title,
                Config.NotificationSettings.message,
                Config.NotificationSettings.icon,
                1000,
                "blue"
            );
            DeleteVehicle(bike)
        end
    end, playerCoords, true)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if onBike then
            counter = true
            if timerSeconds <= 59 then
                timerSeconds = timerSeconds - 1
            elseif timerSeconds == 60 then
                timerSeconds = timerSeconds - 1
                timerMinutes = timerMinutes - 1
            end

            if timerMinutesEnabled and timerSeconds == 0 then
                timerSeconds = 59
                timerMinutes = timerMinutes - 1
            end

            if timerMinutesEnabled and timerMinutes == 0 then
                timerMinutesEnabled = false
                timerSeconds = 59
                timerMinutes = nil
            end

            if timerSeconds == 0 and not timerMinutesEnabled then
                counter = false
                timerSeconds = nil
                timerMinutes = nil
            end

            timer = timer - 1
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if onBike and counter then
            if timerSeconds == nil then
                Citizen.Wait(100)
            else
                if timerMinutesEnabled then
                    DrawText2D(0.505, 0.95, 1.0,1.0,0.4, "The time left from the rented bike: ~b~" ..timerMinutes.. " minute(s) " ..timerSeconds.. " second(s)", 255, 255, 255, 255)
                else
                    DrawText2D(0.505, 0.95, 1.0,1.0,0.4, "The time left from the rented bike: ~b~" ..timerSeconds.. " second(s)", 255, 255, 255, 255)
                end
            end
        end
    end
end)

function OpenBikeMenu()
    MenuV:CloseAll()

    local menu = MenuV:CreateMenu('Bike Rental', 'Chose a bike', 'topleft', 255, 0, 0)
    local menu_button = menu:AddButton({ label = Config.BikeNames.cruiser, value = 'cruiser', description = Config.Currency .. ' ' .. Config.Prices.cruiser .. '/ Minute' })
    menu_button:On("select", function()
        MenuV:CloseMenu(menu)
        rentBike('cruiser')
    end)
    local menu_button = menu:AddButton({ label = Config.BikeNames.bmx, value = 'bmx', description = Config.Currency .. ' ' .. Config.Prices.bmx .. '/ Minute' })
    menu_button:On("select", function()
        MenuV:CloseMenu(menu)
        rentBike('bmx')
    end)
    local menu_button = menu:AddButton({ label = Config.BikeNames.fixter, value = 'fixter', description = Config.Currency .. ' ' .. Config.Prices.fixter .. '/ Minute' })
    menu_button:On("select", function()
        MenuV:CloseMenu(menu)
        rentBike('fixter')
    end)
    local menu_button = menu:AddButton({ label = Config.BikeNames.scorcher, value = 'scorcher', description = Config.Currency .. ' ' .. Config.Prices.scorcher .. '/ Minute' })
    menu_button:On("select", function()
        MenuV:CloseMenu(menu)
        rentBike('scorcher')
    end)
    local menu_button = menu:AddButton({ label = Config.BikeNames.tribike, value = 'tribike', description = Config.Currency .. ' ' .. Config.Prices.tribike .. '/ Minute' })
    menu_button:On("select", function()
        MenuV:CloseMenu(menu)
        rentBike('tribike')
    end)
    local menu_button = menu:AddButton({ label = Config.BikeNames.tribike2, value = 'tribike2', description = Config.Currency .. ' ' .. Config.Prices.tribike2 .. '/ Minute' })
    menu_button:On("select", function()
        MenuV:CloseMenu(menu)
        rentBike('tribike2')
    end)
    local menu_button = menu:AddButton({ label = Config.BikeNames.tribike3, value = 'tribike3', description = Config.Currency .. ' ' .. Config.Prices.tribike3 .. '/ Minute' })
    menu_button:On("select", function()
        MenuV:CloseMenu(menu)
        rentBike('tribike3')
    end)
    menu:Open()
end

function rentBike(bikeType)
    local menu = MenuV:CreateMenu('Bike Rental', 'Chose a bike', 'topleft', 255, 0, 0)
    time = menu:AddRange({ icon = '🕒', label = "Time", description = "How many time do you want to rent this bike? (In minutes)", value = 1, min = 1, max = 60, disabled = false });
    time:On('select', function(item, value)
        local amount = tonumber(value)
        if amount == nil or amount >= 59 then
            Screen.ShowNotification('~r~Invalid~s~ amount or you want to rent it for ~r~too long~s~! (min: ~o~1~s~, max: ~g~59~s~)')
        elseif amount == 0 then
            MenuV:CloseMenu(menu)
        else
            MenuV:CloseMenu(menu)
            timer = amount
            TriggerServerEvent('arp_bikerental:getMoney', bikeType, amount)
        end
        menu.close()
    end)
    menu:Open()
end

function hintToDisplay(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function DrawText2D(x, y, width, height, scale, text, r, g, b, a, outline)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x - width/2, y - height/2 + 0.005)
end
