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
	self.TypeSCP235 = 1
	self:SetModel( "models/scp_235/scp_235_1.mdl" )
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

function ENT:PhysicsCollide(data, phys)
	if data.DeltaTime > 0.2 then
		if data.Speed > 250 then
			self:EmitSound("physics/plaster/drywall_impact_hard" .. math.random(1, 3) .. ".wav", 75, math.random(90,110), 0.5)
		else
			self:EmitSound("physics/plaster/drywall_impact_soft" .. math.random(1, 3) .. ".wav", 75, math.random(90,110), 0.2)
		end
	end
end

function ENT:OnTakeDamage( dmginfo )
end

function ENT:Use( ply )
end