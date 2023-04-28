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

function ENT:Initialize()
	self.ActualSoundPlayed = nil
	self.TypeSoundPlayed = nil
	self.SoundIsStop = false -- Permet de savoir si le son est stopé.
	self.SoundStopDuration = nil -- Permet de savoir pendant cb de temps le son est stop.
	self.CountDurationStop = 0 -- Permet de savoir depuis combien de temps le son à été areté.
	self:SetModel( "models/props_c17/cashregister01a.mdl" )
	self:RebuildPhysics()
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

function ENT:PhysicsCollide( data, physobj )
end

function ENT:OnTakeDamage( dmginfo )
end

-- TODO : Retire un CD et coupe le son quand on l'utilise.
function ENT:Use( ply )
	self:ManageSound()
	if (self.TypeSoundPlayed) then self:EjectDisk() end
end

-- TODO : Lance la musique quand un CD est inséré.
function ENT:Touch( Entity )
	if (Entity.TypeSCP235 and !self.TypeSoundPlayed) then
		self.TypeSoundPlayed = Entity.TypeSCP235
		self:ManageSound()
	end
end

function ENT:Think()
	if (self.ActualSoundPlayed) then
		if (self.ActualSoundPlayed:IsPlaying()) then
			--if SERVER then SCP_235.StopTimeEntity(self:GetPos(), SCP_235_CONFIG.RangeEffect, 3) end
		end
		print(self.ActualSoundPlayed:IsPlaying())
	end
	if (self.SoundIsStop and SERVER) then --TODO : Si oui, on freeze toutes les entités
		--? On stop les joueurs selon la durée totale de l'effet soustrait par le nombres de secondes que l'enregistrement à déjà stop.
		SCP_235.StopTimeEntity(self:GetPos(), SCP_235_CONFIG.RangeEffect, self.SoundStopDuration - self.CountDurationStop)
	end
end

function ENT:EjectDisk()
	local Disk = ents.Create( "scp_235_" .. self.TypeSoundPlayed )
	Disk:SetPos( self:GetPos())
	Disk:Spawn()
	Disk:Activate()
	self.TypeSoundPlayed = nil
end

function ENT:ManageSound()
	if (self.ActualSoundPlayed) then
		self.ActualSoundPlayed:Stop()
		self.ActualSoundPlayed = nil
		-- TODO : Areter tous les timers!
	else
		self.ActualSoundPlayed = CreateSound( self, SCP_235_CONFIG.Disk[self.TypeSoundPlayed].SoundToPlay)
		self.ActualSoundPlayed:Play()
		--TODO : Lancer les timer pour quand s'est sensé freeze les entités.
		--TODO : Lancer un timer pour savoir depuis combien de seconds le son a stop et set self.SoundIsStop.
	end
end

--TODO : Faire des events qui font que si un joueur freeze est touché ou autre, alors ça le defreeze ?