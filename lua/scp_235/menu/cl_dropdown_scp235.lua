if SERVER then return end
local PANEL = {}

-- Refresh the drop-down menu and generate the contained data.
function PANEL:Init()
    self:Clear()
    local DataClass = SCP_235_CONFIG.ClassImmune or {}
    for k, v in pairs( DataClass ) do
        RemoveDropDown:AddChoice( k )
    end
end

function PANEL:Paint(witdh, height)
    local ColorPannel = Color(158, 158, 158)
    draw.RoundedBox(0, 0, 0, witdh, height, ColorPannel)
end

vgui.Register( "DropDownSCP235", PANEL, "DComboBox" )