SWEP.Instructions	= "Left click - Build Structure | Right click - Change Structure | Reload - Rotate Structure"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Category     		= "CIS"

SWEP.ViewModel			= "models/zerochain/props_mystic/v_hammer.mdl"
SWEP.WorldModel			= "models/zerochain/props_mystic/hammer.mdl"
SWEP.HoldType 			= "melee"

SWEP.Primary.ClipSize		= 10000
SWEP.Primary.DefaultClip	= 10000
SWEP.Primary.TakeAmmo 		= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Spread 		= 0.1
SWEP.Primary.Damage 		= 0

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Shockwave Builder"
SWEP.Slot				= 4
SWEP.SlotPos			= 2
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.DrawWeaponInfoBox 	= false


-- [[FONTS]]
if (CLIENT) then

local function CS_CreateFont(name, tbl)
	surface.CreateFont(name, tbl)
end

CS_CreateFont("CS_WEP_LG",
{
	font = "Alegreya Sans SC",
	size = 24,
})

CS_CreateFont("CS_WEP_MD",
{
	font = "Alegreya Sans SC",
	size = 20,
})

CS_CreateFont("CS_WEP_SM",
{
	font = "Alegreya Sans SC",
	size = 18,
})

end

local structures = (CitadelShock.Game.Structures or {})

local function fetchStructureInfo(s, i)
	return (structures[s.selected.class][i] or structures[s.selected.class])
end

local function fetchClosestAttachment(s, tr)
	local spos = tr.HitPos
	local te = tr.Entity
	local atpts = fetchStructureInfo(s, "atpts")[te:GetClass()]
	local cpt = nil

	if (atpts && #atpts > 0) then
		for i=1,#atpts do
			local i = atpts[i]
			if (te:GetAttachment(i)) then
				if not (cpt) then
					cpt = te:GetAttachment(i).Pos
				elseif (spos:Distance(te:GetAttachment(i).Pos) < spos:Distance(cpt)) then 
					cpt = te:GetAttachment(i).Pos
				end
			end
		end
	else
		cpt = tr.HitPos
	end
	
	return cpt
end

function SetupSWEPData(s)
	s.sModel = nil
	s.nextDelay = os.time()

	s.validPos = true
	s.entRotation = 1

	s.strucRotation = {}
	s.strucRotation.indx = 4

	for k,v in pairs(structures) do
		table.insert(s.strucRotation, k)
	end
		
	local strClass = "cis_basestructure"
		
	if (s.strucRotation[s.strucRotation.indx]) then
		strClass = s.strucRotation[s.strucRotation.indx]
	end

	s.selected = {
		class = strClass,
		type = 1,
	}
end
SetupSWEPData(SWEP)

--[[---------------------------------------------------------
	SWEP INIT
-----------------------------------------------------------]]
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

--[[---------------------------------------------------------
	DRAW HUD
-----------------------------------------------------------]]
function SWEP:DrawHUD()
	-- [[Instructions]]
	if (self.Instructions) then
		draw.SimpleTextOutlined( self.Instructions, "CS_WEP_SM", ScrW()/2, ScrH() - 3, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color( 0, 0, 0, 255) )
	end

	-- [[Structure info]]
	local strucInfo = fetchStructureInfo(self, "types")[self.selected.type]
	draw.WordBox( 4, 10, ScrH()/2, "Selected structure: " .. strucInfo.name, "CS_WEP_MD", Color(55, 55, 55, 185 ), Color(255, 255, 255, 255 ) )
	
	local costY = ScrH()/2 + 35
	
	if (strucInfo.reqLevel) then
		costY = costY + 35
		draw.WordBox( 4, 10, ScrH()/2 + 35, "Required Level: " .. strucInfo.reqLevel, "CS_WEP_MD", 
		(strucInfo.reqLevel <= self.Owner:GetLevel() && Color(25, 255, 25, 105 ) || Color(255, 25, 25, 105 )), Color(255, 255, 255, 255 ) )
	end
	
	if (strucInfo.cost) then
		draw.WordBox( 4, 10, costY, "Cost(s): ", "CS_WEP_MD", Color(55, 55, 55, 185 ), Color(255, 255, 255, 255 ) )
		for k,v in pairs(strucInfo.cost) do
			costY = costY + 30
			draw.WordBox( 4, 20, costY + 5, k .. ": " .. v, "CS_WEP_MD", Color(55, 55, 55, 185 ), Color(255, 255, 255, 255 ) )
		end
	end
end

--[[---------------------------------------------------------
   Think displays the selected building prop
-----------------------------------------------------------]]
function SWEP:Think()
	self.validPos = true

	local tr = self.Owner:GetEyeTrace()
	local trEnt, trHit = tr.Entity, tr.HitPos
	local trOwner = (trEnt:ZI_GetOwner() || false)
	local stInf = fetchStructureInfo(self)
	local clAtt = fetchClosestAttachment(self, tr)
	local attPts = (stInf["atpts"][(trEnt && trEnt:GetClass() || "nil")])
		
	if !(attPts) then self.validPos = false end -- Check if this entity can be placed on the trace entity
	if (trHit:Distance(self.Owner:GetPos()) > 250) then if (IsValid(self.sModel)) then self.sModel:Remove() end self.validPos = false return false end
	if (trOwner && trOwner:IsPlayer() && trOwner != self.Owner && trOwner:GetIDLobby() != self.Owner:GetIDLobby()) then self.validPos = false end

	if (CLIENT) then
		if (IsValid(self.sModel)) then self.sModel:Remove() end
		self.sModel = ents.CreateClientProp()
		self.sModel:SetPos( trHit )
		self.sModel:SetAngles( Angle(0,(self.entRotation*90),0) )
		self.sModel:Spawn()
		self.sModel:SetModel( fetchStructureInfo(self, "types")[self.selected.type].model )

		if (self.validPos && clAtt) then
			self.sModel:SetPos(clAtt)
			if (stInf.custPosCheck && !trEnt:IsWorld()) then
				self.sModel:SetPos(stInf.custPosCheck(self.sModel, trEnt))
			end
		end
		
		if (stInf.validPosCheck) then
			self.validPos = stInf.validPosCheck(self.sModel, tr)
		end

		self.sModel:SetColor( (self.validPos && Color( 0, 255, 0, 230 ) || Color( 255, 0, 0, 230 )) )
		self.sModel:SetRenderMode( RENDERMODE_TRANSALPHA )
		
		self.sModel:SetNoDraw(false) -- Bypass the nodraw function when an entity is spawned
	end
	
	return true
end

--[[---------------------------------------------------------
	PrimaryAttack - Places structure
-----------------------------------------------------------]]
function SWEP:ShootEffects()
	self.Weapon:SendWeaponAnim( ACT_VM_SWINGHARD ) -- View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 ) -- 3rd Person Animation
