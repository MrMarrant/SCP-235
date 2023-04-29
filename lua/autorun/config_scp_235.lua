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

SCP_235 = {}
SCP_235_CONFIG  = {}

SCP_235_CONFIG.FolderSounds = "scp_235/"
SCP_235_CONFIG.RangeEffect = 50
SCP_235_CONFIG.Disk = {}
SCP_235_CONFIG.SoundToPlay = {}

--? I know, this is ugly asf, but when you can't manage sound to pause and resume, you don't have many choice left.
--? StopSoundDisk : Indicates in how many seconds the sound will stop, counting from the beginning of the sound played.
--? ResumeSoundDisk : Indicates how many seconds it will take for the sound to resume, counting from the time the sound stopped.

-- SCP-235-1
SCP_235_CONFIG.SoundToPlay[1] = SCP_235_CONFIG.FolderSounds .. "SCP-235-1.wav"

SCP_235_CONFIG.Disk[1] = {}
SCP_235_CONFIG.Disk[1][1] = {}
SCP_235_CONFIG.Disk[1][1].StopSoundDisk = 10
SCP_235_CONFIG.Disk[1][1].ResumeSoundDisk = 3
SCP_235_CONFIG.Disk[1][2] = {}
SCP_235_CONFIG.Disk[1][2].StopSoundDisk = 20
SCP_235_CONFIG.Disk[1][2].ResumeSoundDisk = 4

-- SCP-235-2
SCP_235_CONFIG.SoundToPlay[2] = SCP_235_CONFIG.FolderSounds .. "SCP-235-2.wav"

SCP_235_CONFIG.Disk[2] = {}
SCP_235_CONFIG.Disk[2][1] = {}
SCP_235_CONFIG.Disk[2][1].StopSoundDisk = 20
SCP_235_CONFIG.Disk[2][1].ResumeSoundDisk = 5
SCP_235_CONFIG.Disk[2][2] = {}
SCP_235_CONFIG.Disk[2][2].StopSoundDisk = 42
SCP_235_CONFIG.Disk[2][2].ResumeSoundDisk = 2

if (SERVER) then
end

/*
* Allows you to charge all the files in a folder.
* @string path of the folder to load.
*/
function SCP_235.LoadDirectory(pathFolder)
    local files, directories = file.Find(pathFolder.."*", "LUA")
    for key, value in pairs(files) do
        AddCSLuaFile(pathFolder..value)
        include(pathFolder..value)
    end
    for key, value in pairs(directories) do
        SCP_235.LoadDirectory(pathFolder..value)
    end
end

SCP_235.LoadDirectory("scp_235/functions/")