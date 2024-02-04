--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
local SAMPLE = 10000

-- Variables
-- References
-- Private Functions
-- Class
return {
	Functions = {
		["Rect"] = function()
			for i=1, SAMPLE do
				local _r = Rect.new(1,2,3,4)
			end
		end,
		["Array"] = function()
			for i=1, SAMPLE do
				local _r = {1,2,3,4}
			end
		end,
		["ArrayFrozen"] = function()
			for i=1, SAMPLE do
				local _r = {1,2,3,4}
				table.freeze(_r)
			end
		end,
		["Dict"] = function()
			for i=1, SAMPLE do
				local _r = {
					A=1,
					B=2,
					C=3,
					D=4
				}
			end
		end,
		["DictFrozen"] = function()
			for i=1, SAMPLE do
				local _r = {
					A=1,
					B=2,
					C=3,
					D=4
				}
				table.freeze(_r)
			end
		end,
		["Vector2"] = function()
			for i=1, SAMPLE do
				local _r1, _r2 = Vector2.new(1,2), Vector2.new(3,4)
			end
		end,
		["Vector3"] = function()
			for i=1, SAMPLE do
				local _r1, _r2 = Vector3.new(1,2), Vector3.new(3,4)
			end
		end,
		["NumberRange"] = function()
			for i=1, SAMPLE do
				local _r1, _r2 = NumberRange.new(1,2), NumberRange.new(3,4)
			end
		end,
		["number"] = function()
			for i=1, SAMPLE do
				local _r1, _r2, _r3, _r4 = 1,2,3,4
			end
		end,
	},

}