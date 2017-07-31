--[[
	Game File
	- File for the creation and modification of lobby games
]]
CitadelShock.Game = (CitadelShock.Game or {})
CitadelShock.Game.Disabled = {}
CitadelShock.Game.Resources = {}
CitadelShock.Game.Structures = {}
CitadelShock.Game.Bombs = {}

CitadelShock.Game.Phases = {}

--[[-----------
	SHARED
-------------]]
-- [[Resource creation/removal]]
function CitadelShock.Game:CreateNewResource(nm, val, icon, func)
	table.insert(CitadelShock.Game.Resources, {name = nm, val = val, genRes = func, icon = (icon or false)})
	print("\t --> Registered game resource: " .. nm)
end

function CitadelShock.Game:RemoveResource(nm)
	if !(CitadelShock.Game.Resources[nm]) then return false end
	
	CitadelShock.Game.Resources[nm] = nil
	print("\t --> Removed game resource: " .. nm)
end

-- [[Structure creation/removal]]
function CitadelShock.Game:CreateNewStructure(class, tbl)
	local overRode = false
	if (CitadelShock.Game.Structures[class]) then overRode = true
	else CitadelShock.Game.Structures[class] = {} end
	
	table.Merge(CitadelShock.Game.Structures[class], tbl)
	if (overRode) then print("\t --> Overrode game structure: " .. class)
	else print("\t --> Registered game structure: " .. class)
	end
end

function CitadelShock.Game:RemoveStructure(class)
	if !(CitadelShock.Game.Structures[class]) then return false end
	
	CitadelShock.Game.Structures[class] = nil
	print("\t --> Removed game structure: " .. class)
end

-- [[Bomb creation/removal]]
function CitadelShock.Game:CreateNewBomb(name, tbl)
	CitadelShock.Game.Bombs[name] = tbl
	print("\t --> Registered game bomb: " .. name)
end

function CitadelShock.Game:RemoveBomb(name)
	if !(CitadelShock.Game.Bombs[name]) then return false end
	
	CitadelShock.Game.Bombs[name] = nil
	print("\t --> Removed game bomb: " .. name)
end

-- [[Phase stuff]]
function CShockGame_GetPhases(val)
	return (val && CitadelShock.Game.Phases[val] || CitadelShock.Game.Phases)
end

--[[-----------
	SERVER
-------------]]
if (SERVER) then

function CitadelShock.Game:SpawnBomb(tp, pos)
	local bombs = CitadelShock.Game.Bombs

	local b = ents.Create((tp or "cis_basebomb"))
	if (bombs[tp]) then
		for k,v in pairs(bombs[tp]) do
			b[k] = v
		end
	end

	b:SetPos(pos)
	b:Spawn()
	
	return b
end

--[[
	Name: CitadelShock.Game:GameVerifier()
	- Checks & Verifies open games and handles them. 
	- This shouldn't be called manually unless debugging.
]]
CitadelShock.Game.nextCheck = os.time() + 1
function CitadelShock.Game:GameVerifier()
	if (os.time() >= CitadelShock.Game.nextCheck) then
		CitadelShock.Game.nextCheck = os.time() + 1
		
		for k,v in pairs(CitadelShock.Lobby.lobbies) do
			if not (v.GetGameInfo) then 
				CitadelShock.Lobby.lobbies[k] = nil
			elseif (v:GetGameInfo().active) then
				local gameInfo = v:GetGameInfo()
				local curPhase = v:GetCurrentPhase()
				local curPhaseInf = CShockGame_GetPhases(gameInfo.currentPhase)
				
				if (!curPhase or !curPhaseInf) then return false end
				if (curPhaseInf.custCheck) then if !(curPhaseInf.custCheck(v)) then return false end  end -- Custom phase checks
				
				if (!curPhaseInf.divider) then
					for i=1,#ents.GetAll() do
						local ent = ents.GetAll()[i]
						if (ent:GetName() == "cis_refractwall" && ent:GetInstance() == k) then
							ent:Remove() -- Remove the refractory walls
						end
					end
				end

				if (curPhase.endtime <= os.time()) then
					local nPhase = v:NextPhase() -- Move to the next phase
					
					if not (nPhase) then v:EndGame() end
				end
			end
		end
	end
