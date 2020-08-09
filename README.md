# Invhud
ESX_InventoryHUD rework

** ALL HTML WORK DONE BY PRIOR DEVELOPERS, ALL IMAGES COLLECTED BY PRIOR DEVELOPERS, MAIN FORK FROM SUKURABU SHOPS ESX_INVENTORYHUD **

Major rework on inventoryhud. Will no longer support individual inventorytype.lua files (i.e. trunk.lua, property.lua, player.lua).
Code condensed specifically for my development.

Copy your cash.png and rename it to money.png to have picture for cash in inventory

To open another player inventory you will need to call from client side TriggerEvent('invhud:openPlayerInventory', GetPlayerServerId(closestPlayer), GetPlayerName(closestPlayer)) or from server side TriggerClientEvent('invhud:openPlayerInventory', targetPlayerServerId, targetPlayerName)

To open a property inventory use TriggerEvent('invhud:openPropertyInv', propertyID), to open a safe inventory use TriggerEvent('invhud:openSafeInv', safeID) **YOU WILL NEED TO
REPLACE ANY ESX_INVENTORYHUD EVENTS IN PLAYERSAFES WITH THE PROPER INVHUD EVENT**
