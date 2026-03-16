if _G.SevereClickTeleport == nil then
    _G.SevereClickTeleport = true
    
    local player = game:GetService("Players").LocalPlayer
    local uis = game:GetService("UserInputService")
    local camera = workspace.CurrentCamera
    
    local function isLeftCtrlDown()
        local keys = getpressedkeys() or {}
        for _, k in ipairs(keys) do
            local keyName = tostring(k):lower()
            if keyName:find("control") or keyName:find("ctrl") then
                return true
            end
        end
        return false
    end
    
    task.spawn(function()
        while _G.SevereClickTeleport do
            if isleftclicked() and isLeftCtrlDown() then
                local mouseLoc = uis:GetMouseLocation()
                local vpSize = camera.ViewportSize
                
                local relX = (mouseLoc.X / vpSize.X) * 2 - 1
                local relY = (mouseLoc.Y / vpSize.Y) * -2 + 1
                
                local fov = camera.FieldOfView
                local tanHalf = math.tan(math.rad(fov / 2))
                local aspect = vpSize.X / vpSize.Y
                
                local dir = -(camera.CFrame.LookVector + 
                             (camera.CFrame.RightVector * relX * tanHalf * aspect) + 
                             (camera.CFrame.UpVector * relY * tanHalf))
                
                local char = player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(camera.CFrame.Position + (dir * 70))
                    root.Velocity = Vector3.new(0, 0, 0)
                end
                task.wait(0.3)
            end
            task.wait(0.05)
        end
    end)
else
    _G.SevereClickTeleport = not _G.SevereClickTeleport
end
