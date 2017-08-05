--[[
	GAME CONFIGURATION
]]

--[[
	CONFIG VARIABLES
]]
-- [[Generator]]
CitadelShock.Game.GeneratorHealth = 2500 		-- How much health the generator starts with
CitadelShock.Game.BombPurchaseDelay = 5 		-- Delay between bomb purchases (in seconds)
CitadelShock.Game.MoneyGenerationInts = 60 		-- How frequent the generator spawns money (in seconds)

-- [[Misc]]
CitadelShock.Game.ResourceRespawnTime = 10 		-- How long it takes for a resource to respawn
CitadelShock.Game.MaxResourceAmount = 100 		-- The maximum amount of resources that can be given by a resource node/entity

-- [[Game phases/rounds]]
CitadelShock.Game.Phases = {
	-- Phases go in order (1, 2, 3, etc)
	-- Don't make the phase order less than 0
	-- DIVIDER - The divider is the wall that blocks the teams from seeing eachother (used in the build phase)

	-- [[Build status/phase]]
	[1] = { -- The phase order
		name = "Build", 		-- Phase name (REQUIRED)
		timeLimit = (60*10),		-- Phase time limit/length (REQUIRED)
		canBuild = true,		-- Can players build during this phase? (REQUIRED)
		canFight = false,		-- Can players fight during this phase? (REQUIRED)
		divider = true,			-- Is there a side divider during this phase? (REQUIRED)
		ui = {
			color = Color(55,255,125,255),								-- The color of this phase (REQUIRED)
			icon = "materials/citadelshock/hud/cis_icon_hammer.png",	-- The icon of this phase (REQUIRED)				
		},
		-- [[optional stuff below]]
		custFunc = function(lobby)									-- Custom function to run when this phase starts

		end,
	},
	
	-- [[Fight status/phase]]
	[2] = {
		name = "Fight",
		timeLimit = (60*10),
		canBuild = false,
		canFight = true,
		divider = false,
		ui = {
			color = Color(255,125,55,255),
			icon = "materials/citadelshock/hud/cis_icon_bomb.png",
		},
	},
}


-- [[Game rewards & deductions]]
-- Reward types: EXP, Points, Level, Wins, and Losses
-- Use negative numbers to take/deduct points

CitadelShock.Game.LeavePenalty = { 
	-- The exp & point deduction a player receives for leaving a game.
	EXP = -10,		-- Takes exp from the player
	Points = -2,	-- Takes points from the player
	Losses = 1, 	-- Adds a lose to the player
}

CitadelShock.Game.DrawRewards = {
	-- The exp & point rewards for both teams in the case of a draw.
	EXP = 15,
	Points = 2,
}

CitadelShock.Game.WinRewards = {
	-- Wins and Losses are automatically added when a game ends
	-- The exp & point rewards that winning team players get.
	EXP = 50,
	Points = 5,
}

CitadelShock.Game.KillRewards = {
	-- The exp & point rewards a player gets for killing an enemy
	EXP = 25,
	Points = 1,
}

-- [[Team sides]]
CitadelShock.Game.Sides = { 
	-- Lobby side/team setup, each lobby will be split into however many teams is defined in this table.
	-- I HIGHLY RECOMMEND TO ONLY HAVE 2 TEAMS
	
	-- [[TEAM/SIDE 1]]
	[1] = {
		spos = Vector(61.88, -1684.17, 130.61), 	-- Side/team spawn position (for all players on THIS side)
		gen = {
			pos = Vector(-63.16, -1951.68, 129.60), -- Generator spawn position
			ang = Angle(0, 0, 0), 					-- Generator spawn angles (generally is not needed to be changed)
		},
		resArea = { -- The area in which resources CAN spawn (this is passed to the resource creation function)
			Vector(1030, -2590, 65),	-- Area point one
			Vector(-1121, -2202, 65), 	-- Area point two
		},
		color = Color(205,85,85),		-- Team/Side Color
	},
	
	-- [[TEAM/SIDE 2]]
	[2] = {
		spos = Vector(-95.60, 1819.40, 125.06),
		gen = {
			pos = Vector(-74.22, 1880.23, 125.34),
			ang = Angle(0, 0, 0),
		},
		resArea = {
			Vector(-1085, 2560, 65), 
			Vector(1070, 2196, 65),
		},
		color = Color(85,205,85),
	},
}

