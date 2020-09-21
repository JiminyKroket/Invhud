ESX = nil
ServerItems = {}
itemShopList = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.Use.Societies then
	for k,v in pairs(Config.Shops) do
		if v.Society.Name then
			local socString = string.format('society_%s', v.Society.Name)
			TriggerEvent('esx_society:registerSociety', v.Society.Name, v.Society.Name, socString, socString, socString, {type = 'public'})
		end
	end
end

Notify = function(src, text, timer)
	if timer == nil then
		timer = 5000
	end
	-- TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = text, length = timer, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
	-- TriggerClientEvent('pNotify:SendNotification', src, {text = text, type = 'error', queue = GetCurrentResourceName(), timeout = timer, layout = 'bottomCenter'})
	TriggerClientEvent('esx:showNotification', src, text)
end

doRound = function(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

IsInInv = function(inv, item)
	for k,v in pairs(inv.items) do
		if item == k then
			return true
		end
	end
	for k,v in pairs(inv.weapons) do
		if item == k then
			return true
		end
	end
	return false
end

InvCanCarry = function(xPlayer, inv, name, count, totWeight)
	local total = 0
	local xItem = xPlayer.getInventoryItem(name)
	local itemWeight
	if xItem ~= nil then
		itemWeight = xPlayer.getInventoryItem(name).weight
		if itemWeight == nil then
			itemWeight = 100/(xPlayer.getInventoryItem(name).limit*0.1)
		end
		itemWeight = itemWeight * count
	elseif Config.Weight.WeaponWeights[name] then
		itemWeight = Config.Weight.WeaponWeights[name]
		itemWeight = itemWeight * (count*0.01)
	else
		itemWeight = 0.01
	end
	totWeight = totWeight * 1.00
	for k,v in pairs(inv.items) do
		local xItem = xPlayer.getInventoryItem(k)
		if xItem ~= nil then
			if xItem.weight ~= nil then
				total = total + xItem.weight * v[1].count
			else
				local itemLimit = xItem.limit
				if itemLimit == -1 then
					itemLimit = 100000
				end
				total = total + 100/(itemLimit*0.1) * v[1].count
			end
		else
			total = total + 0.01
		end
	end
	for k,v in pairs(inv.weapons) do
		for i = 1,#v do
			if Config.Weight.WeaponWeights[k] then
				total = total + (Config.Weight.WeaponWeights[k] + (v[i].count*0.01))
			else
				total = total + 5
				print('Weapon weight not set, defaulted to 5')
			end
		end
	end
	if doRound(total, 2) + doRound(itemWeight, 2) > doRound(totWeight, 2) then
		return false
	else
		return true
	end
end

ESX.RegisterServerCallback('invhud:getPlayerLicenses', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT type FROM user_licenses WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function(result)
		local licenses = {}

		for  i = 1,#result do
			table.insert(licenses, result[i].type)
		end

		cb(licenses)
	end)
end)

ESX.RegisterServerCallback('invhud:getPlayerInventory', function(source, cb, target)
	local tPlayer = ESX.GetPlayerFromId(target)

	if tPlayer ~= nil then
		cb({inventory = tPlayer.inventory, money = tPlayer.getMoney(), accounts = tPlayer.accounts, weapons = tPlayer.loadout})
	else
		cb(nil)
	end
end)

ESX.RegisterServerCallback('invhud:doMath', function(source, cb, inv)
	local xPlayer = ESX.GetPlayerFromId(source)
	local total = 0
	for k,v in pairs(inv.items) do
		local xItem = xPlayer.getInventoryItem(k)
		if xItem ~= nil then
			if xItem.weight ~= nil then
				total = total + xItem.weight * v[1].count
			else
				local itemLimit = xItem.limit
				if itemLimit == -1 then
					itemLimit = 100000
				end
				total = total + 100/(itemLimit*0.1) * v[1].count
			end
		else
			total = total + 0.01
		end
	end
	for k,v in pairs(inv.weapons) do
		for i = 1,#v do
			if Config.Weight.WeaponWeights[k] then
				total = total + (Config.Weight.WeaponWeights[k] + (v[i].count*0.01))
			else
				total = total + (5 + (v[i].count*0.01))
				print('Weapon weight not set, defaulted to 5')
			end
		end
	end
	cb(doRound(total))
end)

