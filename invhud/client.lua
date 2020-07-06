local isInInventory = false
local targetPlayer, targetPlayerName, shopData, openedTrunk
local trunkData, gBoxData, stashData, propertyData, safeData, playerInv, Licenses, PlayerData = {}, {}, {}, {}, {}, {}, {}, {}
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
	end
	while not ESX.IsPlayerLoaded() do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
	if Config.Blips.Use then
		for k,v in pairs(Config.Shops) do
			for i = 1,#v.Locations do
				CreateBlip(v.Locations[i], Config.Names[k], 1.0, Config.Colors[k], Config.Blips[k])
			end
		end
	end
	while true do
		Citizen.Wait(5)
		DisableControlAction(0, Config.OpenControl)
		if Config.Markers.Use then
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			for k,v in pairs(Config.Shops) do
				for i = 1,#v.Locations do
					local dis = #(pos - v.Locations[i])
					if dis <= Config.Markers.Draw then
						DrawMarker(Config.Markers.Type, v.Locations[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.Markers.RGB, 200, false, false, 0, false, 0, 0, 0)
						if Config.Markers.UseText then
							DrawShopText(v.Locations[i].x, v.Locations[i].y, v.Locations[i].z+1.0, k..' shop')
						end
					end
				end
			end
			for k,v in pairs(Config.Stash) do
				local dis = #(pos - v.coords)
				if dis <= Config.Markers.Draw then
					DrawMarker(Config.Markers.Type, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.Markers.RGB, 200, false, false, 0, false, 0, 0, 0)
					if Config.Markers.UseText then
						DrawShopText(v.coords.x, v.coords.y, v.coords.z, k)
					end
				end
			end
		end
		if IsDisabledControlJustReleased(0, Config.OpenControl) then
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			if not IsPedSittingInAnyVehicle(ped) then
				local inZone, zoneIn = InShopZone(pos)
				if inZone then
					if Config.NeedsWeaponLicense then
						if zoneIn ~= 'weaponshop' or Licenses['firearm'] ~= nil then
							ESX.TriggerServerCallback('invhud:getShopItems', function(data)
								setShopInventory(data)
								openInventory('shop')
							end, zoneIn)
							Citizen.Wait(250)
						else
							Notify('You do not have a fire-arm license, we can not sell you guns')
						end
					else
						ESX.TriggerServerCallback('invhud:getShopItems', function(data)
							setShopInventory(data)
							openInventory('shop')
						end, zoneIn)
						Citizen.Wait(250)
					end
				else
					local atStash, stashAt = InStashZone(pos)
					if atStash then
						if tonumber(stashAt) ~= nil then
							ESX.TriggerServerCallback('invhud:getInv', function(data)
								setInventory(data, 'stash')
								openInventory('stash')
								stashData.stash = PlayerData.identifier..stashAt
							end, 'stash', PlayerData.identifier..stashAt)
						else
							ESX.TriggerServerCallback('invhud:getInv', function(data)
								setInventory(data, 'stash')
								openInventory('stash')
								stashData.stash = stashAt
							end, 'stash', stashAt)
						end
					else
						local veh = ESX.Game.GetVehicleInDirection()
						if DoesEntityExist(veh) then
							local plate = ESX.Game.GetVehicleProperties(veh).plate
							trunkData.plate = plate
							local trunk = GetEntityBoneIndexByName(veh, 'boot')
							local trunkPos =  GetWorldPositionOfEntityBone(veh, trunk)
							local dis = #(pos - trunkPos)
							if dis < 2.5 then
								local lok = GetVehicleDoorLockStatus(veh)
								if lok == 1 then
									ESX.TriggerServerCallback('invhud:getInv', function(data)
										setInventory(data, 'trunk')
										SetVehicleDoorOpen(veh, 5)
										openedTrunk = veh
										openInventory('trunk')
									end, 'trunk', plate)
								else
									Notify('This trunk is locked')
								end
							else
								openInventory('normal')
							end
						else
							openInventory('normal')
						end
					end
				end
			else
				local veh = GetVehiclePedIsIn(ped, true)
				if DoesEntityExist(veh) then
					local plate = ESX.Game.GetVehicleProperties(veh).plate
					gBoxData.plate = plate
					ESX.TriggerServerCallback('invhud:getInv', function(data)
						setInventory(data, 'gbox')
						openInventory('gbox')
					end, 'gbox', plate)
				end
			end
		end
		if isInInventory then
			DisableAllControlActions(0)
		end
	end
end)

