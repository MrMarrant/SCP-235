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

SCP_235_CONFIG.SoundToPlay = "scp_235/SCP-235-"
SCP_235_CONFIG.RangeEffect = 400
SCP_235_CONFIG.PathImmuneEffect = "data_scp235/immune_effect.json"
SCP_235_CONFIG.Disk = {}

--? I know, this is ugly asf, but when you can't manage sound to pause and resume, you don't have many choice left.
--? StopSoundDisk : Indicates in how many seconds the sound will stop, counting from the beginning of the sound played.
--? ResumeSoundDisk : Indicates how many seconds it will take for the sound to resume, counting from the time the sound stopped.

-- SCP-235-1
SCP_235_CONFIG.Disk[1] = {}
SCP_235_CONFIG.Disk[1][1] = {}
SCP_235_CONFIG.Disk[1][1].StopSoundDisk = 18
SCP_235_CONFIG.Disk[1][1].ResumeSoundDisk = 5
SCP_235_CONFIG.Disk[1][2] = {}
SCP_235_CONFIG.Disk[1][2].StopSoundDisk = 55
SCP_235_CONFIG.Disk[1][2].ResumeSoundDisk = 22
SCP_235_CONFIG.Disk[1][3] = {}
SCP_235_CONFIG.Disk[1][3].StopSoundDisk = 88
SCP_235_CONFIG.Disk[1][3].ResumeSoundDisk = 12
SCP_235_CONFIG.Disk[1][4] = {}
SCP_235_CONFIG.Disk[1][4].StopSoundDisk = 124
SCP_235_CONFIG.Disk[1][4].ResumeSoundDisk = 8

-- SCP-235-2
SCP_235_CONFIG.Disk[2] = {}
SCP_235_CONFIG.Disk[2][1] = {}
SCP_235_CONFIG.Disk[2][1].StopSoundDisk = 1
SCP_235_CONFIG.Disk[2][1].ResumeSoundDisk = 17
SCP_235_CONFIG.Disk[2][2] = {}
SCP_235_CONFIG.Disk[2][2].StopSoundDisk = 59
SCP_235_CONFIG.Disk[2][2].ResumeSoundDisk = 9
SCP_235_CONFIG.Disk[2][3] = {}
SCP_235_CONFIG.Disk[2][3].StopSoundDisk = 81
SCP_235_CONFIG.Disk[2][3].ResumeSoundDisk = 13
SCP_235_CONFIG.Disk[2][4] = {}
SCP_235_CONFIG.Disk[2][4].StopSoundDisk = 104
SCP_235_CONFIG.Disk[2][4].ResumeSoundDisk = 2
SCP_235_CONFIG.Disk[2][5] = {}
SCP_235_CONFIG.Disk[2][5].StopSoundDisk = 141
SCP_235_CONFIG.Disk[2][5].ResumeSoundDisk = 10

-- SCP-235-3
SCP_235_CONFIG.Disk[3] = {}
SCP_235_CONFIG.Disk[3][1] = {}
SCP_235_CONFIG.Disk[3][1].StopSoundDisk = 20
SCP_235_CONFIG.Disk[3][1].ResumeSoundDisk = 6
SCP_235_CONFIG.Disk[3][2] = {}
SCP_235_CONFIG.Disk[3][2].StopSoundDisk = 42
SCP_235_CONFIG.Disk[3][2].ResumeSoundDisk = 2
SCP_235_CONFIG.Disk[3][3] = {}
SCP_235_CONFIG.Disk[3][3].StopSoundDisk = 56
SCP_235_CONFIG.Disk[3][3].ResumeSoundDisk = 18
SCP_235_CONFIG.Disk[3][4] = {}
SCP_235_CONFIG.Disk[3][4].StopSoundDisk = 79
SCP_235_CONFIG.Disk[3][4].ResumeSoundDisk = 3
SCP_235_CONFIG.Disk[3][5] = {}
SCP_235_CONFIG.Disk[3][5].StopSoundDisk = 97
SCP_235_CONFIG.Disk[3][5].ResumeSoundDisk = 8
SCP_235_CONFIG.Disk[3][6] = {}
SCP_235_CONFIG.Disk[3][6].StopSoundDisk = 111
SCP_235_CONFIG.Disk[3][6].ResumeSoundDisk = 12
SCP_235_CONFIG.Disk[3][7] = {}
SCP_235_CONFIG.Disk[3][7].StopSoundDisk = 142
SCP_235_CONFIG.Disk[3][7].ResumeSoundDisk = 4

-- SCP-235-4
-- Very lazy to do it 15 times
SCP_235_CONFIG.Disk[4] = {}
local StopSoundDisk_4 = 11
local ResumeSoundDisk_4 = 4
for i = 1, 15 do
    SCP_235_CONFIG.Disk[4][i] = {}
    SCP_235_CONFIG.Disk[4][i].StopSoundDisk = StopSoundDisk_4 + (10* i)
    SCP_235_CONFIG.Disk[4][i].ResumeSoundDisk = ResumeSoundDisk_4
end

-- Network Value
SCP_235_CONFIG.FreezeEffectPlayer = "SCP_235_CONFIG.FreezeEffectPlayer"
SCP_235_CONFIG.UnFreezeEffectPlayer = "SCP_235_CONFIG.UnFreezeEffectPlayer"
SCP_235_CONFIG.CTSOpenMenuSCP235 = "SCP_235_CONFIG.CTSOpenMenuSCP235"
SCP_235_CONFIG.OpenMenuSCP235 = "SCP_235_CONFIG.OpenMenuSCP235"

if (SERVER) then
    util.AddNetworkString( SCP_235_CONFIG.FreezeEffectPlayer )
    util.AddNetworkString( SCP_235_CONFIG.UnFreezeEffectPlayer )
    util.AddNetworkString( SCP_235_CONFIG.CTSOpenMenuSCP235 )
    util.AddNetworkString( SCP_235_CONFIG.OpenMenuSCP235 )

    if not file.Exists(SCP_235_CONFIG.PathImmuneEffect, "DATA") then
        local SERVER_VALUES = {}
        SERVER_VALUES.JobsImmune = {}
        SERVER_VALUES.ClassImmune = {}
        file.Write(SCP_235_CONFIG.PathImmuneEffect, util.TableToJSON(SERVER_VALUES, true))
    else
        -- TODO : Faire la méthode
        -- SCP_235_CONFIG.ImmuneEffect = SCP_235.GetDataFromFile(SCP_235_CONFIG.PathImmuneEffect)
    end
end

-- TODO : Faire une convar pour ouvrir le menu, check si le joueur est admin avant de l'ouvrir.
if (CLIENT) then
    SCP_235_CONFIG.ScrW = ScrW()
    SCP_235_CONFIG.ScrH = ScrH()
    surface.CreateFont( "SCP235_FreezeFont", {
        font = "Arial",
        size = 35,
        weight = 1000
    } )
end