--# made by InputValue
local Players = game:GetService('Players')

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Backpack = LocalPlayer:WaitForChild('Backpack')

local BuildingTools = nil
local ServerEndpoint = nil

function GetBuildingTools()
	local _Backpack = Backpack:GetChildren()
	for _, Tool in pairs(_Backpack) do
		
		if (Tool.ClassName ~= 'Tool') then
			continue
		end
		
		local SyncAPI = Tool:FindFirstChild('SyncAPI')
		if (SyncAPI ~= nil) then
			print('Found Building Tools')
			
			local _ServerEndpoint = SyncAPI:WaitForChild('ServerEndpoint')
			BuildingTools = Tool
			ServerEndpoint = _ServerEndpoint
			
			return
		else
			continue
		end
	end
end

function InvokeBuildingTools(Arguments)
	task.spawn(function()
		local Success, Error = pcall(function()
			ServerEndpoint:InvokeServer(unpack(Arguments))
		end)
		
		if (Success == false) then
			error(Error)
		end
	end)
end

local BuildingToolsActions = {
	CreatePart = function(PartType, _CFrame, Parent)
		
		print('Calling')
		local Arguments = {
			[1] = 'CreatePart',

			[2] = PartType,
			[3] = _CFrame,
			[4] = Parent
		}
		InvokeBuildingTools(Arguments)
	end,

	CreateConstraints = function(ConstraintType, Part1, Part2)
		local Arguments = {
			[1] = 'CreateConstraints',

			[2] = {
				[1] = Part1,
				[2] = Part2
			},
			[3] = {},

			[4] = Part1,
			[5] = ConstraintType
		}
		InvokeBuildingTools(Arguments)
	end,
	
	CreateMesh = function(Part)
		local Arguments = {
			[1] = 'CreateMeshes',
			[2] = {
				[1] = {
					['Part'] = Part
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,

	SetPartsParent = function(Parts, Parent)
		local Arguments = {
			[1] = 'SetParent',

			[2] = Parts,
			[3] = Parent
		}
		InvokeBuildingTools(Arguments)
	end,

	SetPartsName = function(Parts, Name)
		local Arguments = {
			[1] = 'SetName',

			[2] = Parts,
			[3] = Name
		}
		InvokeBuildingTools(Arguments)
	end,

	SetPartColor = function(Part, Color)
		local Arguments = {
			[1] = 'SyncColor',

			[2] = {
				[1] = {
					['Part'] = Part,
					['Color'] = Color
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,

	SetPartAnchor = function(Part, Boolean)
		local Arguments = {
			[1] = 'SyncAnchor',

			[2] = {
				[1] = {
					['Part'] = Part,
					['Anchored'] = Boolean
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,

	SetPartCollision = function(Part, Boolean)
		local Arguments = {
			[1] = 'SyncCollision',

			[2] = {
				[1] = {
					['Part'] = Part,
					['CanCollide'] = Boolean
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,

	ResizePart = function(Part, _CFrame, Vector)
		local Arguments = {
			[1] = 'SyncResize',

			[2] = {
				[1] = {
					['Part'] = Part,
					['CFrame'] = _CFrame,
					['Size'] = Vector
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,

	RotatePart = function(Part, _CFrame)
		local Arguments = {
			[1] = 'SyncRotate',

			[2] = {
				[1] = {
					['Part'] = Part,
					['CFrame'] = _CFrame
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,

	RemovePart = function(Part)
		local Arguments = {
			[1] = 'Remove',

			[2] = {
				[1] = Part
			}
		}
		InvokeBuildingTools(Arguments)
	end,

	MovePart = function(Part, _CFrame)
		local Arguments = {
			[1] = 'SyncMove',

			[2] = {
				[1] = {
					['Part'] = Part,
					['CFrame'] = _CFrame
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,
	
	UpdateMesh = function(Part, Properties)
		local Arguments = {
			[1] = 'SyncMesh',
			[2] = {
				[1] = {
					['Part'] = Part,
					unpack(Properties)
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,
	
	SetPartTransparency = function(Part, Transparency)
		local Arguments = {
			[1] = 'SyncMaterial',
			[2] = {
				[1] = {
					['Part'] = Part,
					['Transparency'] = Transparency
				}
			}
		}
		InvokeBuildingTools(Arguments)
	end,
}

local DefaultExplosionParent = Character.PrimaryPart

function GetCharacters(ExcludeLocal)
	local _Players = Players:GetPlayers()

	local Characters = {}
	for _, Player in pairs(_Players) do

		if (ExcludeLocal) then
			if (Player ~= LocalPlayer) then

				local Character = Player.Character or Player.CharacterAdded:Wait()
				table.insert(Characters, Character)
			end
		else
			local Character = Player.Character or Player.CharacterAdded:Wait()
			table.insert(Characters, Character)
		end
	end

	return Characters
end

function CreateExplosion(Parent, _CFrame, Size, Range, _Delay, AffectLocal)
	if (not BuildingTools) or (not ServerEndpoint) then
		return
	end

	local Explosion
	BuildingToolsActions.CreatePart(
		'Ball',
		_CFrame,

		DefaultExplosionParent
	);

	Explosion = DefaultExplosionParent:WaitForChild('Part')

	BuildingToolsActions.SetPartColor(Explosion, Color3.fromRGB(255, 180, 0))
	BuildingToolsActions.SetPartCollision(Explosion, false)

	Size = Vector3.new(Size, Size, Size)
	BuildingToolsActions.ResizePart(
		Explosion,
		_CFrame,

		Size
	)

	BuildingToolsActions.SetPartsParent({Explosion}, Parent)

	local Characters = GetCharacters(AffectLocal)
	print(Characters)
	for _, Character in pairs(Characters) do

		local CharacterRoot = Character.PrimaryPart
		local Distance = (CharacterRoot.CFrame.Position - _CFrame.Position).Magnitude

		if (Distance <= Range) then

			local Head = Character:WaitForChild('Head')
			BuildingToolsActions.RemovePart(Head)
		else
			continue
		end
	end
	
	local Parts = workspace:GetChildren()
	for _, Part in pairs(Parts) do
		
		if (Part:IsA('BasePart')) then
			if (Part.Name:find('Base')) then
				continue
			end
			
			local Distance = (Part.CFrame.Position - _CFrame.Position).Magnitude
			if (Distance <= Range) then
				
				BuildingToolsActions.SetPartAnchor(Part, false)
			end
		end
	end

	task.delay(_Delay, function()
		BuildingToolsActions.RemovePart(Explosion)
	end)
end

local CreatedLeg = nil

local ExplosionSize = 5
local ExplosionRange = 15

function CreateLeg()
	local Humanoid = Character:FindFirstChild('Humanoid'):: Humanoid
	if (Humanoid ~= nil) then
		
		local RigType = Humanoid.RigType
		if (RigType ~= Enum.HumanoidRigType.R6) then
			return
		end
	end
	
	--# Anchor player so it doesn't affect the leg
	local _Character = Character:GetChildren()
	for _, CharacterPart in pairs(_Character) do
		
		if (CharacterPart:IsA('BasePart')) then
			BuildingToolsActions.SetPartAnchor(CharacterPart, true)
		end
	end
 	
	local Torso = Character:FindFirstChild('Torso')
	local _Torso = Torso:GetChildren()
	
	local TargetJoint
	for _, Joint in pairs(_Torso) do
		
		if (Joint.ClassName ~= 'Motor6D') then
			continue
		end
		
		if (Joint.Name == 'Right Hip') then
			TargetJoint = Joint
			break
		end
	end
	
	local RightLeg = Character:FindFirstChild('Right Leg')
	local LegSize = RightLeg.Size
	
	local Leg

	BuildingToolsActions.CreatePart('Normal', CFrame.identity, Character)
	
	Leg = Character:WaitForChild('Part')
	BuildingToolsActions.SetPartColor(Leg, Color3.fromRGB())
	BuildingToolsActions.SetPartCollision(Leg, false)
	
	local LegCFrame = CFrame.new(TargetJoint.C1.Position, TargetJoint.C1.Position)
	BuildingToolsActions.ResizePart(Leg, CFrame.identity, LegSize)
	
	local NewLegCFrame = CFrame.new(
		LegCFrame.X,
		
		LegCFrame.Y + .7,
		LegCFrame.Z - 1.5
	)
	
	BuildingToolsActions.MovePart(Leg, NewLegCFrame * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0)))
	BuildingToolsActions.SetPartTransparency(Leg, 1)
	
	BuildingToolsActions.SetPartsName({Leg}, 'FakeLeg')
	BuildingToolsActions.CreateConstraints('Weld', RightLeg, Leg)
	
	BuildingToolsActions.SetPartAnchor(Leg, false)
	for _, CharacterPart in pairs(_Character) do

		if (CharacterPart:IsA('BasePart')) then
			BuildingToolsActions.SetPartAnchor(CharacterPart, false)
		end
	end
	
	local Tool = Instance.new('Tool')
	Tool.RequiresHandle = false
	Tool.Parent = Backpack

	Tool.Activated:Connect(function()
		BuildingToolsActions.SetPartTransparency(RightLeg, 1)
		BuildingToolsActions.SetPartTransparency(Leg, 0)
		
		local LegCFrame = Leg.CFrame
		local ExplosionPosition = LegCFrame.Position + (-LegCFrame.UpVector * (Leg.Size.Y/ 2 + 2.5))
		
		CreateExplosion(
			Leg, 
			CFrame.new(ExplosionPosition),

			ExplosionSize,
			ExplosionRange,
			.5,
			
			true
		)

		task.delay(.3, function()
			BuildingToolsActions.SetPartTransparency(RightLeg, 0)
			BuildingToolsActions.SetPartTransparency(Leg, 1)
		end)
	end)
end

GetBuildingTools()
task.wait(3)

CreateLeg()