DrawShopText = function(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x, y, z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local scale = 0.5
	local text = text
	
	if onScreen then
		SetTextScale(scale, scale)
		SetTextFont(0)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 255)
		SetTextDropshadow(1, 1, 0, 0, 255)
		SetTextEdge(0, 0, 0, 0, 150)
		SetTextDropShadow()
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(2)
		AddTextComponentString(text)
		DrawText(_x,_y)
	end
end

Notify = function(text, timer)
	if timer == nil then
		timer = 5000
	end
	-- exports['mythic_notify']:DoCustomHudText('inform', text, timer)
	-- exports.pNotify:SendNotification({layout = 'centerLeft', text = text, type = 'error', timeout = timer})
	ESX.ShowNotification(text)
end

setInventory = function(data, invType)
    SendNUIMessage(
        {
            action = 'setInfoText',
            text = string.upper(invType)
        }
    )

    items = {}

    if data.blackMoney > 0 then
        blackData = {
            label = _U('black_money'),
            count = data.blackMoney,
            type = 'item_account',
            name = 'black_money',
            usable = false,
            rare = false,
            limit = -1,
            canRemove = false
        }
        table.insert(items, blackData)
    end
	
	if data.cash > 0 then
        cashData = {
            label = 'cash',
            count = data.cash,
            type = 'item_money',
            name = 'cash',
            usable = false,
            rare = false,
            limit = -1,
            canRemove = false
        }
        table.insert(items, cashData)
    end

    if data.items ~= nil then
        for key, value in pairs(data.items) do
			data.items[key][1].name = key
			data.items[key][1].label = value[1].label
			data.items[key][1].type = 'item_standard'
			data.items[key][1].usable = false
			data.items[key][1].rare = false
			data.items[key][1].limit = -1
			data.items[key][1].canRemove = false
			table.insert(items, data.items[key][1])
        end
    end

    if Config.IncludeWeapons and data.weapons ~= nil then
        for key, value in pairs(data.weapons) do
            if data.weapons[key][1] ~= 'WEAPON_UNARMED' then
                table.insert(
                    items,
                    {
                        label = data.weapons[key][1].label,
                        count = data.weapons[key][1].count,
                        limit = -1,
                        type = 'item_weapon',
                        name = key,
                        usable = false,
                        rare = false,
                        canRemove = false
                    }
                )
            end
        end
    end

    SendNUIMessage(
        {
            action = 'setSecondInventoryItems',
            itemList = items
        }
    )
end

setShopInventory = function(data)
    SendNUIMessage(
        {
            action = 'setInfoText',
            text = 'SHOP'
        }
    )

    items = {}

    if data.items ~= nil then
        for k,v in pairs(data.items) do
			table.insert(items, v)
        end
    end

    if data.weapons ~= nil then
        for k,v in pairs(data.weapons) do
            if v.name ~= 'WEAPON_UNARMED' then
                table.insert(items, v)
            end
        end
    end

    SendNUIMessage(
        {
            action = 'setShopInventoryItems',
            itemList = items
        }
    )
end

RegisterNUICallback('PutIntoGBox', function(data, cb)
	if not IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end
	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		local count = tonumber(data.number)

		if data.item.type == 'item_weapon' then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end
		if count == 0 then
			count = 1
		end
		TriggerServerEvent('invhud:putItem', 'gbox', gBoxData.plate, data, count)
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'gbox')
		openInventory('gbox')
	end, 'gbox', gBoxData.plate)

	cb('ok')
end)

RegisterNUICallback('TakeFromGBox', function(data, cb)
	if not IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		TriggerServerEvent('invhud:getItem', 'gbox', gBoxData.plate, data, tonumber(data.number))
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'gbox')
		openInventory('gbox')
	end, 'gbox', gBoxData.plate)

	cb('ok')
end)

RegisterNUICallback('PutIntoTrunk', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end
	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		local count = tonumber(data.number)

		if data.item.type == 'item_weapon' then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end
		if count == 0 then
			count = 1
		end
		TriggerServerEvent('invhud:putItem', 'trunk', trunkData.plate, data, count)
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'trunk')
		openInventory('trunk')
	end, 'trunk', trunkData.plate)

	cb('ok')
end)

RegisterNUICallback('TakeFromTrunk', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		TriggerServerEvent('invhud:getItem', 'trunk', trunkData.plate, data, tonumber(data.number))
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'trunk')
		openInventory('trunk')
	end, 'trunk', trunkData.plate)

	cb('ok')
end)

RegisterNUICallback('PutIntoProperty', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end
	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		local count = tonumber(data.number)

		if data.item.type == 'item_weapon' then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end
		if count == 0 then
			count = 1
		end
		TriggerServerEvent('invhud:putItem', 'property', propertyData.id, data, count)
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'property')
		openInventory('property')
	end, 'property', propertyData.id)

	cb('ok')