ESX.RegisterServerCallback('invhud:getInv', function(source, cb, invType, id, class)
	local xPlayer = ESX.GetPlayerFromId(source)
	local weightLimit = 500
	if class ~= nil then
		if Config.Weight.VehicleLimits.Classes[class] then
			weightLimit = Config.Weight.VehicleLimits.Classes[class][invType]
		elseif Config.Weight.VehicleLimits.CustomModels[class] then
			weightLimit = Config.Weight.VehicleLimits.CustomModels[class][invType]
		elseif Config.Weight.Houses.Shells[class] then
			weightLimit = Config.Weight.Houses.Shells[class]
		end
	end
	MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = id, ['@type'] = invType}, function(result)
		if result[1] then
			cb(result[1])
		else
			MySQL.Async.execute('INSERT INTO `inventories` (owner, type, data, `limit`) VALUES (@id, @type, @data, @limit)', {
				['@id'] = id,
				['@type'] = invType,
				['@data'] = json.encode({items = {}, weapons = {}, blackMoney = 0, cash = 0}),
				['@limit'] = weightLimit
			}, function(rowsChanged)
				if rowsChanged then
					print('Inventory created for: '..id..' with type: '..invType)
				end
			end)
			cb({['owner'] = id, ['type'] = invType, ['data'] = json.encode({items = {}, weapons = {}, blackMoney = 0, cash = 0}), ['limit'] = weightLimit})
		end
	end)
end)

RegisterServerEvent('invhud:removeWeight')
AddEventHandler('invhud:removeWeight', function(source, gun, ammo)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.Weight.AddWeaponsToPlayerWeight then
		local weight
		if Config.Weight.WeaponWeights[gun] then
			weight = Config.Weight.WeaponWeights[gun] + (ammo*0.01)
		else
			weight = 5 + (ammo*0.01)
			print(string.format('Weapon weight not set for %s, defaulted to 5',gun))
		end
		local newWeight = xPlayer.maxWeight - weight
		xPlayer.setMaxWeight(doRound(newWeight, 2))
	end
end)

RegisterServerEvent('esx:removeInventoryItem')
AddEventHandler('esx:removeInventoryItem', function(itemType, itemName, count)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if Config.Weight.AddWeaponsToPlayerWeight then
		if itemType == 'item_weapon' then
			itemName = string.upper(itemName)
			local weight
			if Config.Weight.WeaponWeights[itemName] then
				weight = Config.Weight.WeaponWeights[itemName] + (count*0.01)
			else
				weight = 5 + (count*0.01)
				print(string.format('Weapon weight not set for %s, defaulted to 5',itemName))
			end
			local newWeight = xPlayer.maxWeight + weight
			xPlayer.setMaxWeight(doRound(newWeight, 2))
		end
	end
end)

RegisterServerEvent('invhud:setPlayerWeaponWeight')
AddEventHandler('invhud:setPlayerWeaponWeight', function(weapons)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local weightWaits = 0
	while not xPlayer.maxWeight do
		Citizen.Wait(10)
		xPlayer = ESX.GetPlayerFromId(src)
		weightWaits = weightWaits + 1
		if weightWaits >= 50 then
			print('Failed to receive maxWeight, are you running esx with limits? Turn off the config to add weapon weight to players')
			return
		end
	end
	if xPlayer.maxWeight then
		local total = 0
		for key,value in pairs(weapons) do
			if Config.Weight.WeaponWeights[value.name] then
				total = total + (Config.Weight.WeaponWeights[value.name] + (value.count*0.01))
			else
				total = total + (5 + (value.count*0.01))
				print(string.format('Weapon weight not set for %s, defaulted to 5',value.name))
			end
		end
		local newWeight = xPlayer.maxWeight - total
		xPlayer.setMaxWeight(doRound(newWeight, 2))
	else
		print('If you are running esx with weight, please have the player log out')
	end
end)

