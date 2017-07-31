--[[
	** ZLib - V1 **
	** Developed by Zephruz **
	Library for uncomplicating the complicated.
	Current usage may be limited/restricted.

	** Why does this even exist? What's this for? **
	I am currently developing this to have functions available to eliminate/simplify large blocks of code that would otherwise get in the way.
	Currently some unique features are:
		- SQLite
			* Wipe the entire SQLite database
			* Print the entire SQLite database
			* Queue queries for later proccessing
			* Get the size of the SQLite database

	** Git **
	- Have a problem with it? - git.
	- Have a commit? - git.

	** License and etc. **
	- License: MIT
	- Feel free to use this in any unpaid/paid/whatever, credit is appreciated.
]]

ZLib = {}
ZLib.EnableDebug = true

-- [[ZLib Misc. Functions]]
function ZLib:Message(msg)
	MsgC(Color(0,255,0), "[ZLib] ", Color(255,255,255), msg .. "\n")
end

--[[SQLite]]
ZLib.sql = {}
ZLib.sql.QueryQueue = {}

function ZLib.sql:Query(qry) -- [[ Used to submit a sqlite query. Args: (qry *string* - Query string) ]]
	local query =  sql.Query(qry)

	if (query == false) then
		ZLib:Message("SQLite Error: " .. (sql.LastError() or "No error"))
	end

	return query
end

function ZLib.sql:TableExists(tbl)
	return sql.TableExists(tbl)
end

function ZLib.sql:AddToQueue(qry) -- [[ Used to add a sqlite query to the queue. Args: (qry *string* - Query string)]]
	table.insert(self.QueryQueue, qry)
end

function ZLib.sql:ProcessQueue(queue) -- [[ Used to commit the sqlite queue. Recommended to only use for queries that write to the disk. Args: ([OPTIONAL] queue *table* - Alternative SQLite table to process) ]]
	local queue = (queue or self.QueryQueue)
	local results = {}

	if not (istable(queue)) then return false end
	if (#queue == 0) then ZLib:Message("No queries to process, skipping...") return false end
	ZLib:Message("Proccessing query queue (" .. #queue .. " queries)...")
	sql.Begin()
	for k,v in pairs(queue) do
		local res = ZLib.sql:Query(v)
		results[k] = {}
		results[k].qstr = v
		results[k].result = res
		if (ZLib.EnableDebug) then ZLib:Message("[" .. k .. "] " .. v .. "\n\t--> Query Result: " .. tostring(res))end
	end
	sql.Commit()
	ZLib:Message("Processed query queue (" .. #queue .. " queries)!")

	if not (queue) then self:FlushQueue() end
	return true, results
end

function ZLib.sql:FlushQueue() -- [[ Used to flush the sqlite queue. ]]
	if (#self.QueryQueue == 0) then ZLib:Message("No queries to flush, skipping...") return false end
	ZLib:Message("Flushing query queue (" .. #self.QueryQueue .. " queries)...")
	self.QueryQueue = {}
	ZLib:Message("Query queue flushed!")

	return true
end

function ZLib.sql:GetAllTables() -- [[ Used to retrieve all of the tables in the sqlite database. ]]
	ZLib:Message("Selecting all SQLite tables...")
	local tbls = self:Query("SELECT * FROM sqlite_master")

	if (ZLib.EnableDebug && tbls) then
		ZLib:Message("SQLite Tables:")

		for k,v in pairs(tbls) do
			if (v.type == "table") then
				print("-------------------------")
				print(" --> Full name: " .. (v.name or "No name"))
				print(" --> Table name: " .. (v.tbl_name or "No name"))
				print(" --> Root page: " .. (v.rootpage or "No root page"))
			end
		end
	elseif (ZLib.EnableDebug && !tbls) then
		ZLib:Message(" --> No SQLite tables to output!")
	end

	return (tbls or false)
end

function ZLib.sql:WipeDatabase() -- [[ Wipes the entire sqlite database. WARNING: This will delete ALL sqlite data. ]]
	ZLib:Message("Wiping SQLite tables/indexes...")
	local db = self:GetAllTables()
	local dbQuery = {}

	if not (db) then ZLib:Message("Can't wipe database because there are no tables.") return false end

	for k,v in pairs(db) do
		if (v.type == "table") then
			table.insert(dbQuery, "DROP TABLE `" .. v.tbl_name .. "`")
		end
	end

	ZLib.sql:ProcessQueue(dbQuery)
	ZLib:Message("Wiped SQLite database successfully!")
end

function ZLib.sql:GetDatabaseSize() -- [[ Gets the size of the sqlite database (in bytes). ]]
	local dbSize = file.Size("sv.db", "GAME")

	if (dbSize == -1) then
		ZLib:Message("SQLite database not found!")
	end
	if (ZLib.EnableDebug) then ZLib:Message("SQLite DB Size: " .. dbSize .. " Bytes") end

	return file.Size("sv.db", "GAME")
end

-- [[Flat File]]
ZLib.file = {}

function ZLib.file:IsDir(dir_name, dir_path)
	if not (dir_name) then return false end
end

function ZLib.file:CreateDir(dir_name)
	if not (dir_name) then return false, "No directory name defined for directory creation, aborting." end

	file.CreateDir(dir_name)

	return true
end

function ZLib.file:Write(f_name, f_cont, to_json)
	if not (f_name) then return false, "No file name defined for file read, aborting." end

	if (to_json && istable(f_cont)) then
		f_cont = util.TableToJSON(f_cont)
	end

	file.Write(f_name, f_cont)

	return true, f_cont
end

function ZLib.file:Read(f_name, f_path, to_tbl)
	if not (f_name) then return false, "No file name defined for file read, aborting." end
	if not (f_path) then f_path = "DATA" print("No path defined for file read. Reverting to DATA. File: " .. f_name) end

	local data = file.Read( f_name, f_path )

	if (to_tbl) then
		data = util.JSONToTable(data)
	end

	return data, true
end

return ZLib
