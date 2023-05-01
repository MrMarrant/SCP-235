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
    */
    function SCP_235.FreezeEffectPlayer(Ply, FreezeDuration)
        net.Start(SCP_235_CONFIG.FreezeEffectPlayer)
            net.WriteInt(FreezeDuration, 6)
        net.Send(Ply)
    end
    /*
    * UnFreeze all entities.
    * @Entity The ent to unfreeze.
    */
    function SCP_235.SetEntityUnFreeze(Entity, RecordPlayer)
        table.RemoveByValue( RecordPlayer.EntitiesFreeze, Entity )
        if (!Entity:IsValid()) then return end
        if (Entity:IsPlayer()) then
            Entity:Freeze(false)
        else
            Entity:SetMoveType(Entity.PreviousType)
            Entity:RemoveFlags(FL_FROZEN)
            local EntPhys = Entity:GetPhysicsObject()
            -- TODO : Gérer les objets volant qui bougeaient pas au moment du freeze.
            if (EntPhys:IsValid()) then
                print(Entity)
                print(EntPhys:GetVelocity())
            end
        end
    end

    /*
    * Freeze all entities
    * @Entity The ent to freeze.
    */
    function SCP_235.SetEntityFreeze(Entity, FreezeDuration, RecordPlayer)
        table.insert(RecordPlayer.EntitiesFreeze, Entity)
        if (Entity:IsPlayer()) then
            Entity:Freeze(true)
        else
            Entity.PreviousType = Entity:GetMoveType()
            Entity:SetMoveType(MOVETYPE_NONE)
            Entity:AddFlags(FL_FROZEN)
        end
        timer.Simple(FreezeDuration, function()
            if (Entity) then
                SCP_235.SetEntityUnFreeze(Entity, RecordPlayer)
            end
        end)
    end

    /*
    * 
    * @Vector Le vecteur d'origine ou il faut chercher
    */
    function SCP_235.StopTimeEntity(RecordPlayer, Range, FreezeDuration)
        local EntsFound = ents.FindInSphere( RecordPlayer:GetPos(), Range )
        for key, value in pairs(EntsFound) do
            if (!value:IsFlagSet( FL_FROZEN )) then
                SCP_235.SetEntityFreeze(value, FreezeDuration, RecordPlayer)
                if (value:IsPlayer()) then
                    SCP_235.FreezeEffectPlayer(value, FreezeDuration)
                    -- TODO : Afficher un texte au centre de l'écran pour donner le contexte qu'il n'ont pas conscience d'être freeze.
                    -- TODO : Rendre flou l'écran.
                    -- TODO : Les empecher de parler avec le micro.
                end
            end
        end
    end
end

if (CLIENT) then
    net.Receive(SCP_235_CONFIG.FreezeEffectPlayer, function(Len, Ply)
        local FreezeDuration = net.ReadInt(6)

    end)
end