RegisterServerEvent('invhud:tradePlayerItem')
AddEventHandler('invhud:tradePlayerItem', function(from, target, invType, itemName, itemCount)
	local src = from

	local xPlayer = ESX.GetPlayerFromId(src)
	local tPlayer = ESX.GetPlayerFromId(target)

	if invType == 'item_standard' then
		local xItem = xPlayer.getInventoryItem(itemName)
		local tItem = tPlayer.getInventoryItem(itemName)
		
		if xPlayer.canCarryItem ~= nil then
			if xPlayer.maxWeight ~= nil then
				if itemCount > 0 and xItem.count >= itemCount then
					if tPlayer.canCarryItem(itemName, itemCount) then
						xPlayer.removeInventoryItem(itemName, itemCount)
						tPlayer.addInventoryItem(itemName, itemCount)
					else
						Notify(xPlayer.source, 'This player can not carry that much')
						Notify(tPlayer.source, 'You can not carry that much')
					end
				else
					Notify(xPlayer.source, 'You do not have enough of that item to give')
				end
			else
				Notify(src, 'Max weight error, relog')
			end
		else
			if itemCount > 0 and xItem.count >= itemCount then
				if tItem.limit == -1 or (tItem.count + itemCount) <= tItem.limit then
					xPlayer.removeInventoryItem(itemName, itemCount)
					tPlayer.addInventoryItem(itemName, itemCount)
				else
					Notify(xPlayer.source, 'This player can not carry that much')
					Notify(tPlayer.source, 'You can not carry that much')
				end
			else
				Notify(xPlayer.source, 'You do not have enough of that item to give')
			end
		end
	elseif invType == 'item_account' then
		if itemCount > 0 and xPlayer.getAccount(itemName).money >= itemCount then
			xPlayer.removeAccountMoney(itemName, itemCount)
			tPlayer.addAccountMoney(itemName, itemCount)
		else
			Notify(xPlayer.source, 'You do not have enough in that account to give')
		end
	elseif invType == 'item_money' then
		if xPlayer.getMoney() >= itemCount then
			xPlayer.removeMoney(itemCount)
			tPlayer.addMoney(itemCount)
		else
			Notify(xPlayer.source, 'You do not have enough money')
		end
	elseif invType == 'item_weapon' then
		if not tPlayer.hasWeapon(itemName) then
			local weight
			if Config.Weight.WeaponWeights[itemName] then
				weight = Config.Weight.WeaponWeights[itemName] + (itemCount*0.01)
			else
				weight = 5 + (itemCount*0.01)
				print(string.format('Weapon weight not set for %s, defaulted to 5',itemName))
			end
			if Config.Weight.AddWeaponsToPlayerWeight then
				local newWeight = tPlayer.maxWeight - weight
				if newWeight <= doRound(0, 2) then
					Notify(source, 'Can not hold weapon')
					return
				end
			end
			xPlayer.removeWeapon(itemName)
			tPlayer.addWeapon(itemName, itemCount)
			if Config.Weight.AddWeaponsToPlayerWeight then
				local newWeight = xPlayer.maxWeight + weight
				xPlayer.setMaxWeight(doRound(newWeight, 2))
				newWeight = tPlayer.maxWeight - weight
				tPlayer.setMaxWeight(doRound(newWeight, 2))
			end
		else
			Notify(xPlayer.source, 'This person already has this weapon, just give them ammo')
		end
	end
end)

