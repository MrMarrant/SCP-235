-- SCP 235, A representation of a paranormal object on a fictional series on the game Garry's Mod.
-- Copyright (C) 2023  MrMarrant aka BIBI.

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

if SERVER then return end

local PANEL = {}

local ColorWhite = Color(255, 255, 255)
local ColorRed = Color(255, 0, 0)

local ImgSubMenu = {}
ImgSubMenu[1] = "menu/setting_1.png"
ImgSubMenu[2] = "menu/setting_2.png"

-- TODO : Menu déroulant pour les classes d'entités immunisés à l'effet
-- TODO : Menu déroulant pour les jobs de joueur immunisés à l'effet

function PANEL:Init()
    local ply = LocalPlayer()
    self:SetSize(SCP_235_CONFIG.ScrW * 0.5 , SCP_235_CONFIG.ScrH *0.4 )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( true )
    self:ShowCloseButton( false )
    self.ActualMode = ply.SCP235_GetModeMenu or 1
    local width, height = self:GetSize()

    self.Body = self:Add("EditablePanel") -- Body Pannel where it contain all the parameters
    self.Body:SetSize(width - (width * 0.1), height - (height * 0.08))
    self.Body:SetPos(width * 0.1, height * 0.08)
    function self.Body:Paint(width, height)
        local ColorPannel = Color(84, 84, 84)
        draw.RoundedBoxEx(0, 0, 0, width, height, ColorPannel, false , false, true, true)
    end

    self.LeftBody = self:Add("EditablePanel") -- Left Pannel where you choose the mode
    self.LeftBody:SetSize(width * 0.1, height - (height * 0.08))
    self.LeftBody:SetPos(0,  height * 0.08)
    function self.LeftBody:Paint(width, height)
        local ColorPannel = Color(115, 115, 115)
        draw.RoundedBoxEx(5, 0, 0, width, height, ColorPannel, false , false, true, true)
    end

    local ClassOptions = self.Body:Add("ClassOptionSCP235")
    ClassOptions:SetSize(self.Body:GetSize())
    SCP_235.UpdateChildren(ClassOptions)
    ClassOptions:SetVisible(self.ActualMode == 1 and true or false)

    -- if (DarkRP) then
    --     local JobOptions = self.Body:Add("JobOptionSCP235")
    --     JobOptions:SetSize(self.Body:GetSize())
    --     aegis.UpdateChildren(JobOptions)
    --     JobOptions:SetVisible(self.ActualMode == 2 and true or false)
    -- end

    local WidthLeftBody, HeightLeftBody = self.LeftBody:GetSize()
    local SizeMenu = DarkRP and 2 or 1
    for var = 1, SizeMenu do
        local SubMenu = self.LeftBody:Add("DButton") -- Sub Category individual
        SubMenu:SetSize(WidthLeftBody, HeightLeftBody/SizeMenu)
        SubMenu:SetPos(0, (var-1) * HeightLeftBody/SizeMenu)
        SubMenu:SetText("")
        SubMenu.Mode = var
        function SubMenu:DoClick()
            self.ActualMode = SubMenu.Mode
            ply.SCP235_GetModeMenu = SubMenu.Mode
            SCP_235.UpdateVisibilityBody(self.ActualMode, self.Body)
        end
        function SubMenu:Paint(w, h)
            local ColorPannel = Color(115, 115, 115)
            if (SubMenu:IsHovered() or self.ActualMode == SubMenu.Mode) then
                ColorPannel:SetUnpacked( ColorPannel.r + 10, ColorPannel.g + 10, ColorPannel.b + 10, ColorPannel.a )
            end
            draw.RoundedBoxEx(0, 0, 0, w, h, ColorPannel, false , false, true, true)
        end
        local WidthSubMenu, HeightSubMenu = SubMenu:GetSize()
        local SubImg = SubMenu:Add("DImage")
        SubImg:SetImage(ImgSubMenu[var])
        SubImg:SetSize(WidthSubMenu * 0.6, HeightSubMenu * 0.6)
        SubImg:Center()
    end

    self.CloseButton = self:Add("DButton") -- The X button to close the interface
    self.CloseButton:SetText("X")
    self.CloseButton:SetPos(width - (width * 0.05), 0)
    self.CloseButton:SetSize( width * 0.05, height * 0.08 )
    self.CloseButton.DoClick = function()
        self.CloseButton:GetParent():Remove()
    end
    function self.CloseButton:Paint(width, height)
        self:SetTextColor(ColorWhite)
        if (self:IsHovered()) then
            draw.RoundedBox(0, 0, 0, width, height, ColorRed)
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