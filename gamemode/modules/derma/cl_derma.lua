--[[
	Citadel Shock
	- DERMA MODULE -
]]

-- [[FONTS]]
local function CS_CreateFont(name, tbl)
	surface.CreateFont(name, tbl)
end

CS_CreateFont("CS_DERMA_TITLE",
{
	font = "Alegreya Sans SC",
	size = 18,
})

CS_CreateFont("CS_DERMA_XLG",
{
	font = "Alegreya Sans SC",
	size = 22,
})

CS_CreateFont("CS_DERMA_LG",
{
	font = "Alegreya Sans SC",
	size = 16,
})

CS_CreateFont("CS_DERMA_MD",
{
	font = "Alegreya Sans SC",
	size = 14,
})

CS_CreateFont("CS_DERMA_SM",
{
	font = "Alegreya Sans SC",
	size = 12,
})

local CSDerma = {}

-- [[CS Frame]]
CSDerma.frame = {}
CSDerma.frame.bgMat = Material("materials/citadelshock/gui/derma_grunge_panel.png", "noclamp smooth")

function CSDerma.frame:Init()
	self.title = {text = "DFrame", color = Color(255,255,255,255)}
	self:ShowCloseButton(false)
	self:SetTitle("")
end

function CSDerma.frame:ShowCSCloseButton(bool)
	if (bool) then
		self.closebutton = vgui.Create("CSCloseButton", self)
		self.closebutton:DermaToClose(self)
		self.closebutton:SetPos(self:GetWide() - (self.closebutton:GetWide() + 10), 5)
	end
end

function CSDerma.frame:SetTitleInfo(title, col)
	local col = (col or Color(255,255,255,255))

	self.title.text = title
	self.title.color = col
end

function CSDerma.frame:Paint()
	local w, h = self:GetWide(), self:GetTall()
	local texture_X, texture_Y = 0, 30
	
	surface.SetDrawColor( 0, 0, 0, 125 )
	surface.SetMaterial( self.bgMat	)
	surface.DrawTexturedRect( -3, texture_Y - 3, w + 6, (h - texture_Y) + 6)
	
	surface.SetDrawColor( 40, 40, 40, 255 )
	surface.SetMaterial( self.bgMat	)
	surface.DrawTexturedRect( texture_X, texture_Y, w, h - texture_Y)

	if (self.title) then
		draw.SimpleText( self.title.text, "CS_DERMA_TITLE", 7, 7, Color(12,12,12,200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( self.title.text, "CS_DERMA_TITLE", 5, 5, self.title.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end
end
vgui.Register("CSFrame", CSDerma.frame, "DFrame")

-- [[CS Button]]
CSDerma.button = {}
CSDerma.button.bgMat = ""

function CSDerma.button:Init()
	self.btext = "Button"
	self.brounded = true
	self:SetText("")
end

function CSDerma.button:SetBText(txt)
	return (self.btext or "NIL")
end

function CSDerma.button:SetBText(txt)
	self.btext = (txt or "Button")
end

function CSDerma.button:GetRounded(bool)
	return (self.brounded)
end

function CSDerma.button:SetRounded(bool)
	self.brounded = (bool)
end

function CSDerma.button:WarningActivate(wtxt)
	self.warningActive = true
	self.warningText = self.btext .. " (" .. wtxt .. ")"
end

function CSDerma.button:Paint()
	local bCol = Color(65,65,65,255)
	local hCol = Color(75,75,75,255)
	local btext = self.btext
	local w, h = self:GetWide(), self:GetTall()

	if (self.warningActive) then
		btext = self.warningText
		bCol = Color(185,100,100,255)
		hCol = Color(225,123,119,255)
	end

	if (self:IsHovered()) then
		bCol = hCol
	end
	
	if (self:GetDisabled()) then
		bCol = Color(40,40,40,255)
	end
	
	draw.RoundedBoxEx( 4, 0, 0, w, h, bCol, self.brounded, self.brounded, self.brounded, self.brounded)
	draw.SimpleText( btext, "CS_DERMA_LG", w/2 + 1, h/2 + 1, Color(12,12,12,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( btext, "CS_DERMA_LG", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
vgui.Register("CSButton", CSDerma.button, "DButton")

-- [[CS Close Button]]
CSDerma.closebutton = {}
CSDerma.closebutton.bgMat = ""

function CSDerma.closebutton:Init()
	self.dtclose = (self:GetParent() or nil)
	self:SetSize(25,15)
	self:SetText("")
	self:SetTooltip("Close")
end

function CSDerma.closebutton:DermaToClose(pnl)
	self.dtclose = pnl
end

function CSDerma.closebutton:DoClick()
	if (IsValid(self.dtclose)) then self.dtclose:Remove() end
end

function CSDerma.closebutton:Paint()
	local bCol, tCol = Color(200,64,64,255), Color(255,255,255,255)
	local w, h = self:GetWide(), self:GetTall()
	if (self:IsHovered()) then
		bCol = Color(220,84,84,255)
	end

	draw.RoundedBoxEx( 4, 0, 0, w, h, bCol, true, true, true, true)
	draw.SimpleText( "X", "CS_DERMA_TITLE", w/2, h/2 + 1, tCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end
vgui.Register("CSCloseButton", CSDerma.closebutton, "DButton")

-- [[Scroll Panel]]
CSDerma.scrollpanel = {}

function CSDerma.scrollpanel:Init() 
	local sbar = self:GetVBar()
	if (sbar) then
		function sbar:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35, 255 ) )
		end
		function sbar.btnUp:Paint( w, h )
			draw.RoundedBox( 4, 2, 2, w - 4, h - 4, Color( 65, 65, 65 ) )
		end
		function sbar.btnDown:Paint( w, h )
			draw.RoundedBox( 4, 2, 2, w - 4, h - 4, Color( 65, 65, 65 ) )
		end
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 4, 2, 2, w - 4, h - 4, Color( 45, 45, 45 ) )
		end
	end
end

vgui.Register("CSScrollPanel", CSDerma.scrollpanel, "DScrollPanel")

-- [[Text Entry]]
CSDerma.textentry = {}

function CSDerma.textentry:Init() 
	self.EntryInfo = "CSTextEntry"
	
	self:SetFont("CS_DERMA_LG")
end

function CSDerma.textentry:GetInfoText()
	return self.EntryInfo
end

function CSDerma.textentry:SetInfoText(val)
	self.EntryInfo = val
end

function CSDerma.textentry:Paint(w,h)
	draw.RoundedBox( 4, 0, 0, w, h, Color( 35, 35, 35 ) )
	
	if (self:GetValue():len() == 0 && !self:IsEditing()) then
		draw.SimpleText( self:GetInfoText(), "CS_DERMA_LG", 5, h/2, Color(255,255,255,125), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	
	self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
end

vgui.Register("CSTextEntry", CSDerma.textentry, "DTextEntry")