RegisterServerEvent('invhud:putItem')
AddEventHandler('invhud:putItem', function(invType, owner, data, count)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if data.item.type == 'item_money' then
		data.item.type = 'item_account'
		data.item.name = 'money'
	end
	if data.item.type == 'item_standard' then
		local xItem = xPlayer.getInventoryItem(data.item.name)
		if xItem.count >= count then
			local inventory = {}
			MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
				if result[1] then
					inventory = json.decode(result[1].data)
					if IsInInv(inventory, data.item.name) then
						if InvCanCarry(xPlayer, inventory, data.item.name, count, result[1].limit) then
							xPlayer.removeInventoryItem(data.item.name, count)
							inventory.items[data.item.name][1].count = inventory.items[data.item.name][1].count + count
							MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
								['@owner'] = owner,
								['@type'] = invType,
								['@data'] = json.encode(inventory)
							}, function(rowsChanged)
								if rowsChanged then
									print('Inventory updated for: '..owner..' with type: '..invType)
								end
							end)
						else
							Notify(src, 'This inventory can not hold enough of that item')
						end
					else
						if InvCanCarry(xPlayer, inventory, data.item.name, count, result[1].limit) then
							xPlayer.removeInventoryItem(data.item.name, count)
							inventory.items[data.item.name] = {}
							table.insert(inventory.items[data.item.name], {count = count, label = data.item.label})
							MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
								['@owner'] = owner,
								['@type'] = invType,
								['@data'] = json.encode(inventory)
							}, function(rowsChanged)
								if rowsChanged then
									print('Inventory updated for: '..owner..' with type: '..invType)
								end
							end)
						else
							Notify(src, 'This inventory can not hold enough of that item')
						end
					end
				end
			end)
		else
			Notify(src, 'You do not have that much of '..data.item.name)
		end
	elseif data.item.type == 'item_weapon' then
		if xPlayer.hasWeapon(data.item.name) then
			local inventory = {}
			local weight
			if Config.Weight.WeaponWeights[data.item.name] then
				weight = Config.Weight.WeaponWeights[data.item.name] + (data.item.count*0.01)
			else
				weight = 5 + (data.item.count*0.01)
				print(string.format('Weapon weight not set for %s, defaulted to 5',data.item.name))
			end
			MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
				if result[1] then
					inventory = json.decode(result[1].data)
					if IsInInv(inventory, data.item.name) then
						if InvCanCarry(xPlayer, inventory, data.item.name, count, result[1].limit) then
							xPlayer.removeWeapon(data.item.name)
							if Config.Weight.AddWeaponsToPlayerWeight then
								local newWeight = xPlayer.maxWeight + weight
								xPlayer.setMaxWeight(doRound(newWeight, 2))
							end
							table.insert(inventory.weapons[data.item.name], {count = count, label = data.item.label})
							MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
								['@owner'] = owner,
								['@type'] = invType,
								['@data'] = json.encode(inventory)
							}, function(rowsChanged)
								if rowsChanged then
									print('Inventory updated for: '..owner..' with type: '..invType)
								end
							end)
						else
							Notify(src, 'Inventory cannot hold that weapon')
						end
					else
						if InvCanCarry(xPlayer, inventory, data.item.name, count, result[1].limit) then
							xPlayer.removeWeapon(data.item.name)
							if Config.Weight.AddWeaponsToPlayerWeight then
								local newWeight = xPlayer.maxWeight + weight
								xPlayer.setMaxWeight(doRound(newWeight, 2))
							end
							inventory.weapons[data.item.name] = {}
							table.insert(inventory.weapons[data.item.name], {count = count, label = data.item.label})
							MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
								['@owner'] = owner,
								['@type'] = invType,
								['@data'] = json.encode(inventory)
							}, function(rowsChanged)
								if rowsChanged then
									print('Inventory updated for: '..owner..' with type: '..invType)
								end
							end)
						else
							Notify(src, 'Inventory cannot hold that weapon')
						end
					end
				end
			end)
		else
			Notify(src, 'You do not have that weapon')
		end
	elseif data.item.type == 'item_account' then
		local accountName, money
		if data.item.name == 'money' then
			accountName = 'cash'
			money = xPlayer.getMoney()
		elseif data.item.name == 'black_money' then
			accountName = 'blackMoney'
			money = xPlayer.getAccount(data.item.name).money
		end
		if money >= count then
			local inventory = {}
			MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
				if result[1] then
					inventory = json.decode(result[1].data)
					if data.item.name == 'money' then
						xPlayer.removeMoney(count)
					else
						xPlayer.removeAccountMoney(data.item.name, count)
					end
					inventory[accountName] = inventory[accountName] + count
					MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
						['@owner'] = owner,
						['@type'] = invType,
						['@data'] = json.encode(inventory)
					}, function(rowsChanged)
						if rowsChanged then
							print('Inventory updated for: '..owner..' with type: '..invType)
						end
					end)
				end
			end)
		else
			Notify(src, 'You do not have enough cash to do that')
		end
	end
