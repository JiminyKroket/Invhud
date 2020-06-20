Config = {}
Config.Locale = 'en'
Config.IncludeCash = true -- Include cash in inventory?
Config.IncludeWeapons = true -- Include weapons in inventory?
Config.IncludeAccounts = true -- Include accounts (bank, black money, ...)?
Config.ExcludeAccountsList = {'bank', 'credit'} -- List of accounts names to exclude from inventory
Config.OpenControl = 82 -- Key for opening inventory. Edit html/js/config.js to change key for closing it.
Config.CurrencyIcon = '$' -- Is your languages currency icon

-- List of item names that will close ui when used
Config.CloseUiItems = {"headbag", "fishingrod", "tunerlaptop", "binoculars", "gps", "joint", "cigarette", "cigar", "fixkit", "rollingpaper", "cocaine", "meth"}

Config.Blips = {
	Use = true,
	regular = 52,
	robsliquor = 93,
	youtool = 402,
	prison = 52,
	weaponshop = 110
}

Config.Names = {
	regular = 'Convenience Store',
	robsliquor = 'Liquor Store',
	youtool = 'Hardware Store',
	prison = 'Prison Shop',
	weaponshop = 'Ammunation'
}

Config.Colors = {
	regular = 2,
	robsliquor = 2,
	youtool = 2,
	prison = 1,
	weaponshop = 1
}

Config.Shops = {
    regular = {
        Locations = {
			vector3(373.875,   325.896,  102.566),
			vector3(2557.458,  382.282,  107.622),
			vector3(-3038.939, 585.954,  6.908),
			vector3(-3241.927, 1001.462, 11.830),
			vector3(547.431,   2671.710, 41.156),
			vector3(1961.464,  3740.672, 31.343),
			vector3(2678.916,  3280.671, 54.241),
            vector3(1729.216,  6414.131, 34.037),
            vector3(-48.519,   -1757.514, 28.421),
			vector3(1163.373,  -323.801,  68.205),
			vector3(-707.501,  -914.260,  18.215),
			vector3(-1820.523, 792.518,   137.118),
            vector3(1698.388,  4924.404,  41.063),
            vector3(25.723,   -1346.966, 28.497), 
        },
        Items = {
            {name = 'bread'},
            {name = 'water'},
            {name = 'cigarette'},
            {name = 'lighter'},
            {name = 'rollingpaper'},
            {name = 'phone'},
            {name = 'sandwich'},
            {name = 'hamburger'},
            {name = 'cupcake'},
            {name = 'chips'},
            {name = 'pistachio'},
            {name = 'chocolate'},
            {name = 'cashew'},
            {name = 'cocacola'},
            {name = 'drpepper'},
            {name = 'energy'},
            {name = 'lemonade'},
            {name = 'icetea'}
        },
		Marker = true
    },

    robsliquor = {
		Locations = {
			vector3(1135.808,  -982.281,  45.415),
			vector3(-1222.915, -906.983,  11.326),
			vector3(-1487.553, -379.107,  39.163),
			vector3(-2968.243, 390.910,   14.043),
			vector3(1166.024,  2708.930,  37.157),
			vector3(1392.562,  3604.684,  33.980),
			vector3(-1393.409, -606.624,  29.319)
        },
        Items = {
            {name = 'beer'},
            {name = 'wine'},
            {name = 'vodka'},
            {name = 'tequila'},
            {name = 'whisky'},
            {name = 'grand_cru'}
        },
		Marker = true
	},

    youtool = {
        Locations = {
            vector3(2748.0, 3473.0, 55.68),
        },
        Items = {
            {name = 'drill'},
            {name = 'binocular'},
            {name = 'fixkit'},
            {name = 'gps'},
            {name = 'lockpick'},
            {name = 'scubagear'},
            {name = 'blowtorch'},
            {name = '1gbag'},
            {name = '5gbag'},
            {name = '50gbag'},
            {name = '100gbag'},
            {name = 'lowgradefert'},
            {name = 'highgradefert'},
            {name = 'plantpot'},
            {name = 'drugscales'}
        },
		Marker = true
    },

    prison = {
        Locations = {
            vector3(1728.41, 2584.31, 45.84),
        },
        Items = {
            {name = 'bread'},
            {name = 'water'},
            {name = 'cigarette'},
            {name = 'lighter'},
            {name = 'sandwich'},
            {name = 'chips'}
        },
		Marker = true
    },

    weaponshop = {
        Locations = {
            vector3(-662.180, -934.961, 20.829),
            vector3(810.25, -2157.60, 28.62),
            vector3(1693.44, 3760.16, 33.71),
            vector3(-330.24, 6083.88, 30.45),
            vector3(252.63, -50.00, 68.94),
            vector3(22.09, -1107.28, 28.80),
            vector3(2567.69, 294.38, 107.73),
            vector3(-1117.58, 2698.61, 17.55),
            vector3(842.44, -1033.42, 27.19),
        },
        Weapons = {
            {name = "WEAPON_FLASHLIGHT", label = 'Flashlight', price = 20},
            {name = "WEAPON_STUNGUN", label = 'Tazer', price = 120},
            {name = "WEAPON_KNIFE", label = 'Knife', price = 60},
            {name = "WEAPON_BAT", label = 'Baseball Bat', price = 20},
            {name = "WEAPON_PISTOL", label = '9mm Pistol', price = 200},
            {name = "WEAPON_PUMPSHOTGUN", label = 'Pump-Shotgun', price = 600}
        },
        Items = {
            {name = 'lowcalrounds'},
            {name = 'shotcalrounds'},
            {name = 'midcalrounds'},
            {name = 'highcalrounds'},
            {name = 'speccalrounds'}
        },
		Marker = true
    },
}

