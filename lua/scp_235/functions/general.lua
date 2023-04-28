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

if (SERVER) then
    /*
    * 
    * @Entity The ent to unfreeze.
    */
    function SCP_235.SetEntityUnFreeze(Entity)
        if (Entity:IsPlayer()) then
            --Entity:Freeze(false)
        else --TODO : UnFreeze les autres entités.
            Entity:RemoveFlags( FL_FROZEN )
        end
    end

    /*
    * 
    * @Entity The ent to freeze.
    */
    function SCP_235.SetEntityFreeze(Entity, FreezeDuration)
        if (Entity:IsPlayer()) then
            --Entity:Freeze(true)
        else --TODO : Freeze les autres entités.
            Entity:AddFlags( FL_FROZEN ) --! Pas l'air de fonctionner
        end
        timer.Simple(FreezeDuration, function()
            if (Entity) then
                SCP_235.SetEntityUnFreeze(Entity)
            end
        end)
    end

    /*
    * 
    * @Vector Le vecteur d'origine ou il faut chercher
    */
    function SCP_235.StopTimeEntity(Origin, Range, FreezeDuration)
        local EntsFound = ents.FindInSphere( Origin, Range )
        for key, value in pairs(EntsFound) do
            if (!value:IsFlagSet( FL_FROZEN )) then
                SCP_235.SetEntityFreeze(value, FreezeDuration)
                if (value:IsPlayer()) then
                    -- TODO : Afficher un texte au centre de l'écran pour donner le contexte qu'il n'ont pas conscience d'être freeze.
                    -- TODO : Rendre flou l'écran.
                    -- TODO : Les empecher de parler avec le micro.
                end
            end
        end
    end
end