end)

RegisterServerEvent('invhud:getItem')
AddEventHandler('invhud:getItem', function(invType, owner, data, count)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if data.item.type == 'item_money' then
		data.item.type = 'item_account'
		data.item.name = 'money'
	end
	if data.item.type == 'item_standard' then
		local xItem = xPlayer.getInventoryItem(data.item.name)
		if xPlayer.canCarryItem ~= nil then
			if xPlayer.maxWeight ~= nil then
				if xPlayer.canCarryItem(data.item.name, count) then
					local inventory = {}
					MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
						if result[1] then
							inventory = json.decode(result[1].data)
							if IsInInv(inventory, data.item.name) then
								if inventory.items[data.item.name][1].count >= count then
									xPlayer.addInventoryItem(data.item.name, count)
									inventory.items[data.item.name][1].count = inventory.items[data.item.name][1].count - count
									if inventory.items[data.item.name][1].count <= 0 then
										inventory.items[data.item.name] = nil
									end
									MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
										['@owner'] = owner,
										['@type'] = invType,
										['@data'] = json.encode(inventory)
									}, function(rowsChanged)
										if rowsChanged then
											print('Inventory updated for: '..owner..' with type: '..invType)
										end
									end)
								else
									Notify(src, 'There is not enough of that in the inventory')
								end
							else
								Notify(src, 'There is not enough of that in the inventory')
							end
						end
					end)
				else
					Notify(src, 'You do not have that much of '..data.item.name)
				end
			else
				Notify(src, 'Max weight error, relog')
			end
		else
			if xItem.limit == -1 or (xItem.count + count <= xItem.limit) then
				local inventory = {}
				MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
					if result[1] then
						inventory = json.decode(result[1].data)
						if IsInInv(inventory, data.item.name) then
							if inventory.items[data.item.name][1].count >= count then
								xPlayer.addInventoryItem(data.item.name, count)
								inventory.items[data.item.name][1].count = inventory.items[data.item.name][1].count - count
								if inventory.items[data.item.name][1].count <= 0 then
									inventory.items[data.item.name] = nil
								end
								MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
									['@owner'] = owner,
									['@type'] = invType,
									['@data'] = json.encode(inventory)
								}, function(rowsChanged)
									if rowsChanged then
										print('Inventory updated for: '..owner..' with type: '..invType)
									end
								end)
							else
								Notify(src, 'There is not enough of that in the inventory')
							end
						else
							Notify(src, 'There is not enough of that in the inventory')
						end
					end
				end)
			else
				Notify(src, 'You do not have that much of '..data.item.name)
			end
		end
	elseif data.item.type == 'item_weapon' then
		if not xPlayer.hasWeapon(data.item.name) then
			local inventory = {}
			local weight
			if Config.Weight.WeaponWeights[data.item.name] then
				weight = Config.Weight.WeaponWeights[data.item.name] + (data.item.count*0.01)
			else
				weight = 5 + (data.item.count*0.01)
				print(string.format('Weapon weight not set for %s, defaulted to 5',data.item.name))
			end
			if Config.Weight.AddWeaponsToPlayerWeight then
				local newWeight = xPlayer.maxWeight - weight
				if newWeight <= doRound(0, 2) then
					Notify(source, 'Can not hold weapon')
					return
				end
			end
			MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
				if result[1] then
					inventory = json.decode(result[1].data)
					if IsInInv(inventory, data.item.name) then
						for i = 1,#inventory.weapons[data.item.name] do
							if inventory.weapons[data.item.name][i].count == data.item.count then
								xPlayer.addWeapon(data.item.name, inventory.weapons[data.item.name][i].count)
								if Config.Weight.AddWeaponsToPlayerWeight then
									local newWeight = xPlayer.maxWeight - weight
									xPlayer.setMaxWeight(doRound(newWeight, 2))
								end
								table.remove(inventory.weapons[data.item.name], i)
								MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
									['@owner'] = owner,
									['@type'] = invType,
									['@data'] = json.encode(inventory)
								}, function(rowsChanged)
									if rowsChanged then
										print('Inventory updated for: '..owner..' with type: '..invType)
									end
								end)
								break
							end
						end
					else
						Notify(src, 'There is not enough of that in the inventory')
					end
				end
			end)
		else
			Notify(src, 'You already have this weapon')
		end
	elseif data.item.type == 'item_account' then
		local accountName
		if data.item.name == 'money' then
			accountName = 'cash'
		elseif data.item.name == 'black_money' then
			accountName = 'blackMoney'
		end
		local inventory = {}
		MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
			if result[1] then
				inventory = json.decode(result[1].data)
				if inventory[accountName] >= count then
					if data.item.name == 'money' then
						xPlayer.addMoney(count)
					else
						xPlayer.addAccountMoney(data.item.name, count)
					end
					inventory[accountName] = inventory[accountName] - count
					MySQL.Async.execute('UPDATE inventories SET data = @data WHERE owner = @owner AND type = @type', {
						['@owner'] = owner,
						['@type'] = invType,
						['@data'] = json.encode(inventory)
					}, function(rowsChanged)
						if rowsChanged then
							print('Inventory updated for: '..owner..' with type: '..invType)
						end
					end)
				else
					Notify(src, 'There is not enough of that in the inventory')
				end
			end
		end)
	end
