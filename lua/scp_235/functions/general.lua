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
            net.WriteFloat(FreezeDuration)
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
        Entity.SCP235_IsFreeze = nil
        if (Entity:IsPlayer()) then
            Entity:Freeze(false)
            Entity:SetMoveType(Entity.SCP235_PreviousType)
        end
        local EntPhys = Entity:GetPhysicsObject()
        if (EntPhys:IsValid() and Entity.SCP235_PreviousVelocity) then
            EntPhys:EnableMotion( true )
            EntPhys:SetVelocity(Entity.SCP235_PreviousVelocity)
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
        local EntPhys = Entity:GetPhysicsObject()
        Entity.SCP235_IsFreeze = true
        Entity.SCP235_PreviousType = Entity:GetMoveType()
        if IsValid(EntPhys) then
            Entity.SCP235_PreviousVelocity = EntPhys:GetVelocity()
            EntPhys:EnableMotion( false )
        end
        if (Entity:IsPlayer()) then
            Entity:Freeze(true)
            Entity:SetMoveType(MOVETYPE_NONE)
        end
        timer.Create("SCP_235.FreezeEffect_"..Entity:EntIndex(), FreezeDuration, 1, function()
            if (IsValid(Entity) and IsValid(RecordPlayer)) then
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
            if (!value:IsFlagSet( FL_FROZEN ) or !value.SCP235_IsFreeze) then
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

    -- Remove freeze effect to entity or player when something hit them.
    hook.Add( "EntityTakeDamage", "EntityTakeDamage.UnfreezeEntitiesFreeze", function( target, dmginfo )
        if (target.SCP235_IsFreeze and target:GetClass() != "record_player") then
            timer.Adjust( "SCP_235.FreezeEffect_"..target:EntIndex(), 0, 1, nil )
            if (target:IsPlayer()) then
                SCP_235.UnFreezeEffectPlayer(target)
            end
        end
    end )

    -- TODO: Pas de collision avec les entités quand elles sont freezes!
    -- Remove freeze effect to entity or player when something touch them that is not freeze.
    hook.Add( "ShouldCollide", "ShouldCollide.UnfreezeEntitiesFreeze", function( ent1, ent2 )
        print(ent1, ent2)
        if (ent1:GetClass() != "record_player" and
        ent2:GetClass() != "record_player" and
        (ent1.SCP235_IsFreeze and !ent2.SCP235_IsFreeze) or 
        (!ent1.SCP235_IsFreeze and ent2.SCP235_IsFreeze)) then
            local EntityFreeze = ent1.SCP235_IsFreeze and ent1 or ent2
            timer.Adjust( "SCP_235.FreezeEffect_"..EntityFreeze:EntIndex(), 0, 1, nil )
            if (EntityFreeze:IsPlayer()) then
                SCP_235.UnFreezeEffectPlayer(EntityFreeze)
            end
        end
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
        Ply:ChatPrint( "You are frozen in time, you are not conscious that time has stopped" )
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

-- Context message when players are froozen in time moove into chatprint.
--[[     hook.Add( "HUDPaint", "HUDPaint.SCP35_BlurryEffect", function()
        if (LocalPlayer().SCP235_IsFreeze) then 
            draw.DrawText( "You are frozen in time, you are not conscious that time has stopped", "SCP235_FreezeFont", SCP_235_CONFIG.ScrW * 0.5, SCP_235_CONFIG.ScrH * 0.5, Color(180,180,180,150), TEXT_ALIGN_CENTER )
        end
        --RunConsoleCommand( "stopsound" )
    end ) ]]

    hook.Add( "OnScreenSizeChanged", "OnScreenSizeChanged.SCP35_ScreenSizeChanged", function( oldWidth, oldHeight )
        SCP_235_CONFIG.ScrW = ScrW()
        SCP_235_CONFIG.ScrH = ScrH()
    end )

    hook.Add("RenderScreenspaceEffects","RenderScreenspaceEffects.SCP35_BlurryEffect",SCP_235.BlurryEffect)
end