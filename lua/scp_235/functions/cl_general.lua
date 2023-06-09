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

local bindkey_open_menu = CreateClientConVar("bindkey_open_menu", "J", true, false, "Open Menu config SCP-235")

-- Cooldown for avoid players to spam key bind.
local NextActionKey = CurTime()

-- For manage action player clientside if they try to call action on scramble.
hook.Add( "PlayerButtonDown", "PlayerButtonDown.SCP235_BindKey", function( ply, button )
    local KeyOpenMenu = GetConVar( "bindkey_open_menu" ):GetString()
    local Keyname = string.upper( input.GetKeyName( button ) )
    local CurrentTime = CurTime()

    if (NextActionKey < CurrentTime) then
        NextActionKey = CurrentTime + 1 --? 1s cooldown between each key action.
        if ( Keyname == KeyOpenMenu ) then
            net.Start(SCP_235_CONFIG.CTSOpenMenuSCP235)
            net.SendToServer()
        end
    end
end)
