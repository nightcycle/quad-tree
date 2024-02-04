--!strict
--!native
-- Services
-- Packages
-- Modules
-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- function getMag(x1: number, y1: number, x2: number, y2: number): number
-- 	local a = (x2 - x1)
-- 	local b = (y2 - y1)
-- 	return (a ^ 2 + b ^ 2) ^ (1 / 2)
-- end

function getIfCircleOverlaps(
	x1: number,
	y1: number,
	r1: number,
	x2: number,
	y2: number,
	r2: number
): boolean
	return (r1 + r2)^2 >= (x2-x1)^2 + (y2-y1)^2  -- r1 + r2 >= getMag(x1, y1, x2, y2)
end

function getIfCircleContains(
	inX: number,
	inY: number,
	inR: number,
	outX: number,
	outY: number,
	outR: number
): boolean
	return (outR - inR)^2 >= (outX-inX)^2 + (outY-inY)^2 --getMag(inX, inY, outX, outY)
end

function getIfCircleContainsPoint(
	pX: number,
	pY: number,
	cX: number,
	cY: number,
	radius: number
): boolean
	return (cX-pX)^2 + (cY-pY)^2 <= radius^2 --getMag(pX, pY, cX, cY) <= radius
end

function getIfOverlaps(
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

function getIfContains(
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
type Node<V> = {
	__index: Node<V>,
	Value: V,
	X: number,
	Y: number,
	GetIfContainedBy: (
		self: Node<V>,
		minX: number,
		minY: number,
		maxX: number,
		maxY: number
	) -> boolean,
	new: (x: number, y: number, value: V) -> Node<V>,
}

local Node = {} :: Node<any>
Node.__index = Node

function Node:GetIfContainedBy(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number
): boolean
	return self.X >= minX and self.X < maxX and self.Y >= minY and self.Y < maxY
end

function Node.new(x: number, y: number, value: unknown): Node<any>
	local self: Node<unknown> = setmetatable({}, Node) :: any
	self.X = x
	self.Y = y
	self.Value = value
	table.freeze(self)
	return self
end

-- QuadTree class
export type QuadTree<V> = {
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
	_Subdivide: (self: QuadTree<V>) -> (),
	_Insert: (self: QuadTree<V>, node: Node<V>) -> boolean,
	Insert: (self: QuadTree<V>, x: number, y: number, value: V) -> (), --inserts an item into the tree at a position
	_AddDescendants: (self: QuadTree<V>, array: {[number]: V}) -> (),
	_SearchRadius: (
		self: QuadTree<V>,
		x: number,
		y: number,
		radius: number,
		found: { [number]: Node<any> }
	) -> (),
	SearchRadius: (
		self: QuadTree<V>,
		x: number,
		y: number,
		radius: number
	) -> { [number]: V }, --gets all items in a radius
	_FilterSearchRadius: (
		self: QuadTree<V>,
		x: number,
		y: number,
		radius: number,
		fX: number,
		fY: number,
		fRadius: number,
		found: { [number]: Node<any> }
	) -> (),
	FilterSearchRadius: (
		self: QuadTree<V>,
		x: number,
		y: number,
		radius: number,
		fX: number,
		fY: number,
		fRadius: number
	) -> { [number]: V }, --gets all items in a ring, filtering out items within the inner filter radius
	_SearchRegion: (
		self: QuadTree<V>,
		minX: number,
		minY: number,
		maxX: number,
		maxY: number,
		found: { [number]: Node<any> }
	) -> (),
	SearchRegion: (
		self: QuadTree<V>,
		minX: number,
		minY: number,
		maxX: number,
		maxY: number
	) -> { [number]: V }, --gets all the items in a box
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
		found: { [number]: Node<any> }
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
	) -> { [number]: V }, -- get all the items in a rectangular ring, filtering out all the items in the inner rectangle
	new: (
		minX: number,
		minY: number,
		maxX: number,
		maxY: number,
		capacity: number
	) -> QuadTree<V>, -- creates a new quad tree, establishing the size of the area
}

local QuadTree = {} :: QuadTree<any>
QuadTree.__index = QuadTree

function QuadTree.new(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number,
	capacity: number
): QuadTree<any>
	local self: QuadTree<any> = setmetatable({}, QuadTree) :: any

	self._MinX = minX
	self._MinY = minY
	self._MaxX = maxX
	self._MaxY = maxY
	self._Width = self._MaxX - self._MinX
	self._Height = self._MaxY - self._MinY
	self._CenterX = self._MinX + self._Width / 2
	self._CenterY = self._MinY + self._Height / 2
	self._Radius = (((self._Width * 0.5) ^ 2) + ((self._Height * 0.5) ^ 2))
		^ (1 / 2)
	self._Capacity = capacity
	self._Nodes = table.create(0)
	return self
end

function QuadTree:_AddDescendants(array: {[number]: any}): ()
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

function QuadTree:_Insert(node: Node<any>): boolean
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

function QuadTree:Insert(x: number, y: number, value: any): ()
	return self:_Insert(Node.new(x, y, value))
end

function QuadTree:_SearchRegion(
	minX: number,
	minY: number,
	maxX: number,
	maxY: number,
	found: { [number]: Node<any> }
): ()
	if
		not getIfOverlaps(
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
): { [number]: any }
	local out: { [number]: any } = table.create(0)
	self:_SearchRegion(minX, minY, maxX, maxY, out)
	return out
end

function QuadTree:_SearchRadius(
	x: number,
	y: number,
	radius: number,
	found: { [number]: Node<any> }
): ()

	if getIfCircleContains(
		self._CenterX,
		self._CenterY,
		self._Radius,
		x,
		y,
		radius
	) then
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
): { [number]: any }
	local out: { [number]: any } = table.create(0)
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
	found: { [number]: Node<any> }
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
): { [number]: any }
	local out: { [number]: any } = table.create(0)
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
	found: { [number]: Node<any> }
): ()
	if
		not getIfOverlaps(
			self._MinX,
			self._MinY,
			self._MaxX,
			self._MaxY,
			minX,
			minY,
			maxX,
			maxY
		)
		or getIfContains(
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
): { [number]: any }
	local out: { [number]: any } = table.create(0)
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

return QuadTree
