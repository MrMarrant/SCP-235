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
        Ply.SCP235_IsFreeze = true
        net.Start(SCP_235_CONFIG.FreezeEffectPlayer)
            net.WriteFloat(FreezeDuration)
        net.Send(Ply)
    end

    /*
    * Send a net message to client to remove the freeze effect clientside.
    * @Player Ply The player to display the freeze effect.
    */
    function SCP_235.UnFreezeEffectPlayer(Ply)
        Ply.SCP235_IsFreeze = nil
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
                end
            end
        end
    end

    -- Players freeze can't hear others players and can't be heard by others.
    hook.Add( "PlayerCanHearPlayersVoice", "PlayerCanHearPlayersVoice.SCP235_TimeIsStop", function( Listener, Talker )
        if Listener.SCP235_IsFreeze or Talker.SCP235_IsFreeze then return false end
    end )
end

if (CLIENT) then

    /*
    * Display a blur effect on player that are freeze.
    */
    function SCP_235.BlurryEffect()
        if (LocalPlayer().SCP235_IsFreeze) then
            DrawMaterialOverlay("effects/strider_pinch_dudv", 0.3)
        end
    end

    net.Receive(SCP_235_CONFIG.FreezeEffectPlayer, function(Len)
        local FreezeDuration = net.ReadFloat()
        local Ply = LocalPlayer()
        Ply.SCP235_IsFreeze = true
        timer.Create("SCP_235.BlurryEffect_"..Ply:EntIndex(), FreezeDuration, 1, function()
            if (IsValid(Ply)) then
                Ply.SCP235_IsFreeze = nil
            end
        end)
    end)

    net.Receive(SCP_235_CONFIG.UnFreezeEffectPlayer, function(Len)
        local Ply = LocalPlayer()
        Ply.SCP235_IsFreeze = nil
        if (timer.Exists("SCP_235.BlurryEffect_"..Ply:EntIndex())) then
            timer.Remove("SCP_235.BlurryEffect_"..Ply:EntIndex())
        end
    end)

    hook.Add( "HUDPaint", "HUDPaint.SCP35_BlurryEffect", function()
        if (LocalPlayer().SCP235_IsFreeze) then 
            draw.DrawText( "You are frozen in time, you are not conscious that time has stopped", "SCP235_FreezeFont", SCP_235_CONFIG.ScrW * 0.5, SCP_235_CONFIG.ScrH * 0.5, Color(180,180,180,150), TEXT_ALIGN_CENTER )
        end
    end )

    hook.Add( "OnScreenSizeChanged", "OnScreenSizeChanged.SCP35_ScreenSizeChanged", function( oldWidth, oldHeight )
        SCP_235_CONFIG.ScrW = ScrW()
        SCP_235_CONFIG.ScrH = ScrH()
    end )

    hook.Add("RenderScreenspaceEffects","RenderScreenspaceEffects.SCP35_BlurryEffect",SCP_235.BlurryEffect)
end