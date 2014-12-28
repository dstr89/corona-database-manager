Corona Database Manager
=====================

##Usage##

Used for handling database connection, creating tables, table queries etc.

This module uses two other modules: 
* CoronaAdvancedLogging module (https://github.com/promptcode/CoronaAdvancedLogging)
* XML parser module by Alexander Makeev (http://lua-users.org/wiki/LuaXml)

###main.lua###

Check out the sample Corona project in this repository. Quick preview:

```lua
-- REQUIRE MODULES
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
	log:log("Application verson", p1)

	-- Update parametar
	local incremented = tonumber(p1) + 1
	params:update("application.version", incremented)	

	-- Get parameter again
	local p2 = params:get("application.version")
	log:log("Application verson", p2)	
end
```

##dba.lua##

Used for opening / closing database connection and executing queries.

```lua
local log = require("utility.log")
local dba = require("database.dba")
-- Execute update
dba:exec("UPDATE params SET VALUE = '55' WHERE name = 'application.version'")
-- Get rows
for row in dba:nrows("SELECT * FROM params WHERE name = 'application.version'") do
	log:log("Application version", row.value)
end
```

##tables.xml##

All tables defined in tables XML file will be created if they do not exist.

```xml
<?xml version="1.0"?>
<tables>
	<table name="params" class="database.tables.params"/>
</tables>
```

##params.xml##

All parameters defined in params XML will be inserted with default values if they do not exist.

```xml
<?xml version="1.0"?>
<params>
	<!-- Parameters and default values -->
	<param name="application.version" value="1" description=""/>
	<param name="database.version" value="1" description=""/>
</params>
```

##params.lua##

Params is an ORM-like database table adapter. You can add your own adapters in the same way. Each adapter should have a create function and other functions used for working with the specific database table.

```lua
-- Create table
function table:create()
	-- Create table if it does not exist
	local q1 = [[CREATE TABLE IF NOT EXISTS ]] .. table.name .. [[ (id INTEGER PRIMARY KEY autoincrement, name, value, description);]]
	dba:exec(q1)
	-- For params table we always inser default values
	insertDefaultValues()
end
-- Insert param
function table:insert(name, value, description)
	local q = [[INSERT INTO ]] .. table.name .. [[ VALUES (NULL, ']].. name .. [[', ']].. value .. [[', ']].. description .. [[');]]
	dba:exec(q)
end
-- Get param
function table:get(name)
	for row in dba:nrows("SELECT * FROM " .. table.name .. " WHERE name = '" .. name .. "'") do
		return row.value
	end
	return nil
end
-- Delete param
function table:delete(name)
	for row in dba:nrows("DELETE FROM " .. table.name .. " WHERE name = '" .. name .. "'") do
		return row.currentFileIndex
	end
	return nil
end
-- Update param
function table:update(name, value)
	local q = "UPDATE " .. table.name .. " SET value = '" .. value .. "' WHERE name = '" .. name .. "'"
	dba:exec(q)
end
```

##Logging##

Each SQL query is logged into console and into a log file located in Documents Directory.
More about CoronaAdvancedLogging can be found here: https://github.com/promptcode/CoronaAdvancedLogging


