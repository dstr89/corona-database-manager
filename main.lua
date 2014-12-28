-------------------------------------------------
-- SAMPLE DATABASE MANAGER - main
--
-- @Daniel 05.07.2014
-------------------------------------------------

-------------------------------------------------
-- REQUIRE MODULES
-------------------------------------------------

local log = require("utility.log")
local dba = require("database.dba")
local params = require("database.tables.params")

-- Main function, called on applications first start
local function main()
	
	-- SETUP DATABASE MODULE
	dba:openConnection("test_db", nil, true) 
	dba:createTables()

	-- SETUP ADVANCED LOGGING MODULE
	log:set(dba.db, "youremail@gmail.com")

	-- Get parameter
	local p1 = params:get("application.version")
	log:log("Application version", p1)

	-- Update parametar
	local incremented = tonumber(p1) + 1
	params:update("application.version", incremented)	

	-- Get parameter again
	local p2 = params:get("application.version")
	log:log("Application version", p2)	

end

main();

