--[[
	-- View redrawing

	* Options
		- 
		- Realistic view (Cvar value 1)
		- Regular view (Cvar value 0)
]]

local ply = LocalPlayer()

local cvars = {
	["zdraw_type"] = {val = "0", desc = "Select your preferred view type. {Regular = 0, Normal (see your body) = 1, Realism = 2, Third Person = 3"},
	["zdraw_fov"] = {val = "115", desc = "Set your view FOV."},
}
local viewTypes = {
	[0] = { -- Regular Viewtype
		function(ply, pos, ang, fov)
			local view = {}
			view.origin = pos
			view.angles = ang
			view.fov = (GetConVar("zdraw_fov"):GetInt() or fov)
			view.drawviewer = false

			return view
		end,
	},
	[1] = { -- Normal Viewtype
		function(ply, pos, ang, fov)
			local view = {}
			view.origin = (ply:GetAttachment(1).Pos or pos)
			view.angles = ang
			view.fov = (GetConVar("zdraw_fov"):GetInt() or fov)
			view.drawviewer = true

			return view
		end,
	},
	[2] = { -- Realistic Viewtype
		function(ply, pos, ang, fov)
			local view = {}
			view.origin = (ply:GetAttachment(1).Pos or pos)
			view.angles = (ply:GetAttachment(1).Ang or ang)
			view.fov = (GetConVar("zdraw_fov"):GetInt() or fov)
			view.drawviewer = true

			return view
		end,
	},
	[3] = {	-- Thirdperson Viewtype
		function(ply, pos, ang, fov)
			local view = {}
			view.origin = pos - (ang:Forward()*60)
			view.angles = ang
			view.fov = (GetConVar("zdraw_fov"):GetInt() or fov)
			view.drawviewer = true

			return view
		end,
	},
}

for k,v in pairs(cvars) do
	CreateClientConVar(k, v.val, true, false, v.desc)
end

local function VDraw_CalcView( ply, pos, ang, fov )
	local viewNum = 0
	if (ConVarExists("zdraw_type")) then viewNum = GetConVar("zdraw_type"):GetInt() end

	local view = (viewTypes[viewNum][1](ply, pos, ang, fov) or viewTypes[0][1](ply, pos, ang, fov))

	return view
end
hook.Add( "CalcView", "VDraw_CalcView", VDraw_CalcView )

hook.Add("DoDrawCrosshair", "VDraw_DrawCrosshair", function() print("test") end)