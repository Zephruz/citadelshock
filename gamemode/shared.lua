GM.Name = "Citadel Shock"
GM.Author = "Zephruz, ZeroChain"
GM.Email = "N/A"
GM.Website = "N/A"

_R = debug.getregistry()

-- [[PRECACHES]]
local pcf = {
	"cis_base_bombs",
	"cis_bomb_effects",
	"cis_m01",
	"cis_ressource_effects",
	"cis_shockwave_gun",
}
for k,v in pairs(pcf) do
	game.AddParticles( "particles/" ..  v .. ".pcf")
	print("Loaded particle file: " .. v)
end

local particles = {
	"cis_basebomb_explosion_small",
	"cis_basebomb_explosion_medium",
	"cis_basebomb_explosion_big",
	"cis_bomb_fuse01",
	"cis_shockwave_small",
}
for k,v in pairs(particles) do
	PrecacheParticleSystem(v)
end

DeriveGamemode("sandbox")

-- [[GM Variables]]
-- DO NOT EDIT THESE
CitadelShock = (CitadelShock or {})
CitadelShock.Debug = {
	devMode = true,
	betterMsgs = true,
}
CitadelShock.Version = 1
CitadelShock.LibsLoaded = false
CitadelShock.CoreLoaded = false
CitadelShock.ModulesLoaded = false
CitadelShock.ConfigLoaded = false

--[[--------------------
		NETWORK VARS
------------------------]]
CitadelShock.Network = {}
CitadelShock.Network.vars = {}

--[[--------------------
		LOBBY VARS
------------------------]]
CitadelShock.Lobby = (CitadelShock.Lobby or {})
CitadelShock.Lobby.MaxSize = 10
CitadelShock.Lobby.MinSize = 1

--[[--------------------
		GAME VARS
------------------------]]
CitadelShock.Game = (CitadelShock.Game or {})
CitadelShock.Game.TimeLimit = 50000 -- Game time limit in Seconds
CitadelShock.Game.MaxResourceAmount = 100 -- The maximum amount of resource that can be given by a resource node/entity
CitadelShock.Game.LeavePenalty = { -- The exp/point penalty a player gets for leaving a game.
	exp = 10,
	points = 5,
}
CitadelShock.Game.Sides = { -- Lobby side/team setup, each lobby will be split into however many teams is defined in this table.
	-- [[TEAM/SIDE 1]]
	[1] = {
		spos = Vector(61.88, -1684.17, 130.61), -- Side/team spawn position (for all players)
		gen = {
			pos = Vector(-63.16, -1951.68, 129.60), -- Generator spawn position
			ang = Angle(0, 0, 0), -- Generator spawn angles (generally isn't needed to be changed)
		},
		resArea = { -- The area in which resources spawn
			Vector(1030, -2590, 65), -- Area point one
			Vector(-1121, -2202, 65), -- Area point two
		},
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
	},
}

--[[--------------------
		PLAYER VARS
------------------------]]
CitadelShock.Player = (CitadelShock.Player or {})
CitadelShock.Player.OpenHelpOnSpawn = true
CitadelShock.Player.teams = {
	[0] = {
		name = "lobby",
		pname = "Lobby",
		color = Color(255,255,255,255),
		spos = Vector(2.66, -16.84, 2400.03),
	},
	[1] = {
		name = "ingame",
		pname = "In-Game",
		color = Color(88,255,88,255),
	},
	[2] = {
		name = "respawning",
		pname = "Respawning",
		color = Color(255,88,88,255),
		spos = Vector(35.76, 45.74, 899.82),
	},
	[3] = {
		name = "spectator",
		pname = "Spectator",
		color = Color(88,88,255,255),
		spos = Vector(35.76, 45.74, 899.82),
	},
}

-- [[MISC]]
function CitadelShock:Message(msg, pref, pref_col)
	if !(CitadelShock.Debug.betterMsgs) then return false end
	MsgC((pref_col or Color(0,255,0)), (pref or "[Citadel Shock] "), Color(255,255,255), msg .. "\n")
end

function CitadelShock:CreateNewTeam(tbl)
	team.SetUp(tbl.id, tbl.pname, tbl.color, (tbl.joinable or false))
	team.SetClass(tbl.id, "player_" .. tbl.name)
end

-- [[GM Shared]]
function GM:CreateTeams()
	for k,v in pairs(CitadelShock.Player.teams) do
		v.id = k
		CitadelShock:CreateNewTeam(v)
	end
end

function GM:GravGunPunt(ply,ent) return false end