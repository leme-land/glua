local TYPE_SENT = 0
local TYPE_VEHICLE = 1
local TYPE_NPC = 2
local TYPE_WEAPON = 3
local TYPE_PROP = 4

local toolmode_allow_creator = GetConVar("toolmode_allow_creator")
local creator_arg = GetConVar("creator_arg")
local creator_name = GetConVar("creator_name")
local creator_type = GetConVar("creator_type")

local pMenu = nil

local function GetArgument()
	return creator_arg:GetString()
end

local function SetArgument(argument)
	if not isstring(argument) then argument = tostring(argument) end

	RunConsoleCommand(creator_arg:GetName(), argument)
end

local function GetName()
	return creator_name:GetString()
end

local function SetName(name)
	if not isstring(name) then name = tostring(name) end

	RunConsoleCommand(creator_name:GetName(), name)
end

local function GetType()
	return creator_type:GetInt()
end

local function SetType(type)
	if not isnumber(type) then type = tonumber(type) or TYPE_SENT end

	RunConsoleCommand(creator_type:GetName(), type)
end

local function CreateRow(contentPanel, left, right)
	local row = vgui.Create("DPanel", contentPanel)

	row:SetPaintBackground(false)

	left:SetParent(row)
	left:SetContentAlignment(6)
	right:SetParent(row)
	right:SetContentAlignment(4)

	row.left = left
	row.right = right

	function row:PerformLayout(width, height)
		local centerX = width / 3
		local centerY = height / 2

		self.left:SetX(centerX - (self.left:GetWide() + 5))
		self.left:SetY(centerY - (self.left:GetTall() / 2))

		self.right:SetX(centerX + 5)
		self.right:SetY(centerY - (self.right:GetTall() / 2))
		self.right:SetWide(width - self.right:GetX())
	end

	return row
end

local function PopulateMenu(frame, contentPanel)
	contentPanel.rows = {}

	do
		local label_type = vgui.Create("DLabel", contentPanel)

		label_type:SetDark(true)
		label_type:SetText("Creator Type")
		surface.SetFont(label_type:GetFont())
		label_type:SetSize(surface.GetTextSize(label_type:GetText()))

		local currentType = GetType()
		local dropdown_type = vgui.Create("DComboBox", contentPanel)

		dropdown_type:SetSortItems(false)
		dropdown_type:AddChoice("Scripted Entity", TYPE_SENT, currentType == TYPE_SENT)
		dropdown_type:AddChoice("Vehicle", TYPE_VEHICLE, currentType == TYPE_VEHICLE)
		dropdown_type:AddChoice("NPC", TYPE_NPC, currentType == TYPE_NPC)
		dropdown_type:AddChoice("Weapon", TYPE_WEAPON, currentType == TYPE_WEAPON)
		dropdown_type:AddChoice("Prop", TYPE_PROP, currentType == TYPE_PROP)

		function dropdown_type:OnSelect(_, _, data)
			SetType(data)
		end

		table.insert(contentPanel.rows, CreateRow(contentPanel, label_type, dropdown_type))
	end

	do
		local label_arguemnt = vgui.Create("DLabel", contentPanel)

		label_arguemnt:SetDark(true)
		label_arguemnt:SetText("Creator Argument")
		surface.SetFont(label_arguemnt:GetFont())
		label_arguemnt:SetSize(surface.GetTextSize(label_arguemnt:GetText()))

		local textbox_argument = vgui.Create("DTextEntry", contentPanel)

		textbox_argument:SetText(GetArgument())
		textbox_argument:SetUpdateOnType(true)

		function textbox_argument:OnValueChange(text)
			SetArgument(text)
		end

		table.insert(contentPanel.rows, CreateRow(contentPanel, label_arguemnt, textbox_argument))
	end

	do
		local label_name = vgui.Create("DLabel", contentPanel)

		label_name:SetDark(true)
		label_name:SetText("Creator Item Name")
		surface.SetFont(label_name:GetFont())
		label_name:SetSize(surface.GetTextSize(label_name:GetText()))

		local textbox_name = vgui.Create("DTextEntry", contentPanel)

		textbox_name:SetText(GetName())
		textbox_name:SetUpdateOnType(true)

		function textbox_name:OnValueChange(text)
			SetName(text)
		end

		table.insert(contentPanel.rows, CreateRow(contentPanel, label_name, textbox_name))
	end

	function contentPanel:PerformLayout(width, height)
		local rowCount = #self.rows
		local left, top, right, bottom = self:GetDockPadding()

		local setupHeight = height - (top + bottom)

		local sectionOffset = (((top + bottom) / 2) / rowCount) * (rowCount - 1)
		local sectionWidth = width - (left + right)
		local sectionHeight = (setupHeight / rowCount) - sectionOffset

		local step = sectionHeight + 5

		for i = 1, rowCount do
			local row = self.rows[i]
			if not row:IsValid() then continue end

			row:SetPos(left, top)
			row:SetSize(sectionWidth, sectionHeight)

			top = top + step
		end
	end