--[[
	RESOURCES
	- Resources that are spawned in-game for harvesting.
]]

-- /* Disabled (default) bombs, resources & structures, false = enabled, true = disabled */
-- These are ONLY for default resources & structures.
CitadelShock.Game.Disabled = {
	-- Structures
	structures = {
		["cis_struc_foundation"] = false,
		["cis_struc_wall"] = false,
		["cis_struc_beam"] = false,
		["cis_struc_roof"] = false,
		["cis_struc_stairs"] = false,
	},
	
	-- Resources
	resources = {
		["money"] = false,
		["wood"] = false,
		["stone"] = false,
		["metal"] = false,
	},
	
	-- Bombs
	bombs = {
		["cis_bomb_small"] = false,
		["cis_bomb_medium"] = false,
		["cis_bomb_big"] = false,
		["cis_bomb_proximity"] = false,
		["cis_bomb_logs"] = false,
	},
}

-- /* The amount of resources a team starts with */
-- These are ONLY for default resources.
CitadelShock.Game.StartResources = {
	-- Resources
	["money"] = 500,
	["wood"] = 0,
	["stone"] = 0,
	["metal"] = 0,
}

-- /* The info of default bombs */
-- These are ONLY for default bombs.
CitadelShock.Game.BombInfo = {
	-- [[Proximity Bomb]]
	-- Available costs: money, wood, stone, and metal
	
	["cis_bomb_proximity"] = {
		reqLevel = 10, 							-- The level required to purchase this bomb
		BombName = "Proximity Bomb",													-- Name of the bomb
		BombCost = {["money"] = 475, ["wood"] = 25, ["stone"] = 25, ["metal"] = 20},	-- Resource costs of the bomb
		BlastRadius = 250,																-- Blast radius of the bomb
		BlastDamageMultiplier = 15,														-- The damage of the bomb
		BombMass = 20,																	-- The weight of the bomb
	},
	
	-- [[Small Bomb]]
	["cis_bomb_small"] = {
		reqLevel = 1,
		BombName = "Small Bomb",
		BombCost = {["money"] = 250, ["wood"] = 5, ["stone"] = 5},
		BlastRadius = 350,
		BlastDamageMultiplier = 10,
		BombMass = 10,
	},
	
	-- [[Medium Bomb]]
	["cis_bomb_medium"] = {
		reqLevel = 3,
		BombName = "Medium Bomb",
		BombCost = {["money"] = 350, ["wood"] = 10, ["stone"] = 10},
		BlastRadius = 600,
		BlastDamageMultiplier = 15,
		BombMass = 15,	
	},
	
	-- [[Big Bomb]]
	["cis_bomb_big"] = {
		reqLevel = 7,
		BombName = "Big Bomb",
		BombCost = {["money"] = 475, ["wood"] = 15, ["stone"] = 15},
		BlastRadius = 800,
		BlastDamageMultiplier = 20,
		BombMass = 18,	
	},
	
	["cis_bomb_logs"] = {
		reqLevel = 1,
		BombName = "Log Bomb",
		BombCost = {["money"] = 25, ["wood"] = 20, ["stone"] = 15},
		BlastRadius = 350,
		BlastDamageMultiplier = 15,
		BombMass = 300,
	}
}

