# Invhud
ESX_InventoryHUD rework
**THIS SCRIPT IS NOT TESTED NOR SUPPORTED FOR ESX2.0 AND ABOVE OR ANY NON GITHUB TAG FROM THE ESX-ORG LINK HERE: https://github.com/esx-framework/es_extended/tags**

IF YOU HAVE NOT REMOVED ESX's STANDARD INVENTORY EVENT, DO SO BY COMMENTING(THE TWO DASHES IN FRONT LIKE DISPLAYED) OR DELETING THIS THREAD FROM YOUR ESX CLIENT/MAIN.LUA
-- Citizen.CreateThread(function()
	-- while true do
		-- Citizen.Wait(0)

		-- if IsControlJustReleased(0, 289) then
			-- if IsInputDisabled(0) and not isDead and not ESX.UI.Menu.IsOpen('default', 'es_extended', 'inventory') then
				-- ESX.ShowInventory()
			-- end
		-- end
	-- end
-- end)

THIS THREAD CAN BE FOUND STARTING ON THE FOLLOWING LINES FOR UNEDITED VERSIONS OF THE PROCEEDING ESX VERSION: LINE 462 FOR ESX1.0(I HAVE/WILL NOT CHECK EACH SEPARATE 1.0.TAG),
LINE 480 FOR ESX1.1, LINE 444 FOR ESX1.2, LINE 438 FOR ESXV1-FINAL.

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