end

local function GetSpawnableEntities()
	local dataList = list.Get("SpawnableEntities")

	local isAdmin = LocalPlayer():IsAdmin()

	local data = {}

	for k, v in next, dataList do
		if not isAdmin and v.AdminOnly then continue end
		local name = v.PrintName or v.ClassName
		local class = v.ClassName or k

		data[class] = name
	end

	return data
end

local function GetVehicleList()
	local dataList = list.Get("Vehicles")

	local data = {}

	for k, v in next, dataList do
		local name = v.Name or v.Class
		local class = v.Class or k

		data[class] = name
	end

	return data
end

local function GetNPCWeaponList()
	local dataList = list.Get("NPCUsableWeapons")

	local data = {}

	for i = 1, #dataList do
		local currentItem = dataList[i]

		if not isstring(currentItem.class) then continue end
		if not isstring(currentItem.title) then continue end
		if data[currentItem.class] then continue end

		data[currentItem.class] = currentItem.title
	end

	return data
end

local function GetSpawnableWeapons()
	local dataList = list.Get("Weapon")

	local data = {}

	for k, v in next, dataList do
		if not v.Spawnable then continue end
		local name = v.PrintName or v.ClassName
		local class = v.ClassName or k

		data[class] = name
	end

	return data
end

local function OpenItemList(title, data)
	local frame = vgui.Create("DFrame")

	frame:SetSize(250, 300)
	frame:SetTitle(title)
	frame:Center()

	local displayList = vgui.Create("DScrollPanel", frame)

	displayList:Dock(FILL)

	local function OnButtonClick(self)
		SetClipboardText(self.class)
	end

	for k, v in next, data do
		local button = vgui.Create("DButton", displayList)

		button:Dock(TOP)
		button:SetText(language.GetPhrase(v))
		button:SetTooltip("Click to copy to clipboard")
		button.class = k
		button.DoClick = OnButtonClick

		displayList:AddItem(button)
	end

	frame:MakePopup()
end

local function OpenMenu()
	local frame = vgui.Create("DFrame")

	frame:SetSizable(true)
	frame:SetSize(400, 400)
	frame:SetMinimumSize(frame:GetSize())
	frame:SetTitle("Creator Modifier")
	frame:Center()

	local menuBar = vgui.Create("DMenuBar", frame)

	local menuBar_menu = menuBar:AddMenu("Menu")

	menuBar_menu:AddOption("Show Spawnable Entities", function()
		OpenItemList("Spawnable Entities", GetSpawnableEntities())
	end)

	menuBar_menu:AddOption("Show Spawnable Vehicles", function()
		OpenItemList("Spawnable Vehicles", GetVehicleList())
	end)

	menuBar_menu:AddOption("Show NPC Usable Weapons", function()
		OpenItemList("NPC Usable Weapons", GetNPCWeaponList())
	end)

	menuBar_menu:AddOption("Show Spawnable Weapons", function()
		OpenItemList("Spawnable Weapons", GetSpawnableWeapons())
	end)

	local contentPanel = vgui.Create("DPanel", frame)

	contentPanel:DockPadding(5, 5, 5, 5)

	frame.menuBar = menuBar
	frame.contentPanel = contentPanel

	frame.m_fPerformLayout = frame.PerformLayout
	function frame:PerformLayout(width, height)
		self:m_fPerformLayout(width, height)

		local left, top, right, bottom = self:GetDockPadding()

		self.menuBar:SetPos(0, top)
		self.menuBar:SetSize(width, 20)

		self.contentPanel:SetPos(left, top + self.menuBar:GetTall() + 2)
		self.contentPanel:SetSize(width - (left + right), height - (top + bottom + (self.contentPanel:GetY() - top)))
	end

	if toolmode_allow_creator:GetBool() then
		PopulateMenu(frame, contentPanel)
	else
		local label = vgui.Create("DLabel", contentPanel)

		label:Dock(FILL)
		label:SetContentAlignment(5)
		label:SetDark(true)
		label:SetText("Creator tool is disabled on this server")
	end

	pMenu = frame
	frame:MakePopup()
end

concommand.Add("creator_modifier", function()
	if not IsValid(pMenu) then
		OpenMenu()
	end
end)