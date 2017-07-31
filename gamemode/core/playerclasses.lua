--[[-----------------------------------
			PLAYER CLASSES
--------------------------------------]]
DEFINE_BASECLASS( "player_default" )

local models = {
	"models/player/Group01/female_0%s.mdl",
	"models/player/Group01/male_0%s.mdl",
}

local loadoutTypes = {
	[0] = {
		name = "lobby",
		f = {
			["Loadout"] = function(self)
				self.Player:StripWeapons()
				self.Player:SetHealth(100)
				
				if (self.Player:IsInLobby()) then
					self.Player:SetReady(false)
				end
			end,
			["Spawn"] = function(self) 
				self.Player:Spawn()
				
				self.Player:SetPos((CitadelShock.Player.teams[self.Player:GetStatus()].spos or Vector(0,0,0)))
				self.Player:UnSpectate()
				
				self.Player:SetTeam( 0 )
				self.Player:SetModel(models[ math.random( #models ) ]:Replace("%s", math.random(1, 6)))
				self.Player:SetPlayerColor( Vector( 1, 1, 1 ) )
				
				self.Player:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			end,
		},
	},
	[1] = {
		name = "ingame",
		f = {
			["Loadout"] = function(self)
				self.Player:StripWeapons()
				self.Player:Give("weapon_cis_shockwavegun")
				self.Player:Give("cis_buildtool")
				self.Player:Give("weapon_physcannon")
				
				self.Player:SetHealth(100)
			end,
			["Spawn"] = function(self)
				if (!self.Player:IsInLobby() or !self.Player:IsInGame()) then self.Player:SetStatus(0) return false end
				
				self.Player:Spawn()
				
				self.Player:SetPos((CitadelShock.Game.Sides[self.Player:GetSide()].spos or Vector(0,0,0)))
				self.Player:UnSpectate()
				
				self.Player:SetTeam( 1 )
				self.Player:SetModel(models[ math.random( #models ) ]:Replace("%s", math.random(1, 6)))
				self.Player:SetPlayerColor( Vector( 1, 1, 1 ) )
				
				self.Player:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			end,
		},
	},
	[2] = {
		name = "respawning",
		f = {
			["Loadout"] = function(self)
				self.Player:SetTeam( 2 )
				self.Player:StripWeapons()
			end,
			["Spawn"] = function(self)
				if (!self.Player:IsInLobby() or !self.Player:IsInGame()) then self.Player:SetStatus(0) return false end
				if not (self.Player:Alive()) then self.Player:Spawn() end

				self.Player:Spectate( OBS_MODE_ROAMING )
				self.Player:SetPos((CitadelShock.Player.teams[self.Player:GetStatus()].spos or Vector(0,0,0)))
				timer.Simple((CitadelShock.Game.RespawnTime or 5),
				function()
					self.Player:SetStatus(1)
				end)
			end,
		},
	},
	[3] = {
		name = "spectator",
		f = {
			["Loadout"] = function(self)
				self.Player:SetTeam( 3 )
				self.Player:StripWeapons()
			end,
			["Spawn"] = function(self)
				if (self.Player:IsInLobby() && self.Player:IsInGame()) then self.Player:SetStatus(0) return false end
				if not (self.Player:Alive()) then self.Player:Spawn() end
				
				self.Player:Spectate( OBS_MODE_ROAMING )
				self.Player:SetPos((CitadelShock.Player.teams[self.Player:GetStatus()].spos or Vector(0,0,0)))
			end,
		},
	},
}

for k,v in pairs(loadoutTypes) do
	local PLAYER = {}

	if (v.f) then
		for p,f in pairs(v.f) do
			PLAYER[p] = f
		end
	end

	player_manager.RegisterClass( "player_" .. v.name, PLAYER, "player_default" )
end
