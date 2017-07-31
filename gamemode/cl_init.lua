include( "shared.lua" )

-- [[Functions]]
function CitadelShock:ChatMessage(msg)
	if (CitadelShock.Player.ChatNotifications) then
		chat.AddText(Color(255,35,35), "[Citadel Shock] ", Color(255,255,255), msg)
	end
	
	hook.Run("CIS.Hook.ChatMessage", msg)
end

local function InitModules()
	local modulePath = GM.FolderName .. "/gamemode/modules/"
	local mod_files, mod_dirs = file.Find(modulePath .. "*", "LUA")

	for k,v in SortedPairs(mod_dirs) do
		if (file.Exists( modulePath .. v .. "/cl_init.lua", "LUA" )) then include(modulePath .. v .. "/cl_init.lua") end

		for fl_k, fl_v in SortedPairs(file.Find(modulePath .. v .. "/*.lua", "LUA"), false) do
			include(modulePath .. v .. "/" .. fl_v)
		end
	end

	for k,v in SortedPairs(mod_files) do
		include(modulePath .. v)
	end

	CitadelShock:Message("Modules loaded", " --> ")
	CitadelShock.ModulesLoaded = true
	hook.Run("CIS.ModulesLoaded")
end

-- [[LOAD LIBS]]
local function InitLibraries()
	local libPath = GM.FolderName .. "/gamemode/libs/"
	local lib_files, lib_dirs = file.Find(libPath .. "*", "LUA")

	for k,v in SortedPairs(lib_dirs) do
		if (file.Exists( libPath .. v .. "/cl_init.lua", "LUA" )) then include(libPath .. v .. "/cl_init.lua") end

		for fl_k, fl_v in SortedPairs(file.Find(libPath .. v .. "/*.lua", "LUA"), false) do
			include(libPath .. v .. "/" .. fl_v)
		end
	end

	for k,v in SortedPairs(lib_files) do
		include(libPath .. v)
	end

	CitadelShock:Message("Libraries loaded", " --> ")
	CitadelShock.LibsLoaded = true
	hook.Run("CIS.LibrariesLoaded")
end

local function InitCore()
	local corePath = GM.FolderName .. "/gamemode/core/"
	local core_files, core_dirs = file.Find(corePath .. "*", "LUA")

	for k,v in SortedPairs(core_dirs) do
		if (file.Exists( corePath .. v .. "/cl_init.lua", "LUA" )) then include(corePath .. v .. "/cl_init.lua") end

		for fl_k, fl_v in SortedPairs(file.Find(corePath .. v .. "/*.lua", "LUA"), false) do
			include(corePath .. v .. "/" .. fl_v)
		end
	end

	for k,v in SortedPairs(core_files) do
		include(corePath .. v)
	end

	CitadelShock:Message("Core loaded", " --> ")
	CitadelShock.CoreLoaded = true
	hook.Run("CIS.CoreLoaded")
end

local function InitConfig()
	local configPath = GM.FolderName .. "/gamemode/config/"
	local config_files, config_dirs = file.Find(configPath .. "*", "LUA")

	for k,v in SortedPairs(config_dirs) do
		if (file.Exists( configPath .. v .. "/cl_init.lua", "LUA" )) then include(configPath .. v .. "/cl_init.lua") end

		for fl_k, fl_v in SortedPairs(file.Find(configPath .. v .. "/*.lua", "LUA"), false) do
			include(configPath .. v .. "/" .. fl_v)
		end
	end

	for k,v in SortedPairs(config_files) do
		include(configPath .. v)
	end

	CitadelShock:Message("Config loaded", " --> ")
	CitadelShock.ConfigLoaded = true
	hook.Run("CIS.ConfigLoaded")
end

-- [[CLIENT Gamemode hooks]]
function GM:ContextMenuOpen() return false end
function GM:OnSpawnMenuOpen() return false end

-- [[Initialize Gamemode]]
function CitadelShock:Initialize()
	self:Message([[/////////////////////////////////
  _____ _ _            _      _  _____ _                _
 / ____(_| |          | |    | |/ ____| |              | |
| |     _| |_ __ _  __| | ___| | (___ | |__   ___   ___| | __
| |    | | __/ _` |/ _` |/ _ | |\___ \| '_ \ / _ \ / __| |/ /
| |____| | || (_| | (_| |  __| |____) | | | | (_) | (__|   <
 \_____|_|\__\__,_|\__,_|\___|_|_____/|_| |_|\___/ \___|_|\_\
Version: ]] .. CitadelShock.Version .. [[

/////////////////////////////////]], "")
	InitLibraries()
	InitCore()
	InitModules()
	InitConfig()
	self:Message("--------------------------------------", "")
	self:Message("Successfully loaded Citadel Shock", " --> ")
	self:Message("--------------------------------------", "")
	hook.Run("CIS.Hook.GM_Setup")
	
	RunConsoleCommand("hud_deathnotice_time", "0")
	
	if (CitadelShock.Player.OpenHelpOnSpawn) then RunConsoleCommand("mainmenu") end
end

CitadelShock:Initialize()
