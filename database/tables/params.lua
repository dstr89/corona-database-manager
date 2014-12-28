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

local table = {}
local dba = require("database.dba")

-------------------------------------------------
-- STATIC PROPERTIES
-------------------------------------------------

table.name = "params"
table.paramsXml = "database/params.xml"

table.log = nil

-------------------------------------------------
-- PRIVATE FUNCTIONS
-------------------------------------------------

-- Check if param exist
local function checkIfExists(name)
	for row in dba:nrows("SELECT * FROM " .. table.name .. " WHERE name = '" .. name .. "'") do
		return true
	end
	return false
end

-- Insert param only if it does not exist
local function insertIfNotExists(name, value, description)
	if (checkIfExists(name) == false) then
		if (description == nil) then
			description = ""
		end

		local q = [[INSERT INTO ]] .. table.name .. [[ VALUES (NULL, ']].. name .. [[', ']].. value .. [[', ']].. description .. [[');]]
		dba:exec(q)
	end
end

-- Inserts default values
local function insertDefaultValues(paramsXml)
	table.paramsXml = paramsXml or "database/params.xml"

	local xml = require( "external.xml" ).newParser()
	local params = xml:loadFile( table.paramsXml )

	--Loop trough all params defined in params.xml
	for i=1, #params.child do
		local param = params.child[i]
		local paramName = param.properties["name"]
		local paramValue = param.properties["value"]
		local paramDescription = param.properties["description"]

		insertIfNotExists(paramName, paramValue, paramDescription)
	end
end

-------------------------------------------------
-- PUBLIC FUNCTIONS
-------------------------------------------------

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

return table