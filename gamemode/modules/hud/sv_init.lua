--[[
	Citadel Shock
	- HUD MODULE -
	- SV INIT -
]]

-- Load HUDs
local hudsPath = GM.FolderName .. "/gamemode/modules/hud/huds/"
local hud_files, hud_dirs = file.Find(hudsPath .. "cl_hud_*.lua", "LUA")

for cl_k,cl_v in pairs(hud_files) do
	AddCSLuaFile(hudsPath .. cl_v)
end
