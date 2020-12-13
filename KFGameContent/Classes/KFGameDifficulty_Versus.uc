//=============================================================================
// KFGameDifficulty_Versus
//=============================================================================
// Manages difficulty based gameplay settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFGameDifficulty_Versus extends KFGameDifficultyInfo;

defaultproperties
{	
	Normal={(WaveCountMod=0.53, //0.85, //0.72 //0.62feltgood
		DoshKillMod=1.2, //1.1
		StartingDosh=500,  //300
		RespawnDosh=500, //300
		AmmoPickupsMod=0.65, //0.4
		ItemPickupsMod=0.450000, //0.45
		SelfInflictedDamageMod=0.100000)}
}
