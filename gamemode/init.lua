-- [[INIT GAMEMODE]]
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- [[LOAD LIBS]]
local function InitLibraries()
	CitadelShock:Message("Libraries:")
	local libPath = GM.FolderName .. "/gamemode/libs/"
	local lib_files, lib_dirs = file.Find(libPath .. "*", "LUA")

	for k,v in SortedPairs(lib_files) do
		if (!v:StartWith("sv_") && !v:StartWith("cl_")) then
			AddCSLuaFile(libPath .. v)
			include(libPath .. v)
			print("\t --> Loaded (SH) library file: '" .. v .. "'")
		elseif (v:StartWith("sv_")) then
			include(libPath .. v)
			print("\t --> Loaded (SV) library file: '" .. v .. "'")
		elseif (v:StartWith("cl_")) then
			AddCSLuaFile(libPath .. v)
			print("\t --> Loaded (CL) library file: '" .. v .. "'")
		end
	end

	for k,v in SortedPairs(lib_dirs) do
		if (file.Exists( libPath .. v .. "/sv_init.lua", "LUA" )) then include(libPath .. v .. "/sv_init.lua") end

		for fl_k, fl_v in SortedPairs(file.Find(libPath .. v .. "/*.lua", "LUA"), false) do
			if (!fl_v:StartWith("sv_") && !fl_v:StartWith("cl_")) then
				AddCSLuaFile(libPath .. v .. "/" .. fl_v)
				include(libPath .. v .. "/" .. fl_v)
			elseif (fl_v:StartWith("sv_")) then
				include(libPath .. v .. "/" .. fl_v)
			elseif (fl_v:StartWith("cl_")) then
				AddCSLuaFile(libPath .. v .. "/" .. fl_v)
			end
		end

		print("\t --> Loaded library '" .. v .. "'")
	end

	CitadelShock:Message("Libraries loaded successfully", "\t --> ")
	CitadelShock.LibsLoaded = true
	hook.Run("CIS.LibrariesLoaded")
end

