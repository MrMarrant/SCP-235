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
        if Entity.SCP235_OldTouch then 
            Entity.Touch = Entity.SCP235_OldTouch
            Entity.SCP235_OldTouch = nil
        end
        if Entity.SCP235_CallBackID then
            Entity:RemoveCallback( "PhysicsCollide", Entity.SCP235_CallBackID )
            Entity.SCP235_CallBackID = nil
        end
        if (Entity:IsPlayer()) then
            Entity:Freeze(false)
            if Entity.SCP235_PreviousType then
                Entity:SetMoveType(Entity.SCP235_PreviousType)
            end
        end
        if Entity:IsNPC() then
            SCP_235.UnFreezeNPC(Entity)
        end
        local EntPhys = Entity:GetPhysicsObject()
        if (EntPhys:IsValid() and Entity.SCP235_PreviousVelocity) then
            EntPhys:EnableMotion( true )
            EntPhys:SetVelocity(Entity.SCP235_PreviousVelocity)
        end
        Entity.SCP235_IsFreeze = nil
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
        -- ? Collision between players doesn't work for somes reasons .. ?
        -- ? That's why i use the PlayerUse hook, anw.
        -- TODO : Faire fonctionner sur les npc
        -- Collision for Players AND prop_physics
        if Entity:GetClass() == "prop_physics" or Entity:IsPlayer() or Entity:IsNPC() then
            Entity.SCP235_CallBackID = Entity:AddCallback( "PhysicsCollide", function(ent, data) 
                SCP_235.CollideEvent(ent, data.HitEntity)
            end)
        elseif Entity:GetClass() != "record_player" then -- Collision for others, like regular entities.
            Entity.SCP235_OldTouch = Entity.Touch
            function Entity:Touch(EntityHit)
                SCP_235.CollideEvent(Entity, EntityHit)
            end
        end
        
        if IsValid(EntPhys) then
            Entity.SCP235_PreviousVelocity = EntPhys:GetVelocity()
            EntPhys:EnableMotion( false )
        end
        if (Entity:IsPlayer()) then
            Entity.SCP235_PreviousType = Entity:GetMoveType()
            Entity:SetMoveType(MOVETYPE_NONE)
            Entity:Freeze(true)
        end
        if Entity:IsNPC() then
            SCP_235.FreezeNPC(Entity)
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
        PrintTable(EntsFound)
        for key, value in pairs(EntsFound) do
            if value:EntIndex() != 1 then
                if (!value:IsFlagSet( FL_FROZEN ) or !value.SCP235_IsFreeze) then
                    SCP_235.SetEntityFreeze(value, FreezeDuration, RecordPlayer)
                    if (value:IsPlayer()) then
                        SCP_235.FreezeEffectPlayer(value, FreezeDuration)
                    end
                end
            end
        end
    end

    /* Custom Touch Event set when entities are freezes.
    * @Entity Entity The entity who was collide
    * @Entity EntityHit The entity that hit
    */
    function SCP_235.CollideEvent(EntityTouch, EntityHit)
        if !EntityHit.SCP235_IsFreeze and !EntityHit:IsWorld() and EntityTouch.SCP235_IsFreeze then
            timer.Adjust( "SCP_235.FreezeEffect_"..EntityTouch:EntIndex(), 0, 1, nil )
            if (EntityTouch:IsPlayer()) then
                SCP_235.UnFreezeEffectPlayer(EntityTouch)
            end
        end
    end

    function SCP_235.FreezeNPC(NPCTarget)
        NPCTarget:SetMoveYawLocked( true )
        NPCTarget.SCP235_PreviousType = NPCTarget:GetMoveType()
        NPCTarget:SetMoveType(MOVETYPE_NONE)
        local AllEnts = ents.GetAll()
        NPCTarget.SCP_235_PreviousRelation = {}
        for i, value in pairs(AllEnts) do
            NPCTarget.SCP_235_PreviousRelation[value:EntIndex()] = NPCTarget:Disposition( value )
            NPCTarget:AddEntityRelationship( value, D_NU )
        end
    end

    function SCP_235.UnFreezeNPC(NPCTarget)
        NPCTarget:SetMoveYawLocked( false )
        if NPCTarget.SCP235_PreviousType then
            NPCTarget:SetMoveType(NPCTarget.SCP235_PreviousType)
        end
        if NPCTarget.SCP_235_PreviousRelation then
            for key, value in pairs(NPCTarget.SCP_235_PreviousRelation) do
                local EntFound = Entity( key )
                print(EntFound)
                if IsValid(EntFound) then
                    NPCTarget:AddEntityRelationship( EntFound, value )
                end
            end
        end
    end

    -- Players freeze can't hear others players and can't be heard by others.
    hook.Add( "PlayerCanHearPlayersVoice", "PlayerCanHearPlayersVoice.SCP235_TimeIsStop", function( Listener, Talker )
        if Listener.SCP235_IsFreeze or Talker.SCP235_IsFreeze then return false end
    end )

    -- Remove freeze effect to entity or player when something hit them.
    hook.Add( "EntityTakeDamage", "EntityTakeDamage.SCP_235_UnfreezeEntitiesFreeze", function( target, dmginfo )
        if (target.SCP235_IsFreeze and target:GetClass() != "record_player") then
            timer.Adjust( "SCP_235.FreezeEffect_"..target:EntIndex(), 0, 1, nil )
            if (target:IsPlayer()) then
                SCP_235.UnFreezeEffectPlayer(target)
            end
        end
    end )

    -- If a player do a use method on a freeze object, i will do it like with collision.
    hook.Add( "PlayerUse", "PlayerUse.SCP_235_UnfreezeEntitiesFreeze", function( ply, ent )
        SCP_235.CollideEvent(ent, ply)
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

    hook.Add( "OnScreenSizeChanged", "OnScreenSizeChanged.SCP35_ScreenSizeChanged", function( oldWidth, oldHeight )
        SCP_235_CONFIG.ScrW = ScrW()
        SCP_235_CONFIG.ScrH = ScrH()
    end )

    hook.Add("RenderScreenspaceEffects","RenderScreenspaceEffects.SCP35_BlurryEffect",SCP_235.BlurryEffect)
end