local sprays = {}
local mins = Vector(0, -32, -32)
local maxs = Vector(2, 32, 32)
local color_red = Color(255, 0, 0, 255)

local function RemoveSpray(steamID)
    for i = #sprays, 1, -1 do
        if steamID == nil or sprays[i].steamID == steamID then
            table.Empty(sprays[i])
            table.remove(sprays, i)
        end
    end
end

net.Receive("spray_view", function()
    if not LocalPlayer():IsAdmin() then return end -- It doesn't matter if this is bypassed, who cares if other people see sprays. Just to avoid inconvenience for other players

    local steamID = net.ReadString()
    local name = net.ReadString()
    local hitPos = net.ReadVector()
    local normal = net.ReadVector()

    RemoveSpray(steamID)

    if steamID:len() < 1 or name:len() < 1 or hitPos:IsZero() or normal:IsZero() then -- Player left or something went wrong
        return
    end

    local angle = normal:Angle()
    if angle.pitch > 0 or angle.pitch < -0 then
        angle:SnapTo("y", 90)
    end

    table.insert(sprays, {
        steamID = steamID,
        name = name,
        hitPos = hitPos,
        angle = angle
    })
end)

local function DrawCentered(x, y, text)
    local tw, th = surface.GetTextSize(text)
    surface.SetTextPos(x - (tw / 2), y)
    surface.DrawText(text)

    return y + th
end

hook.Add("PostDrawHUD", "spray_view", function()
    local localPlayer = LocalPlayer()
    local hitPos = localPlayer:GetEyeTrace().HitPos

    for i = #sprays, 1, -1 do
        if not sprays[i].hitPos then continue end -- Wtflip

        if hitPos:IsEqualTol(sprays[i].hitPos, 32) then
            if localPlayer:KeyDown(IN_ATTACK2) and not localPlayer:KeyDownLast(IN_ATTACK2) then
                table.remove(sprays, i)
                break
            end

            cam.Start2D()
                surface.SetFont("BudgetLabel")
                surface.SetTextColor(255, 255, 255, 255)

                local x = ScrW() / 2
                local y = (ScrH() / 2) - 256

                y = DrawCentered(x, y, sprays[i].steamID)
                y = DrawCentered(x, y, sprays[i].name)
                y = DrawCentered(x, y, "")

                local attack2 = input.LookupBinding("+attack2", true)

                if attack2 then
                    surface.SetTextColor(255, 0, 0, 255)
                    DrawCentered(x, y, string.format("Press %s to remove from local database", language.GetPhrase(attack2)))
                end
            cam.End2D()

            local view = render.GetViewSetup() -- Fix cam.Start3D sucking

            cam.Start3D(view.origin, view.angles, view.fov, view.x, view.y, view.width, view.height, view.znear, view.zfar)
                render.DrawWireframeBox(sprays[i].hitPos, sprays[i].angle, mins, maxs, color_red, true)
            cam.End3D()

            break
        end
    end
end)