end
hook.Add("Think", "CIS.Hook.GameVerifier", CitadelShock.Game.GameVerifier)

--[[
	Name: CIS.Game.GiveResource
	- Hook that's called to reward a lobby with resources.
]]
hook.Add("CIS.Game.GiveResource", "CIS.Game.GiveResource", function(ent)
	if (!ent.GetIDLobby or !ent.GetIDSide) then ent:Remove() return false end
	if not (CitadelShock.Lobby:FindByID(ent:GetIDLobby())) then ent:Remove() return false end
	local lobby = CitadelShock.Lobby:FindByID(ent:GetIDLobby())

	if not (lobby:GetGameInfo().active) then return false end
	if not (ent.ResourceSize) then ent.ResourceSize = 1 end

	lobby:GiveResource(ent.ResourceType, math.Round(ent.ResourceSize * 100, 0), ent:GetIDSide())
end)

--[[
	Name: CIS.Game.PreStructurePlace
	- Hook that's called when a player is about to place a structure.
]]
hook.Add("CIS.Game.PreStructurePlace", "CIS.Game.PreStructurePlace", function(ply, struc, ent)
	if (!IsValid(ply) or !struc) then return false, "Invalid player/cost, please contact an administrator." end
	local lobby = CitadelShock.Lobby:FindByID(ply:GetIDLobby())
	local lobbySides = lobby:GetGameSides()
	local gameInfo = lobby:GetGameInfo()
	local curPhase = lobby:GetCurrentPhase()
	local curPhaseInfo = CShockGame_GetPhases(gameInfo.currentPhase)
	local side = ply:GetSide()
	
	if (!lobby or !lobbySides[side]) then return false, "You're not in a lobby/in-game!" end
	if (!curPhaseInfo.canBuild) then return false, "You can't build while fighting!" end
	if (struc.reqLevel && ply:GetLevel() < struc.reqLevel) then return false, "You don't have the required level to build this structure! (Level " .. struc.reqLevel .. ")" end 
	
	-- [[Check spawns]]
	local defSideInfo = CitadelShock.Game.Sides
		
	if (defSideInfo) then
		for i=1,#defSideInfo do
			if (ent:IsValid() && defSideInfo[i] && defSideInfo[i].spos) then
				if (defSideInfo[i].spos:Distance(ent:GetPos()) <= 250) then
					return false, "You can't build that close to the spawn!"
				end
			end
		end
	end
	
	-- [[Check available resources]]
	local resources = lobbySides[side].resources
	
	for k,v in pairs(struc.cost) do
		if (resources[k] && resources[k] > v) then
			lobby:GiveResource(k, (-v), side)
		else 
			return false, "Your side doesn't have enough resources!"
		end
	end
	
	return true, "Structure placed"
end)

