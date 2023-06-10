
if SERVER then return end

local PANEL = {}

local ColorPannel = Color(255, 255, 255)
local ColorBGTitle = Color(61, 61, 61)
local ColorText = Color(14, 13, 13)

function PANEL:Init()
    local Description = self:Add("DPanel")
    Description:Dock( TOP )
    Description:DockMargin(0, 0, 0, 40)
    function Description:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, ColorBGTitle)
        draw.DrawText( "Class Config", "DermaDefault", w*0.5, h*0.35, ColorPannel, TEXT_ALIGN_CENTER )
    end

    local RemovePanel = self:Add("DPanel")
    RemovePanel:Dock( BOTTOM )
    RemovePanel:DockMargin(36, 0, 36, 80)

    local RemoveDropDown = RemovePanel:Add("DropDownSCP235")
    RemoveDropDown:Dock( FILL )
    
    local RemoveButton = RemovePanel:Add("DButton")
    RemoveButton:Dock( BOTTOM )
    RemoveButton.DoClick = function()
        local ClassSelected = RemoveDropDown:GetOptionText( RemoveDropDown:GetSelectedID() )
        -- TODO : Méthode pour retirer un élément du menu
        --aegis.RemoveElementFromList(AEGIS_CONFIG.PathModelsInfected, jobSelected, ComboBoxRemove, "ModelsInfected")
    end

    local RemoveDescription = self:Add("DPanel")
    RemoveDescription:Dock( BOTTOM )
    RemoveDescription:DockMargin(36, 0, 0, 0)
    function RemoveDescription:Paint(w, h)
        draw.DrawText( "Description Remove panel", "DermaDefault", 0, 0, ColorPannel, TEXT_ALIGN_LEFT )
    end

    local AddDescription = self:Add("DPanel")
    AddDescription:Dock( TOP )
    AddDescription:DockMargin(36, 0, 0, 0)
    function AddDescription:Paint(w, h)
        draw.DrawText( "Description Add panel", "DermaDefault", 0, 0, ColorPannel, TEXT_ALIGN_LEFT )
    end

    local AddPanel = self:Add("DPanel")
    AddPanel:Dock( TOP )
    AddPanel:DockMargin(36, 0, 36, 80)
    function AddPanel:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    local TextEntryForm = AddPanel:Add("DTextEntry")
    TextEntryForm.TextEntry = true
    TextEntryForm:SetDrawLanguageID( false )
    TextEntryForm:Dock( FILL )
    TextEntryForm:DockMargin( 0, 0, 0, 5 )
    TextEntryForm:SetPlaceholderText( "The class of the entitie." )
    function TextEntryForm:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, ColorPannel)
        self:DrawTextEntryText(ColorText, ColorText, ColorText)
    end

    local AddButton = AddPanel:Add("DButton")
    AddButton:Dock( BOTTOM )
    AddButton.DoClick = function()
        local ClassEnter = TextEntryForm:GetValue()
        if ClassEnter == "" then return end
        -- TODO : Méthode pour ajouter un élément au menu
        -- aegis.UpdateDataFromClientToServer(AEGIS_CONFIG.PathModelsInfected, modelPath, jobSelected, "ModelsInfected")
        TextEntryForm:SetValue("")
        timer.Simple( engine.TickInterval(), function() 
            if (IsValid(RemoveDropDown)) then RemoveDropDown:Init()  end
        end )
    end
end

vgui.Register( "ClassOptionSCP235", PANEL, "EditablePanel" )