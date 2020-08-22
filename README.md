# Invhud
ESX_InventoryHUD rework

** ALL HTML WORK DONE BY PRIOR DEVELOPERS, ALL IMAGES COLLECTED BY PRIOR DEVELOPERS, MAIN FORK FROM SUKURABU SHOPS ESX_INVENTORYHUD **

Major rework on inventoryhud. Will no longer support individual inventorytype.lua files (i.e. trunk.lua, property.lua, player.lua).
Code condensed specifically for my development.

Copy your cash.png and rename it to money.png to have picture for cash in inventory

**TO USE LIMITS IN SECONDARY INVENTORIES**
Run the following sql query:
ALTER TABLE `items` ADD COLUMN `limit` INT(11) NOT NULL DEFAULT 50;
Then go to the end of line 26 of your es_extended\server\common.lua, create a new line by pressing 'Enter/Return', add the following: limit = v.limit,
Finally go to the end of line 249 of your es_extended\server\main.lua, create a new line by pressing 'Enter/Return', add the following: limit = item.limit,

To open another player inventory you will need to call from client side 
```
local cP, cD = ESX.Game.GetClosestPlayer()
if cD > 0 and cD < 3.0 then
	TriggerEvent('invhud:openPlayerInventory', GetPlayerServerId(cP), GetPlayerName(cP))
else
	ESX.ShowNotification('Nobody')
end
```
Don't attempt to call from server.

To open a property inventory use 
```
local propertyID = 'I Must Be A String Unique To The Property'
TriggerEvent('invhud:openPropertyInv', propertyID)
```
Don't attempt to call from server.

To open a safe inventory use 
```
local safeID = 'I Must Be A String Unique To The Safe'
TriggerEvent('invhud:openSafeInv', safeID)
```
**YOU WILL NEED TO REPLACE ANY ESX_INVENTORYHUD EVENTS IN PLAYERSAFES WITH THE PROPER INVHUD EVENT**
**YOU CAN OPEN ANY INVENTORY OUTSIDE OF INVHUD WITH THESE TWO EVENTS**