Config.Bullets = {
	lowcalrounds = {
		453432689,
		3219281620,
		1593441988,
		-1716589765,
		-1076751822,
		-771403250,
		137902532,
		584646201,
		324215364,
		-619010992,
		
	},
	midcalrounds = {
		-598887786,
		-1045183535,
		736523883,
		2024373456,
		-270015777,
		171789620,
		1627465347,
		-1121678507,
		-1063057011,
		1649403952,
		-952879014,
		
	},
	highcalrounds = {
		-1660422300,
		2144741730,
		3686625920,
		-1074790547,
		961495388,
		-2084633992,
		4208062921,
		-1357824103,
		2132975508,
		100416529,
		205991906,
		177293209,
		
	},
	shotcalrounds = {
		487013001,
		2017895192,
		-1654528753,
		-494615257,
		-1466123874,
		984333226,
		-275439685,
		317205821,
		
	},
	speccalrounds = {
		911657153,
		1198879012,
		-1568386805,
		-1312131151,
		1119849093,
		2138347493,
		1834241177,
		1672152130,
		1305664598,
		125959754,
		-1813897027,
		741814745,
		-1420407917,
		-1600701090,
		615608432,
		101631238,
		883325847,
		1233104067,
		600439132,
		126349499,
		-37975472,
		-1169823560
	}
}

Config.Stash = {
    ['LSPD'] = {
        coords = vector3(452.16, -980.14, 29.69),
        size = vector3(1.0, 1.0, 1.0),
        job = 'lspd',
        markerType = 2,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = 'Open Stash ~INPUT_CONTEXT~'
    },
    ['BCSO'] = {
        coords = vector3(1851.20, 3690.78, 33.27),
        size = vector3(1.0, 1.0, 1.0),
        job = 'bcso',
        markerType = 2,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = 'Open Stash ~INPUT_CONTEXT~'
    },
    ['1'] = {
        coords = vector3(1848.28, 3689.40, 33.27),
        size = vector3(1.0, 1.0, 1.0),
        job = 'identifier',
        markerType = 2,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = 'Open Stash ~INPUT_CONTEXT~'
    },
    ['2'] = {
        coords = vector3(444.37, -980.02, 29.69),
        size = vector3(1.0, 1.0, 1.0),
        job = 'identifier',
        markerType = 2,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = 'Open Stash ~INPUT_CONTEXT~'
    }
}
