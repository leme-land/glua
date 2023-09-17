-- Potential issue with players joining and sprays not existing for them until re-sprayed, need to investigate

util.AddNetworkString("spray_view")

hook.Add("PlayerSpray", "spray_view", function(pPlayer)
    local tr = pPlayer:GetEyeTraceNoCursor()

    net.Start("spray_view")
        net.WriteString(pPlayer:SteamID())
        net.WriteVector(tr.HitPos)
    net.Broadcast()
end)

hook.Add("PlayerDisconnected", "spray_view", function(pPlayer)
    net.Start("spray_view")
        net.WriteString(pPlayer:SteamID())
    net.Broadcast()
end)