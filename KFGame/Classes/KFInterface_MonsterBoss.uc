//=============================================================================
// KFInterface_MonsterBoss
//=============================================================================
// Pawn interface for any shared behavior between bosses, whether they are
//      unique based on KFPawn_MonsterBoss, or an upgraded variant (ex: FP King).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

interface KFInterface_MonsterBoss;

//AI Controller notes:
// - Two calls to class'AICommand_BossTheatrics'.static.DoTheatrics in the AI controller for a boss
// - See KFAIController_ZedBoss or KFAIController_ZedFleshpoundKing

//Pawn Notes:
// - Generally do the following in the PossessedBy() call:
//    - PlayBossMusic();
//    - ServerDoSpecialMove(SM_BossTheatrics);

//Pawn overrides to disable functionality related to head popping.  These are optional, but are implemented for all standard TWI bosses.
// - function CauseHeadTrauma(float BleedOutTime = 5.f);
// - simulated function bool PlayDismemberment(int InHitZoneIndex, class<KFDamageType> InDmgType, optional vector HitDirection)
// - simulated function PlayHeadAsplode()
// - simulated function ApplyHeadChunkGore(class<KFDamageType> DmgType, vector HitLocation, vector HitDirection)

//Quick access to a pawn reference
simulated function KFPawn_Monster GetMonsterPawn();

//Localization Accessors
simulated function string GetRandomBossCaption();

//Status Accessors
static simulated event bool IsABoss();
simulated function float GetHealthPercent();

//Intro functionality
simulated function SetAnimatedBossCamera(bool bEnable, optional vector CameraOffset);
simulated function bool UseAnimatedBossCamera();
simulated function name GetBossCameraSocket();
simulated function vector GetBossCameraOffset();

//Death functionality
function OnZedDied(Controller Killer);

simulated function String GetIconPath();

//Wave functionality
function KFAIWaveInfo GetWaveInfo(int BattlePhase, int Difficulty);
function byte GetNumMinionsToSpawn();