end)

RegisterNUICallback('TakeFromProperty', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		TriggerServerEvent('invhud:getItem', 'property', propertyData.id, data, tonumber(data.number))
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'property')
		openInventory('property')
	end, 'property', propertyData.id)

	cb('ok')
end)

RegisterNUICallback('PutIntoSafe', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end
	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		local count = tonumber(data.number)

		if data.item.type == 'item_weapon' then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end
		if count == 0 then
			count = 1
		end
		TriggerServerEvent('invhud:putItem', 'safe', safeData.id, data, count)
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'safe')
		openInventory('safe')
	end, 'safe', safeData.id)

	cb('ok')
end)

RegisterNUICallback('TakeFromSafe', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		TriggerServerEvent('invhud:getItem', 'safe', safeData.id, data, tonumber(data.number))
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'safe')
		openInventory('safe')
	end, 'safe', safeData.id)

	cb('ok')
end)

RegisterNUICallback('TakeFromShop', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		TriggerServerEvent('invhud:SellItemToPlayer', data.item.type, data.item.name, tonumber(data.number))
	end

	Wait(150)
	loadPlayerInventory()

	cb('ok')
end)

RegisterNUICallback('PutIntoStash', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end
	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		local count = tonumber(data.number)

		if data.item.type == 'item_weapon' then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end
		if count == 0 then
			count = 1
		end
		TriggerServerEvent('invhud:putItem', 'stash', stashData.stash, data, count)
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'stash')
		openInventory('stash')
	end, 'stash', stashData.stash)

	cb('ok')
end)

RegisterNUICallback('TakeFromStash', function(data, cb)
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		TriggerServerEvent('invhud:getItem', 'stash', stashData.stash, data, tonumber(data.number))
	end
	Wait(250)
	loadPlayerInventory()
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'stash')
		openInventory('stash')
	end, 'stash', stashData.stash)

	cb('ok')
end)

InShopZone = function(pos)
	local inShop, shopIn = false, nil
	for k,v in pairs(Config.Shops) do
		for i = 1,#v.Locations do
			local dis = #(pos - v.Locations[i])
			if dis < 1.5 then
				inShop = true
				shopIn = k
			end
		end
	end
	return inShop, shopIn
end

InStashZone = function(pos)
	local atStash, stashAt = false, nil
	for k,v in pairs(Config.Stash) do
		local dis = #(pos - v.coords)
		if dis < 1.5 and (PlayerData.job.name == v.job or v.job == 'identifier') then
			atStash = true
			stashAt = k
		end
	end
	return atStash, stashAt
end

openInventory = function(invType)
    loadPlayerInventory()
    isInInventory = true
    SendNUIMessage(
        {
            action = 'display',
            type = invType
        }
    )
    SetNuiFocus(true, true)
end

closeInventory = function()
    isInInventory = false
	if openedTrunk then
		SetVehicleDoorShut(openedTrunk, 5, false, false)
		openedTrunk = nil
	end
    SendNUIMessage(
        {
            action = 'hide'
        }
    )
    SetNuiFocus(false, false)
end

RegisterNUICallback('NUIFocusOff', function()
	closeInventory()
end)

RegisterNUICallback('GetNearPlayers', function(data, cb)
	local playerPed = PlayerPedId()
	local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
	local foundPlayers = false
	local elements = {}

	for i = 1, #players, 1 do
		if players[i] ~= PlayerId() then
			foundPlayers = true

			table.insert(
				elements,
				{
					label = GetPlayerName(players[i]),
					player = GetPlayerServerId(players[i])
				}
			)
		end
	end

	if not foundPlayers then
		Notify('Nobody is near you')
	else
		SendNUIMessage(
			{
				action = 'nearPlayers',
				foundAny = foundPlayers,
				players = elements,
				item = data.item
			}
		)
	end
	cb('ok')
end)

RegisterNUICallback('UseItem', function(data, cb)
	TriggerServerEvent('esx:useItem', data.item.name)

	if shouldCloseInventory(data.item.name) then
		closeInventory()
	else
		Citizen.Wait(250)
		loadPlayerInventory()
	end

	cb('ok')
end)

RegisterNUICallback('DropItem', function(data, cb)
	if IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		TriggerServerEvent('esx:removeInventoryItem', data.item.type, data.item.name, data.number)
	end

	Wait(250)
	loadPlayerInventory()

	cb('ok')
end)

