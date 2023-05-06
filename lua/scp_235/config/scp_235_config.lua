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
SCP_235_CONFIG.Disk[1][1].StopSoundDisk = 3
SCP_235_CONFIG.Disk[1][1].ResumeSoundDisk = 3
SCP_235_CONFIG.Disk[1][2] = {}
SCP_235_CONFIG.Disk[1][2].StopSoundDisk = 10
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

-- Network Value
SCP_235_CONFIG.FreezeEffectPlayer = "SCP_235_CONFIG.FreezeEffectPlayer"
SCP_235_CONFIG.UnFreezeEffectPlayer = "SCP_235_CONFIG.UnFreezeEffectPlayer"

if (SERVER) then
    util.AddNetworkString( SCP_235_CONFIG.FreezeEffectPlayer )
    util.AddNetworkString( SCP_235_CONFIG.UnFreezeEffectPlayer )
end

if (CLIENT) then
    SCP_235_CONFIG.ScrW = ScrW()
    SCP_235_CONFIG.ScrH = ScrH()
    surface.CreateFont( "SCP235_FreezeFont", {
        font = "Arial",
        size = 35,
        weight = 1000
    } )
end