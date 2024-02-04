--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
local SAMPLE = 10000
local a,b,c,d = 1,2,3,4
local rect = Rect.new(a,b,c,d)
local array = {a,b,c,d}
local frozenArray = {a,b,c,d}
table.freeze(frozenArray)
local dict = {
	A=a,
	B=b,
	C=c,
	D=d
}
local frozenDict = {
	A=a,
	B=b,
	C=c,
	D=d
}
table.freeze(frozenDict)
local v2A, v2B = Vector2.new(a,b), Vector2.new(c,d)
local v3A, v3B = Vector3.new(a,b), Vector3.new(c,d)
local rangeA, rangeB = NumberRange.new(a,b), NumberRange.new(c,d)
-- Variables
-- References
-- Private Functions
-- Class
return {
	Functions = {
		["number"] = function()
			for i=1, SAMPLE do
				local _a = a
				local _b = b
				local _c = c
				local _d = d
			end
		end,
		["Rect"] = function()
			for i=1, SAMPLE do
				local _a = rect.Min.X
				local _b = rect.Min.Y
				local _c = rect.Max.X
				local _d = rect.Max.Y
			end
		end,
		["Array"] = function()
			for i=1, SAMPLE do
				local _a = array[1]
				local _b = array[2]
				local _c = array[3]
				local _d = array[4]
			end
		end,
		["ArrayFrozen"] = function()
			for i=1, SAMPLE do
				local _a = frozenArray[1]
				local _b = frozenArray[2]
				local _c = frozenArray[3]
				local _d = frozenArray[4]
			end
		end,
		["Dict"] = function()
			for i=1, SAMPLE do
				local _a = dict.A
				local _b = dict.B
				local _c = dict.C
				local _d = dict.D
			end
		end,
		["DictFrozen"] = function()
			for i=1, SAMPLE do
				local _a = frozenDict.A
				local _b = frozenDict.B
				local _c = frozenDict.C
				local _d = frozenDict.D
			end
		end,
		["Vector2"] = function()
			for i=1, SAMPLE do
				local _a = v2A.X
				local _b = v2A.Y
				local _c = v2B.X
				local _d = v2B.Y
			end
		end,
		["Vector3"] = function()
			for i=1, SAMPLE do
				local _a = v3A.X
				local _b = v3A.Y
				local _c = v3B.X
				local _d = v3B.Y
			end
		end,
		["NumberRange"] = function()
			for i=1, SAMPLE do
				local _a = v3A.X
				local _b = v3A.Y
				local _c = v3B.X
				local _d = v3B.Y
			end
			for i=1, SAMPLE do
				local _a = rangeA.Min
				local _b = rangeA.Max
				local _c = rangeB.Min
				local _d = rangeB.Max
			end
		end,
	},

}