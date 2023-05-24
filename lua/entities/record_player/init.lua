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

AddCSLuaFile("shared.lua")
include("shared.lua")

local HardImpactSoundList = {
	"physics/metal/metal_sheet_impact_hard2.wav",
	"physics/metal/metal_sheet_impact_hard6.wav",
	"physics/metal/metal_sheet_impact_hard7.wav",
	"physics/metal/metal_sheet_impact_hard8.wav"
}

function ENT:Initialize()
	self:GenerateID() -- Permet d'indiquer l'id de l'entité, on dois savoir précisément quel est l'entité généré.
	self.IsSoundPlayed = false -- Permet d'indiquer si un CD est joué, reste à true si le son est terminé mais que le cd n'a pas été retiré.
	self.IsCDInserted = false -- Permet d'indiquer si un CD est inséré.
	self.TypeSoundPlayed = nil -- Permet d'indiquer quel type de CD à été inséré.
	self.EntitiesFreeze = {}
	self.NextUse = CurTime()
	self.UseCoolDown = 1.5
	self:SetModel( "models/record_player/record_player.mdl" )
	self:RebuildPhysics()
end

function ENT:GenerateID()
	local OthersRecordPlayer = ents.FindByClass( "record_player" )
	local MaxID = 0
	local KeySelfEnt = table.KeyFromValue( OthersRecordPlayer, self )
	table.remove( OthersRecordPlayer, KeySelfEnt )
	if (!table.IsEmpty( OthersRecordPlayer)) then
		for key, value in ipairs(OthersRecordPlayer) do
			if (MaxID > value.IDSCP235) then
				MaxID = value.IDSCP235
			end
		end
	end
	self.IDSCP235 = MaxID + 1
end

function ENT:RebuildPhysics( )
	self:SetModelScale( 1 )
	self:PhysicsInit( SOLID_VPHYSICS ) 
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS ) 
	self:SetUseType(SIMPLE_USE)
	self:PhysWake()
end

function ENT:PhysicsCollide(data, phys)
	if data.DeltaTime > 0.2 then
		if data.Speed > 250 then
			self:EmitSound(table.Random( HardImpactSoundList ), 75, math.random(90,110), 0.5)
		else
			self:EmitSound("physics/metal/metal_solid_impact_soft" .. math.random(1, 3) .. ".wav", 75, math.random(90,110), 0.2)
		end
	end
end

-- Si un joueur essaye de retirer le disque durant un gel, il ne se passera rien.
function ENT:Use( ply )
	if CurTime() < self.NextUse or self.SCP235_IsFreeze then return end
	self.NextUse = CurTime() + self.UseCoolDown
	if (self.IsCDInserted) then self:EjectDisk() end
end

function ENT:Touch( Entity )
	if (Entity.TypeSCP235 and !self.IsCDInserted) then
		self:InsertDisk(Entity)
	end
end

function ENT:OnRemove()
	if (self.IsCDInserted) then
		self:EjectDisk()
	end
end

function ENT:InsertDisk(Entity)
	self.IsCDInserted = true
	self.TypeSoundPlayed = Entity.TypeSCP235
	self:SetBodygroup( 1, 1 )
	self:ResetSequence( "vinyl_play" )

	Entity:Remove()
	self:ManageSound()
	self:SetStopSound()
end

function ENT:EjectDisk()
	self:SetBodygroup( 0, 0 )
	self:ResetSequence( "idle" )

	local Disk = ents.Create( "scp_235_" .. self.TypeSoundPlayed )
	Disk:SetPos( self:GetPos())
	Disk:Spawn()
	Disk:Activate()
	self:ManageSound()
	self:StopEveryTimerCreated()
	self.EntitiesFreeze = {}
	self.TypeSoundPlayed = nil
	timer.Simple(1, function() --? Permet d'éviter que le disque jeté soit inséré lors de la colision.
		if (self:IsValid()) then self.IsCDInserted = false end
	end)
end

function ENT:ManageSound()
	if (self.IsSoundPlayed) then
		self.IsSoundPlayed = false
		self:StopSound(SCP_235_CONFIG.SoundToPlay..self.TypeSoundPlayed..".mp3")

	else
		self.IsSoundPlayed = true
		self:EmitSound(SCP_235_CONFIG.SoundToPlay..self.TypeSoundPlayed..".mp3")
	end
end

function ENT:SetStopSound()
	for key, value in ipairs(SCP_235_CONFIG.Disk[self.TypeSoundPlayed]) do
		timer.Create( "SCP-235-Stop-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key, value.StopSoundDisk, 1, function()
			if (!self:IsValid()) then return end
			--? On stop les joueurs selon la durée totale de l'effet.
			SCP_235.StopTimeEntity(self, SCP_235_CONFIG.RangeEffect, value.ResumeSoundDisk)
		end )
	end
end

function ENT:StopEveryTimerCreated()
	for key, value in ipairs(SCP_235_CONFIG.Disk[self.TypeSoundPlayed]) do
		if (timer.Exists( "SCP-235-Stop-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key)) then
			timer.Remove( "SCP-235-Stop-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key )
		end
	end

	for key, value in SortedPairs(self.EntitiesFreeze) do
		if (value:IsValid()) then
			timer.Adjust( "SCP_235.FreezeEffect_"..value:EntIndex(), 0, 1, nil )
		end
	end
end