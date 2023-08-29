local cam_End2D = cam.End2D
local cam_Start2D = cam.Start2D
local draw_GetFontHeight = draw.GetFontHeight
local input_GetKeyName = input.GetKeyName
local input_IsButtonDown = input.IsButtonDown
local language_GetPhrase = language.GetPhrase
local math_max = math.max
local surface_DrawOutlinedRect = surface.DrawOutlinedRect
local surface_DrawRect = surface.DrawRect
local surface_DrawText = surface.DrawText
local surface_GetTextSize = surface.GetTextSize
local surface_SetDrawColor = surface.SetDrawColor
local surface_SetFont = surface.SetFont
local surface_SetTextColor = surface.SetTextColor
local surface_SetTextPos = surface.SetTextPos
local BUTTON_CODE_COUNT = BUTTON_CODE_COUNT

local movement_display_enabled = CreateClientConVar("movement_display_enabled", 1, true, false, "Enable/Disable the movement display", 0, 1)
local movement_display_background = CreateClientConVar("movement_display_background", 1, true, false, "Enable/Disable background", 0, 1)

local SCREEN_WIDTH = ScrW()
local SCREEN_HEIGHT = ScrH()

local activeKeys = {}

hook.Add("DrawOverlay", "movement_display", function()
	if not movement_display_enabled:GetBool() then return end

	local DO_BACKGROUND = movement_display_background:GetBool()

	for i = 1, #activeKeys do activeKeys[i] = nil end

	surface_SetFont("BudgetLabel")
	surface_SetTextColor(255, 255, 255, 255)

	cam_Start2D()
		local width = 0

		for i = 1, BUTTON_CODE_COUNT do
			if input_IsButtonDown(i) then
				local keyName = input_GetKeyName(i)
				keyName = language_GetPhrase(keyName):upper()

				activeKeys[#activeKeys + 1] = keyName

				if DO_BACKGROUND then
					local tw, _ = surface_GetTextSize(keyName)
					width = math_max(width, tw)
				end
			end
		end

		if #activeKeys > 0 then
			local xPos = SCREEN_WIDTH - 100
			local yPos = SCREEN_HEIGHT - 150

			if DO_BACKGROUND then
				local fontHeight = draw_GetFontHeight("BudgetLabel")
				local height = fontHeight * #activeKeys

				local rectOffset = fontHeight * (#activeKeys - 1) -- I don't know why it's needed but it is
				local rectX = xPos - 5
				local rectY = (yPos - rectOffset) - 5
				local rectWidth = width + 10
				local rectHeight = height + 10

				surface_SetDrawColor(50, 50, 50, 150)
				surface_DrawRect(rectX, rectY, rectWidth, rectHeight)

				surface_SetDrawColor(0, 0, 0, 255)
				surface_DrawOutlinedRect(rectX, rectY, rectWidth, rectHeight)
			end

			for i = 1, #activeKeys do
				surface_SetTextPos(xPos, yPos)
				surface_DrawText(activeKeys[i])

				local _, th = surface_GetTextSize(activeKeys[i])
				yPos = yPos - th
			end
		end
	cam_End2D()
end)

hook.Add("OnScreenSizeChanged", "movement_display", function()
	SCREEN_WIDTH = ScrW()
	SCREEN_HEIGHT = ScrH()
end)