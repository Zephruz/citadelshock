--[[
	Citadel Shock
	- DATA MODULE -
]]

CitadelShock.data = {}
CitadelShock.dataSaver = "sqlite"

-- [[Flat File]]
CitadelShock.data.file = {}
CitadelShock.data.file.structure = {}
CitadelShock.data.file.main_dir = "citadelshock"

function CitadelShock.data.file:Initialize()
	if not (file.IsDir(self.main_dir, "DATA")) then
		file.CreateDir(self.main_dir)
	end

	if not (file.IsDir(self.main_dir .. "/logs", "DATA")) then
		file.CreateDir(self.main_dir .. "/logs")
	end
end

-- [[SQLite]]
CitadelShock.data.sqlite = {}
CitadelShock.data.sqlite.tables = {
	citadelshock = {active = false, create = "CREATE TABLE `%nm` ()"},
	citshock_player_tbl = {active = true, create = "CREATE TABLE `%nm` (stid varchar(255) NOT NULL, points INT NOT NULL, level INT NOT NULL, exp INT NOT NULL, wins INT NOT NULL, losses INT NOT NULL, PRIMARY KEY (stid))"},
}

function CitadelShock.data.sqlite:Initialize()
	CitadelShock:Message("SQLite tables:")
	for tbl_nm,data in pairs(self.tables) do
		if (data.active) then
			if not (ZLib.sql:TableExists(tbl_nm)) then
				ZLib.sql:Query(data.create:Replace('%nm', tbl_nm))
				print("\t --> Table `" .. tbl_nm .. "` doesn't exist, creating...")

				if (ZLib.sql:TableExists(tbl_nm)) then print("\t\t --> Table `" .. tbl_nm .. "` created!") end
			elseif (ZLib.sql:TableExists(tbl_nm)) then
				print("\t --> Table `" .. tbl_nm .. "` exists!")
			end
		else
			print("\t --> Table `" .. tbl_nm .. "` disabled!")
		end
	end
	CitadelShock:Message("SQLite loaded successfully", "\t --> ")
end

-- [[Data Handling]]
function CitadelShock.data:Initialize()
	local dataLoad = CitadelShock.data[CitadelShock.dataSaver]

	-- Initialize SQLite Data
	if (dataLoad.Initialize) then
		dataLoad:Initialize()
	end
end
hook.Add("CIS.ModulesLoaded", "CS_LoadedMods", CitadelShock.data.Initialize)

function CitadelShock.data:ResetData()
	local dataLoad = self[CitadelShock.dataSaver]

	if (dataLoad.ResetData) then
		dataLoad:ResetData()
	end
end

--[[
	Player
]]
local plySQLTable = {
	["stid"] = {val = ""},
	["points"] = {val = 0},
	["level"] = {val = 1},
	["exp"] = {val = 0},
	["wins"] = {val = 0},
	["losses"] = {val = 0},
}
local plyMeta = FindMetaTable("Player")

function plyMeta:SetSQLValue(var, val)
	if !(self) then return false end
	local data = CitadelShock.data:PlayerExists(self)
	
	if !(data) then CitadelShock.data:PlayerCreate(ply) else data = data[1] end
	if !(plySQLTable[var]) then CitadelShock:Message("Invalid data specified for " .. self:Nick() .. " (" .. self:SteamID() .. "), aborting!") return false end
	
	local res = ZLib.sql:Query("UPDATE `citshock_player_tbl` SET " .. var .. " = " .. val .. " WHERE stid = '" .. self:SteamID() .. "'")
	if (res) then ZLib.sql:Message(res) end
end


function CitadelShock.data:PlayerExists(ply)
	local data = ZLib.sql:Query("SELECT * FROM `citshock_player_tbl` WHERE stid = '" .. ply:SteamID() .. "'")

	return data
end

function CitadelShock.data:PlayerCreate(ply)
	CitadelShock:Message("Creating data for " .. ply:Nick() .. " (" .. ply:SteamID() .. ")...")
	ZLib.sql:Query("INSERT INTO `citshock_player_tbl` (stid, points, level, exp, wins, losses) VALUES ('" .. ply:SteamID() .. "', '0', '1', '0', '0', '0')")
	local data = CitadelShock.data:PlayerExists(ply)

	if (data) then
		CitadelShock:Message("Data created for " .. ply:Nick() .. " (" .. ply:SteamID() .. ")!")
	else
		CitadelShock:Message("Data creation failed for " .. ply:Nick() .. " (" .. ply:SteamID() .. ")!")
	end

	return data
end

function CitadelShock.data:InitPlayer(ply)
	if not IsValid(ply) then return false end
	local data = CitadelShock.data:PlayerExists(ply)

	if not (data) then data = CitadelShock.data:PlayerCreate(ply)
	else data = data[1]
		CitadelShock:Message("Data fetched for " .. ply:Nick() .. " (" .. ply:SteamID() .. ")!")
	end
	
	PrintTable(data)

	-- [[Data Values]]
	ply:SetNW2Int("CIS.PNW.points", (data.points or 0))
	ply:SetNW2Int("CIS.PNW.level", (data.level or 1))
	ply:SetNW2Int("CIS.PNW.exp", (data.exp or 0))
	ply:SetNW2Int("CIS.PNW.wins", (data.wins or 0))
	ply:SetNW2Int("CIS.PNW.losses", (data.losses or 0))
	
	-- [[Game Values]]
	ply:SetNW2Int("CIS.PNW.Status", 0)
	ply:SetNW2Int("CIS.PNW.LobbyID", -1)
	ply:SetNW2Int("CIS.PNW.SideID", -1)
	ply:SetNW2Int("CIS.PNW.SpecGame", -1)
	ply:SetNW2Bool("CIS.PNW.LobbyReady", false)
	
	ply:SetStatus(0) -- lobby status
end