RegisterNUICallback('GiveItem', function(data, cb)
	local playerPed = PlayerPedId()
	local players, nearbyPlayer = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), 3.0)
	local foundPlayer = false
	for i = 1, #players, 1 do
		if players[i] ~= PlayerId() then
			if GetPlayerServerId(players[i]) == data.player then
				foundPlayer = true
			end
		end
	end

	if foundPlayer then
		local count = tonumber(data.number)

		if data.item.type == 'item_weapon' then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end

		TriggerServerEvent('esx:giveInventoryItem', data.player, data.item.type, data.item.name, count)
		Wait(250)
		loadPlayerInventory()
	else
		Notify('Nobody is near you')
	end
	cb('ok')
end)

shouldCloseInventory = function(itemName)
    for index, value in ipairs(Config.CloseUiItems) do
        if value == itemName then
            return true
        end
    end

    return false
end

shouldSkipAccount = function(accountName)
    for index, value in ipairs(Config.ExcludeAccountsList) do
        if value == accountName then
            return true
        end
    end

    return false
end

loadPlayerInventory = function(inv)
	if not inv then
		ESX.TriggerServerCallback('invhud:getPlayerInventory', function(data)
			items = {}
			inventory = data.inventory
			accounts = data.accounts
			money = data.money
			weapons = data.weapons

			if Config.IncludeCash and money ~= nil and money > 0 then
				moneyData = {
					label = _U('cash'),
					name = 'money',
					type = 'item_account',
					count = money,
					usable = false,
					rare = false,
					limit = -1,
					canRemove = true
				}

				table.insert(items, moneyData)
			end

			if Config.IncludeAccounts and accounts ~= nil then
				for key, value in pairs(accounts) do
					if not shouldSkipAccount(accounts[key].name) then
						local canDrop = accounts[key].name == 'money' or accounts[key].name == 'black_money'
						if accounts[key].name ~= 'money' then
							if accounts[key].money > 0 then
								accountData = {
									label = accounts[key].label,
									count = accounts[key].money,
									type = 'item_account',
									name = accounts[key].name,
									usable = false,
									rare = false,
									limit = -1,
									canRemove = canDrop
								}
								table.insert(items, accountData)
							end
						end
					end
				end
			end

			if inventory ~= nil then
				for key, value in pairs(inventory) do
					if inventory[key].count <= 0 then
						inventory[key] = nil
					else
						inventory[key].type = 'item_standard'
						inventory[key].id = id
						table.insert(items, inventory[key])
					end
				end
			end

			if Config.IncludeWeapons and weapons ~= nil then
				for key, value in pairs(weapons) do
					local weaponHash = GetHashKey(weapons[key].name)
					local playerPed = PlayerPedId()
					if HasPedGotWeapon(playerPed, weaponHash, false) and weapons[key].name ~= 'WEAPON_UNARMED' then
						local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
						table.insert(
							items,
							{
								label = weapons[key].label,
								count = ammo,
								limit = -1,
								type = 'item_weapon',
								name = weapons[key].name,
								usable = false,
								rare = false,
								canRemove = true
							}
						)
					end
				end
			end
			playerInv = items
			SendNUIMessage(
				{
					action = 'setItems',
					itemList = items
				}
			)
		end, GetPlayerServerId(PlayerId()))
	else
		items = inv
		playerInv = items
		SendNUIMessage(
			{
				action = 'setItems',
				itemList = items
			}
		)
	end
end

IsPedHoldingWeapon = function(selWep, tabWep)
	local hasWeap
	for i = 1,#Config.Bullets[tabWep] do
		if selWep == Config.Bullets[tabWep][i] then
			hasWeap = true
		end
	end
	return hasWeap
end

CreateBlip = function(coords, text, radius, color, sprite)
	local blip = AddBlipForCoord(coords)
	SetBlipSprite(blip, sprite)
	SetBlipColour(blip, color)
	SetBlipScale(blip, 0.8)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end

RegisterNetEvent('invhud:openPropertyInv')
AddEventHandler('invhud:openPropertyInv', function(name)
	local ped = PlayerPedId()
	propertyData.id = name
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'property')
		openInventory('property')
	end, 'property', propertyData.id)
end)

RegisterNetEvent('invhud:openSafeInv')
AddEventHandler('invhud:openSafeInv', function(name)
	local ped = PlayerPedId()
	safeData.id = name
	ESX.TriggerServerCallback('invhud:getInv', function(data)
		setInventory(data, 'safe')
		openInventory('safe')
	end, 'safe', safeData.id)
end)

