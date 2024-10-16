--!strict
--!native
-- Services
-- Packages
-- Modules
-- Types
type NodeImpl<V> = {
	__index: NodeImpl<V>,
	GetIfContainedBy: (
		self: Node<V>,
		minX: number,
		minY: number,
		maxX: number,
		maxY: number
	) -> boolean,
	new: (x: number, y: number, value: V) -> Node<V>,
}
type Node<V> = typeof(setmetatable(
	{} :: {
		Value: V,
		X: number,
		Y: number,
	},
	{} :: NodeImpl<V>
))
type QuadTreeImpl<V> = {
	__index: QuadTreeImpl<V>,
	_Subdivide: (self: QuadTree<V>) -> (),
	_Insert: (self: QuadTree<V>, node: Node<V>) -> boolean,
	Insert: (
		self: QuadTree<V>,
		x: number,
		y: number,
		value: V
	) -> (), --inserts an item into the tree at a position
	_AddDescendants: (self: QuadTree<V>, array: { V }) -> (),
	_SearchRadius: (
		self: QuadTree<V>,
		x: number,
		y: number,
		radius: number,
		found: { V }
	) -> (),
	SearchRadius: (
		self: QuadTree<V>,
		x: number,
		y: number,
		radius: number
	) -> { V }, --gets all items in a radius
	_FilterSearchRadius: (
		self: QuadTree<V>,
		x: number,
		y: number,
		radius: number,
		fX: number,
		fY: number,
		fRadius: number,
		found: { V }
	) -> (),
	FilterSearchRadius: (
		self: QuadTree<V>,
		x: number,
		y: number,
		radius: number,
		fX: number,
		fY: number,
		fRadius: number
	) -> { V }, --gets all items in a ring, filtering out items within the inner filter radius
	_SearchRegion: (
		self: QuadTree<V>,
		minX: number,
		minY: number,
		maxX: number,
		maxY: number,
		found: { V }
	) -> (),
	SearchRegion: (
		self: QuadTree<V>,
		minX: number,
		minY: number,
		maxX: number,
		maxY: number
	) -> { V }, --gets all the items in a box
	_FilterSearchRegion: (
		self: QuadTree<V>,
		minX: number,
		minY: number,
		maxX: number,
		maxY: number,
		fMinX: number,
		fMinY: number,
		fMaxX: number,
		fMaxY: number,
		found: { V }
	) -> (),
	FilterSearchRegion: (
		self: QuadTree<V>,
		minX: number,
		minY: number,
		maxX: number,
		maxY: number,
		fMinX: number,
		fMinY: number,
		fMaxX: number,
		fMaxY: number
	) -> { V }, -- get all the items in a rectangular ring, filtering out all the items in the inner rectangle
	new: (
		minX: number,
		minY: number,
		maxX: number,
		maxY: number,
		capacity: number
	) -> QuadTree<V>, -- creates a new quad tree, establishing the size of the area
}

export type QuadTree<V> = typeof(setmetatable(
	{} :: {
		__index: QuadTree<V>,
		_MinX: number,
		_MinY: number,
		_MaxX: number,
		_MaxY: number,
		_Width: number,
		_Height: number,
		_Radius: number,
		_CenterX: number,
		_CenterY: number,
		_Capacity: number,
		_Nodes: { [number]: Node<V> },
		_Subdivisions: { [number]: QuadTree<V> }?,
	},
	{} :: QuadTreeImpl<V>
))
-- Constants
-- Variables
-- References
-- Private Functions
function getDistance(x1: number, y1: number, x2: number, y2: number): number
	local a = (x2 - x1)
	local b = (y2 - y1)
	return ((a ^ 2) + (b ^ 2)) ^ 0.5
end

function getIfCircleOverlaps(
	x1: number,
	y1: number,
	r1: number,
	x2: number,
	y2: number,
	r2: number
): boolean
	return (r1 + r2) >= getDistance(x1, y1, x2, y2)
end

function getIfCircleContains(
	inX: number,
	inY: number,
	inR: number,
	outX: number,
	outY: number,
	outR: number
): boolean
	return outR >= getDistance(inX, inY, outX, outY) + inR
end

function getIfCircleContainsPoint(
	pX: number,
	pY: number,
	cX: number,
	cY: number,
	radius: number
): boolean
	return getDistance(pX, pY, cX, cY) <= radius
end

