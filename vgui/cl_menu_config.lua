if SERVER then return end

local PANEL = {}

-- TODO : Menu déroulant pour les classes d'entités immunisés à l'effet
-- TODO : Menu déroulant pour les jobs de joueur immunisés à l'effet

function PANEL:Init()

    self:SetSize(SCP_235_CONFIG.ScrW , SCP_235_CONFIG.ScrH )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )
    self.ActualMode = ply.Scramble_GetModeMenu or 1
    local width, height = self:GetSize()

    ParentMenu.Body = self:Add("EditablePanel") -- Body Pannel where it contain all the parameters
    ParentMenu.Body:SetSize(width - (width * 0.1), height - (height * 0.08))
    ParentMenu.Body:SetPos(width * 0.1, height * 0.08)
    function ParentMenu.Body:Paint(width, height)
        local ColorPannel = Color(84, 84, 84)
        draw.RoundedBoxEx(0, 0, 0, width, height, ColorPannel, false , false, true, true)
    end

    ParentMenu.LeftBody = ParentMenu:Add("EditablePanel") -- Left Pannel where you choose the mode
    ParentMenu.LeftBody:SetSize(width * 0.1, HeightParent - (height * 0.08))
    ParentMenu.LeftBody:SetPos(0,  height * 0.08)
    function ParentMenu.LeftBody:Paint(width, height)
        local ColorPannel = Color(115, 115, 115)
        draw.RoundedBoxEx(5, 0, 0, width, height, ColorPannel, false , false, true, true)
    end

    self.CloseButton = self:Add("DButton") -- The X button to close the interface
    self.CloseButton:SetText("X")
    self.CloseButton:SetPos(width - (width * 0.05), 0)
    self.CloseButton:SetSize( width * 0.05, height * 0.08 )
    self.CloseButton.DoClick = function()
        self.CloseButton:GetParent():Remove()
    end
    function self.CloseButton:Paint(width, height)
        local ColorPannel =  Color(255, 255, 255)
        self.CloseButton:SetTextColor(ColorPannel)
        if (self.CloseButton:IsHovered()) then
            draw.RoundedBox(0, 0, 0, width, height, Color(255, 0, 0))
        end
    end
end

function PANEL:Paint(w, h)
    local ColorPannel = Color(115, 115, 115)
    local ColorTitle = Color(245, 245, 245)
    draw.RoundedBox(5, 0, 0, w, h, ColorPannel)
    draw.DrawText( "SCP-235 Menu", "ChatFont", w/2, h*0.02, ColorTitle, TEXT_ALIGN_CENTER )
end

vgui.Register( "MenuConfigSCP235", PANEL, "DFrame" )