end)

ESX.RegisterServerCallback('invhud:getShopItems', function(source, cb, shoptype)
	itemShopList = {items = {}, weapons = {}}
	local itemResult = MySQL.Sync.fetchAll('SELECT * FROM items')
	local itemInformation = {}

	for i=1, #itemResult, 1 do

		if itemInformation[itemResult[i].name] == nil then
			itemInformation[itemResult[i].name] = {}
		end

		itemInformation[itemResult[i].name].name = itemResult[i].name
		itemInformation[itemResult[i].name].label = itemResult[i].label
		itemInformation[itemResult[i].name].limit = itemResult[i].limit
		itemInformation[itemResult[i].name].rare = itemResult[i].rare
		itemInformation[itemResult[i].name].can_remove = itemResult[i].can_remove
		itemInformation[itemResult[i].name].price = itemResult[i].price
		if Config.Shops[shoptype].Account == 'black_money' then
			itemInformation[itemResult[i].name].price = itemInformation[itemResult[i].name].price * 2
		end

		for _, v in pairs(Config.Shops[shoptype].Items) do
			if v.name == itemResult[i].name then
				table.insert(itemShopList.items, {
					type = 'item_standard',
					name = itemInformation[itemResult[i].name].name,
					label = itemInformation[itemResult[i].name].label,
					limit = itemInformation[itemResult[i].name].limit,
					rare = itemInformation[itemResult[i].name].rare,
					can_remove = itemInformation[itemResult[i].name].can_remove,
					price = itemInformation[itemResult[i].name].price,
					count = 1
				})
			end
		end
	end
	if Config.Shops[shoptype].Weapons ~= nil then
		for _, v in pairs(Config.Shops[shoptype].Weapons) do
			if Config.Shops[shoptype].Account == 'black_money' then
				v.price = v.price * 2
			end
			table.insert(itemShopList.weapons, {
				type = 'item_weapon',
				name = v.name,
				label = v.label,
				limit = 1,
				ammo = 1,
				rare = false,
				can_remove = false,
				price = v.price,
				count = 1
			})
		end
	end
	itemShopList = itemShopList
	cb(itemShopList)
end)

