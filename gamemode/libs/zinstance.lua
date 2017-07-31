--[[
		INSTANCES
		By Zephruz
	/* An advanced entity instancing system for GMOD */
]]

Instances = {}

-- [[Config]
Instances.allowInstanceSwapping = true -- Enable/disable the ability for players to join an instance
Instances.allowCrossInstanceChat = false -- Enable/disable the ability to speak/chat with players in other instances
Instances.deleteEmptyInstances = true -- Delete instances that have no players/entities
Instances.globalInstance = -1 -- The ID of the global instance (Don't change this)
Instances.defaultInstance = 0 -- The ID of the default instance (Don't change this)

-- [[Localized config - DON'T EDIT]]
local allowInstanceSwapping = Instances.allowInstanceSwapping
local allowCrossInstanceChat = Instances.allowCrossInstanceChat
local deleteEmptyInstances = Instances.deleteEmptyInstances
local globalInstance = Instances.globalInstance
local defaultInstance = Instances.defaultInstance

_instances = (_instances or {[globalInstance]={name="global_instance",permanent=true,joinable=false},[defaultInstance]={name="default_instance",permanent=true,joinable=false}})

--[[
	Name: Instances:New()
	Creates a new instance
	- This inserts it into the _instances table for later access
]]
function Instances:New(tbl, id)
	local iID
	local iTBL = (tbl or {name = "instance_", joinable = true})
	iID = (id or table.insert(_instances, iTBL))
	_instances[iID] = iTBL
	_instances[iID].name = iTBL.name .. iID
	_instances[iID].joinable = iTBL.joinable
	
	for k,v in pairs(Instances:GetMapEntities()) do
		local ce = v:Clone()
		
		if (ce) then
			ce:SetInstance(iID)
		end
	end
	
	return iID, _instances[iID]
end

--[[
	Name: Instances:Delete(id)
	Deletes an instance
		- Returns false for a non-existant instance
]]
function Instances:Delete(id)
	local inst = self:GetByID(id)
	if !(inst) then return false end
	
	if (SERVER) then
		for _,e in pairs(inst.ents) do
			if (IsValid(e)) then
				if (e:IsPlayer()) then
					e:SetInstance(defaultInstance)
				else
					e:Remove()
					-- print("deleted instance locked entity - " .. tostring(e))
				end
			end
		end
	end
	
	_instances[id] = nil
	
	-- print("Removed instance. (" .. id .. ")") 
	
	return true
end

--[[
	Name: Instances:GetByID(id)
	Gets an instance by an ID.
		- Returns nil for a non-existant instance
]]
function Instances:GetByID(id)
	if (!id or !_instances[id]) then return end
	
	_instances[id].ents = {}
	
	for k,v in pairs(ents.GetAll()) do
		if (v:GetInstance() == id) then
			table.insert(_instances[id].ents, v)
		end
	end
	
	return _instances[id]
end

--[[
	Name: Instances:CleanByID(id)
	Cleans an instances entities
]]
function Instances:CleanByID(id)
	local inst = self:GetByID(id)
	if !(inst) then return false end
	
	-- Clean up
	for _,e in pairs(inst.ents) do
		if (IsValid(e)) then
			if !(e:IsPlayer()) then
				e:Remove()
				-- print("deleted instanced (" .. id .. ") entity - " .. tostring(e))
			end
		end
	end
	
	return true
end

--[[
	Name: Instances:GetAll()
	Gets all the instances
	- Inserts any entities that are in the instance
	- This will handle any instances that are empty
]]
function Instances:GetAll()
	-- Refresh/create the entities table for each instance
	for k,v in pairs(_instances) do
		_instances[k].ents = {}
	end
	
	-- Check if players have a valid instance
	for _,e in pairs(ents.GetAll()) do
		if (_instances[e:GetInstance()]) then
			table.insert(_instances[e:GetInstance()].ents, e)
		--[[else
			print(e:GetClass() .. " - in a non-existant instance. (" .. e:GetInstance() .. ")")]]
		end
	end
	
	return (_instances or {})
end

--[[
	Name: Instances:CleanUpAll()
	Cleans & removes all instances that are empty or have inactive entities
]]
function Instances:CleanUpAll()
	-- Clean instances
	for k,v in pairs(_instances) do
		self:CleanByID(k)
	end
end

--[[
	Name: Instances:UpdateAllEntities()
	Updates all of the entities
	- Sets collision checks
	- Sets visibility
]]
function Instances:UpdateAllEntities()
	for k,v in pairs(ents.GetAll()) do
		if (CLIENT) then
			if (v:GetInstance() != LocalPlayer():GetInstance()) then

				v:SetNoDraw(true)

			else

				v:SetNoDraw(false)
				
			end
		end
	end
end

--[[
	Name: Instances:GetWorldEntities()
	Gets all of the world entities.
]]
function Instances:GetWorldEntities()
	local wEnts = {}

	for k,v in pairs(ents.GetAll()) do
		if (v:IsWorld()) then
		
			table.insert(wEnts, v)
			
		end
	end
	
	return wEnts
end

--[[
	Name: Instances:GetMapEntities()
	Gets all of the map entities.
]]
function Instances:GetMapEntities()
	local mEnts = {}

	for k,v in pairs(ents.GetAll()) do
		if (!v:IsWorld() && v.CreatedByMap && v:CreatedByMap()) then
			
			table.insert(mEnts, v)
			
		end
	end
	
	return mEnts
end

--[[-----------------
	ENTITY META
--------------------]]
local entMeta = FindMetaTable("Entity")

-- [[Sets an entity/players instance]]
function entMeta:SetInstance(id)
	if (self:IsWorld()) then self:SetNW2Int("Instance", globalInstance) return _instances[id] end
	
	self:SetNW2Int("Instance", id)
	
	-- if (self:IsPlayer()) then self:ChatPrint("Your instance has been set to " .. id .. "!") end
	
	return _instances[id]
end

-- [[Clones an entity]]
local entBlacklist = {"info_particle_system"}

function entMeta:Clone()
	if !(IsValid(self)) then return end
	if (table.HasValue(entBlacklist, self:GetClass())) then return end

	local ce = ents.Create(self:GetClass())
	if !(IsValid(ce)) then return end
	ce:SetPos((self:GetPos() or Entity(1):GetPos()))
	ce:SetAngles((self:GetAngles() or Angle(0,0,0)))
	ce:SetName(self:GetName())
	if (self:GetModel()) then ce:SetModel(self:GetModel()) end
	if (self:GetTable()) then ce:SetTable(self:GetTable()) end

	ce:Spawn()
	ce:Activate()
		
	return ce
end

-- [[Gets an entity/players instance]]
function entMeta:GetInstance()
	if not (IsValid(self)) then return defaultInstance end
	return (self:GetNW2Int("Instance") or defaultInstance)
end

-- [[Marks an entity as global]]
function entMeta:MarkGlobal()
	self:SetInstance()
end

-- [[Gets if an entity is global]]
function entMeta:IsGlobal()
	return (self:GetInstance() == globalInstance || false)
end

-- [[Gets if an entity is a map/world entity]]
function entMeta:IsMapEntity()
	if (!self:IsWorld() && self.CreatedByMap && self:CreatedByMap()) then
		
		return true
		
	end
	
	return false
end

-- [[Sets if an entities visibility is going to be forced]]
function entMeta:SetForcedVisibility(bool)
	self.forceVisibility = bool
	return self.forceVisibility
end

-- [[Gets an entities forced visibility status]]
function entMeta:GetForcedVisibility()
	return (self.forceVisibility or false)
end

--[[-----------------
	OWNERSHIP META
--------------------]]

-- [[Gets the children of an entity]]
function entMeta:ZI_GetChildren()
	local children = {}
	
	for k,v in pairs(ents.GetAll()) do
		if (v:ZI_GetOwner() == self) then
		
			table.insert(children, v)
			
		end
	end
	
	return children
end

-- [[Sets an entities owner]]
function entMeta:ZI_SetOwner(ent)
	self.ZI_Owner = ent
	
	self:SetInstance(ent:GetInstance())
	
	hook.Run("_instance.OwnerSet", self, ent)
end

-- [[Gets an entities owner | Returns the original self.Owner if self.ZI_Owner is nil]]
function entMeta:ZI_GetOwner()
	if (!self.ZI_Owner && self.Owner) then self.ZI_Owner = self.Owner end
	
	return (self.ZI_Owner)
end

--[[-----------------
	HOOKS
--------------------]]

-- [[Called when an entity is created so we can assign them instances]]
hook.Add("OnEntityCreated", "_instance.EntityCreated",
function(ent)
	ent:SetCustomCollisionCheck(true)

	-- [[Set global/world entities to the instance -1]]
	if (ent:IsWorld()) then
	
		ent:MarkGlobal()
		ent:SetCustomCollisionCheck(false)

	end
	
	-- [[Check for player (corpse) ragdoll entities]]
	for k,v in pairs(player.GetAll()) do 
		if (v:GetRagdollEntity() == ent) then 
			
			ent:SetInstance(v:GetInstance())
			ent:SetCustomCollisionCheck(false)
			
		end 
	end
end)

-- [[Checks for when the NW2 Variable "Instance" is changed and then updates entities]]
hook.Add("EntityNetworkedVarChanged", "_instance.EntNWVarChanged",
function( ent, name, ov, nv )
	if (name == "Instance") then
		if (SERVER) then
				
			-- Move the children to the same instance
			for k,v in pairs(ent:ZI_GetChildren()) do
		
				v:SetInstance(nv)
				
			end
			
		end

		if (CLIENT) then
			if !(_instances[nv]) then Instances:New({name = "instance_", joinable = false}, nv) end
		end
		
		-- Check if the old instance is empty
		if (ov && ent:IsPlayer()) then
			local oInst = Instances:GetByID(ov)

			if (oInst && deleteEmptyInstances && !oInst.permanent) then
				local del = true
				for k,v in pairs(oInst.ents) do
					if (v:IsPlayer()) then del = false end
				end
				if (del) then Instances:Delete(ov) end
			end
		end
	end
end)

-- [[A workaround for weapons considering when OnEntityCreated is called, they don't have an owner]]
hook.Add("PlayerSwitchWeapon", "_instance.WeaponSwitched", function(p, ow, nw) if (nw:GetInstance() != p:GetInstance()) then nw:SetInstance(p:GetInstance()) end end)

-- [[Damage checking]]
hook.Add("PlayerShouldTakeDamage", "_instance.PlayerShouldTakeDamage",
function(ply, att)
	local allowDmgFrom = {"trigger_hurt", "trigger_remove"}
	if (table.HasValue(allowDmgFrom, att:GetClass())) then return true end
	if (ply:GetInstance() != att:GetInstance()) then return false end
end)

-- [[Collision checking]]
hook.Add("ShouldCollide", "_instance.CollisionCheck",
function(e1,e2)
	if (!e1:IsWorld() && !e2:IsWorld()) then
		if (e1.GetInstance && e2.GetInstance && e1:GetInstance() != e2:GetInstance()) then
			if (e1:GetInstance() != -1 or e2:GetInstance() != -1) then
				return false
			end
		end
	end
end)

-- [[Sound emission]]
hook.Add( "EntityEmitSound", "_instance.EntityEmitSound", 
function(t)
	if (CLIENT && t.Entity) then
		if (t.Entity:GetInstance() != LocalPlayer():GetInstance() && !t.Entity:IsWorld()) then
			return false
		end
	end
end)

if (CLIENT) then -- [[Client hooks]]

-- [[Target drawing override]]
hook.Add("HUDDrawTargetID", "_instance.DrawTargetID",
function()
	local tr = LocalPlayer():GetEyeTrace()
	local ply = tr.Entity

	if (IsValid(ply) && ply:IsPlayer()) then 
		if (ply:GetInstance() != LocalPlayer():GetInstance()) then
			return false
		end
	end
end)

-- [[Work around for player drawing]]
hook.Add("PrePlayerDraw", "_instance.PrePlayerDraw", 
function(ply)
	if (!ply:GetNoDraw() && ply:GetInstance() != LocalPlayer():GetInstance()) then 
		ply:SetNoDraw(true)
	elseif (ply:GetNoDraw() && ply:GetInstance() == LocalPlayer():GetInstance()) then
		ply:SetNoDraw(false)
	end
end)

-- [[Work around for entity drawing]]
hook.Add("Think", "_instance.InstEntsDraw",
function()
	local ents = ents.GetAll()
	for i=1,#ents do
		if (ents[i].GetInstance && !ents[i].forceVisibility) then
			if (ents[i]:IsGlobal()) then
			
				ents[i]:SetNoDraw(false)
				
			elseif (ents[i]:GetInstance() != LocalPlayer():GetInstance()) then
			
				if (table.HasValue(getClientEntities(), ents[i])) then

					ents[i]:SetInstance(LocalPlayer():GetInstance())
			
				elseif !(ents[i]:GetNoDraw()) then
				
					ents[i]:SetNoDraw(true)
				
				end
				
			elseif (ents[i]:GetInstance() == LocalPlayer():GetInstance() && ents[i]:GetNoDraw()) then
			
				ents[i]:SetNoDraw(false)
				
			end
		end
	end
end)

end

if (SERVER) then -- [[Server Hooks]]

-- [[Player Talk]]
hook.Add("PlayerCanHearPlayersVoice", "_instance.PlayerCanHearPlayersVoice",
function(pl, pt)
	if (pl:GetInstance() != pt:GetInstance()) then return false end
end)

-- [[Player Chat]]
hook.Add("PlayerCanSeePlayersChat", "_instance.PlayerCanSeePlayersChat",
function(text, to, pl, ps)
	if (!allowCrossInstanceChat) then
		if (pl:GetInstance() != ps:GetInstance()) then return false end
	end
end)

end

--[[-----------------
	MISC.
--------------------]]
function getClientEntities()
	local cParams = {
		"viewmodel",
		"C_",
	}
	local cEnts = {}
	
	for k,v in pairs(ents.GetAll()) do
		for i=1,#cParams do
			if (v:GetClass():find(cParams[i])) then
				table.insert(cEnts, v)
			end
		end
	end
	
	return cEnts
end

--[[-----------------
	PLAYER ENTITY OWNER
	- I wanted to override the original ownership because no-colliding with owners is a stupid fucking idea.
	- I decided not to override them and create a different namespace.
--------------------]]
local function initOverrideSpawnHooks()
	local plyE_Hooks = {
		"PlayerSpawnedEffect",
		"PlayerSpawnedNPC",
		"PlayerSpawnedProp",
		"PlayerSpawnedRagdoll",
		"PlayerSpawnedSENT",
		"PlayerSpawnedSWEP",
		"PlayerSpawnedVehicle",
	}

	local function spawnHook(p, m, e)
		local e = (e or m)

		e:ZI_SetOwner(p)
	end

	for k,v in pairs(plyE_Hooks) do
		hook.Add(v, "_instance." .. v, spawnHook)
	end
end

initOverrideSpawnHooks()

--[[-----------------
	Random shit below.
	Mainly for debugging and other stuff.
--------------------]]
if (SERVER) then
	util.AddNetworkString("instance.Join")
	
	net.Receive("instance.Join",
	function(len, ply)
		local iid = net.ReadInt(32)
		local itbl = {}
		
		if (iid == ply:GetInstance() or !allowInstanceSwapping) then return false end
		
		if (Instances:GetAll()[iid]) then
			if not (Instances:GetAll()[iid].joinable) then return false end
		else
			iid, itbl = Instances:New()
		end
	
		ply:SetInstance(iid)
	end)
end

if (CLIENT) then

	function Instances:Join(id)
		net.Start("instance.Join")
			net.WriteInt(id,32)
		net.SendToServer()
	end

	local function instanceMenu()
		local menu = vgui.Create("DFrame")
		menu:SetSize(400,450)
		menu:SetTitle("Instances")
		menu:Center()
		menu:MakePopup()
		
		local cInstInfo = vgui.Create("DPanel",menu)
		cInstInfo:Dock(TOP)
		cInstInfo:DockMargin(5,0,5,5)
		cInstInfo:SetTall(35)
		cInstInfo.Paint = function(s,w,h)
			draw.RoundedBoxEx(4,0,0,w,h,Color(55,55,55,155),true,true,true,true)
		
			local lp = LocalPlayer()
			draw.SimpleText( "Your current instance: " .. lp:GetInstance(), "DermaDefault", w/2 + 1, 4, Color(55,55,55,155), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			draw.SimpleText( "Your current instance: " .. lp:GetInstance(), "DermaDefault", w/2, 3, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
			
			draw.SimpleText( "Double click an instance to join it.", "DermaDefault", w/2 + 1, h - 3, Color(55,55,55,155), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( "Double click an instance to join it.", "DermaDefault", w/2, h - 4, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		end

		local instances = vgui.Create("DListView",menu)
		instances:Dock(FILL)
		instances:DockMargin(5,0,5,5)
		instances:AddColumn( "ID" ):SetWidth( 15 )
		instances:AddColumn( "Name" )
		instances:AddColumn( "Joinable" )
		instances:AddColumn( "# of Entities" )
		
		for k,v in pairs(Instances:GetAll()) do
			instances:AddLine(k, v.name, v.joinable, #v.ents)
		end
		
		instances.DoDoubleClick = function(s, lid, line)
			local iid = line:GetValue(1)
			
			Instances:Join(iid)
		end

	end
	concommand.Add("instances", instanceMenu)
	
end