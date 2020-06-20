ESX = nil
ServerItems = {}
itemShopList = {}

TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

Notify = function(src, text, timer)
	if timer == nil then
		timer = 5000
	end
	-- TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = text, length = timer, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
	-- TriggerClientEvent("pNotify:SendNotification", src, {text = text, type = "error", queue = GetCurrentResourceName(), timeout = timer, layout = "bottomCenter"})
	TriggerClientEvent('esx:showNotification', src, text)
end

ESX.RegisterServerCallback("invhud:getPlayerInventory", function(source, cb, target)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if targetXPlayer ~= nil then
		cb({inventory = targetXPlayer.inventory, money = targetXPlayer.getMoney(), accounts = targetXPlayer.accounts, weapons = targetXPlayer.loadout})
	else
		cb(nil)
	end
end)

AddEventHandler('esx:giveIventoryItem', function(target, itemType, label, count)
	print(target, itemType, label, count)
	if itemType == 'item_money' then
		local src = source
		local xPlayer = ESX.GetPlayerFromId(src)
		local xTarget = ESX.GetPlayerFromId(target)
		if xPlayer.getMoney() >= count then
		  xPlayer.removeMoney(count)
		  xTarget.addMoney(count)
		  Notify(xPlayer.source, 'You have given '..Config.CurrencyIcon..count..' to '..xTarget.identifier)
		  Notify(xTarget.source, 'You have received '..Config.CurrencyIcon..count..' from '..xPlayer.identifier)
		else
		  Notify(xPlayer.source, 'You do not have '..Config.CurrenyIcon..count..' to give to '..xTarget.identifier)
		end
	end
end)

RegisterServerEvent("invhud:tradePlayerItem")
AddEventHandler("invhud:tradePlayerItem", function(from, target, type, itemName, itemCount)
	local src = from

	local sourceXPlayer = ESX.GetPlayerFromId(src)
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if type == "item_standard" then
		local sourceItem = sourceXPlayer.getInventoryItem(itemName)
		local targetItem = targetXPlayer.getInventoryItem(itemName)

		if itemCount > 0 and sourceItem.count >= itemCount then
			if targetItem.limit ~= -1 and (targetItem.count + itemCount) > targetItem.limit then
			else
				sourceXPlayer.removeInventoryItem(itemName, itemCount)
				targetXPlayer.addInventoryItem(itemName, itemCount)
			end
		end
	elseif type == "item_money" then
		if itemCount > 0 and sourceXPlayer.getMoney() >= itemCount then
			sourceXPlayer.removeMoney(itemCount)
			targetXPlayer.addMoney(itemCount)
		end
	elseif type == "item_account" then
		if itemCount > 0 and sourceXPlayer.getAccount(itemName).money >= itemCount then
			sourceXPlayer.removeAccountMoney(itemName, itemCount)
			targetXPlayer.addAccountMoney(itemName, itemCount)
		end
	elseif type == "item_weapon" then
		if not targetXPlayer.hasWeapon(itemName) then
			sourceXPlayer.removeWeapon(itemName)
			targetXPlayer.addWeapon(itemName, itemCount)
		end
	end
end)

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

ESX.RegisterServerCallback('invhud:getInv', function(source, cb, type, id)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = id, ['@type'] = type}, function(result)
		if result[1] then
			cb(json.decode(result[1].data))
		else
			MySQL.Async.execute('INSERT INTO `inventories` (owner, type, data) VALUES (@id, @type, @data)', {
				['@id'] = id,
				['@type'] = type,
				['@data'] = json.encode({items = {}, weapons = {}, blackMoney = 0, cash = 0})
			}, function(rowsChanged)
				if rowsChanged then
					print('Inventory created for: '..id..' with type: '..type)
				end
			end)
			cb({items = {}, weapons = {}, blackMoney = 0, cash = 0})
		end
	end)
end)

