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
	self.SoundIsStop = false -- Permet de savoir si le son est stopé.
	self.KeyIdentifierStop = nil -- Permet de savoir quel est le stop actuel.
	self.EntitiesFreeze = {}
	self.NextUse = CurTime()
	self.UseCoolDown = 1.5
	self:SetModel( "models/props_c17/cashregister01a.mdl" )
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
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
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

function ENT:Use( ply )
	if CurTime() < self.NextUse then return end
	self.NextUse = CurTime() + self.UseCoolDown
	if (self.IsCDInserted) then self:EjectDisk() end
end

function ENT:Touch( Entity )
	if (Entity.TypeSCP235 and !self.IsCDInserted) then
		self:InsertDisk(Entity)
	end
end

function ENT:Think()
	if (self.SoundIsStop and SERVER) then
		--? On stop les joueurs selon la durée totale de l'effet soustrait par le nombres de secondes que l'enregistrement à déjà stop.
		SCP_235.StopTimeEntity(self, SCP_235_CONFIG.RangeEffect, self:GetCountDurationStop())
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
	Entity:Remove()
	self:ManageSound()
	self:SetStopSound()
end

function ENT:EjectDisk()
	local Disk = ents.Create( "scp_235_" .. self.TypeSoundPlayed )
	Disk:SetPos( self:GetPos())
	Disk:Spawn()
	Disk:Activate()
	self:ManageSound()
	self:StopEveryTimerCreated()
	for key, value in ipairs(self.EntitiesFreeze) do
		SCP_235.SetEntityUnFreeze(value, self)
	end
	self.EntitiesFreeze = {}
	self.TypeSoundPlayed = nil
	self.SoundIsStop = false
	self.KeyIdentifierStop = nil
	timer.Simple(1, function() --? Permet d'éviter que le disque jeté soit inséré lors de la colision.
		if (self:IsValid()) then self.IsCDInserted = false end
	end)
end

function ENT:ManageSound()
	if (self.IsSoundPlayed) then
		self.IsSoundPlayed = false
		self:StopSound(SCP_235_CONFIG.SoundToPlay[self.TypeSoundPlayed])

	else
		self.IsSoundPlayed = true
		self:EmitSound(SCP_235_CONFIG.SoundToPlay[self.TypeSoundPlayed])
	end
end

function ENT:SetStopSound()
	for key, value in ipairs(SCP_235_CONFIG.Disk[self.TypeSoundPlayed]) do
		timer.Create( "SCP-235-Stop-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key, value.StopSoundDisk, 1, function()
			if (!self:IsValid()) then return end
			self.KeyIdentifierStop = key
			self.SoundIsStop = true
			timer.Create( "SCP-235-Resume-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key, value.ResumeSoundDisk, 1, function()
				if (!self:IsValid()) then return end
				self.SoundIsStop = false
			end )
		end )
	end
end

function ENT:GetCountDurationStop()
	return timer.TimeLeft( "SCP-235-Resume-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..self.KeyIdentifierStop )
end

function ENT:StopEveryTimerCreated()
	for key, value in ipairs(SCP_235_CONFIG.Disk[self.TypeSoundPlayed]) do
		if (timer.Exists( "SCP-235-Stop-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key)) then
			timer.Remove( "SCP-235-Stop-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key )
		end
		if (timer.Exists( "SCP-235-Resume-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key)) then
			timer.Remove( "SCP-235-Resume-"..self.IDSCP235.."-"..self.TypeSoundPlayed.."-"..key )
		end
	end
	for key, value in ipairs(self.EntitiesFreeze) do
		if (value:IsPlayer()) then
			SCP_235.UnFreezeEffectPlayer(value)
		end
	end
end

--TODO : Faire des events qui font que si un joueur freeze est touché ou autre, alors ça le defreeze ?