function getIfBoxOverlaps(
	aMinX: number,
	aMinY: number,
	aMaxX: number,
	aMaxY: number,
	bMinX: number,
	bMinY: number,
	bMaxX: number,
	bMaxY: number
): boolean
	return (aMinX < bMaxX)
		and (aMaxX > bMinX)
		and (aMinY < bMaxY)
		and (aMaxY > bMinY)
end

function getIfBoxContains(
	insideMinX: number,
	insideMinY: number,
	insideMaxX: number,
	insideMaxY: number,
	outsideMinX: number,
	outsideMinY: number,
	outsideMaxX: number,
	outsideMaxY: number
): boolean
	return insideMinX >= outsideMinX
		and insideMaxX <= outsideMaxX
		and insideMinY >= outsideMinY
		and insideMaxY <= outsideMaxY
end

-- Node class
local Node: NodeImpl<unknown> = {} :: any
Node.__index = Node

function Node:GetIfContainedBy(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number
): boolean
	return self.X >= minX and self.X < maxX and self.Y >= minY and self.Y < maxY
end

function Node.new(x: number, y: number, value: unknown): Node<unknown>
	local self: Node<unknown> = setmetatable({}, Node) :: any
	self.X = x
	self.Y = y
	self.Value = value
	table.freeze(self)
	return self
end

-- QuadTree class

local QuadTree: QuadTree<unknown> = {} :: any
QuadTree.__index = QuadTree

function QuadTree.new(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number,
	capacity: number
): QuadTree<unknown>
	local self: QuadTree<unknown> = setmetatable({}, QuadTree) :: any

	self._MinX = minX
	self._MinY = minY
	self._MaxX = maxX
	self._MaxY = maxY
	self._Width = self._MaxX - self._MinX
	self._Height = self._MaxY - self._MinY
	self._CenterX = self._MinX + self._Width / 2
	self._CenterY = self._MinY + self._Height / 2
	self._Radius = getDistance(self._MinX, self._MinY, self._MaxX, self._MaxY)
		/ 2
	self._Capacity = capacity
	self._Nodes = table.create(0)
	return self
end

function QuadTree:_AddDescendants(array: { unknown }): ()
	for i, v in ipairs(self._Nodes) do
		table.insert(array, v)
	end
	local subs = self._Subdivisions
	if subs then
		for i, sub in ipairs(subs) do
			sub:_AddDescendants(array)
		end
	end
end

function QuadTree:_Subdivide()
	assert(self._Subdivisions == nil, `already subdivided`)
	self._Subdivisions = {
		QuadTree.new(
			self._CenterX,
			self._CenterY,
			self._MaxX,
			self._MaxY,
			self._Capacity
		),
		QuadTree.new(
			self._CenterX,
			self._MinY,
			self._MaxX,
			self._CenterY,
			self._Capacity
		),
		QuadTree.new(
			self._MinX,
			self._MinY,
			self._CenterX,
			self._CenterY,
			self._Capacity
		),
		QuadTree.new(
			self._MinX,
			self._CenterY,
			self._CenterX,
			self._MaxY,
			self._Capacity
		),
	}
end

function QuadTree:_Insert(node: Node<unknown>): boolean
	if
		not node:GetIfContainedBy(
			self._MinX,
			self._MinY,
			self._MaxX,
			self._MaxY
		)
	then
		return false
	end

	if #self._Nodes < self._Capacity then
		table.insert(self._Nodes, node)
		return true
	else
		if not self._Subdivisions then
			self:_Subdivide()
		end
		local subdivisions = self._Subdivisions
		assert(subdivisions)
		if node.X < self._CenterX then
			if node.Y < self._CenterY then
				return subdivisions[3]:_Insert(node)
			else
				return subdivisions[4]:_Insert(node)
			end
		else
			if node.Y < self._CenterY then
				return subdivisions[2]:_Insert(node)
			else
				return subdivisions[1]:_Insert(node)
			end
		end
	end
end

function QuadTree:Insert(x: number, y: number, value: unknown): ()
	return self:_Insert(Node.new(x, y, value))
end

function QuadTree:_SearchRegion(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number,
	found: { unknown }
): ()
	if
		not getIfBoxOverlaps(
			self._MinX,
			self._MinY,
			self._MaxX,
			self._MaxY,
			minX,
			minY,
			maxX,
			maxY
		)
	then
		return
	end
	for _, node in ipairs(self._Nodes) do
		if node:GetIfContainedBy(minX, minY, maxX, maxY) then
			table.insert(found, node.Value)
		end
	end

	if self._Subdivisions then
		for i, child in ipairs(self._Subdivisions) do
			child:_SearchRegion(minX, minY, maxX, maxY, found)
		end
	end
