local sprays = {}

net.Receive("spray_view", function()
    if not LocalPlayer():IsAdmin() then return end -- It doesn't matter if this is bypassed, who cares if other people see sprays. Just to avoid inconvenience for other players

    local steamID = net.ReadString()
    local hitPos = net.ReadVector()

    if steamID:len() < 1 or hitPos:IsZero() then
        for i = #sprays, 1, -1 do
            if sprays[i].steamID == steamID then
                sprays[i].steamID = nil -- Empty table
                sprays[i].hitPos = nil

                table.remove(sprays, i)
            end
        end

        return
    end

    table.insert(sprays, {
        steamID = steamID,
        hitPos = hitPos
    })
end)

hook.Add("PostDrawHUD", "spray_view", function()
    local hitPos = LocalPlayer():GetEyeTrace().HitPos

    for i = 1, #sprays do
        if not sprays[i].hitPos then continue end -- Wtflip

        if hitPos:IsEqualTol(sprays[i].hitPos, 32) then
            surface.SetFont("BudgetLabel")
            surface.SetTextColor(255, 255, 255, 255)

            local tw, th = surface.GetTextSize(sprays[i].steamID)
            surface.SetTextPos((ScrW() / 2) - (tw / 2), (ScrH() / 2) - 256)
            surface.DrawText(sprays[i].steamID)

            break
        end
    end
end)