-- [[INIT MODULES]]
local function InitModules()
	CitadelShock:Message("Modules:")
	local modulePath = GM.FolderName .. "/gamemode/modules/"
	local mod_files, mod_dirs = file.Find(modulePath .. "*", "LUA")

	for k,v in SortedPairs(mod_dirs) do
		if (file.Exists( modulePath .. v .. "/sv_init.lua", "LUA" )) then include(modulePath .. v .. "/sv_init.lua") end

		for fl_k, fl_v in SortedPairs(file.Find(modulePath .. v .. "/*.lua", "LUA"), false) do
			if (!fl_v:StartWith("sv_") && !fl_v:StartWith("cl_")) then
				AddCSLuaFile(modulePath .. v .. "/" .. fl_v)
				include(modulePath .. v .. "/" .. fl_v)
			elseif (fl_v:StartWith("sv_")) then
				include(modulePath .. v .. "/" .. fl_v)
			elseif (fl_v:StartWith("cl_")) then
				AddCSLuaFile(modulePath .. v .. "/" .. fl_v)
			end
		end

		print("\t --> Loaded module '" .. v .. "'")
	end

	if (#mod_files > 0) then print("\t --> Misc. module files:") end
	for k,v in SortedPairs(mod_files) do
		if (!v:StartWith("sv_") && !v:StartWith("cl_")) then
			AddCSLuaFile(modulePath .. v)
			include(modulePath .. v)
			print("\t --> Loaded (SH) module file: '" .. v .. "'")
		elseif (v:StartWith("sv_")) then
			include(modulePath .. v)
			print("\t --> Loaded (SV) module file: '" .. v .. "'")
		elseif (v:StartWith("cl_")) then
			AddCSLuaFile(modulePath .. v)
			print("\t --> Loaded (CL) module file: '" .. v .. "'")
		end
	end

	CitadelShock:Message("Modules loaded successfully", "\t --> ")
	CitadelShock.ModulesLoaded = true
	hook.Run("CIS.ModulesLoaded")
end

-- [[INIT CORE]]
local function InitCore()
	CitadelShock:Message("Core:")
	local corePath = GM.FolderName .. "/gamemode/core/"
	local core_files, core_dirs = file.Find(corePath .. "*", "LUA")

	for k,v in SortedPairs(core_dirs) do
		if (file.Exists( corePath .. v .. "/sv_init.lua", "LUA" )) then include(corePath .. v .. "/sv_init.lua") end

		for fl_k, fl_v in SortedPairs(file.Find(corePath .. v .. "/*.lua", "LUA"), false) do
			if (!fl_v:StartWith("sv_") && !fl_v:StartWith("cl_")) then
				AddCSLuaFile(corePath .. v .. "/" .. fl_v)
				include(corePath .. v .. "/" .. fl_v)
			elseif (fl_v:StartWith("sv_")) then
				include(corePath .. v .. "/" .. fl_v)
			elseif (fl_v:StartWith("cl_")) then
				AddCSLuaFile(corePath .. v .. "/" .. fl_v)
			end
		end

		print("\t --> Loaded core '" .. v .. "'")
	end

	if (#core_files > 0) then print("\t --> Misc. core files:") end
	for k,v in SortedPairs(core_files) do
		if (!v:StartWith("sv_") && !v:StartWith("cl_")) then
			AddCSLuaFile(corePath .. v)
			include(corePath .. v)
			print("\t --> Loaded (SH) core file: '" .. v .. "'")
		elseif (v:StartWith("sv_")) then
			include(corePath .. v)
			print("\t --> Loaded (SV) core file: '" .. v .. "'")
		elseif (v:StartWith("cl_")) then
			AddCSLuaFile(corePath .. v)
			print("\t --> Loaded (CL) core file: '" .. v .. "'")
		end
	end

	CitadelShock:Message("Core loaded successfully", "\t --> ")
	CitadelShock.CoreLoaded = true
	hook.Run("CIS.CoreLoaded")
end

-- [[INIT CONFIG]]
local function InitConfig()
	CitadelShock:Message("Config:")
	local configPath = GM.FolderName .. "/gamemode/config/"
	local config_files, config_dirs = file.Find(configPath .. "*", "LUA")

	for k,v in SortedPairs(config_dirs) do
		if (file.Exists( configPath .. v .. "/sv_init.lua", "LUA" )) then include(configPath .. v .. "/sv_init.lua") end

		for fl_k, fl_v in SortedPairs(file.Find(configPath .. v .. "/*.lua", "LUA"), false) do
			if (!fl_v:StartWith("sv_") && !fl_v:StartWith("cl_")) then
				AddCSLuaFile(configPath .. v .. "/" .. fl_v)
				include(configPath .. v .. "/" .. fl_v)
			elseif (fl_v:StartWith("sv_")) then
				include(configPath .. v .. "/" .. fl_v)
			elseif (fl_v:StartWith("cl_")) then
				AddCSLuaFile(configPath .. v .. "/" .. fl_v)
			end
		end

		print("\t --> Loaded config '" .. v .. "'")
	end

	if (#config_files > 0) then print("\t --> Misc. config files:") end
	for k,v in SortedPairs(config_files) do
		if (!v:StartWith("sv_") && !v:StartWith("cl_")) then
			AddCSLuaFile(configPath .. v)
			include(configPath .. v)
			print("\t --> Loaded (SH) config file: '" .. v .. "'")
		elseif (v:StartWith("sv_")) then
			include(configPath .. v)
			print("\t --> Loaded (SV) config file: '" .. v .. "'")
		elseif (v:StartWith("cl_")) then
			AddCSLuaFile(configPath .. v)
			print("\t --> Loaded (CL) config file: '" .. v .. "'")
		end
	end

	CitadelShock:Message("Config loaded successfully", "\t --> ")
	CitadelShock.ConfigLoaded = true
	hook.Run("CIS.ConfigLoaded")
end

-- [[Initialize Gamemode]]
function CitadelShock:Initialize()
	print([[/////////////////////////////////
  _____ _ _            _      _  _____ _                _
 / ____(_| |          | |    | |/ ____| |              | |
| |     _| |_ __ _  __| | ___| | (___ | |__   ___   ___| | __
| |    | | __/ _` |/ _` |/ _ | |\___ \| '_ \ / _ \ / __| |/ /
| |____| | || (_| | (_| |  __| |____) | | | | (_) | (__|   <
 \_____|_|\__\__,_|\__,_|\___|_|_____/|_| |_|\___/ \___|_|\_\
	]])

	self:Message("Version: " .. self.Version, " --> ")
	self:Message("Initializing Citadel Shock\n/////////////////////////////////", " --> ")
	InitLibraries()
	InitCore()
	InitModules()
	InitConfig()
	print("--------------------------------------")
	self:Message("Successfully loaded Citadel Shock\n--------------------------------------", " --> ")
	print("/////////////////////////////////")
	self:Message("Setting-up Gamemode\n/////////////////////////////////", " --> ")
	hook.Run("CIS.Hook.GM_Setup")
	self:Message("Finished gamemode setup", " --> ")
	
	-- cmds
	RunConsoleCommand("sbox_godmode", "0")
end

CitadelShock:Initialize()