end

function QuadTree:SearchRegion(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number
): { unknown }
	local out: { unknown } = table.create(0)
	self:_SearchRegion(minX, minY, maxX, maxY, out)
	return out
end

function QuadTree:_SearchRadius(
	x: number,
	y: number,
	radius: number,
	found: { unknown }
): ()
	if
		getIfCircleContains(
			self._CenterX,
			self._CenterY,
			self._Radius,
			x,
			y,
			radius
		)
	then
		self:_AddDescendants(found)
		return
	end

	if
		not getIfCircleOverlaps(
			self._CenterX,
			self._CenterY,
			self._Radius,
			x,
			y,
			radius
		)
	then
		return
	end

	for _, node in ipairs(self._Nodes) do
		if getIfCircleContainsPoint(node.X, node.Y, x, y, radius) then
			table.insert(found, node.Value)
		end
	end

	if self._Subdivisions then
		for i, child in ipairs(self._Subdivisions) do
			child:_SearchRadius(x, y, radius, found)
		end
	end
end

function QuadTree:SearchRadius(
	x: number,
	y: number,
	radius: number
): { unknown }
	local out: { unknown } = table.create(0)
	self:_SearchRadius(x, y, radius, out)
	return out
end

function QuadTree:_FilterSearchRadius(
	x: number,
	y: number,
	radius: number,
	fX: number,
	fY: number,
	fRadius: number,
	found: { unknown }
): ()
	if
		not getIfCircleOverlaps(
			self._CenterX,
			self._CenterY,
			self._Radius,
			x,
			y,
			radius
		)
		or getIfCircleContains(
			self._CenterX,
			self._CenterY,
			self._Radius,
			fX,
			fY,
			fRadius
		)
	then
		return
	end

	for _, node in ipairs(self._Nodes) do
		if getIfCircleContainsPoint(node.X, node.Y, x, y, radius) then
			if
				not getIfCircleContainsPoint(node.X, node.Y, fX, fY, fRadius)
			then
				table.insert(found, node.Value)
			end
		end
	end

	if self._Subdivisions then
		for i, child in ipairs(self._Subdivisions) do
			child:_FilterSearchRadius(x, y, radius, fX, fY, fRadius, found)
		end
	end
end

function QuadTree:FilterSearchRadius(
	x: number,
	y: number,
	radius: number,
	fX: number,
	fY: number,
	fRadius: number
): { unknown }
	local out: { unknown } = table.create(0)
	self:_FilterSearchRadius(x, y, radius, fX, fY, fRadius, out)
	return out
end

function QuadTree:_FilterSearchRegion(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number,
	fMinX: number,
	fMinY: number,
	fMaxX: number,
	fMaxY: number,
	found: { unknown }
): ()
	if
		not getIfBoxOverlaps(
			self._MinX,
			self._MinY,
			self._MaxX,
			self._MaxY,
			minX,
			minY,
			maxX,
			maxY
		)
		or getIfBoxContains(
			self._MinX,
			self._MinY,
			self._MaxX,
			self._MaxY,
			fMinX,
			fMinY,
			fMaxX,
			fMaxY
		)
	then
		return
	end

	for _, node in ipairs(self._Nodes) do
		if
			node:GetIfContainedBy(minX, minY, maxX, maxY)
			and not node:GetIfContainedBy(fMinX, fMinY, fMaxX, fMaxY)
		then
			table.insert(found, node.Value)
		end
	end

	if self._Subdivisions then
		for i, child in ipairs(self._Subdivisions) do
			child:_FilterSearchRegion(
				minX,
				minY,
				maxX,
				maxY,
				fMinX,
				fMinY,
				fMaxX,
				fMaxY,
				found
			)
		end
	end
end

function QuadTree:FilterSearchRegion(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number,
	fMinX: number,
	fMinY: number,
	fMaxX: number,
	fMaxY: number
): { unknown }
	local out: { unknown } = table.create(0)
	self:_FilterSearchRegion(
		minX,
		minY,
		maxX,
		maxY,
		fMinX,
		fMinY,
		fMaxX,
		fMaxY,
		out
	)
	return out
end

return {
	new = function<V>(
		minX: number,
		minY: number,
		maxX: number,
		maxY: number,
		capacity: number
	): QuadTree<V>
		return QuadTree.new(minX, minY, maxX, maxY, capacity) :: any
	end,
}
