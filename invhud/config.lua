Config = {}
Config.Locale = 'en'
Config.IncludeCash = true -- Include cash in inventory?
Config.IncludeWeapons = true -- Include weapons in inventory?
Config.IncludeBlackMoney = true -- Include black money in inventory?
Config.OpenControl = 82 -- Key for opening inventory. Edit html/js/config.js to change key for closing it.
Config.CurrencyIcon = '$' -- Currency icon used for non html text
Config.NeedsWeaponsLicense = true -- Player needs weapon license to use weapon shop?

-- List of item names that will close ui when used
Config.CloseUiItems = {"headbag", "fishingrod", "tunerlaptop", "binoculars", "joint", "cigarette", "cigar", "fixkit", "rollingpaper", "cocaine", "meth", 'lowcalrounds',
	'shotcalrounds', 'midcalrounds', 'highcalrounds', 'speccalrounds'
}

Config.Shops = { -- SET ALL SHOP INFORMATION HERE: TABLE NAME IS STORE NAME, TYPE(TYPE OF SHOP, 'purchase', 'sell', 'mix' AVAILABLE, CHOOSE WHAT THE PLAYER CAN DO AT THAT SHOP),
	-- ACCOUNT(PLAYER ACCOUNT TO GIVE/TAKE MONEY FROM), LOCATIONS(SHOP LOCATIONS), SOCIETY(SET SOCIETY NAME TO PAY TO/FROM, SET false IF NO SOCIETY IS USED),
	-- BUYBACK(SET VALUE FROM 0.0-1.0, AMOUNT OF ITEM PRICE GIVEN WHEN SELLING TO SHOP), ITEMS(ITEMS SHOP CAN SELL/BUY), 
	-- MARKERS(USE MARKERS?, WHAT SHAPE?, HOW FAR?, SHOW NAME?, WHAT COLOR?), BLIPS(USE BLIPS?, WHAT PICTURE?, WHAT COLOR?, HOW BIG?, WHERE TO DISPLAY?)
    ['24/7 Convenience'] = {
		Type = 'purchase',
		Account = 'money',
		Society = {
			Name = 'convenience',
			Options = {
				withdraw = true,
				deposit = true,
				wash = false,
				employess = true,
				grades = true
			},
		},
		BuyBack = 0.5,
        Locations = {
			Store = {
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
			Boss = {
				vector3(372.875,   322.896,  102.566),
				-- vector3(2557.458,  382.282,  107.622),
				-- vector3(-3038.939, 585.954,  6.908),
				-- vector3(-3241.927, 1001.462, 11.830),
				-- vector3(547.431,   2671.710, 41.156),
				-- vector3(1961.464,  3740.672, 31.343),
				-- vector3(2678.916,  3280.671, 54.241),
				-- vector3(1729.216,  6414.131, 34.037),
				-- vector3(-48.519,   -1757.514, 28.421),
				-- vector3(1163.373,  -323.801,  68.205),
				-- vector3(-707.501,  -914.260,  18.215),
				-- vector3(-1820.523, 792.518,   137.118),
				-- vector3(1698.388,  4924.404,  41.063),
				-- vector3(25.723,   -1346.966, 28.497),
			},
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
		Markers = {
			Use = true,
			Type = 1,
			Draw = 15,
			UseText = true,
			RGB = vector3(0, 255, 0)
		},
		Blips = {
			Use = true,
			Sprite = 52,
			Color = 2,
			Scale = 1.0,
			Display = 4
		}
    },
	
	['24/7 Black Market'] = {
		Type = 'purchase',
		Account = 'black_money',
		Society = {
			Name = false,
			Options = {
				withdraw = true,
				deposit = true,
				wash = false,
				employess = true,
				grades = true
			},
		},
		BuyBack = 0.5,
        Locations = {
			Store = {
				vector3(379.83, 356.55, 101.59),
				vector3(2553.08, 399.43, 107.56),
				vector3(-3047.65, 590.06, 6.78),
				vector3(-3248.03, 1009.90, 11.47),
				vector3(541.79, 2663.72, 41.17),
				vector3(1953.03, 3753.31, 31.21),
				vector3(2670.60, 3286.36, 54.24),
				vector3(1741.49, 6419.75, 34.04),
				vector3(-40.92, -1747.86, 28.33),
				vector3(1160.64, -311.81, 68.28),
				vector3(-725.28, -904.76, 19.45),
				vector3(-1829.39, 801.23, 137.41),
				vector3(1702.57,  4916.74,  41.08),
			},
			Boss = {
				vector3(378.83, 357.55, 101.59),
				-- vector3(2553.08, 399.43, 107.56),
				-- vector3(-3047.65, 590.06, 6.78),
				-- vector3(-3248.03, 1009.90, 11.47),
				-- vector3(541.79, 2663.72, 41.17),
				-- vector3(1953.03, 3753.31, 31.21),
				-- vector3(2670.60, 3286.36, 54.24),
				-- vector3(1741.49, 6419.75, 34.04),
				-- vector3(-40.92, -1747.86, 28.33),
				-- vector3(1160.64, -311.81, 68.28),
				-- vector3(-725.28, -904.76, 19.45),
				-- vector3(-1829.39, 801.23, 137.41),
				-- vector3(1702.57,  4916.74,  41.08),
			},
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
		Markers = {
			Use = true,
			Type = 1,
			Draw = 5,
			UseText = true,
			RGB = vector3(255, 0, 0)
		},
		Blips = {
			Use = false,
			Sprite = 52,
			Color = 2,
			Scale = 1.0,
			Display = 4
		}
    },

    ['Robs Liquour'] = {
		Type = 'purchase',
		Account = 'money',
		Society = {
			Name = false,
			Options = {
				withdraw = true,
				deposit = true,
				wash = false,
				employess = true,
				grades = true
			},
		},
		BuyBack = 0.5,
		Locations = {
			Store = {
				vector3(1135.808,  -982.281,  45.415),
				vector3(-1222.915, -906.983,  11.326),
				vector3(-1487.553, -379.107,  39.163),
				vector3(-2968.243, 390.910,   14.043),
				vector3(1166.024,  2708.930,  37.157),
				vector3(1392.562,  3604.684,  33.980),
				vector3(-1393.409, -606.624,  29.319)
			},
			Boss = {
				vector3(1134.808,  -983.281,  45.415),
				-- vector3(-1222.915, -906.983,  11.326),
				-- vector3(-1487.553, -379.107,  39.163),
				-- vector3(-2968.243, 390.910,   14.043),
				-- vector3(1166.024,  2708.930,  37.157),
				-- vector3(1392.562,  3604.684,  33.980),
				-- vector3(-1393.409, -606.624,  29.319)
			},
        },
        Items = {
            {name = 'beer'},
            {name = 'wine'},
            {name = 'vodka'},
            {name = 'tequila'},
            {name = 'whisky'},
            {name = 'grand_cru'}
        },
		Markers = {
			Use = true,
			Type = 1,
			Draw = 15,
			UseText = true,
			RGB = vector3(0, 255, 0)
		},
		Blips = {
			Use = true,
			Sprite = 93,
			Color = 2,
			Scale = 1.0,
			Display = 4
		}
	},

    ['You Tool'] = {
		Type = 'purchase',
		Account = 'money',
		Society = {
			Name = false,
			Options = {
				withdraw = true,
				deposit = true,
				wash = false,
				employess = true,
				grades = true
			},
		},
		BuyBack = 0.5,
        Locations = {
			Store = {
				vector3(2748.0, 3473.0, 55.68),
			},
			Boss = {
				vector3(2747.0, 3474.0, 55.68),
			},
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
		Markers = {
			Use = true,
			Type = 1,
			Draw = 15,
			UseText = true,
			RGB = vector3(0, 255, 0)
		},
		Blips = {
			Use = true,
			Sprite = 402,
			Color = 2,
			Scale = 1.0,
			Display = 4
		}
    },

    ['Bolinkbroke Penitentiary'] = {
		Type = 'purchase',
		Account = 'money',
		Society = {
			Name = false,
			Options = {
				withdraw = true,
				deposit = true,
				wash = false,
				employess = true,
				grades = true
			},
		},
		BuyBack = 0.5,
        Locations = {
			Store = {
				vector3(1728.41, 2584.31, 45.84),
			},
			Boss = {
				vector3(1727.41, 2583.31, 45.84),
			},
        },
        Items = {
            {name = 'bread'},
            {name = 'water'},
            {name = 'cigarette'},
            {name = 'lighter'},
            {name = 'sandwich'},
            {name = 'chips'}
        },
		Markers = {
			Use = true,
			Type = 1,
			Draw = 15,
			UseText = true,
			RGB = vector3(0, 255, 0)
		},
		Blips = {
			Use = true,
			Sprite = 52,
			Color = 2,
			Scale = 1.0,
			Display = 4
		}
    },

    ['Ammunation'] = {
		Type = 'purchase',
		Account = 'money',
		Society = {
			Name = false,
			Options = {
				withdraw = true,
				deposit = true,
				wash = false,
				employess = true,
				grades = true
			},
		},
		BuyBack = 0.5,
        Locations = {
			Store = {
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
			Boss = {
				vector3(-663.180, -933.961, 20.829),
				-- vector3(810.25, -2157.60, 28.62),
				-- vector3(1693.44, 3760.16, 33.71),
				-- vector3(-330.24, 6083.88, 30.45),
				-- vector3(252.63, -50.00, 68.94),
				-- vector3(22.09, -1107.28, 28.80),
				-- vector3(2567.69, 294.38, 107.73),
				-- vector3(-1117.58, 2698.61, 17.55),
				-- vector3(842.44, -1033.42, 27.19),
			},
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
		Markers = {
			Use = true,
			Type = 1,
			Draw = 15,
			UseText = true,
			RGB = vector3(0, 255, 0)
		},
		Blips = {
			Use = true,
			Sprite = 110,
			Color = 2,
			Scale = 1.0,
			Display = 4
		}
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
		useText = true,
        size = vector3(1.0, 1.0, 1.0),
        job = 'lspd',
        markerType = 2,
		draw = 15,
        markerColour = { x = 255, y = 255, z = 255 },
        msg = 'Open Stash ~INPUT_CONTEXT~'
    },
    ['BCSO'] = {
        coords = vector3(1851.20, 3690.78, 33.27),
		useText = true,
        size = vector3(1.0, 1.0, 1.0),
        job = 'bcso',
        markerType = 2,
		draw = 15,
        markerColour = { x = 255, y = 255, z = 255 },
        msg = 'Open Stash ~INPUT_CONTEXT~'
    },
    ['1'] = {
        coords = vector3(1848.28, 3689.40, 33.27),
		useText = true,
        size = vector3(1.0, 1.0, 1.0),
        job = 'identifier',
        markerType = 2,
		draw = 15,
        markerColour = { x = 255, y = 255, z = 255 },
        msg = 'Open Stash ~INPUT_CONTEXT~'
    },
    ['2'] = {
        coords = vector3(444.37, -980.02, 29.69),
		useText = true,
        size = vector3(1.0, 1.0, 1.0),
        job = 'identifier',
        markerType = 2,
		draw = 15,
        markerColour = { x = 255, y = 255, z = 255 },
        msg = 'Open Stash ~INPUT_CONTEXT~'
    }
}