RegisterServerEvent('invhud:SellItemToPlayer')
AddEventHandler('invhud:SellItemToPlayer',function(invType, item, count, shop)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if invType == 'item_standard' then
		local tItem = xPlayer.getInventoryItem(item)
		if xPlayer.canCarryItem ~= nil then
			if xPlayer.maxWeight ~= nil then
				if xPlayer.canCarryItem(item, count) then
					local list = itemShopList.items
					for k,v in pairs(list) do
						if v.name == item then
							local totalPrice = count * v.price
							if shop.Account ~= 'money' and shop.Account ~= 'cash' then
								if xPlayer.getAccount(shop.Account).money >= totalPrice then
									xPlayer.removeAccountMoney(shop.Account, totalPrice)
									xPlayer.addInventoryItem(item, count)
									Notify(source, 'You purchased '..count..' '..v.label..' for '..Config.CurrencyIcon..totalPrice)
									if shop.Society.Name then
										TriggerEvent('esx_addonaccount:getSharedAccount', string.format('society_%s', shop.Society.Name), function(account)
											account.addMoney(totalPrice)
										end)
									end
								else
									Notify(source, 'You do not have enough money!')
								end
							else
								if xPlayer.getMoney() >= totalPrice then
									xPlayer.removeMoney(totalPrice)
									xPlayer.addInventoryItem(item, count)
									Notify(source, 'You purchased '..count..' '..v.label..' for '..Config.CurrencyIcon..totalPrice)
									if shop.Society.Name then
										TriggerEvent('esx_addonaccount:getSharedAccount', string.format('society_%s', shop.Society.Name), function(account)
											account.addMoney(totalPrice)
										end)
									end
								else
									Notify(source, 'You do not have enough money!')
								end
							end
						end
					end
				else
					Notify(source, 'You do not have enough space in your inventory!')
				end
			else
				Notify(src, 'Max weight error, relog')
			end
		else
			if tItem.count + count <= tItem.limit then
				local list = itemShopList.items
				for k,v in pairs(list) do
					if v.name == item then
						local totalPrice = count * v.price
						if shop.Account ~= 'money' and shop.Account ~= 'cash' then
							if xPlayer.getAccount(shop.Account).money >= totalPrice then
								xPlayer.removeAccountMoney(shop.Account, totalPrice)
								xPlayer.addInventoryItem(item, count)
								Notify(source, 'You purchased '..count..' '..v.label..' for '..Config.CurrencyIcon..totalPrice)
								if shop.Society.Name then
									TriggerEvent('esx_addonaccount:getSharedAccount', string.format('society_%s', shop.Society.Name), function(account)
										account.addMoney(totalPrice)
									end)
								end
							else
								Notify(source, 'You do not have enough money!')
							end
						else
							if xPlayer.getMoney() >= totalPrice then
								xPlayer.removeMoney(totalPrice)
								xPlayer.addInventoryItem(item, count)
								Notify(source, 'You purchased '..count..' '..v.label..' for '..Config.CurrencyIcon..totalPrice)
								if shop.Society.Name then
									TriggerEvent('esx_addonaccount:getSharedAccount', string.format('society_%s', shop.Society.Name), function(account)
										account.addMoney(totalPrice)
									end)
								end
							else
								Notify(source, 'You do not have enough money!')
							end
						end
					end
				end
			else
				Notify(source, 'You do not have enough space in your inventory!')
			end
		end
	end
	
	if invType == 'item_weapon' then
		local targetWeapon = xPlayer.hasWeapon(tostring(item))
        if not targetWeapon then
            local list = itemShopList.weapons
			for k,v in pairs(list) do
				if v.name == item then
					local totalPrice = 1 * v.price
					if shop.Account ~= 'money' and shop.Account ~= 'cash' then
						if xPlayer.getAccount(shop.Account).money >= totalPrice then
							xPlayer.removeAccountMoney(shop.Account, totalPrice)
							xPlayer.addWeapon(v.name, v.ammo)
							Notify(source, 'You purchased a '..v.label..' for '..Config.CurrencyIcon..totalPrice)
							if shop.Society.Name then
								TriggerEvent('esx_addonaccount:getSharedAccount', string.format('society_%s', shop.Society.Name), function(account)
									account.addMoney(totalPrice)
								end)
							end
						else
							Notify(source, 'You do not have enough money!')
						end
					else
						if xPlayer.getMoney() >= totalPrice then
							xPlayer.removeMoney(totalPrice)
							xPlayer.addWeapon(v.name, v.ammo)
							Notify(source, 'You purchased a '..v.label..' for '..Config.CurrencyIcon..totalPrice)
							if shop.Society.Name then
								TriggerEvent('esx_addonaccount:getSharedAccount', string.format('society_%s', shop.Society.Name), function(account)
									account.addMoney(totalPrice)
								end)
							end
						else
							Notify(source, 'You do not have enough money!')
						end
					end
				end
            end
        else
            Notify(source, 'You already own this weapon!' )
        end
	end
end)

