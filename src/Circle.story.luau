--!strict
local _Package = script.Parent
local _Packages = _Package.Parent
-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
-- Packages
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Maid"))
-- Modules
-- Types
-- Constants
local IMAGE_SIZE = 360
local POINT_SIZE = 2
local SCALE = 1.5
local CAPACITY = 4
local SAMPLE_SIZE = 1024 --4096
local SELECTION_RADIUS = 40
local FILTER_RADIUS = SELECTION_RADIUS / 2
-- Variables
-- References
-- Class
return function(frame: Frame)
	local maid = Maid.new()
	task.spawn(function()
		local QuadTree = require(script.Parent)
		type QuadTree<V> = QuadTree.QuadTree<V>

		local imageLabel = maid:GiveTask(Instance.new("ImageLabel"))
		imageLabel.Size = UDim2.fromOffset(IMAGE_SIZE*SCALE, IMAGE_SIZE*SCALE)

		local editableImage = maid:GiveTask(Instance.new("EditableImage"))
		editableImage.Size = Vector2.one * IMAGE_SIZE

		local tree = QuadTree.new(0,0,IMAGE_SIZE,IMAGE_SIZE, CAPACITY)
		for i=1, SAMPLE_SIZE do
			local point = Vector3.new(math.random(1, IMAGE_SIZE),math.random(1, IMAGE_SIZE))
			tree:Insert(point.X, point.Y, point)
		end

		local function update(pos: Vector2)

			local results = tree:FilterSearchRadius(
				pos.X,
				pos.Y,
				SELECTION_RADIUS,
				pos.X,
				pos.Y,
				FILTER_RADIUS
			)

			editableImage:DrawRectangle(Vector2.zero, editableImage.Size-Vector2.one, Color3.new(1,1,1), 0)

			local fullPoints: {[number]: Vector3} = {}
			local function drawNode(subTree: QuadTree<Vector3>?)
				if not subTree then return end
				assert(subTree)

				local origin = Vector2.new(
					math.clamp(math.round(subTree._MinX), 0, IMAGE_SIZE-1),
					math.clamp(math.round(subTree._MinY), 0, IMAGE_SIZE-1)
				)
				local size = Vector2.new(
					math.round(subTree._Width),
					math.round(subTree._Height)
				)
				size = Vector2.new(
					math.clamp(size.X, 1, IMAGE_SIZE-origin.X),
					math.clamp(size.Y, 1, IMAGE_SIZE-origin.Y)
				)

				if size.X > 0 and size.Y > 0 and origin.X >= 0 and origin.Y >= 0 then
					pcall(function()
						editableImage:DrawRectangle(
							origin,
							size,
							Color3.new(0,0,0),
							0
						)
					end)


					if size.X > 2 and size.Y > 2 then
						pcall(function()
							editableImage:DrawRectangle(
								origin+Vector2.one,
								size-Vector2.one-Vector2.one,
								Color3.new(1,1,1),
								0
							)
						end)

					end

					for i, v in pairs(subTree._Nodes) do

						-- pcall(function()
							table.insert(fullPoints, v.Value)
							-- editableImage:DrawRectangle(
							-- 	Vector2.new(math.round(v.X), math.round(v.Y))-(Vector2.one*POINT_SIZE*0.5),
							-- 	Vector2.one*POINT_SIZE,
							-- 	Color3.new(1,0,0),
							-- 	0
							-- )
						-- end)

					end

				end
				if subTree._Subdivisions then
					for i, child in ipairs(subTree._Subdivisions) do
						drawNode(child)
					end
				end
			end
			drawNode(tree)
			for i, v in ipairs(fullPoints) do
				pcall(function()
					editableImage:DrawRectangle(
						Vector2.new(math.round(v.X), math.round(v.Y))-(Vector2.one*POINT_SIZE*0.5),
						Vector2.one*POINT_SIZE,
						Color3.new(1,0,0),
						0
					)
				end)
			end
			pcall(function()
				editableImage:DrawCircle(
					pos,
					SELECTION_RADIUS,
					Color3.new(1,1,0),
					0.2
				)
			end)
			pcall(function()
				editableImage:DrawCircle(
					pos,
					FILTER_RADIUS,
					Color3.new(0,0,0),
					0.5
				)
			end)

			for i, v in pairs(results) do

				pcall(function()
					editableImage:DrawRectangle(
						Vector2.new(math.round(v.X), math.round(v.Y))-(Vector2.one*POINT_SIZE*0.5),
						Vector2.one*POINT_SIZE,
						Color3.new(0,0,1),
						0
					)
				end)

			end

		end

		local pos: Vector2?
		maid:GiveTask(UserInputService.InputChanged:Connect(function(inputObject: InputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
				pos = Vector2.new(inputObject.Position.X, inputObject.Position.Y) / SCALE
			end
		end))
		maid:GiveTask(RunService.RenderStepped:Connect(function()
			if pos then
				update(pos)
			else
				update(Vector2.zero)
			end
		end))

		editableImage.Parent = imageLabel
		imageLabel.Parent = frame

	end)
	return function()
		maid:Destroy()
	end
end