--[[
	Name: CIS.Game.PreBombSpawn
	- Hook that's called when a player is about to purchase a bomb.
]]
hook.Add("CIS.Game.PreBombSpawn", "CIS.Game.PreBombSpawn", function(ply, btype)
	local bomb = CitadelShock.Game.Bombs[btype]

	if !(ply) then return false, "No player specified!" end
	if !(btype) then return false, "No bomb type specified!" end
	if !(bomb) then return false, "Invalid bomb specified!" end
	
	local lobby = CitadelShock.Lobby:FindByID(ply:GetIDLobby())
	local lobbySides = lobby:GetGameSides()
	local gameInfo = lobby:GetGameInfo()
	local curPhase = lobby:GetCurrentPhase()
	local curPhaseInfo = CShockGame_GetPhases(gameInfo.currentPhase)
	local side = ply:GetSide()
	if (!lobby or !lobbySides[side]) then return false, "You aren't in a lobby and/or game!" end
	if (!bomb.BombCost) then return false, "Bomb cost isn't valid!" end
	if (bomb.reqLevel && ply:GetLevel() < bomb.reqLevel) then return false, "You don't have the required level to purchase this bomb! (Level " .. bomb.reqLevel .. ")" end 

	if (bomb.custCheck) then bomb.custCheck(bomb) end
	
	if (!curPhaseInfo.canFight) then return false, "You can't buy bombs in the building phase!" end
	
	if (ply.NextBombBuy && ply.NextBombBuy > os.time()) then 
		return false, "You can buy a bomb in " .. ply.NextBombBuy - os.time() .. " seconds."
	end
	
	local resources = lobbySides[side].resources
	
	for k,v in pairs(bomb.BombCost) do
		if (resources[k] && resources[k] > v) then
			lobby:GiveResource(k, (-v), side)
			
			ply.NextBombBuy = os.time()+CitadelShock.Game.BombPurchaseDelay -- Set delay
		else 
			return false, "Your side doesn't have enough resources!"
		end
	end
	
	return true, "Bomb (" .. bomb.BombName .. ") purchased!"
end)

--[[
	Name: CIS.Game.PlayerInitSpawn
	- Hook that's called when a player is (initially) spawning.
	- Sets their game-based information.
]]
hook.Add("CIS.PlayerInitialSpawn", "CIS.Game.PlayerInitSpawn", function(ply)
	for k,v in pairs(CitadelShock.Game.Resources) do
		ply:SetNW2Int("CitadelShock.Game.res." .. v.name, v.val)
	end
end)

--[[
	Name: CIS.Game.PostPlayerDeath
	- Hook that's called after a player has been killed.
	- Sets their status to "respawning".
]]
hook.Add("PostPlayerDeath", "CIS.Game.PostPlayerDeath", function(v, i, a)
	if (v:IsInLobby() && v:IsInGame()) then 
		v:SetStatus(2)
	end
end)

--[[
	Name: CIS.Game.PlayerDeath
	- Hook that's called when a player is killed
	- Used to reward a player for kills
]]
hook.Add("PlayerDeath", "CIS.Game.PlayerDeath", function(v, i, a)
	if (v:IsPlayer() && a:IsPlayer()) then 
		if (v:IsInLobby() && v:IsInGame() && a:IsInLobby() && a:IsInGame()) then a:GiveRewards(CitadelShock.Game.KillRewards) end
	end
end)


end

--[[-----------
	CLIENT
-------------]]
if (CLIENT) then
CitadelShock.Game.Results = (CitadelShock.Game.Results or false)
end

