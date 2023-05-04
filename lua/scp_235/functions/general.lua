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
    * Send a net message to client to display the freeze effect.
    * @Player Ply The player to display the freeze effect.
    * @number FreezeDuration The duration of the effect.
    */
    function SCP_235.FreezeEffectPlayer(Ply, FreezeDuration)
        net.Start(SCP_235_CONFIG.FreezeEffectPlayer)
            net.WriteUInt(FreezeDuration, 6)
        net.Send(Ply)
    end

    /*
    * Send a net message to client to remove the freeze effect clientside.
    * @Player Ply The player to display the freeze effect.
    */
    function SCP_235.UnFreezeEffectPlayer(Ply)
        net.Start(SCP_235_CONFIG.UnFreezeEffectPlayer)
        net.Send(Ply)
    end

    /*
    * UnFreeze all entities.
    * @Entity Entity The ent to unfreeze.
    * @Entity RecordPlayer The RecordPlayer ent who call the method.
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
    * @Entity Entity The ent to freeze.
    * @number FreezeDuration The duration of the effect.
    * @Entity RecordPlayer The RecordPlayer ent who call the method.
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
    * @Entity RecordPlayer The RecordPlayer ent who call the method.
    * @number Range The range of the effect.
    * @number FreezeDuration The duration of the effect.
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

    /*
    * Display a blur effect on player that are freeze.
    */
    function SCP_235.BlurryEffect()
        local Ply = LocalPlayer()
        local CurentTime = FrameTime()
        local AddAlpha = 1
        local DrawAlpha = 10
        local Delay = 1
            
        if Ply.SCP235_IsFreeze then 
            AddAlpha = 0.2
            DrawAlpha = 0.99
            Delay = 0.05
        else
            AddAlpha = math.Clamp(ply.AddAlpha + CurentTime * 0.4, 0.2, 1)
            DrawAlpha = math.Clamp(ply.DrawAlpha - CurentTime * 0.4, 0, 0.99)
            Delay = math.Clamp(ply.Delay - CurentTime * 0.4, 0, 0.05)
        end
        
        DrawMotionBlur( AddAlpha, DrawAlpha, Delay )
    end

    net.Receive(SCP_235_CONFIG.FreezeEffectPlayer, function(Len)
        local FreezeDuration = net.ReadUInt(6)
        local Ply = LocalPlayer()
        Ply.SCP235_IsFreeze = true
        timer.Create("SCP_235.BlurryEffect_"..Ply::EntIndex(), FreezeDuration, 1, function()
            if (IsValid(Ply)) then
                Ply.SCP235_IsFreeze = nil
            end
        end)
    end)

    net.Receive(SCP_235_CONFIG.UnFreezeEffectPlayer, function(Len)
        local Ply = LocalPlayer()
        Ply.SCP235_IsFreeze = nil
        if (timer.Exists("SCP_235.BlurryEffect_"..Ply::EntIndex())) then
            timer.Remove("SCP_235.BlurryEffect_"..Ply::EntIndex())
        end
    end)

    hook.Add("RenderScreenspaceEffects","RenderScreenspaceEffects.SCP35_BlurryEffect",SCP_235.BlurryEffect)
end