end

function SWEP:PrimaryAttack()
	if (os.time() < self.nextDelay) then return false end
	self.nextDelay = os.time() + 0.1

	self:ShootEffects()
	
	local tr = self.Owner:GetEyeTrace()
	local clAt = fetchClosestAttachment(self, tr)
	
	if (SERVER) then
		local ent = tr.Entity
		
		if not (self.validPos) then return false end
		
		-- spawn it
		local stInf = fetchStructureInfo(self)
		local stTypes = stInf["types"][self.selected.type]
		local struct = ents.Create( self.selected.class )
		struct:SetPos(clAt)
		struct:SetAngles( Angle(0,(self.entRotation*90),0) )

		struct:Spawn()

		struct:ZI_SetOwner(self.Owner)
		struct:SetModel(stTypes.model)
		struct:SetHealth(stTypes.health)
		struct.costs = stTypes.cost
		
		if (stInf.custPosCheck && !tr.Entity:IsWorld()) then
			struct:SetPos(stInf.custPosCheck(struct, ent))
		end
		
		if (stInf.validPosCheck && !stInf.validPosCheck(struct, tr)) then
			struct:Remove()
			self.Owner:SendMessage("You can't place that there!")
			return false
		end
		
		if (self.Owner:IsInGame()) then
			struct:SetIDLobby(self.Owner:GetIDLobby())
			struct:SetIDSide(self.Owner:GetSide())
			
			local cSpwn, err = hook.Run("CIS.Game.PreStructurePlace", self.Owner, (stTypes), struct)
				
			if !(cSpwn) then 
				struct:Remove()
				self.Owner:SendMessage(err)
			end
		end
	end
end

--[[---------------------------------------------------------
	SecondaryAttack - Selects the building structure
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
	if (os.time() < self.nextDelay) then return false end
	self.nextDelay = os.time() + 0.1
	if (fetchStructureInfo(self, "types")[self.selected.type + 1]) then
		self.selected.type = self.selected.type + 1
	else
		local sRot = self.strucRotation
		sRot.indx = sRot.indx + 1
		local struc = sRot[sRot.indx]
		
		if !(struc) then 
			sRot.indx = 1
			struc = sRot[1]
		end

		self.selected.class = struc
		self.selected.type = 1
		return false
	end
end

--[[---------------------------------------------------------
	Reload - Rotates the building structure
-----------------------------------------------------------]]
function SWEP:Reload()
	if (os.time() < self.nextDelay) then return false end
	self.nextDelay = os.time() + 0.1
	if (self.entRotation <= 1) then self.entRotation = 4 else self.entRotation = self.entRotation - 1 end
end

--[[---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
-----------------------------------------------------------]]
function SWEP:ShouldDropOnDie() return false end

function SWEP:Holster()
	if (CLIENT && IsValid(self.sModel)) then
		self.sModel:Remove()
	end
	SetupSWEPData(self)
	return true
end

function SWEP:OnRemove()
	if (CLIENT && IsValid(self.sModel)) then
		self.sModel:Remove()
	end
	return true
end