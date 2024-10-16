--!strict
-- Services
-- Packages
local Octree = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("Packages")
		:WaitForChild("Octree")
)
-- Modules
local QuadTree = require(
	game:GetService("ReplicatedStorage")
		:WaitForChild("Packages")
		:WaitForChild("package")
)
-- Types
-- Constants
local QUERY_COUNT = 256 -- 2048
local DIM = 2 ^ 15
-- local FILTER_RATIO = 0.5
-- local FILTER_RADIUS = FILTER_RATIO * QUERY_RADIUS
-- local FILTER_WIDTH = FILTER_RADIUS * FILTER_RATIO
-- Variables
-- References

local methods: { [string]: (profiler: Profiler) -> () } = {}

-- Private Functions
function test(capacity: number, valueCount: number, radius: number)
	local octree = Octree.new(DIM)
	local tree = QuadTree.new(0, 0, DIM, DIM, capacity)
	-- local queryWidth = math.round(math.sqrt(((radius*2)^2)/2))

	for i = 1, valueCount do
		local point = Vector3.new(math.random(1, DIM), math.random(1, DIM))
		tree:Insert(point.X, point.Y, point)
	end

	local queryPoints: { [number]: Vector3 } = {}
	for i = 1, QUERY_COUNT do
		local point = Vector3.new(math.random(1, DIM), math.random(1, DIM))
		table.insert(queryPoints, point)
	end

	methods[`octree-search-radius;radius={radius},size={valueCount}    `] = function(
		profiler: Profiler
	)
		for i = 1, QUERY_COUNT do
			octree:SearchRadius(queryPoints[i], radius)
		end
	end

	methods[`quad-search-radius;radius={radius},size={valueCount},capacity={capacity}`] = function(
		profiler: Profiler
	)
		for i = 1, QUERY_COUNT do
			tree:SearchRadius(queryPoints[i].X, queryPoints[i].Y, radius)
		end
	end
	-- methods[`quad-filter-search-radius`] = function()
	-- 	for i=1, QUERY_COUNT do
	-- 		tree:FilterSearchRadius(
	-- 			queryPoints[i].X, queryPoints[i].Y, QUERY_RADIUS,
	-- 			queryPoints[i].X, queryPoints[i].Y, FILTER_RADIUS
	-- 		)
	-- 	end
	-- end
	-- methods[`quad-search-region;wid={queryWidth},siz={valueCount},cap={capacity}`] = function()
	-- 	for i=1, QUERY_COUNT do
	-- 		tree:SearchRegion(
	-- 			queryPoints[i].X,
	-- 			queryPoints[i].Y,
	-- 			queryPoints[i].X+queryWidth,
	-- 			queryPoints[i].Y+queryWidth
	-- 		)
	-- 	end
	-- end
	-- methods[`quad-filter-search-region`] = function()
	-- 	for i=1, QUERY_COUNT do
	-- 		tree:FilterSearchRegion(
	-- 			queryPoints[i].X,
	-- 			queryPoints[i].Y,
	-- 			queryPoints[i].X+QUERY_WIDTH,
	-- 			queryPoints[i].Y+QUERY_WIDTH,
	-- 			queryPoints[i].X+QUERY_WIDTH*(FILTER_RATIO/2),
	-- 			queryPoints[i].Y+QUERY_WIDTH*(FILTER_RATIO/2),
	-- 			queryPoints[i].X+FILTER_WIDTH,
	-- 			queryPoints[i].Y+FILTER_WIDTH
	-- 		)
	-- 	end
	-- end
end
local defaultCapacity = 2
local defaultValue = 2048
local defaultRadius = 16

test(defaultCapacity, defaultValue, defaultRadius)

test(defaultCapacity * 0.5, defaultValue, defaultRadius)
test(defaultCapacity * 2, defaultValue, defaultRadius)

-- test(defaultCapacity, defaultValue, defaultRadius*0.25)
-- test(defaultCapacity, defaultValue, defaultRadius*0.5)
-- test(defaultCapacity, defaultValue, defaultRadius*2)
-- test(defaultCapacity, defaultValue, defaultRadius*4)

-- test(defaultCapacity*0.25, defaultValue*4, defaultRadius)
-- test(defaultCapacity*0.5, defaultValue*4, defaultRadius)
-- test(defaultCapacity*2, defaultValue*4, defaultRadius)
-- test(defaultCapacity*4, defaultValue*4, defaultRadius)

-- test(defaultCapacity*0.25, defaultValue*16, defaultRadius)
-- test(defaultCapacity*0.5, defaultValue*16, defaultRadius)
-- test(defaultCapacity*2, defaultValue*16, defaultRadius)
-- test(defaultCapacity*4, defaultValue*16, defaultRadius)

-- test(defaultCapacity, defaultValue*0.25, defaultRadius)
-- test(defaultCapacity, defaultValue*0.5, defaultRadius)
-- test(defaultCapacity, defaultValue*2, defaultRadius)
-- test(defaultCapacity, defaultValue*4, defaultRadius)

-- test(defaultCapacity, defaultValue, defaultRadius*0.25)
-- test(defaultCapacity, defaultValue, defaultRadius*0.5)
-- test(defaultCapacity, defaultValue, defaultRadius*2)
-- test(defaultCapacity, defaultValue, defaultRadius*4)

-- Class
return {
	Functions = methods,
}
