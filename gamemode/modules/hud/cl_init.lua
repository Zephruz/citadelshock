--[[
	Citadel Shock
	- HUD MODULE -
	- CL INIT -
]]

local DISABLED_HUD = {
	CHudHealth = true,
	CHudBattery = true,
	CHudWeaponSelection = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudZoom = true,
}

hook.Add( "HUDShouldDraw", "CIS.Hook.HideHUD", 
function(nm) 
	if (DISABLED_HUD[nm]) then 
		return false 
	end 
end)

-- [[FONTS]]
local function CS_CreateFont(name, tbl)
	surface.CreateFont(name, tbl)
end

CS_CreateFont("CS_HUD_XXLG",
{
	font = "Alegreya Sans SC",
	size = 34,
})

CS_CreateFont("CS_HUD_XLG",
{
	font = "Alegreya Sans SC",
	size = 34,
})

CS_CreateFont("CS_HUD_LG",
{
	font = "Alegreya Sans SC",
	size = 30,
})

CS_CreateFont("CS_HUD_MD",
{
	font = "Alegreya Sans SC",
	size = 26,
})

CS_CreateFont("CS_HUD_SM",
{
	font = "Alegreya Sans SC",
	size = 22,
})

CS_CreateFont("CS_HUD_XSM",
{
	font = "Alegreya Sans SC",
	size = 18,
})

CS_CreateFont("CS_HUD_XXSM",
{
	font = "Alegreya Sans SC",
	size = 14,
})

-- [[MISC]]
local meta = FindMetaTable( "Player" )
function meta:SelectWeapon( class )
	if ( !self:HasWeapon( class ) ) then return end
	self.DoWeaponSwitch = self:GetWeapon( class )
end

hook.Add( "CreateMove", "CIS.Hook.WeaponSwitch", function( cmd )
	if ( !IsValid( LocalPlayer().DoWeaponSwitch ) ) then return end

	cmd:SelectWeapon( LocalPlayer().DoWeaponSwitch )

	if ( LocalPlayer():GetActiveWeapon() == LocalPlayer().DoWeaponSwitch ) then
		LocalPlayer().DoWeaponSwitch = nil
	end
end)

-- [[HUD]]
CitadelShock.HUD = {}
CitadelShock.HUDS = {}
CitadelShock.HUD.ActiveHUD = 1
CitadelShock.HUD.ActiveWeapon = 1
CitadelShock.HUD.WeaponHUD = {
	active = false,
	timeleft = 0,
	maxcols = 6,
	weapons = {},
	timerlen = 300,
}

-- [[Create HUD]]
function CitadelShock:RegisterHUD(tbl)
	local id = table.insert(self.HUDS, tbl)
	MsgC(Color(255,255,255), "\t --> Registered HUD #" .. id .. "\n")
end

-- [[Load HUDs]]
local hudsPath = GM.FolderName .. "/gamemode/modules/hud/huds/"
local hud_files, hud_dirs = file.Find(hudsPath .. "cl_hud_*.lua", "LUA")

for cl_k,cl_v in pairs(hud_files) do
	include(hudsPath .. cl_v)
end

local mat = Material( "vgui/white")
local function CS_CallDrawHUD()
    -- [[Draw Background]]
    hook.Remove( "HUDPaintBackground", "CIS.HUD.DrawBG" )
    hook.Add("HUDPaintBackground", "CIS.HUD.DrawBG",
    function()
        if (CitadelShock.HUDS[CitadelShock.HUD.ActiveHUD].Background) then
            CitadelShock.HUDS[CitadelShock.HUD.ActiveHUD].Background()
        end
    end)
        
    -- [[Draw Elements]]
	hook.Remove( "HUDPaint", "CIS.HUD.DrawHUD" )
	hook.Add( "HUDPaint", "CIS.HUD.DrawHUD",
    function()
		for _,ele in SortedPairs(CitadelShock.HUDS[CitadelShock.HUD.ActiveHUD].Elements, false) do
            if (ele.status && table.HasValue(ele.status, LocalPlayer():GetStatus()) or not ele.status) then
                ele.draw()
            end
        end
	end)
end
concommand.Add("cis_reloadhud", CS_CallDrawHUD)
CS_CallDrawHUD()

-- [[HUD Functions]]
hook.Add("PlayerBindPress", "CIS.Hook.BP_WeaponSwitch",
function(ply, bind, pressed)
	local binds = {
		["invprev"] = function(weapons)
			if (CitadelShock.HUD.ActiveWeapon <= 1) then
				CitadelShock.HUD.ActiveWeapon = #weapons
			else
				CitadelShock.HUD.ActiveWeapon = CitadelShock.HUD.ActiveWeapon - 1
			end
		end,
		["invnext"] = function(weapons)
			if (CitadelShock.HUD.ActiveWeapon >= #weapons) then
				CitadelShock.HUD.ActiveWeapon = 1
			else
				CitadelShock.HUD.ActiveWeapon = CitadelShock.HUD.ActiveWeapon + 1
			end
		end,
	}

	if not (pressed) then return true end
	local weapons = LocalPlayer():GetWeapons()
	if (#weapons <= 0) then return false end
	if (!input.IsMouseDown(MOUSE_LEFT) && binds[bind]) then
		for k,v in pairs(binds) do
			if (k == bind) then
				v(weapons)
			end
		end

		CitadelShock.HUD.WeaponHUD.active = true
		CitadelShock.HUD.WeaponHUD.timeleft = CitadelShock.HUD.WeaponHUD.timerlen -- HUD Draw ticks
		CitadelShock.HUD.WeaponHUD.weapons = weapons
	end

	if (input.IsMouseDown(MOUSE_LEFT) && CitadelShock.HUD.WeaponHUD.active) then
		CitadelShock.HUD.WeaponHUD.active = false
	end

	local to_weapon = weapons[CitadelShock.HUD.ActiveWeapon]

	if (IsValid(to_weapon)) then
		LocalPlayer():SelectWeapon( to_weapon:GetClass() )
	end
end)