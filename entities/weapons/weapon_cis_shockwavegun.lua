

-- Variables that are used on both client and server

SWEP.Instructions	= "Left click - Create Shockwave | Right click - Collect Resource"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false
SWEP.UseHands			= true
SWEP.Category     		= "CIS"

SWEP.ViewModel			= "models/zerochain/props_mystic/v_shockwavegun.mdl"
SWEP.WorldModel			= "models/zerochain/props_mystic/shockwavegun.mdl"
SWEP.HoldType 			= "rpg"

SWEP.Primary.ClipSize		= 10000
SWEP.Primary.DefaultClip	= 10000
SWEP.Primary.TakeAmmo 		= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Spread 		= 0.1
SWEP.Primary.Recoil 		= 10 // How much recoil does the weapon have?
SWEP.Primary.Delay 			= 1.3 // How long must you wait before you can fire again?
SWEP.Primary.Force 			= 1000 // The force of the shot.
SWEP.Primary.Damage 		= 0
SWEP.Primary.Cone			= 255

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= true
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Shockwave Gun"
SWEP.Slot				= 3
SWEP.SlotPos			= 1
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

--[[---------------------------------------------------------
	SWEP INIT
-----------------------------------------------------------]]
function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

--[[---------------------------------------------------------
	SWEP INIT
-----------------------------------------------------------]]
function SWEP:ShootEffects()
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) -- View model animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 ) -- 3rd Person Animation
end

--[[---------------------------------------------------------
	DRAW HUD
-----------------------------------------------------------]]
function SWEP:DrawHUD()
	-- [[Instructions]]
	if (self.Instructions) then
		draw.SimpleTextOutlined( self.Instructions, "CS_WEP_SM", ScrW()/2, ScrH() - 3, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, Color( 0, 0, 0, 255) )
	end
end

--[[---------------------------------------------------------
	Creates a Decal
-----------------------------------------------------------]]
function SWEP:CreateDecal(tr)
	local Pos1 = tr.HitPos + tr.HitNormal
	local Pos2 = tr.HitPos - tr.HitNormal
	util.Decal("Dark", Pos1, Pos2)
end

--[[---------------------------------------------------------
	PrimaryAttack - Creates a shockwave
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
	local tr = self.Owner:GetEyeTrace()
	if (tr.HitPos:Distance(self:GetOwner():GetPos()) > 1000) then return false end
	self:ShootEffects()
	self:CreateDecal(tr)
	self.Owner:ViewPunch( Angle( -10, 0, 0 ) )

	-- Check the distance of the hitpos Make a Shockwave
	if ( SERVER ) then
		local ent = ents.Create( "cis_shockwave" )
		ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 )
		ent:SetAngles( tr.HitNormal:Angle() )
		ent:SetOwner(self:GetOwner())
		ent:Spawn()
		if(!ent:IsValid())then return false end

		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	end
end


--[[---------------------------------------------------------
	SecondaryAttack - Harvests Resources
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
	local tr = self.Owner:GetEyeTrace()
	local trEnt = tr.Entity
	
	self:ShootEffects()

	if (SERVER) then
		if (trEnt.Harvestable && self.Owner:GetPos():Distance(trEnt:GetPos()) <= (trEnt.MaxHarvestDist or 100)) then
			if !(trEnt:GetIsHarvested()) then
				trEnt:Harvest(self.Owner)
			end
		end
	end
end

--[[---------------------------------------------------------
	Creates an extra Impact Effect, only works if Bullets are shooten
-----------------------------------------------------------]]
function SWEP:DoImpactEffect( tr, nDamageType )
	if ( tr.HitSky ) then return end

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos + tr.HitNormal )
	effectdata:SetNormal( tr.HitNormal )
	util.Effect( "AR2Impact", effectdata )
end

--[[---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
-----------------------------------------------------------]]
function SWEP:ShouldDropOnDie()
	return false
end