RegisterServerEvent('invhud:putItem')
AddEventHandler('invhud:putItem', function(invType, owner, data, count)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	if data.item.type == 'item_standard' then
		local xItem = xPlayer.getInventoryItem(data.item.name)
		if xItem.count >= count then
			local inventory = {}
			MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
				if result[1] then
					inventory = json.decode(result[1].data)
					if IsInInv(inventory, data.item.name) then
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
					end
				end
			end)
		else
			Notify(src, 'You do not have that much of '..data.item.name)
		end
	elseif data.item.type == 'item_weapon' then
		if xPlayer.hasWeapon(data.item.name) then
			local inventory = {}
			MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
				if result[1] then
					inventory = json.decode(result[1].data)
					if IsInInv(inventory, data.item.name) then
						xPlayer.removeWeapon(data.item.name)
						inventory.weapons[data.item.name][1].count = inventory.weapons[data.item.name][1].count + count
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
						xPlayer.removeWeapon(data.item.name)
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
					end
				end
			end)
		else
			Notify(src, 'You do not have that weapon')
		end
	elseif data.item.type == 'item_money' then
		local cash = xPlayer.getMoney()
		if cash >= count then
			local inventory = {}
			MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
				if result[1] then
					inventory = json.decode(result[1].data)
					xPlayer.removeMoney(count)
					inventory.cash = inventory.cash + count
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
	if data.item.type == 'item_standard' then
		local xItem = xPlayer.getInventoryItem(data.item.name)
		if xPlayer.canCarryItem ~= nil then
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
			if xItem.count + count <= xItem.limit then
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
			MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
				if result[1] then
					inventory = json.decode(result[1].data)
					if IsInInv(inventory, data.item.name) then
						if inventory.weapons[data.item.name][1].count >= 1 then
							xPlayer.addWeapon(data.item.name, inventory.weapons[data.item.name][1].count)
							inventory.weapons[data.item.name] = nil
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
			Notify(src, 'You already have this weapon')
		end
	elseif data.item.type == 'item_money' then
		local inventory = {}
		MySQL.Async.fetchAll('SELECT * FROM inventories WHERE owner = @owner AND type = @type', {['@owner'] = owner, ['@type'] = invType}, function(result)
			if result[1] then
				inventory = json.decode(result[1].data)
				if inventory.cash >= count then
					xPlayer.addMoney(count)
					inventory.cash = inventory.cash - count
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

ESX.RegisterServerCallback("invhud:getShopItems", function(source, cb, shoptype)
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

		if shoptype == "regular" then
			for _, v in pairs(Config.Shops.regular.Items) do
				if v.name == itemResult[i].name then
					table.insert(itemShopList.items, {
						type = "item_standard",
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
		if shoptype == "robsliquor" then
			for _, v in pairs(Config.Shops.robsliquor.Items) do
				if v.name == itemResult[i].name then
					table.insert(itemShopList.items, {
						type = "item_standard",
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
		if shoptype == "youtool" then
			for _, v in pairs(Config.Shops.youtool.Items) do
				if v.name == itemResult[i].name then
					table.insert(itemShopList.items, {
						type = "item_standard",
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
		if shoptype == "prison" then
			for _, v in pairs(Config.Shops.prisonshop.Items) do
				if v.name == itemResult[i].name then
					table.insert(itemShopList.items, {
						type = "item_standard",
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
		if shoptype == "weaponshop" then
			for _, v in pairs(Config.Shops.weaponshop.Items) do
				if v.name == itemResult[i].name then
					table.insert(itemShopList.items, {
						type = "item_standard",
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
	end
	if shoptype == "weaponshop" then
		for _, v in pairs(Config.Shops.weaponshop.Weapons) do
			table.insert(itemShopList.weapons, {
				type = "item_weapon",
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

RegisterNetEvent("invhud:SellItemToPlayer")
AddEventHandler("invhud:SellItemToPlayer",function(invType, item, count)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if invType == "item_standard" then
		local targetItem = xPlayer.getInventoryItem(item)
		if xPlayer.canCarryItem ~= nil then
			if xPlayer.canCarryItem(item, count) then
				local list = itemShopList.items
				for k,v in pairs(list) do
					if v.name == item then
						local totalPrice = count * v.price
						if xPlayer.getMoney() >= totalPrice then
							xPlayer.removeMoney(totalPrice)
							xPlayer.addInventoryItem(item, count)
							Notify(source, 'You purchased '..count.." "..v.label)
						else
							Notify(source, 'You do not have enough money!')
						end
					end
				end
			else
				Notify(source, 'You do not have enough space in your inventory!')
			end
		else
			if targetItem.count + count <= targetItem.limit then
				local list = itemShopList.items
				for k,v in pairs(list) do
					if v.name == item then
						local totalPrice = count * v.price
						if xPlayer.getMoney() >= totalPrice then
							xPlayer.removeMoney(totalPrice)
							xPlayer.addInventoryItem(item, count)
							Notify(source, 'You purchased '..count.." "..v.label)
						else
							Notify(source, 'You do not have enough money!')
						end
					end
				end
			else
				Notify(source, 'You do not have enough space in your inventory!')
			end
		end
	end
	
	if invType == "item_weapon" then
		local targetWeapon = xPlayer.hasWeapon(tostring(item))
        if not targetWeapon then
            local list = itemShopList.weapons
			for k,v in pairs(list) do
				if v.name == item then
					local totalPrice = 1 * v.price
					if xPlayer.getMoney() >= totalPrice then
						xPlayer.removeMoney(totalPrice)
						xPlayer.addWeapon(v.name, v.ammo)
						Notify(source, 'You purchased a '..v.label)
					else
						Notify(source, 'You do not have enough money!')
					end
				end
            end
        else
            Notify(source, 'You already own this weapon!' )
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
		
