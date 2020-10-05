# Invhud
ESX_InventoryHUD rework

** ALL HTML WORK DONE BY PRIOR DEVELOPERS, ALL IMAGES COLLECTED BY PRIOR DEVELOPERS, MAIN FORK FROM SUKURABU SHOPS ESX_INVENTORYHUD **

Major rework on inventoryhud. Will no longer support individual inventorytype.lua files (i.e. trunk.lua, property.lua, player.lua).
Code condensed specifically for my development.

If wishing to use licenses you Need to add
```
TriggerEvent('invhud:refreshLicenses')
```
To the client file that gives the player the license

If wishing to have weapons count towards player weight you Need to add 
```
TriggerEvent('invhud:removeWeight', xPlayer.source, pickup.name, pickup.count)
```
To your es_extended server main.lua 'esx:onPickup' event 

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
local propertyID = 'I Must Be A String Unique To The Property' -- REQUIRED
local propertyShell = 'shell_name_for_property' -- NOT REQUIRED (FOR USE WITH SHELL HOUSING TO GIVE WEIGHT LIMITS BASED ON SHELL)
TriggerEvent('invhud:openPropertyInv', propertyID, propertyShell)
```
Don't attempt to call from server.

To open a safe inventory use 
```
local safeID = 'I Must Be A String Unique To The Safe'
TriggerEvent('invhud:openSafeInv', safeID)
```
**YOU WILL NEED TO REPLACE ANY ESX_INVENTORYHUD EVENTS IN PLAYERSAFES WITH THE PROPER INVHUD EVENT**
**YOU CAN OPEN ANY INVENTORY OUTSIDE OF INVHUD WITH THESE TWO EVENTS**