--[[-----------
	Game Configuration Setup
-------------]]
hook.Add("CIS.Hook.GM_Setup", "CIS.Hook.Game_Setup",
function()
	--[[------------------
		RESOURCES
	--------------------]]
	CitadelShock:Message("Game resource setup: ", " --> ")

	-- [[MONEY]]
	CitadelShock.Game:CreateNewResource("money", (CitadelShock.Game.StartResources["money"] or 0), "icon16/money_dollar.png", function(l, s, sid) end)
	
	-- [[TREES]]
	CitadelShock.Game:CreateNewResource("wood", (CitadelShock.Game.StartResources["wood"] or 0), "icon16/house.png",
	function(l, s, sid)
		local id = l:GetID()
		
		-- [[TREES]]
		local resBoxB = s.resArea
		local claimedPos = {}

		for tree=1,math.random(2,3) do
			local spawnPos, cPos = l:GenerateSpawnPos(resBoxB, claimedPos)
			if (cPos) then claimedPos = cPos end
			local t = ents.Create( "cis_baseresource" )
			if ( !IsValid( t ) ) then return end
			t:SetPos(spawnPos - Vector(0,0,5))
			
			-- [[TREE INFO]]
			t.ResourceType = "wood"
			t.Models = {
				harvested = {model = "models/zerochain/props_foliage/tree01_stump.mdl", collide = COLLISION_GROUP_NONE},
				notharvested = {model = "models/zerochain/props_foliage/tree01.mdl", collide = COLLISION_GROUP_NONE},
			}
			
			t:Spawn()
			
			t:SetIDLobby(id)
			t:SetIDSide(sid)
			t:SetHarvestParticles("cis_collect_rock_effect")
			t:SetHarvestSounds("wood")
		end
	end)
	
	-- [[STONE]]
	CitadelShock.Game:CreateNewResource("stone", (CitadelShock.Game.StartResources["stone"] or 0), "icon16/database.png",
	function(l, s, sid)
		local id = l:GetID()
		
		-- [[ROCKS]]
		local resBoxB = s.resArea
		local claimedPos = {}

		for rock=1,math.random(2,3) do
			local spawnPos, cPos = l:GenerateSpawnPos(resBoxB, claimedPos)
			if (cPos) then claimedPos = cPos end
			local r = ents.Create( "cis_baseresource" )
			if ( !IsValid( r ) ) then return end
			r:SetPos(spawnPos - Vector(0,0,5))
			
			-- [[STONE INFO]]
			r.ResourceType = "stone"
			r.Models = {
				harvested = {model = "models/zerochain/props_foliage/rock02_ore01_reduced.mdl", collide = COLLISION_GROUP_NONE},
				notharvested = {model = "models/zerochain/props_foliage/rock02_ore01.mdl", collide = COLLISION_GROUP_NONE},
			}

			r:Spawn()
			
			r:SetIDLobby(id)
			r:SetIDSide(sid)
			r:SetHarvestParticles("cis_collect_rock_effect")
			r:SetHarvestSounds("rock")
		end
	end)
	
	-- [[METAL]]
	CitadelShock.Game:CreateNewResource("metal", (CitadelShock.Game.StartResources["metal"] or 0), "icon16/bullet_black.png",
	function(l, s, sid)
		local id = l:GetID()
		
		-- [[METAL]]
		local resBoxB = s.resArea
		local claimedPos = {}

		for metal=1,math.random(2,3) do
			local spawnPos, cPos = l:GenerateSpawnPos(resBoxB, claimedPos)
			if (cPos) then claimedPos = cPos end
			local m = ents.Create( "cis_baseresource" )
			if ( !IsValid( m ) ) then return end
			m:SetPos(spawnPos - Vector(0,0,5))
			m:SetColor(Color(25,25,25,255))
			
			-- [[METAL INFO]]
			m.ResourceType = "metal"
			m.Models = {
				harvested = {model = "models/zerochain/props_foliage/rock01_ore01_reduced.mdl", collide = COLLISION_GROUP_NONE},
				notharvested = {model = "models/zerochain/props_foliage/rock01_ore01.mdl", collide = COLLISION_GROUP_NONE},
			}

			m:Spawn()
			
			m:SetIDLobby(id)
			m:SetIDSide(sid)
			m:SetHarvestParticles("cis_collect_rock_effect")
			m:SetHarvestSounds("rock")
		end
	end)
	
	--[[------------------
		STRUCTURES
	--------------------]]
	local sInfo = CitadelShock.Game.StructureInfo
	CitadelShock:Message("Game structure setup: ", " --> ")
	
	CitadelShock.Game:CreateNewStructure("cis_struc_foundation", {
		-- The types of structures that are available for this structure base.
		types = {
			[1] = {
				name = "Wood Foundation",
				model = "models/zerochain/props_structure/wood_foundation.mdl",
				health = (sInfo["cis_struc_foundation"][1].health or 200),
				cost = (sInfo["cis_struc_foundation"][1].cost or {["wood"] = 100}),
				reqLevel = (sInfo["cis_struc_foundation"][1].reqLevel or 1),
			},
			[2] = {
				name = "Stone Foundation",
				model = "models/zerochain/props_structure/stone_foundation.mdl",
				health = (sInfo["cis_struc_foundation"][2].health or 500),
				cost = (sInfo["cis_struc_foundation"][2].cost or {["stone"] = 100}),
				reqLevel = (sInfo["cis_struc_foundation"][2].reqLevel or 1),
			},
			[3] = {
				name = "Metal Foundation",
				model = "models/zerochain/props_structure/metal_foundation.mdl",
				health = (sInfo["cis_struc_foundation"][3].health or 1000),
				cost = (sInfo["cis_struc_foundation"][3].cost or {["metal"] = 100}),
				reqLevel = (sInfo["cis_struc_foundation"][3].reqLevel or 1),
			},
		},
		
		-- The entities this structure can snap to/be placed on
		atpts = {
			["cis_struc_foundation"] = {7,8,9,10}, -- The attachment points this structure can snap to
			["worldspawn"] = {}, -- No attachment points means it can be placed anywhere on the entity
		},
		
		-- Custom Positioning Check - arguments are New Structure, Parent/Trace Structure or entity, always return a vector
		custPosCheck = function(ns, ps)
			local nsp, psp = ns:GetPos(), ps:GetPos()

			return nsp - (psp - nsp) - Vector(0,0,39)
		end,
		
		-- Custom valid position check - ne = to-be-placed entity, tr = player trace, always return true or false
		validPosCheck = function(ne, tr)
			local validPosBypasses = {
				"keyframe_rope",
				"move_rope",
			}	
		
			local validPos = true
			local c1, c2 = ne:GetModelBounds()
			c1, c2 = c1*0.9, c2*0.9
			c1, c2 = ne:LocalToWorld(c1), ne:LocalToWorld(c2)
			
			for k,v in pairs(ents.FindInBox( c1, c2 )) do
				if !(table.HasValue(validPosBypasses, v:GetClass())) then
					if (!v:IsWorld() && !v:IsWeapon() && v != tr.Entity && v != ne) then
						validPos = false
					end
				end
			end

			return validPos
		end,
	})

	CitadelShock.Game:CreateNewStructure("cis_struc_wall", {
		types = {
			[1] = {
				name = "Wood Wall",
				model = "models/zerochain/props_structure/wood_wall.mdl",
				health = (sInfo["cis_struc_wall"][1].health or 200),
				cost = (sInfo["cis_struc_wall"][1].cost or {["wood"] = 100}),
				reqLevel = (sInfo["cis_struc_wall"][1].reqLevel or 1),
			},
			[2] = {
				name = "Stone Wall",
				model = "models/zerochain/props_structure/stone_wall.mdl",
				health = (sInfo["cis_struc_wall"][2].health or 500),
				cost = (sInfo["cis_struc_wall"][2].cost or {["stone"] = 100}),
				reqLevel = (sInfo["cis_struc_wall"][2].reqLevel or 1),
			},
			[3] = {
				name = "Metal Wall",
				model = "models/zerochain/props_structure/metal_wall.mdl",
				health = (sInfo["cis_struc_wall"][3].health or 1000),
				cost = (sInfo["cis_struc_wall"][3].cost or {["metal"] = 100}),
				reqLevel = (sInfo["cis_struc_wall"][3].reqLevel or 1),
			},
		},
		atpts = {
			["cis_struc_foundation"] = {7,8,9,10},
			["cis_struc_wall"] = {2},
		},
	})

	CitadelShock.Game:CreateNewStructure("cis_struc_beam", {
		types = {
			[1] = {
				name = "Wood Beam",
				model = "models/zerochain/props_structure/wood_beam.mdl",
				health = (sInfo["cis_struc_beam"][1].health or 200),
				cost = (sInfo["cis_struc_beam"][1].cost or {["wood"] = 100}),
				reqLevel = (sInfo["cis_struc_beam"][1].reqLevel or 1),
			},
			[2] = {
				name = "Stone Beam",
				model = "models/zerochain/props_structure/stone_beam.mdl",
				health = (sInfo["cis_struc_beam"][2].health or 500),
				cost = (sInfo["cis_struc_beam"][2].cost or {["stone"] = 100}),
				reqLevel = (sInfo["cis_struc_beam"][2].reqLevel or 1),
			},
			[3] = {
				name = "Metal Beam",
				model = "models/zerochain/props_structure/metal_beam.mdl",
				health = (sInfo["cis_struc_beam"][3].health or 1000),
				cost = (sInfo["cis_struc_beam"][3].cost or {["metal"] = 100}),
				reqLevel = (sInfo["cis_struc_beam"][3].reqLevel or 1),
			},
		},
		atpts = {
			["cis_struc_foundation"] = {2,3,4,5,6},
			["cis_struc_beam"] = {2},
		},
	})

	CitadelShock.Game:CreateNewStructure("cis_struc_roof", {
		types = {
			[1] = {
				name = "Wood Roof",
				model = "models/zerochain/props_structure/wood_roof.mdl",
				health = (sInfo["cis_struc_roof"][1].health or 200),
				cost = (sInfo["cis_struc_roof"][1].cost or {["wood"] = 100}),
				reqLevel = (sInfo["cis_struc_roof"][1].reqLevel or 1),
			},
			[2] = {
				name = "Stone Roof",
				model = "models/zerochain/props_structure/stone_roof.mdl",
				health = (sInfo["cis_struc_roof"][2].health or 500),
				cost = (sInfo["cis_struc_roof"][2].cost or {["stone"] = 100}),
				reqLevel = (sInfo["cis_struc_roof"][2].reqLevel or 1),
			},
			[3] = {
				name = "Metal Roof",
				model = "models/zerochain/props_structure/metal_roof.mdl",
				health = (sInfo["cis_struc_roof"][3].health or 1000),
				cost = (sInfo["cis_struc_roof"][3].cost or {["metal"] = 100}),
				reqLevel = (sInfo["cis_struc_roof"][3].reqLevel or 1),
			},
		},
		atpts = {
			["cis_struc_beam"] = {2},
		},
	})
	
	CitadelShock.Game:CreateNewStructure("cis_struc_stairs", {
		types = {
			[1] = {
				name = "Wood Stairs",
				model = "models/zerochain/props_structure/wood_stair.mdl",
				health = (sInfo["cis_struc_stairs"][1].health or 200),
				cost = (sInfo["cis_struc_stairs"][1].cost or {["wood"] = 100}),
				reqLevel = (sInfo["cis_struc_stairs"][1].reqLevel or 1),
			},
			[2] = {
				name = "Stone Stairs",
				model = "models/zerochain/props_structure/stone_stair.mdl",
				health = (sInfo["cis_struc_stairs"][2].health or 500),
				cost = (sInfo["cis_struc_stairs"][2].cost or {["stone"] = 100}),
				reqLevel = (sInfo["cis_struc_stairs"][2].reqLevel or 1),
			},
			[3] = {
				name = "Metal Stairs",
				model = "models/zerochain/props_structure/metal_stair.mdl",
				health = (sInfo["cis_struc_stairs"][3].health or 1000),
				cost = (sInfo["cis_struc_stairs"][3].cost or {["metal"] = 100}),
				reqLevel = (sInfo["cis_struc_stairs"][3].reqLevel or 1),
			},
		},
		atpts = {
			["worldspawn"] = {},
		},
	})
	
	--[[------------------
		BOMBS
	--------------------]]
	CitadelShock:Message("Game bomb setup: ", " --> ")
	
	local bInfo = CitadelShock.Game.BombInfo
	
	CitadelShock.Game:CreateNewBomb("cis_bomb_logs", {
		reqLevel = (bInfo["cis_bomb_logs"].reqLevel or 1),
		BombName = (bInfo["cis_bomb_logs"].BombName or "Log Bomb"),
		BombCost = (bInfo["cis_bomb_logs"].BombCost or {["money"] = 25, ["wood"] = 100, ["stone"] = 25}),
		BlastRadius = (bInfo["cis_bomb_logs"].BlastRadius or 350),
		BlastDamageMultiplier = 10,
		ExplodeTime = 2.5,
		BombMass = (bInfo["cis_bomb_logs"].BombMass or 15),
		BombDrag = 0.2,
		Model = "models/zerochain/props_mystic/bomb_logs.mdl",
	})
	
	CitadelShock.Game:CreateNewBomb("cis_bomb_small",
	{
		reqLevel = (bInfo["cis_bomb_small"].reqLevel or 1),
		BombName = (bInfo["cis_bomb_small"].BombName or "Small Bomb"),
		BombCost = (bInfo["cis_bomb_small"].BombCost or {["money"] = 250, ["wood"] = 5, ["stone"] = 5}),
		BlastRadius = (bInfo["cis_bomb_small"].BlastRadius or 350),
		BlastDamageMultiplier = 10,
		ExplodeTime = 5,
		BombMass = (bInfo["cis_bomb_small"].BombMass or 15),
		BombDrag = 0.2,
		Model = "models/zerochain/props_mystic/bomb_small.mdl",
	})
	
	CitadelShock.Game:CreateNewBomb("cis_bomb_medium",
	{
		reqLevel = (bInfo["cis_bomb_medium"].reqLevel or 1),
		BombName = (bInfo["cis_bomb_medium"].BombName or "Medium Bomb"),
		BombCost = (bInfo["cis_bomb_medium"].BombCost or {["money"] = 350, ["wood"] = 15, ["stone"] = 15}),
		BlastRadius = (bInfo["cis_bomb_medium"].BlastRadius or 600),
		BlastDamageMultiplier = 12,
		ExplodeTime = 8,
		BombMass = (bInfo["cis_bomb_medium"].BombMass or 19),
		BombDrag = 0.3,
		Model = "models/zerochain/props_mystic/bomb_medium.mdl",
	})
	
	CitadelShock.Game:CreateNewBomb("cis_bomb_big",
	{
		reqLevel = (bInfo["cis_bomb_big"].reqLevel or 1),
		BombName = (bInfo["cis_bomb_big"].BombName or "Big Bomb"),
		BombCost = (bInfo["cis_bomb_big"].BombCost or {["money"] = 475, ["wood"] = 25, ["stone"] = 25}),
		BlastRadius = (bInfo["cis_bomb_big"].BlastRadius or 800),
		BlastDamageMultiplier = 14,
		ExplodeTime = 10,
		BombMass = (bInfo["cis_bomb_big"].BombMass or 23),
		BombDrag = 0.4,
		Model = "models/zerochain/props_mystic/bomb_big.mdl",
	})
	
	CitadelShock.Game:CreateNewBomb("cis_bomb_proximity",
	{
		reqLevel = (bInfo["cis_bomb_proximity"].reqLevel or 1),
		BombName = (bInfo["cis_bomb_proximity"].BombName or "Proximity Bomb"),
		BombCost = (bInfo["cis_bomb_proximity"].BombCost or {["money"] = 475, ["wood"] = 25, ["stone"] = 25, ["metal"] = 20}),
		BlastRadius = (bInfo["cis_bomb_proximity"].BlastRadius or 800),
		BlastDamageMultiplier = 14,
		ExplodeTime = 10,
		BombMass = (bInfo["cis_bomb_proximity"].BombMass or 23),
		BombDrag = 0.4,
		Model = "models/zerochain/props_mystic/bomb_proximity.mdl",
	})
	
	-- Check for disabled hard-coded resources/structures
	for nm,bool in pairs(CitadelShock.Game.Disabled.resources) do
		if (bool) then
			CitadelShock.Game:RemoveResource(nm)
		end
	end
		
	for class,bool in pairs(CitadelShock.Game.Disabled.structures) do
		if (bool) then
			CitadelShock.Game:RemoveStructure(class)
		end	
	end
	
	for class,bool in pairs(CitadelShock.Game.Disabled.bombs) do
		if (bool) then
			CitadelShock.Game:RemoveBomb(class)
		end	
	end
end)
	