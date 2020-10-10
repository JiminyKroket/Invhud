# Invhud
ESX_InventoryHUD rework

OPEN KEY IS A KEY BIND. AN IN GAME KEY BIND. IF YOU RAN THE SCRIPT WITHOUT CONFIGURING IT PROPERLY, OR
IF YOU HAVE ANY CLIENTS WHO ALREADY HAVE THIS KEY MAPPED, THE ONLY WAY TO ADJUST A KEY BIND IS
IN YOUR KEY BINDS IN GAME.

** MOST HTML WORK DONE BY PRIOR DEVELOPERS, ALL IMAGES COLLECTED BY PRIOR DEVELOPERS, MAIN FORK FROM SUKURABU SHOPS ESX_INVENTORYHUD **

Major rework on inventoryhud. Will no longer support individual inventorytype.lua files (i.e. trunk.lua, property.lua, player.lua).
Code condensed specifically for my development.

If wishing to have weapons count towards player weight you Need to add 
```
TriggerEvent('invhud:removeWeight', xPlayer.source, pickup.name, pickup.count)
```
To your es_extended server main.lua 'esx:onPickup' event 


Don't attempt to call from server.
To open a property inventory use 
```
local propertyID = 'I Must Be A String Unique To The Property' -- REQUIRED
local propertyShell = 'shell_name_for_property' -- NOT REQUIRED (FOR USE WITH SHELL HOUSING TO GIVE WEIGHT LIMITS BASED ON SHELL)
TriggerEvent('invhud:openPropertyInv', propertyID, propertyShell)
```
To open a safe inventory use 
```
local safeID = 'I Must Be A String Unique To The Safe'
TriggerEvent('invhud:openSafeInv', safeID)
```
**YOU WILL NEED TO REPLACE ANY ESX_INVENTORYHUD EVENTS IN PLAYERSAFES WITH THE PROPER INVHUD EVENT**
**YOU CAN OPEN ANY INVENTORY OUTSIDE OF INVHUD WITH THESE TWO EVENTS**