-- /* The info of default structures */
-- These are ONLY for default structures.
CitadelShock.Game.StructureInfo = {
	-- Foundations
	["cis_struc_foundation"] = {
		-- cost = resource costs to build the structure, health = the structure health, reqLevel = Required Level to build the structure
		[1] = {cost = {["wood"] = 15}, health = 300, reqLevel = 1}, -- Wood foundation
		[2] = {cost = {["stone"] = 35}, health = 600, reqLevel = 3}, -- Stone foundation
		[3] = {cost = {["metal"] = 35}, health = 900, reqLevel = 5}, -- Metal foundation
	},
	
	-- Walls
	["cis_struc_wall"] = {
		[1] = {cost = {["wood"] = 15}, health = 300, reqLevel = 1}, -- Wood wall
		[2] = {cost = {["stone"] = 35}, health = 600, reqLevel = 3}, -- Stone wall
		[3] = {cost = {["metal"] = 35}, health = 900, reqLevel = 5}, -- Metal wall
	},
	
	-- Beams
	["cis_struc_beam"] = {
		[1] = {cost = {["wood"] = 15}, health = 300, reqLevel = 1}, -- Wood beam
		[2] = {cost = {["stone"] = 35}, health = 600, reqLevel = 3}, -- Stone beam
		[3] = {cost = {["metal"] = 35}, health = 900, reqLevel = 5}, -- Metal beam
	},
	
	-- Roofs
	["cis_struc_roof"] = {
		[1] = {cost = {["wood"] = 15}, health = 300, reqLevel = 1}, -- Wood roof
		[2] = {cost = {["stone"] = 35}, health = 600, reqLevel = 3}, -- Stone roof
		[3] = {cost = {["metal"] = 35}, health = 900, reqLevel = 5}, -- Metal roof
	},
	
	-- Stairs
	["cis_struc_stairs"] = {
		[1] = {cost = {["wood"] = 15}, health = 300, reqLevel = 1}, -- Wood stairs
		[2] = {cost = {["stone"] = 35}, health = 600, reqLevel = 3}, -- Stone stairs
		[3] = {cost = {["metal"] = 35}, health = 900, reqLevel = 5}, -- Metal stairs
	},
}

--[[------------------------
	!!!!!!!!!!!!!!!!!!!!!
	CREATE NEW STUFF HERE
	!!!!!!!!!!!!!!!!!!!!!
--------------------------]]

--[[ /* RESOURCES */
	-- New resources CAN be utilized by new structures.
]]
/*
	CitadelShock.Game:CreateNewResource("imaresource", -- The name of the resource.
	0, -- The amount of this resource each side starts with.
	"icon16/house.png", -- The icon this resource is on the HUD.
	function(l, s, sid) -- (Lobby (lobby meta object), Side (table), Side ID (int))
	
		-- This is where you set up the resource.
		-- This function is called at the start of EVERY game.
		-- This is where I would generally spawn resources within the defined resource area.
		
	end)
*/



--[[ /* STRUCTURES */
	- Structures require an entity to be created
]]
/*
	CitadelShock.Game:CreateNewStructure("cis_struc_foundation", {
		types = { -- The types of structures that are available for this structure base. 
			[1] = {
				name = "Wood Structure", 		-- The visible name of this structure when selected on the structure placement SWEP.
				model = "models/zerochain/props_structure/wood_structure.mdl",  -- The model of this structure.
				health = 750, 													-- The amount of health this structure has
				cost = {["wood"] = 100}, 										-- The resource cost of this structure
			},
		},
		atpts = { -- Set attachment point positioning. MODELS MUST HAVE ATTACHMENT POINTS SET.
			["cis_struc_foundation"] = {5,6,7,8}, 	-- The attachment points this structure can snap to (5, 6, 7, and 8)
			["worldspawn"] = {},					-- No attachment points means it can be placed anywhere on the entity
		},
		custPosCheck = function(ns, ps) end, 		-- [OPTIONAL] (new Structure, parent Structure) Custom position checking. Set a custom position for the structure on a parent/trace entity. RETURN A VECTOR
		validPosCheck = function(ns, tr) end,		-- [OPTIONAL] (new Structure, player Trace) Valid position checking. Set a valid position check for the structure. RETURN A BOOLEAN
	})
*/



--[[ /* BOMBS */
	- Bambs man
]]
/*
	CitadelShock.Game:CreateNewBomb("cis_bomb_small", {
		reqLevel = 1, 					-- The level required to purchase this bomb
		BombMass = 15,					-- The weight/mass of the bomb
		BombDrag = 0.2, 				-- The air resistance of the bomb
		BlastRadius = 350,				-- The blast radius of the bomb
		BlastDamageMultiplier = 10,		-- The damage multiplier
		ExplodeTime = 5,				-- How long it takes for the bomb to explode
		Model = "models/zerochain/props_mystic/bomb_small.mdl", -- Bomb Model
	})
*/