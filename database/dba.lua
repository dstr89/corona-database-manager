-------------------------------------------------
-- CORONA SDK - DATABASE MANAGER
-- Version: 1.0.0
-- Used for handling database connection, tables and queries
--
-- Revised BSD License:
--
-- Copyright (c) 2014, Daniel Strmečki <email: daniel.strmecki@gmail.com, web: promptcode.com>
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--   * Redistributions of source code must retain the above copyright
--     notice, this list of conditions and the following disclaimer.
--   * Redistributions in binary form must reproduce the above copyright
--     notice, this list of conditions and the following disclaimer in the
--     documentation and/or other materials provided with the distribution.
--   * Neither the name of the <organization> nor the
--     names of its contributors may be used to endorse or promote products
--     derived from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL DANIEL STRMEČKI BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------

local dba = {}
local sqlite3 = require ("sqlite3")
local log = require("utility.log")

-------------------------------------------------
-- STATIC PROPERTIES
-------------------------------------------------

dba.databaseName = "default_database"
dba.directory = system.DocumentsDirectory
dba.tablesXml = "database/tables.xml"
dba.db = nil

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

-- System events listener
local function onSystemEvent( event )
	if( event.type == "applicationExit" ) then            
		dba.db:close()
	end
end

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

-- Setter for log properties
function dba:openConnection(databaseName, directory, addListenerToCloseConnetion)
	dba.databaseName = databaseName or "default_database"
	dba.directory = directory or system.DocumentsDirectory

	-- Open database connection
	local path = system.pathForFile(databaseName, system.DocumentsDirectory)
	dba.db = sqlite3.open(path)  

	-- Close database connection
	if (addListenerToCloseConnetion == true) then
		Runtime:addEventListener("system", onSystemEvent)
	end
end

-- Create database tables
function dba:createTables(tablesXml)
	dba.tablesXml = tablesXml or "database/tables.xml"

	local xml = require( "external.xml" ).newParser()
	local tables = xml:loadFile( dba.tablesXml )

	--Loop trough all tables defined in tables.xml
	for i=1, #tables.child do
		local table = tables.child[i]
		local tableName = table.properties["name"]
		local tableClass = table.properties["class"]

		-- Create tables
		local adapter = require(tableClass)
		adapter.create()
	end
end

-- Execute query
function dba:exec(query)
	local r = dba.db:exec(query)
	if (log ~= nil) then
		if (log.db ~= nil) then
			log:log("SQL (" .. r .. "): " .. query)
		end
	end
	return r
end

-- Get rows
function dba:nrows(query)
	if (log ~= nil) then
		if (log.db ~= nil) then
			log:log("SQL: " .. query)
		end
	end
	return dba.db:nrows(query)
end

return dba