RegisterServerEvent('invhud:SellItemToShop')
AddEventHandler('invhud:SellItemToShop',function(invType, item, count, shop)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if invType == 'item_standard' then
		local tItem = xPlayer.getInventoryItem(item)
		if tItem.count >= count then
			local list = itemShopList.items
			for k,v in pairs(list) do
				if v.name == item then
					local totalPrice = count * v.price * shop.BuyBack
					if totalPrice < 1 then
						totalPrice = 0
					end
					if shop.Society.Name then
						TriggerEvent('esx_addonaccount:getSharedAccount', string.format('society_%s', shop.Society.Name), function(account)
							if account.money >= totalPrice then
								if shop.Account ~= 'money' and shop.Account ~= 'cash' then
									xPlayer.addAccountMoney(shop.Account, totalPrice)
									xPlayer.removeInventoryItem(item, count)
									Notify(source, 'You sold '..count..' '..v.label..' for '..Config.CurrencyIcon..totalPrice)
									account.removeMoney(totalPrice)
								else
									xPlayer.addMoney(totalPrice)
									xPlayer.removeInventoryItem(item, count)
									Notify(source, 'You sold '..count..' '..v.label..' for '..Config.CurrencyIcon..totalPrice)
									account.removeMoney(totalPrice)
								end
							else
								Notify(source, 'The shop does not have enough money')
							end
						end)
					else
						if shop.Account ~= 'money' and shop.Account ~= 'cash' then
							xPlayer.addAccountMoney(shop.Account, totalPrice)
							xPlayer.removeInventoryItem(item, count)
							Notify(source, 'You sold '..count..' '..v.label..' for '..Config.CurrencyIcon..totalPrice)
						else
							xPlayer.addMoney(totalPrice)
							xPlayer.removeInventoryItem(item, count)
							Notify(source, 'You sold '..count..' '..v.label..' for '..Config.CurrencyIcon..totalPrice)
						end
					end
				end
			end
		else
			Notify(source, 'You do not have '..count..' '..item..' in your inventory!')
		end
	end
	
	if invType == 'item_weapon' then
		local targetWeapon = xPlayer.hasWeapon(tostring(item))
        if targetWeapon then
            local list = itemShopList.weapons
			for k,v in pairs(list) do
				if v.name == item then
					local totalPrice = 1 * v.price * shop.BuyBack
					if totalPrice < 1 then
						totalPrice = 0
					end
					if shop.Account ~= 'money' and shop.Account ~= 'cash' then
						xPlayer.addAccountMoney(shop.Account, totalPrice)
						xPlayer.removeWeapon(v.name, 0)
						Notify(source, 'You sold a '..v.label..' for '..Config.CurrencyIcon..totalPrice)
					else
						xPlayer.removeMoney(totalPrice)
						xPlayer.removeWeapon(v.name, 0)
						Notify(source, 'You sold a '..v.label..' for '..Config.CurrencyIcon..totalPrice)
					end
				end
            end
        else
            Notify(source, 'You do not own this weapon!' )
        end
	end
end)

for k,v in pairs(Config.Bullets) do
	ESX.RegisterUsableItem(k, function(source)
		TriggerClientEvent('invhud:usedAmmo', source, k)
	end)
end

RegisterServerEvent('invhud:usedAmmo')
AddEventHandler('invhud:usedAmmo', function(item)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	xPlayer.removeInventoryItem(item, 1)
end)