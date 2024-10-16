--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
local SAMPLE = 1000
local x1, y1, x2, y2 = 1.2, 2.3, 3.4, 4.5
-- Variables
-- References
-- Private Functions
-- Class
return {
	Functions = {
		["symbols"] = function()
			for i = 1, SAMPLE do
				local x = (x2 - x1)
				local y = (y2 - y1)
				local _dist = ((x ^ 2) + (y ^ 2)) ^ 0.5
			end
		end,
		["math.sqrt"] = function()
			for i = 1, SAMPLE do
				local x = (x2 - x1)
				local y = (y2 - y1)
				local _dist = math.sqrt((x ^ 2) + (y ^ 2))
			end
		end,
		["math.pow"] = function()
			for i = 1, SAMPLE do
				local x = (x2 - x1)
				local y = (y2 - y1)
				local _dist = (math.pow(x, 2) + math.pow(y, 2)) ^ 0.5
			end
		end,
		["math.pow+sqrt"] = function()
			for i = 1, SAMPLE do
				local x = (x2 - x1)
				local y = (y2 - y1)
				local _dist = math.sqrt((math.pow(x, 2) + math.pow(y, 2)))
			end
		end,
		["V2"] = function()
			for i = 1, SAMPLE do
				local a = Vector2.new(x1, y1)
				local b = Vector2.new(x2, y2)
				local _dist = (a - b).Magnitude
			end
		end,
		["V3"] = function()
			for i = 1, SAMPLE do
				local a = Vector3.new(x1, y1)
				local b = Vector3.new(x2, y2)
				local _dist = (a - b).Magnitude
			end
		end,
	},
}
