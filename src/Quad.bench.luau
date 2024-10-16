--!strict
-- Services
-- Packages
-- Modules
local QuadTree = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("Packages")
		:WaitForChild("package")
)
-- Types
-- Constants
local QUERY_COUNT = 128
local VALUE_COUNT = 500
local DIM = 2 ^ 15
local QUERY_RADIUS = 256
local QUERY_WIDTH = QUERY_RADIUS * 2
local FILTER_RATIO = 0.5
local FILTER_RADIUS = FILTER_RATIO * QUERY_RADIUS
local FILTER_WIDTH = FILTER_RADIUS * FILTER_RATIO
local CAPACITY = 16

-- Variables
-- References
local tree = QuadTree.new(0, 0, DIM, DIM, CAPACITY)
for i = 1, VALUE_COUNT do
	local point = Vector3.new(math.random(1, DIM), math.random(1, DIM))
	tree:Insert(point.X, point.Y, point)
end

local queryPoints: { [number]: Vector3 } = {}
for i = 1, QUERY_COUNT do
	local point = Vector3.new(math.random(1, DIM), math.random(1, DIM))
	table.insert(queryPoints, point)
end

-- Private Functions
-- Class
return {
	Functions = {
		["search-radius"] = function()
			for i = 1, QUERY_COUNT do
				tree:SearchRadius(
					queryPoints[i].X,
					queryPoints[i].Y,
					QUERY_RADIUS
				)
			end
		end,
		["filter-search-radius"] = function()
			for i = 1, QUERY_COUNT do
				tree:FilterSearchRadius(
					queryPoints[i].X,
					queryPoints[i].Y,
					QUERY_RADIUS,
					queryPoints[i].X,
					queryPoints[i].Y,
					FILTER_RADIUS
				)
			end
		end,
		["search-region"] = function()
			for i = 1, QUERY_COUNT do
				tree:SearchRegion(
					queryPoints[i].X,
					queryPoints[i].Y,
					queryPoints[i].X + QUERY_WIDTH,
					queryPoints[i].Y + QUERY_WIDTH
				)
			end
		end,
		["filter-search-region"] = function()
			for i = 1, QUERY_COUNT do
				tree:FilterSearchRegion(
					queryPoints[i].X,
					queryPoints[i].Y,
					queryPoints[i].X + QUERY_WIDTH,
					queryPoints[i].Y + QUERY_WIDTH,
					queryPoints[i].X + QUERY_WIDTH * (FILTER_RATIO / 2),
					queryPoints[i].Y + QUERY_WIDTH * (FILTER_RATIO / 2),
					queryPoints[i].X + FILTER_WIDTH,
					queryPoints[i].Y + FILTER_WIDTH
				)
			end
		end,
	},
}