RegisterNetEvent('invhud:usedAmmo')
AddEventHandler('invhud:usedAmmo', function(key)
	local ped = PlayerPedId()
	local wep = GetSelectedPedWeapon(ped)
	if IsPedHoldingWeapon(wep, key) then
		MakePedReload(ped)
		AddAmmoToPed(GetPlayerPed(-1), wep, 20)
		TriggerServerEvent('invhud:usedAmmo', key)
	else
		Notify('You do not have a weapon for that ammo clip equipped')
	end
end)

RegisterNetEvent('invhud:GetLicenses')
AddEventHandler('invhud:GetLicenses', function (licenses)
    for i = 1, #licenses, 1 do
        Licenses[licenses[i].type] = true
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function()
	PlayerData = ESX.GetPlayerData()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		closeInventory()
	end
end)

-------------PLAYER----------------

RegisterNetEvent('invhud:openPlayerInventory')
AddEventHandler('invhud:openPlayerInventory', function(target, playerName)
	targetPlayer = target
	targetPlayerName = playerName
	setPlayerInventoryData()
	openInventory('player')
end)

refreshPlayerInventory = function()
    setPlayerInventoryData()
end

setPlayerInventoryData = function()
    ESX.TriggerServerCallback('invhud:getPlayerInventory', function(data)
		SendNUIMessage(
			{
				action = 'setInfoText',
				text = '<strong>' .. _U('player_inventory') .. '</strong><br>' .. targetPlayerName .. ' (' .. targetPlayer .. ')'
			}
		)

		items = {}
		inventory = data.inventory
		accounts = data.accounts
		money = data.money
		weapons = data.weapons

		if Config.IncludeCash and money ~= nil and money > 0 then
			moneyData = {
				label = _U('cash'),
				name = 'money',
				type = 'item_account',
				count = money,
				usable = false,
				rare = false,
				limit = -1,
				canRemove = true
			}

			table.insert(items, moneyData)
		end

		if Config.IncludeAccounts and accounts ~= nil then
			for key, value in pairs(accounts) do
				if not shouldSkipAccount(accounts[key].name) then
					local canDrop = accounts[key].name == 'money' or accounts[key].name == 'black_money'
					if accounts[key].name ~= 'money' then
						if accounts[key].money > 0 then
							accountData = {
								label = accounts[key].label,
								count = accounts[key].money,
								type = 'item_account',
								name = accounts[key].name,
								usable = false,
								rare = false,
								limit = -1,
								canRemove = canDrop
							}
							table.insert(items, accountData)
						end
					end
				end
			end
		end

		if inventory ~= nil then
			for key, value in pairs(inventory) do
				if inventory[key].count <= 0 then
					inventory[key] = nil
				else
					inventory[key].type = 'item_standard'
					inventory[key].id = id
					table.insert(items, inventory[key])
				end
			end
		end

		if Config.IncludeWeapons and weapons ~= nil then
			for key, value in pairs(weapons) do
				local weaponHash = GetHashKey(weapons[key].name)
				local playerPed = PlayerPedId()
				if HasPedGotWeapon(playerPed, weaponHash, false) and weapons[key].name ~= 'WEAPON_UNARMED' then
					local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
					table.insert(
						items,
						{
							label = weapons[key].label,
							count = ammo,
							limit = -1,
							type = 'item_weapon',
							name = weapons[key].name,
							usable = false,
							rare = false,
							canRemove = true
						}
					)
				end
			end
		end

		SendNUIMessage(
			{
				action = 'setSecondInventoryItems',
				itemList = items
			}
		)
	end, targetPlayer)
end

RegisterNUICallback('PutIntoPlayer', function(data, cb)
	if IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		local count = tonumber(data.number)

		if data.item.type == 'item_weapon' then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end

		TriggerServerEvent('invhud:tradePlayerItem', GetPlayerServerId(PlayerId()), targetPlayer, data.item.type, data.item.name, count)
	end

	Wait(250)
	refreshPlayerInventory()
	loadPlayerInventory()

	cb('ok')
end)

RegisterNUICallback('TakeFromPlayer', function(data, cb)
	if IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	if type(data.number) == 'number' and math.floor(data.number) == data.number then
		local count = tonumber(data.number)

		if data.item.type == 'item_weapon' then
			count = GetAmmoInPedWeapon(PlayerPedId(), GetHashKey(data.item.name))
		end

		TriggerServerEvent('invhud:tradePlayerItem', targetPlayer, GetPlayerServerId(PlayerId()), data.item.type, data.item.name, count)
	end

	Wait(250)
	refreshPlayerInventory()
	loadPlayerInventory()

	cb('ok')
end)
