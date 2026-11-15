local CameraObject = game.Workspace.CameraFolder:WaitForChild("CameraPart")
local Camera = game.Workspace.CurrentCamera

local SpaceCraft = game.Workspace:WaitForChild("SpaceCraft")
local SpectateButton = script.Parent:WaitForChild("SpectateButton")

local cameraMode = false
local LastFrame = Camera.CFrame

local upkey = false
local downkey = false
local leftkey = false
local rightkey = false

local CameraZoomSensitivity = 5
local CameraScrollSensitivity = 50

Camera.CameraType = Enum.CameraType.Scriptable
Camera.CFrame = CameraObject.CFrame

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

mouse.WheelForward:Connect(function()
	
	Camera.CFrame = Camera.CFrame + Camera.CFrame.LookVector * CameraZoomSensitivity
	
end)

mouse.WheelBackward:Connect(function()

	Camera.CFrame = Camera.CFrame + Camera.CFrame.LookVector * -CameraZoomSensitivity

end)



UserInputService.InputBegan:Connect(function(input)
	
	if input.KeyCode == Enum.KeyCode.Up then
		
		upkey = true
		
	end
	if input.KeyCode == Enum.KeyCode.Down then

		downkey = true

	end
	if input.KeyCode == Enum.KeyCode.Right then

		rightkey = true

	end
	if input.KeyCode == Enum.KeyCode.Left then

		leftkey = true

	end
	
	
end)

UserInputService.InputEnded:Connect(function(input)
	
	if input.KeyCode == Enum.KeyCode.Up then
		
		upkey = false
		
	end
	if input.KeyCode == Enum.KeyCode.Down then

		downkey = false

	end
	if input.KeyCode == Enum.KeyCode.Right then

		rightkey = false

	end
	if input.KeyCode == Enum.KeyCode.Left then

		leftkey = false

	end
	
end)

RunService.RenderStepped:Connect(function(dt)
	
	if upkey then
		
		Camera.CFrame = Camera.CFrame + Vector3.new(0, 0, -CameraScrollSensitivity)
		
	end
	if downkey then

		Camera.CFrame = Camera.CFrame + Vector3.new(0, 0, CameraScrollSensitivity)

	end
	if rightkey then

		Camera.CFrame = Camera.CFrame + Vector3.new(CameraScrollSensitivity, 0, 0)

	end
	if leftkey then

		Camera.CFrame = Camera.CFrame + Vector3.new(-CameraScrollSensitivity, 0, 0)

	end
	
	
	
end)
	
mouse.Button1Down:Connect(function()
	
	
	local mousepos = mouse.Hit.Position

    SpaceCraft.Position = mousepos

end)

SpectateButton.MouseButton1Down:Connect(function()
	
	if cameraMode == false then
		cameraMode = true
		LastFrame = Camera.CFrame
	Camera.CameraSubject = SpaceCraft
	Camera.CameraType = Enum.CameraType.Custom
	else
		cameraMode = false
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = LastFrame
	end
	
end)
