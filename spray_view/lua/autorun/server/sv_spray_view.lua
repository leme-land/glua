-- Potential issue with players joining and sprays not existing for them until re-sprayed, need to investigate

local vector_up = Vector(0, 0, 4)

local traceResult = {}

local traceData = {
    mask = MASK_SOLID_BRUSHONLY,
    collisiongroup = COLLISION_GROUP_NONE,
    output = traceResult
}


util.AddNetworkString("spray_view")

hook.Add("PlayerSpray", "spray_view", function(pPlayer)
    traceData.start = pPlayer:EyePos()
    traceData.start:Add(vector_up)

    traceData.endpos = pPlayer:GetForward()
    traceData.endpos:Mul(128)
    traceData.endpos:Add(traceData.start)

    util.TraceLine(traceData)

    net.Start("spray_view")
        net.WriteString(pPlayer:SteamID())
        net.WriteString(pPlayer:GetName())
        net.WriteVector(traceResult.HitPos)
        net.WriteVector(traceResult.HitNormal)
    net.Broadcast()
end)