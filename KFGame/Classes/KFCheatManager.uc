//=============================================================================
// KFCheatManager
//=============================================================================
// Base CheatManager for KFGame
//
// Note: If using ToggleDebugCamera and exec functions, call GetMyPawn()
// instead of using Pawn reference.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFCheatManager extends GameCheatmanager
	native;

//@HSL_MOD_BEGIN - amiller 5/11/2016 - Adding support to save extra data into profile settings
`include(KFProfileSettings.uci)
//@HSL_MOD_END
/** Debug scene related properties */
var bool					bDebugSceneEnabled;
var KFSceneCaptureDebugCam	DebugSceneCamera;
var KFAIController			DebugKFAIC;
var KFPawn_Monster			DebugTarget;

var name CheatType;

/** Whether splatter gun more is currently enabled. Used to toggle between normal
	shooting mode and shooting splatters */
var transient bool bUsingSplatterGun;

/** for ReadGlobalStat */
var transient bool bRequestedGlobalStats;

/*********************************************************************************************
 * native cheats
 *********************************************************************************************/
exec native final function SetPerkLevel( int NewPerkLevel );
exec native final function SetPerkPrestigeLevel(int NewPerkLevel);
exec native final function ResetPerkLevels();
exec native final function AnalyzeCharacterAttachments();
exec native final function FixupCharacterAttachmentLocalization();

/** Global (aka Aggregated) stats */
exec native function ReadGlobalStat(string statId, optional int HistoryNumDays);

/** Helps to identify all the translucent materials that are tagged with bTranslucencyInheritDominantShadowsFromOpaque
    for performance reasons. Having this checked will activate the "CopyToTranslucencyAttenTex" code path whenever
    the material is in view.
    */
exec native final function FindTranslucencyInheritDominantShadowMaterials();

/** Create and save an empty upk */
native final function MakeEmptyPackage();

exec native function ForceDailyObjective(int ObjectiveIndex, int UIIndex);
exec native function ResetDailyObjectives();
exec native function GiveVaultDosh(int Amount);

/*********************************************************************************************
 * script cheats
 *********************************************************************************************/

/**
 * GetMyPawn() : Use this to get a valid KFCheatManager.Pawn reference!
 *  If you need to access the CheatManager's Pawn (Pawn / Outer.Pawn), use this function
 *  instead of directly using the "Pawn" variable. If the player executing the cheat is in
 *  DebugCamera mode (see ToggleDebugCamera()), "Pawn" will be null because the player will
 *  be unpossessed by his normal PlayerController and possessed by a KFDebugCameraController.
 *  DebugCameraControllers have no pawn, but GetMyPawn() will return the pawn that you're
 *  looking for whether the player is in DebugCamera mode or not.
 */
function Pawn GetMyPawn()
{
	/**
	 * If Outer.Pawn is null, assume that player is in DebugCamera mode and instead
	 * assume that Outer is a DebugCameraCameraController and return the reference to
	 * the player's unpossessed PlayerController's Pawn.
	 */
	return (Pawn!=none)?Pawn:DebugCameraController(Outer).OriginalControllerRef.Pawn;
}

exec function SetShellToState(int ShellIndex, byte ShellState)
{
	local KFWeap_GrenadeLauncher_CylinderBase GLBase;
	local KFPawn MyPawn;

	MyPawn = KFPawn(GetMyPawn());
	if (MyPawn != none && MyPawn.MyKFWeapon != none)
	{
		GLBase = KFWeap_GrenadeLauncher_CylinderBase(MyPawn.MyKFWeapon);

		if (GLBase != none)
		{
			GLBase.SetShellToState(ShellIndex, ShellState);
		}
	}

}

exec function SetFakeDownloadProgress (bool bDownloading, float PercentageComplete)
{
    local KFGameViewportClient KFVP;

    KFVP = KFGameViewportClient(class'Engine'.static.GetEngine().GameViewport);

    KFVP.NotifyDownloadProgress(PMT_DownloadProgress, "TEST", "59");
}

exec function SetInventoryFilter (string FilterType, int NewEnum)
{
    local string MyFilterType;
    local KFPlayerController KFPC;
    `log("Set Filter Called: " @FilterType @NewEnum);
    MyFilterType = Caps(FilterType);

    KFPC = KFPlayerController(Outer);
    if(KFPC != none && KFPC.MyGFxManager != none && KFPC.MyGFxManager.InventoryMenu != none)
    {
        switch (MyFilterType)
        {
            case "WEAPON":
                KFPC.MyGFxManager.InventoryMenu.Callback_WeaponTypeFilterChanged(NewEnum);
                break;
            case "RARITY":
                KFPC.MyGFxManager.InventoryMenu.Callback_RarityTypeFilterChanged(NewEnum);
                break;
            case "PERK":
                KFPC.MyGFxManager.InventoryMenu.Callback_PerkTypeFilterChanged(NewEnum);
                break;
            default:
                `log("Bad filter type provided!"@FilterType);
        }
    }
}

exec function PrintOutCurrentPrestigeInfo()
{
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;

	KFPC = KFPlayerController(Outer);
	`log("Curennt perk prestige level: " @KFPC.CurrentPerk.GetPrestigeLevel());

	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	`log("KPRI active prestige level: " @KFPRI.GetActivePerkPrestigeLevel());
}

exec function DisplayFreeTrialFeatureBlockedPopUp()
{
	class'KFGFxMoviePlayer_Manager'.static.DisplayFreeTrialFeatureBlockedPopUp();
}

exec function DisplayFreeTrialOverPopUp()
{
	class'KFGFxMoviePlayer_Manager'.static.DisplayFreeTrialOverPopUp();
}

exec function TestItemServerStatusIndicatorStart()
{
	local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxManager != none && KFPC.MyGFxManager.BackendStatusIndicatorWidget != none)
    {
        KFPC.MyGFxManager.BackendStatusIndicatorWidget.StartFlickeringConnectionLost();
    }
}

exec function TestItemServerStatusIndicatorStop()
{
	local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxManager != none && KFPC.MyGFxManager.BackendStatusIndicatorWidget != none)
    {
        KFPC.MyGFxManager.BackendStatusIndicatorWidget.StopFlickeringConnectionLost();
    }
}

exec function OpenScreenSizeMovie()
{
	KFPlayerController(Outer).MyGFxManager.OpenScreenSizeMovie();
}


exec function CloseScreenSizeMovie()
{
	KFPlayerController(Outer).MyGFxManager.ScreenSizeMovie.SaveAndClose();
}

exec function OpenIIS ()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(Outer);

    KFPC.MyGFxManager.OpenMenu(UI_IIS);
}

exec function SetIISText (string MyString)
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(Outer);

    KFPC.MyGFxManager.IISMenu.SetString("loginText",  MyString);
}

exec function TestSongInfoWidget(String S)
{
    local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxHUD != none )
    {
        KFPC.MyGFxHUD.MusicNotification.ShowSongInfo(S);
    }

}

exec function TestNumbPrompts(int NumberOfPrompts)
{
    local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxManager != none )
    {
        KFPC.MyGFxManager.ManagerObject.SetInt("numPrompts", NumberOfPrompts);
    }
}

exec function TestMapMessage(String S, float time)
{
    local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxHUD != none )
    {
        KFPC.MyGFxHUD.MapTextWidget.DisplayMapText(S, time, true);
    }
}

exec function TestMapCounterMessage(String S, float time)
{
    local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxHUD != none )
    {
        KFPC.MyGFxHUD.MapCounterTextWidget.DisplayMapText(S, time);
    }
}

exec function MakeFakePopUp()
{
    local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxManager != none )
    {
        KFPC.MyGFxManager.DelayedShowDisconnectMessage();
    }
}

exec function SetCharacterAttachment(int MeshIndex, int SkinIndex, int AttachmentIndex, optional bool bIgnoreConflictingSlots = false)
{
    local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxManager != none && KFPC.MyGFxManager.GearMenu != none)
    {
        KFPC.MyGFxManager.GearMenu.RelayFromCheatManager(P, CO_Attachment, MeshIndex, SkinIndex, AttachmentIndex, bIgnoreConflictingSlots);
    }
}

exec function PrintOutCharacterCosmeticInfo()
{
    local KFPlayerReplicationInfo KFPRI;
    local int i;
    KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
    if(KFPRI == none)
    {
        return;
    }

    `log("PRINTING OUT COSMETIC INFO!");
    for(i = 0; i < 3 /*MAX_COSMETIC_ATTACHMENTS*/; ++i)
    {
        `log("Item on slot index: " @i @"Mesh index: " @KFPRI.RepCustomizationInfo.AttachmentMeshIndices[i] @"Skin index" @KFPRI.RepCustomizationInfo.AttachmentSkinIndices[i] );
    }

    `log("********END PRINT ATTACHMENTS*****************");

}

exec function TestLocalMessage ()
{
    ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteNotEnoughPlayers);
}

// Start firing automatically
exec function AutoFire(float interval)
{
    StartFire();
    SetTimer(interval,true,nameof(FireAgain),self);
}

// Stop firing automatically
exec function StopAutoFire()
{
    StopFire();
    ClearTimer(nameof(FireAgain),self);
}

simulated function FireAgain()
{
    StopFire();
    StartFire();
}

exec function TestGrenade(optional string GrenadePath)
{
	local vector StartTrace, TraceDir;
	local KFProj_Grenade	SpawnedGrenade;
	local class<KFProj_Grenade> GrenadeClass;

	if( GrenadePath == "" )
	{
		GrenadePath = "KFGameContent.KFProj_HEGrenade";
	}

    GrenadeClass = class<KFProj_Grenade>(DynamicLoadObject(GrenadePath, class'Class'));

	// Leave a splat on level geometry along the direction being shot at
	StartTrace = Pawn.GetWeaponStartTraceLocation();
	TraceDir = vector(Pawn.Weapon.GetAdjustedAim(StartTrace));

	// Spawn Grenade
	SpawnedGrenade = Pawn.Weapon.Spawn( GrenadeClass, Pawn.Weapon );
	if( SpawnedGrenade != none && !SpawnedGrenade.bDeleteMe )
	{
		SpawnedGrenade.Init( TraceDir );
	}
}

exec function TestConcussiveGrenade()
{
    local vector StartTrace, TraceDir;
    local KFProj_Grenade    SpawnedGrenade;
    local class<KFProj_Grenade> GrenadeClass;

    GrenadeClass = class<KFProj_Grenade>(DynamicLoadObject("KFGameContent.KFProj_DynamiteGrenade", class'Class'));

    // Leave a splat on level geometry along the direction being shot at
    StartTrace = Pawn.GetWeaponStartTraceLocation();
    TraceDir = vector(Pawn.Weapon.GetAdjustedAim(StartTrace));

    // Spawn Grenade
    SpawnedGrenade = Pawn.Weapon.Spawn( GrenadeClass, Pawn.Weapon );
    if( SpawnedGrenade != none && !SpawnedGrenade.bDeleteMe )
    {
        SpawnedGrenade.ExplosionTemplate.ExplosionEffects = SpawnedGrenade.default.AltExploEffects;
        SpawnedGrenade.Init( TraceDir );
    }
}

exec function TestNukeGrenade()
{
    local vector StartTrace, TraceDir;
    local KFProj_Grenade    SpawnedGrenade;
    local class<KFProj_Grenade> GrenadeClass;

    GrenadeClass = class<KFProj_Grenade>(DynamicLoadObject("KFGameContent.KFProj_DynamiteGrenade", class'Class'));

    // Leave a splat on level geometry along the direction being shot at
    StartTrace = Pawn.GetWeaponStartTraceLocation();
    TraceDir = vector(Pawn.Weapon.GetAdjustedAim(StartTrace));

    // Spawn Grenade
    SpawnedGrenade = Pawn.Weapon.Spawn( GrenadeClass, Pawn.Weapon );
    if( SpawnedGrenade != none && !SpawnedGrenade.bDeleteMe )
    {
        SpawnedGrenade.ExplosionTemplate = class'KFPerk_Demolitionist'.static.GetNukeExplosionTemplate();
        SpawnedGrenade.ExplosionActorClass = class'KFPerk_Demolitionist'.static.GetNukeExplosionActorClass();
        SpawnedGrenade.Init( TraceDir );
    }
}

exec function BurnFX()
{
    KFPawn(GetMyPawn()).AfflictionHandler.ToggleEffects(AF_FirePanic, True);
}

exec function StopBurnFX()
{
    KFPawn(GetMyPawn()).AfflictionHandler.ToggleEffects(AF_FirePanic, False);
}


exec function SetInflate(float InflateParam)
{
	local KFPawn_Monster KFPM;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
        KFPM.AfflictionHandler.UpdateMaterialParameter(AF_Microwave, InflateParam);
	}
}

exec function SetChar(float CharParam)
{
	local KFPawn_Monster KFPM;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
        KFPM.AfflictionHandler.UpdateMaterialParameter(AF_FirePanic, CharParam);
	}
}

exec function ToggleZedsIgnoreMe()
{
	local KFAIController KFAIC;

    KFPawn(GetMyPawn()).bAIZedsIgnoreMe = !KFPawn(GetMyPawn()).bAIZedsIgnoreMe;

	foreach AllActors( class'KFAIController', KFAIC )
	{
        if( KFAIC != none && KFAIC.Enemy == GetMyPawn() )
        {
            KFAIC.Enemy = none;
        }
    }

    ClientMessage(GetMyPawn()@"Zeds Ignore Me: "$KFPawn(GetMyPawn()).bAIZedsIgnoreMe, CheatType );
}

exec function ToggleFrustration(optional int enabledValue=5)
{
    if( class'KFAIController'.default.FrustrationThreshold == 0 )
    {
        ConsoleCommand("SETNOPEC KFAIController FrustrationThreshold"@enabledValue);
    }
    else
    {
        ConsoleCommand("SETNOPEC KFAIController FrustrationThreshold"@0);
    }
}

exec function ZedTeleport()
{
	local KFAIController KFAIC;

    KFPawn(GetMyPawn()).bAIZedsIgnoreMe = !KFPawn(GetMyPawn()).bAIZedsIgnoreMe;

	foreach AllActors( class'KFAIController', KFAIC )
	{
        if( KFAIC != none )
        {
            KFAIC.RelocateTeleport();
        }
    }

    ClientMessage("Teleporting zeds for reorganization", CheatType );
}

exec function ZedStuck()
{
	local KFAIController KFAIC;

    KFPawn(GetMyPawn()).bAIZedsIgnoreMe = !KFPawn(GetMyPawn()).bAIZedsIgnoreMe;

	foreach AllActors( class'KFAIController', KFAIC )
	{
        if( KFAIC != none )
        {
            KFAIC.HandleStuck();
        }
    }

    ClientMessage("Forcing HandleStuck For Zeds", CheatType );
}

exec function LogCurrentWave()
{
    local int i, j, k;
    local KFAISpawnManager SpawnManager;

    if( KFGameInfo(WorldInfo.Game) != none )
	{
        SpawnManager =  KFGameInfo(WorldInfo.Game).SpawnManager;

    	`log("Current Loaded Wave Setup");
        for( i = 0; i < SpawnManager.AvailableSquads.Length; i++ )
    	{
    		for( j = 0; j < SpawnManager.AvailableSquads[i].MonsterList.Length; j++ )
    		{
                `log( "AvailableSquads "$i$" MonsterList "$j$" is "$GetEnum(enum'EAIType',SpawnManager.AvailableSquads[i].MonsterList[j].Type)$" Num: "$SpawnManager.AvailableSquads[i].MonsterList[j].Num$" SquadName: "$SpawnManager.AvailableSquads[i] );
    		}
    	}

        `log("Current Waves Info For Wave: "$KFGameInfo(WorldInfo.Game).MyKFGRI.WaveNum$" which is "$(KFGameInfo(WorldInfo.Game).MyKFGRI.WaveNum - 1)$" in the wave array ");

		i = KFGameInfo(WorldInfo.Game).MyKFGRI.WaveNum - 1;

        for( j = 0; j < SpawnManager.WaveSettings.Waves[i].Squads.Length; j++ )
		{
    		for( k = 0; k < SpawnManager.WaveSettings.Waves[i].Squads[j].MonsterList.Length; k++ )
    		{
                `log( "Wave "$i$" Squads "$j$" MonsterList "$k$" is "$GetEnum(enum'EAIType',SpawnManager.WaveSettings.Waves[i].Squads[j].MonsterList[k].Type)$" Num: "$SpawnManager.WaveSettings.Waves[i].Squads[j].MonsterList[k].Num );
            }
		}

        for( j = 0; j < SpawnManager.WaveSettings.Waves[i].SpecialSquads.Length; j++ )
        {
            if( SpawnManager.WaveSettings.Waves[i].SpecialSquads[j] != none )
            {
                for( k = 0; k < SpawnManager.WaveSettings.Waves[i].SpecialSquads[j].MonsterList.Length; k++ )
                {
                    `log( "Wave "$i$" Special Squad MonsterList "$k$" is "$GetEnum(enum'EAIType',SpawnManager.WaveSettings.Waves[i].SpecialSquads[j].MonsterList[k].Type)$" Num: "$SpawnManager.WaveSettings.Waves[i].SpecialSquads[j].MonsterList[k].Num );
                }
            }
            else
            {
                `log( "Wave "$i$" No Special Squad " );
            }
        }
	}
}

exec function LogAllWaves()
{
    local int i, j, k;
    local KFAISpawnManager SpawnManager;

    if( KFGameInfo(WorldInfo.Game) != none )
	{
        SpawnManager =  KFGameInfo(WorldInfo.Game).SpawnManager;

    	`log("Current Loaded Wave Setup");
        for( i = 0; i < SpawnManager.AvailableSquads.Length; i++ )
    	{
    		for( j = 0; j < SpawnManager.AvailableSquads[i].MonsterList.Length; j++ )
    		{
                `log( "AvailableSquads "$i$" MonsterList "$j$" is "$GetEnum(enum'EAIType',SpawnManager.AvailableSquads[i].MonsterList[j].Type)$" Num: "$SpawnManager.AvailableSquads[i].MonsterList[j].Num$" SquadName: "$SpawnManager.AvailableSquads[i] );
    		}
    	}

        `log("All Waves Info");
    	for( i = 0; i < SpawnManager.WaveSettings.Waves.Length; i++ )
    	{
    		for( j = 0; j < SpawnManager.WaveSettings.Waves[i].Squads.Length; j++ )
    		{
        		for( k = 0; k < SpawnManager.WaveSettings.Waves[i].Squads[j].MonsterList.Length; k++ )
        		{
                    `log( "Wave "$i$" Squads "$j$" MonsterList "$k$" is "$GetEnum(enum'EAIType',SpawnManager.WaveSettings.Waves[i].Squads[j].MonsterList[k].Type)$" Num: "$SpawnManager.WaveSettings.Waves[i].Squads[j].MonsterList[k].Num );
                }
    		}

            for( j = 0; j < SpawnManager.WaveSettings.Waves[i].SpecialSquads.Length; j++ )
            {
        		if( SpawnManager.WaveSettings.Waves[i].SpecialSquads[j] != none )
        		{
                    for( k = 0; k < SpawnManager.WaveSettings.Waves[i].SpecialSquads[j].MonsterList.Length; k++ )
            		{
                        `log( "Wave "$i$" Special Squad MonsterList "$k$" is "$GetEnum(enum'EAIType',SpawnManager.WaveSettings.Waves[i].SpecialSquads[j].MonsterList[k].Type)$" Num: "$SpawnManager.WaveSettings.Waves[i].SpecialSquads[j].MonsterList[k].Num );
                    }
                }
                else
                {
                    `log( "Wave "$i$" No Special Squad " );
                }
            }
    	}
	}
}

exec function PowerUpHellishRage()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController( Outer );
    if( KFPC != none )
    {
        KFPC.ReceivePowerUp(class'KFPowerUp_HellishRage');
    }
}

// Enter the name of a weapons skeletal mesh to spawn it without animations
exec function SpawnGunModel( string GunMeshString )
{
	local SkeletalMesh GunMesh;

    GunMesh = SkeletalMesh(DynamicLoadObject(GunMeshString, class'SkeletalMesh'));

	KFPawn( Pawn ).ArmsMesh.DetachFromAny();
    KFSkeletalMeshComponent(Pawn.Weapon.Mesh).SetSkeletalMesh( GunMesh );
    KFSkeletalMeshComponent(Pawn.Weapon.Mesh).SetAnimTreeTemplate( none );
    KFSkeletalMeshComponent(Pawn.Weapon.Mesh).AnimSets.length = 0;
}

exec function HansGunsOut()
{
	local KFPawn_Monster KFPM;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
        KFPM.DoSpecialMove(SM_ChangeStance, false, none, 1);
	}
}

exec function HansGunsAway()
{
	local KFPawn_Monster KFPM;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
        KFPM.DoSpecialMove(SM_ChangeStance, false, none, 0);
	}
}

// Force the weapon to the stop at the first frame of the idle pose
exec function WeapForceIdle()
{
    KFWeapon(Pawn.Weapon).PlayAnimation(KFWeapon(Pawn.Weapon).IdleAnims[0], 0.0, false, 0.0);
    SetTimer(0.001,false,nameof(FreezeWeapAnimUpdate),self);
}

simulated function FreezeWeapAnimUpdate()
{
    KFSkeletalMeshComponent(Pawn.Weapon.Mesh).bPauseAnims = true;
}

/** Used by animators to test new content */
exec function TestWeaponAnim(name AnimName)
{
	KFWeapon(Pawn.Weapon).PlayAnimation(AnimName, 0.0, false, 0.0);
}

exec function SetPauseMonsterAnims( bool bPause )
{
	local KFPawn_Monster KFPM;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
        KFPM.Mesh.bPauseAnims = bPause;
	}
}

exec function NoSpread()
{
	if( KFWeapon(Pawn.Weapon) != none )
	{
		KFWeapon(Pawn.Weapon).Spread[0] = 0;
		KFWeapon(Pawn.Weapon).Spread[1] = 0;
		ClientMessage("Spread Disabled", CheatType );
	}
}

exec function GoSpread()
{
	if( KFWeapon(Pawn.Weapon) != none )
	{
		KFWeapon(Pawn.Weapon).Spread[0] = KFWeapon(Pawn.Weapon).default.Spread[0];
		KFWeapon(Pawn.Weapon).Spread[1] = KFWeapon(Pawn.Weapon).default.Spread[1];
		ClientMessage("Spread Enabled", CheatType );
	}
}

exec function HideMenus()
{
    if(KFPlayerController(Outer).MyGFxManager != none)
    {
        KFPlayerController(Outer).MyGFxManager.SetMenuVisibility(false);
    }
    else
    {
        `log("MENU MANAGER NOT READY");
    }
}

exec function DebugShowVoteKick()
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	if (KFPlayerController(Outer).MyGFxHUD != none && KFPRI != None)
	{
		KFPlayerController(Outer).MyGFxHUD.ShowKickVote(KFPRI, 10, true);
	}
}

exec function DebugShowVoteSkipTrader()
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	if (KFPlayerController(Outer).MyGFxHUD != none && KFPRI != None)
	{
		KFPlayerController(Outer).MyGFxHUD.ShowSkipTraderVote(KFPRI, 10, true);
	}
}

exec function DebugShowVotePauseGame()
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	if (KFPlayerController(Outer).MyGFxHUD != none && KFPRI != None)
	{
		KFPlayerController(Outer).RequestPauseGame();
	}
}

exec function ToggleForceCrosshair()
{
    KFHudBase(MyHud).bForceDrawCrosshair = !KFHudBase(MyHud).bForceDrawCrosshair;
}

exec function ToggleCrosshair()
{
    KFHudBase(MyHud).bDrawCrosshair = !KFHudBase(MyHud).bDrawCrosshair;
}

/**
 * Toggle the flame collision between simple and complex collision
 */
exec function FlameSetComplex(bool bDoCollideComplex)
{
	if( KFWeap_FlameBase(Pawn.Weapon) != none )
	{
		KFWeap_FlameBase(Pawn.Weapon).SetFlameComplex(bDoCollideComplex);
	}
}

/**
 * Toggle the flame damage debug settings
 */
exec function FlameDebugDamage(bool bDebugDirectDamage, bool bDebugSplashDamage, bool bDebugShowSplashRadius, bool bDebugShowCollision)
{
    local KFWeap_FlameBase KWFB;

    KWFB = KFWeap_FlameBase(Pawn.Weapon);

	if( KWFB != none )
	{
		KWFB.SetFlameDebugDamage(bDebugDirectDamage, bDebugSplashDamage, bDebugShowSplashRadius, bDebugShowCollision);
	}
}

/**
 * Toggle the flame effects debug settings
 */
exec function FlameDebugFX(bool bDebugShowSeeds, bool bDebugShowBones, bool bDebugForceNonPlayerParticles)
{
    local KFWeap_FlameBase KWFB;

    KWFB = KFWeap_FlameBase(Pawn.Weapon);

	if( KWFB != none )
	{
		KWFB.SetFlameDebugFX(bDebugShowSeeds, bDebugShowBones, bDebugForceNonPlayerParticles);
	}
}

/**
 * Toggle the flame effects debug settings
 */
exec function FlameDebugFX3P(bool bDebugShowSeeds, bool bDebugShowBones, bool bDebugForceNonPlayerParticles)
{
    local KFWeapAttach_SprayBase KFSB;
 	local KFPawn KFP;

	KFP = KFPawn(Pawn);
	if ( KFP != None )
	{
		KFSB = KFWeapAttach_SprayBase(KFP.WeaponAttachment);

    	if( KFSB != none )
    	{
    		KFSB.SetFlameDebugFX(bDebugShowSeeds, bDebugShowBones, bDebugForceNonPlayerParticles);
    	}
	}
}

/**
 * Toggle the flame damage debug settings
 */
exec function FlameDebugDamage3P(bool bDebugDirectDamage, bool bDebugSplashDamage, bool bDebugShowSplashRadius, bool bDebugShowCollision)
{
    local KFWeapAttach_SprayBase KFSB;
 	local KFPawn KFP;

	KFP = KFPawn(Pawn);
	if ( KFP != None )
	{
		KFSB = KFWeapAttach_SprayBase(KFP.WeaponAttachment);

    	if( KFSB != none )
    	{
    		KFSB.SetFlameDebugDamage(bDebugDirectDamage, bDebugSplashDamage, bDebugShowSplashRadius, bDebugShowCollision);
    	}
	}
}

/**
 * Switch to the next music track
 */
simulated exec function NextTrack()
{
	if( KFGameReplicationInfo(WorldInfo.GRI) != none )
	{
       KFGameReplicationInfo(WorldInfo.GRI).PlayNewMusicTrack();
	}
}

/**
 * Directly set the music volume
 */
simulated exec function SetMusicVolume( float NewVolume )
{
	local float MusicVolumeMultiplier;
//@HSL_MOD_BEGIN - amiller 5/11/2016 - Adding support to save extra data into profile settings
	local OnlinePlayerStorage Profile;

	Profile = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(LocalPlayer(Player).ControllerId);
	MusicVolumeMultiplier = NewVolume ;
	GetALocalPlayerController().SetAudioGroupVolume( 'Music', MusicVolumeMultiplier );
	Profile.SetProfileSettingValueFloat(KFID_MusicVolumeMultiplier, MusicVolumeMultiplier);
	KFProfileSettings(Profile).Save( LocalPlayer(Player).ControllerId );
//@HSL_MOD_END
	class'KFGameEngine'.static.StaticSaveConfig();
}

simulated exec function SetPadVolume( float NewVolume )
{
	class'KFGameEngine'.static.SetWWisePADVolume(NewVolume);
}

exec function Weapon GiveWeapon( String WeaponClassStr )
{
	local KFInventoryManager KFIM;
	local Weapon NewWeap;

	KFIM = KFInventoryManager(Pawn.InvManager);
	if (KFIM !=none)
	{
		KFIM.bInfiniteWeight = true;
		NewWeap = super.GiveWeapon(WeaponClassStr);
		KFIM.bInfiniteWeight = false;
	}

	return NewWeap;
}

/**
 * Give the player han's dual mkbs
 */
simulated exec function MKB()
{
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_DualMKb42_Hans" );
}

/**
 * Give the player the Minigun
 */
simulated exec function Minigun()
{
    GiveWeapon( "KFGameContent.KFWeap_Minigun" );
}

/**
 * Give the player the Vampire
 */
simulated exec function Vampire()
{
	GiveWeapon( "KFGameContent.KFWeap_HRG_Vampire" );
}

/**
 * Give the player the HRG SonicGun
 */
simulated exec function SonicGun()
{
	GiveWeapon( "KFGameContent.KFWeap_HRG_SonicGun" );
}


/**
 * Give the player all pistol weapons
 */
simulated exec function Pistols()
{
    GiveWeapon( "KFGameContent.KFWeap_Pistol_9mm" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_G18C" );
	GiveWeapon( "KFGameContent.KFWeap_Revolver_Rem1858" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_Medic" );
	GiveWeapon( "KFGameContent.KFWeap_GrenadeLauncher_HX25" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_Colt1911" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_Flare" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Deagle" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_ChiappaRhino" );
}

/**
 * Give the player all dummy weapons
 */
simulated exec function DummyWeapon()
{
	GiveWeapon( "KFGameContent.KFWeap_AssetDummy" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Dummy" );
}

/**
 * Give the player all perk knives
 */
simulated exec function Melee()
{
    GiveWeapon( "KFGameContent.KFWeap_Knife_Berserker" );
    GiveWeapon( "KFGameContent.KFWeap_Knife_Commando" );
    GiveWeapon( "KFGameContent.KFWeap_Knife_Support" );
    GiveWeapon( "KFGameContent.KFWeap_Knife_Demolitionist" );
    GiveWeapon( "KFGameContent.KFWeap_Knife_Firebug" );
    GiveWeapon( "KFGameContent.KFWeap_Knife_FieldMedic" );
	GiveWeapon( "KFGameContent.KFWeap_Knife_Gunslinger" );
	GiveWeapon( "KFGameContent.KFWeap_Knife_Sharpshooter" );
	GiveWeapon( "KFGameContent.KFWeap_Knife_SWAT" );
	GiveWeapon( "KFGameContent.KFWeap_Knife_Survivalist" );
}

/**
 * Give the player the nailgun
 */
simulated exec function Nails()
{
	GiveWeapon( "KFGameContent.KFWeap_Shotgun_Nailgun" );
}

/**
 * Give the player all Berserker weapons
 */
simulated exec function Berserk()
{
    GiveWeapon( "KFGameContent.KFWeap_Blunt_Crovel" );
	GiveWeapon( "KFGameContent.KFWeap_Shotgun_Nailgun" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_HRGTeslauncher" );
	GiveWeapon( "KFGameContent.KFWeap_Edged_Katana" );
	GiveWeapon( "KFGameContent.KFWeap_Edged_FireAxe" );
	GiveWeapon( "KFGameContent.KFWeap_Blunt_ChainBat" );
	GiveWeapon( "KFGameContent.KFWeap_Blunt_MedicBat" );
    GiveWeapon( "KFGameContent.KFWeap_Edged_Zweihander" );
	GiveWeapon( "KFGameContent.KFWeap_Blunt_Pulverizer" );
    GiveWeapon(" KFGameContent.KFWeap_Blunt_PowerGloves" );
	GiveWeapon( "KFGameContent.KFWeap_Eviscerator" );
    GiveWeapon( "KFGameContent.KFWeap_Blunt_MaceAndShield" );
    GiveWeapon( "KFGameContent.KFWeap_Edged_IonThruster" );
	GiveWeapon( "KFGameContent.KFWeap_Edged_AbominationAxe" );
}

/**
 * Give the player all Commando weapons
 */
simulated exec function Assault()
{
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_AR15" );
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_Bullpup" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_AK12" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_MKB42" );
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_SCAR" );
    GiveWeapon( "KFGameContent.KFWeap_LMG_Stoner63A" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_Thompson" );
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_M16M203" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_Medic" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_FNFal" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_MedicRifleGrenadeLauncher" );
	GiveWeapon( "KFGameContent.KFWeap_Minigun" );
}

/**
 * Give the player all Support weapons
 */
simulated exec function Shotty()
{
	GiveWeapon( "KFGameContent.KFWeap_Shotgun_MB500" );
	GiveWeapon( "KFGameContent.KFWeap_HRG_Revolver_Buckshot" );
    GiveWeapon( "KFGameContent.KFWeap_Shotgun_DoubleBarrel" );
    GiveWeapon( "KFGameContent.KFWeap_Shotgun_HZ12" );
    GiveWeapon( "KFGameContent.KFWeap_Shotgun_M4" );
    GiveWeapon( "KFGameContent.KFWeap_Shotgun_AA12" );
	GiveWeapon( "KFGameContent.KFWeap_Shotgun_ElephantGun" );
	GiveWeapon( "KFGameContent.KFWeap_Shotgun_DragonsBreath" );
	GiveWeapon( "KFGameContent.KFWeap_Shotgun_Nailgun" );
	GiveWeapon( "KFGameContent.KFWeap_Shotgun_Medic" );
}

simulated exec function MineRec()
{
    GiveWeapon( "KFGameContent.KFWeap_Mine_Reconstructor" );
}

simulated exec function FrostSAxe()
{
	GiveWeapon( "KFGameContent.KFWeap_Rifle_FrostShotgunAxe" );
}

/**
 * Give the player all Medic weapons
 */
simulated exec function Medic()
{
    GiveWeapon( "KFGameContent.KFWeap_Mine_Reconstructor" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Medic" );
    GiveWeapon( "KFGameContent.KFWeap_SMG_Medic" );
	GiveWeapon( "KFGameContent.KFWeap_HRG_Healthrower" );
    GiveWeapon( "KFGameContent.KFWeap_Shotgun_Medic" );
    GiveWeapon( "KFGameContent.KFWeap_Rifle_Hemogoblin" );
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_Medic" );
	GiveWeapon( "KFGameContent.KFWeap_Rifle_HRGIncision" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_MedicRifleGrenadeLauncher" );
	GiveWeapon( "KFGameContent.KFWeap_Blunt_MedicBat" );
	GiveWeapon( "KFGameContent.KFWeap_HRG_Vampire" );
}

/**
 * Give the player all Demolitionist weapons
 */
simulated exec function Demo()
{
    GiveWeapon( "KFGameContent.KFWeap_GrenadeLauncher_HX25" );
    GiveWeapon( "KFGameContent.KFWeap_Thrown_C4" );
    GiveWeapon( "KFGameContent.KFWeap_GrenadeLauncher_M79" );
	GiveWeapon( "KFGameContent.KFWeap_RocketLauncher_SealSqueal");
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_M16M203" );
    GiveWeapon( "KFGameContent.KFWeap_RocketLauncher_RPG7" );
    GiveWeapon( "KFGameContent.KFWeap_RocketLauncher_Seeker6" );
	GiveWeapon( "KFGameContent.KFWeap_GrenadeLauncher_M32" );
	GiveWeapon( "KFGameContent.KFWeap_Blunt_Pulverizer" );
	GiveWeapon( "KFGameContent.KFWeap_HuskCannon" );
	GiveWeapon( "KFGameContent.KFWeap_Shotgun_HRG_Kaboomstick" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_Blunderbuss" );
}

/**
 * Give the player all Firebug weapons
 */
simulated exec function Firebug()
{
    GiveWeapon( "KFGameContent.KFWeap_Flame_CaulkBurn" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Flare" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_DualFlare" );
    GiveWeapon( "KFGameContent.KFWeap_Shotgun_DragonsBreath" );
	GiveWeapon( "KFGameContent.KFWeap_SMG_Mac10" );
    GiveWeapon( "KFGameContent.KFWeap_Flame_Flamethrower" );
    GiveWeapon( "KFGameContent.KFWeap_Beam_Microwave" );
    GiveWeapon( "KFGameContent.KFWeap_HuskCannon" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_Microwave" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_HRGIncendiaryRifle" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_HRGScorcher" );
}

/**
 * Give the player all dual weapons
 */
simulated exec function Dualies()
{
    GiveWeapon( "KFGameContent.KFWeap_Revolver_DualRem1858" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_DualColt1911" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_DualG18" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_DualHRGWinterbite" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_DualDeagle" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_ChiappaRhinoDual" );
    GiveWeapon( "KFGameContent.KFWeap_Revolver_DualSW500" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_DualAF2011" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_DualFlare" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Dual9mm" );
}

simulated exec function Singles()
{
	GiveWeapon( "KFGameContent.KFWeap_Revolver_Rem1858" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Colt1911" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_HRGWinterbite" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Deagle" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_ChiappaRhino" );
    GiveWeapon( "KFGameContent.KFWeap_Revolver_SW500" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_AF2011" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_Medic" );
	GiveWeapon( "KFGameContent.KFWeap_Rifle_Winchester1894" );
	GiveWeapon( "KFGameContent.KFWeap_GrenadeLauncher_HX25" );
	GiveWeapon( "KFGameContent.KFWeap_Pistol_Flare" );
	GiveWeapon( "KFGameContent.KFWeap_Rifle_CenterfireMB464" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_9mm" );
}

/**
 * Give the player all Sharpshooter weapons
 */
simulated exec function Sharpshooter()
{
    GiveWeapon( "KFGameContent.KFWeap_Rifle_Winchester1894" );
    GiveWeapon( "KFGameContent.KFWeap_Rifle_CenterfireMB464" );
    GiveWeapon( "KFGameContent.KFWeap_Bow_Crossbow" );
	GiveWeapon( "KFGameContent.KFWeap_Rifle_MosinNagant" );
    GiveWeapon( "KFGameContent.KFWeap_Rifle_M14EBR" );
    GiveWeapon( "KFGameContent.KFWeap_Rifle_RailGun" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_FNFal" );
	GiveWeapon( "KFGameContent.KFWeap_Rifle_M99" );
	GiveWeapon( "KFGameContent.KFWeap_Revolver_Rem1858" );
	GiveWeapon( "KFGameContent.KFWeap_Revolver_SW500" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Flare" );
    GiveWeapon( "KFGameContent.KFWeap_Bow_CompoundBow" );
}

/**
 * Give the player all Swat weapons
 */
simulated exec function SWAT()
{
    GiveWeapon( "KFGameContent.KFWeap_SMG_MP7" );
    GiveWeapon( "KFGameContent.KFWeap_SMG_MP5RAS" );
	GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_Thompson" );
	GiveWeapon( "KFGameContent.KFWeap_HRG_Nailgun" );
    GiveWeapon( "KFGameContent.KFWeap_SMG_P90" );
    GiveWeapon( "KFGameContent.KFWeap_SMG_HK_UMP");
    GiveWeapon( "KFGameContent.KFWeap_SMG_Kriss" );
	GiveWeapon( "KFGameContent.KFWeap_SMG_G18" );
	GiveWeapon( "KFGameContent.KFWeap_SMG_Medic" );
	GiveWeapon( "KFGameContent.KFWeap_SMG_Mac10" );
}

/** Give the player all survivalist weapons */
exec function Surv()
{
    GiveWeapon( "KFGameContent.KFWeap_HRG_EMP_ArcGenerator" );
    GiveWeapon( "KFGameContent.KFWeap_Ice_FreezeThrower" );
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_LazerCutter" );
    GiveWeapon( "KFGameContent.KFWeap_HRG_SonicGun" );
}

/**
 * Give the player all 3d scope using weapons
 */
simulated exec function Scope()
{
    GiveWeapon( "KFGameContent.KFWeap_Rifle_M14EBR" );
}

/**
 * Give the player all assault rifle weapons
 */
simulated exec function ScopeFOV(float NewFOV)
{
    if( KFWeap_ScopedBase(Pawn.Weapon) != none )
    {
        KFWeap_ScopedBase(Pawn.Weapon).SceneCapture.SetCaptureParameters( ,NewFOV );
    }
}

simulated exec function Winter()
{
    GiveWeapon( "KFGameContent.KFWeap_Pistol_DualHRGWinterbite" );
    GiveWeapon( "KFGameContent.KFWeapDef_HRGWinterbite" );
    GiveWeapon( "KFGameContent.KFWeap_Rifle_HRGIncision" );
    GiveWeapon( "KFGameContent.KFWeap_SMG_G18" );
	GiveWeapon( "KFGameContent.KFWeap_Rifle_MosinNagant" );
}

simulated exec function Summer() //give the player the weapons for the summer update
{
    GiveWeapon( "KFGameContent.KFWeap_Blunt_PowerGloves" );
    GiveWeapon( "KFGameContent.KFWeap_Rifle_M99" );
    GiveWeapon( "KFGameContent.KFWeap_GrenadeLauncher_M32" );
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_Thompson" );
    GiveWeapon( "KFGameContent.KFWeap_AssaultRifle_MKB42" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_ChiappaRhinoDual" );
}

/**
 * Give the player all flame weapons
 */
simulated exec function Flame()
{
    Firebug();
}

/**
 * Give the player all rifle weapons
 */
simulated exec function Rifle()
{
    GiveWeapon( "KFGameContent.KFWeap_Rifle_Winchester1894" );
}

/**
 * Give the player all SMG weapons
 */
simulated exec function SMG()
{
    Swat();
    GiveWeapon( "KFGameContent.KFWeap_SMG_Medic" );
}

/* AllWeapons
	Give player all available weapons
*/
exec function AllWeapons()
{
    GiveWeapon( "KFGameContent.KFWeap_Pistol_9mm" );
    GiveWeapon( "KFGameContent.KFWeap_Pistol_Deagle" );
    Assault();
    Berserk();
    Demo();
    Firebug();
    Medic();
    Swat();
    Shotty();
    Surv();
}

/**
 * Toggle recoil on and off for testing
 */
simulated exec function KillRecoil()
{
	if( Pawn != none && KFWeapon(Pawn.Weapon) != none )
	{
        KFWeapon(Pawn.Weapon).maxRecoilPitch = 0;
    	KFWeapon(Pawn.Weapon).minRecoilPitch = 0;
    	KFWeapon(Pawn.Weapon).maxRecoilYaw = 0;
    	KFWeapon(Pawn.Weapon).minRecoilYaw = 0;
    	ClientMessage("Recoil Disabled", CheatType );
	}
}

simulated exec function WeapFOV(float NewFov, optional bool bScaleByAspectRatio = true)
{
	local float AdjustedFOV;
    local float DummyParam;

    if( KFWeapon(Pawn.Weapon) != none )
    {
        if( bScaleByAspectRatio )
        {
            AdjustedFOV = KFPlayerController(Outer).CalcFOVForAspectRatio(NewFOV, myHUD.SizeX, myHUD.SizeY, DummyParam);
        }
        else
        {
            AdjustedFOV = NewFOV;
        }

        KFWeapon(Pawn.Weapon).SetFOV(AdjustedFOV);
    }
}

/** Enables quick custom depth of field settings */
exec function QuickDOF( bool bEnableDOF,
                        optional float StaticDOFDistance=1000.f,
                        optional float Aperture=0.25f,
                        optional float FocusBlendRate=0.f )
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController( Outer );
    if( KFPC != none )
    {
        KFPC.ClientEnableDepthOfField( bEnableDOF, StaticDOFDistance, Aperture, FocusBlendRate );
    }
}

/** Enables more precise DOF settings */
exec function CustomDOF( bool bEnableDOF,
                            optional float FocalDistance=1200.f,
                            optional float FocalRadius=1200.f,
                            optional float SharpRadius=1000.f,
                            optional float MinBlurSize=0.0f,
                            optional float MaxNearBlurSize=4.0f,
                            optional float MaxFarBlurSize=3.0f,
                            optional float ExpFalloff=1.0f,
                            optional float BlendInSpeed=1.0f,
                            optional float BlendOutSpeed=1.0f )
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController( Outer );
    if( KFPC != none )
    {
        KFPC.ClientCustomDepthOfField( bEnableDOF,
                                        FocalDistance,
                                        FocalRadius,
                                        SharpRadius,
                                        MinBlurSize,
                                        MaxNearBlurSize,
                                        MaxFarBlurSize,
                                        ExpFalloff,
                                        BlendInSpeed,
                                        BlendOutSpeed );
    }
}

simulated exec function ShowDownloadPopup(string NewText, string NewTExt2)
{
	local KFPlayerController KFPC;
	KFPC = KFPlayerController(Outer);

	KFPC.ShowConnectionProgressPopup( PMT_DownloadProgress, NewText, NewTExt2);
}

/**
 * Screen blur
 */
simulated exec function BackgroundBlur(bool bBlur)
{
	local KFPlayerController KFPC;
	local KFPawn KFP;

	KFPC = KFPlayerController(Outer);
	KFP = KFPawn(Pawn);

	if( bBlur )
	{
		KFPC.EnableBlur(true, 6.0, 1.0, 1.0);
		KFPC.ConsoleCommand("PlayersOnly");
		KFPC.EnableReflections(false);

		if( KFPC.UsingFirstPersonCamera() )
		{
			KFP.SetFirstPersonVisibility(false);
			KFP.DetachComponent(KFP.ArmsMesh);
		}
	}
	else
	{
		KFPC.EnableBlur(false, 0.0, 1.0, 1.0);
		KFPC.ConsoleCommand("PlayersOnly");
		KFPC.EnableReflections(true);

		if( KFPC.UsingFirstPersonCamera() )
		{
			KFP.SetFirstPersonVisibility(true);
			KFP.AttachComponent(KFP.ArmsMesh);
		}
	}
}

/**
 * Hide first person weapon and hands
 */
 exec function ShowHands(bool bShow)
 {
    local KFPlayerController KFPC;
    local KFPawn KFP;

    KFPC = KFPlayerController(Outer);
    KFP = KFPawn(Pawn);

    if( !bShow)
    {
        if( KFPC.UsingFirstPersonCamera() )
        {
            KFP.SetFirstPersonVisibility(false);
            KFP.DetachComponent(KFP.ArmsMesh);
        }
    }
    else
    {
        if( KFPC.UsingFirstPersonCamera() )
        {
            KFP.SetFirstPersonVisibility(true);
            KFP.AttachComponent(KFP.ArmsMesh);
        }
    }
 }

/**
 * Scale weapon shoot camera anims for testing
 */
simulated exec function ScaleShootCameraAnims(float NewScale)
{
    local int i;

	if( Pawn != none && KFWeapon(Pawn.Weapon) != none )
	{
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLastAnim, NewScale);


		for( i = 0; i < KFWeapon(Pawn.Weapon).FireSightedAnims.Length; i++ )
		{
            SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireSightedAnims[i], NewScale);
		}

        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopSightedAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLastSightedAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopStartAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopStartSightedAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopEndAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopEndSightedAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireScopedAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopScopedAnim, NewScale);
        SetWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLastScopedAnim, NewScale);
        SetWeaponCameraAnimScale('Shoot_Burst2', NewScale);
        SetWeaponCameraAnimScale('Shoot_Burst', NewScale);
        SetWeaponCameraAnimScale('Shoot_Burst2_Iron', NewScale);
        SetWeaponCameraAnimScale('Shoot_Burst_Iron', NewScale);
	}
}

/**
 * Scale weapon shoot camera anims for testing
 */
simulated exec function RestoreShootCameraAnims()
{
    local int i;

	if( Pawn != none && KFWeapon(Pawn.Weapon) != none )
	{
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLastAnim);


		for( i = 0; i < KFWeapon(Pawn.Weapon).FireSightedAnims.Length; i++ )
		{
            RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireSightedAnims[i]);
		}

        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopSightedAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLastSightedAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopStartAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopStartSightedAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopEndAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopEndSightedAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireScopedAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLoopScopedAnim);
        RestoreWeaponCameraAnimScale(KFWeapon(Pawn.Weapon).FireLastScopedAnim);
        RestoreWeaponCameraAnimScale('Shoot_Burst2');
        RestoreWeaponCameraAnimScale('Shoot_Burst');
        RestoreWeaponCameraAnimScale('Shoot_Burst2_Iron');
        RestoreWeaponCameraAnimScale('Shoot_Burst_Iron');
	}
}

simulated function SetWeaponCameraAnimScale(name CameraAnimName, float NewScale)
{
    local AnimSequence AnimSeq;
    local int i;
    local KFAnimNotify_CameraAnim CameraAnim;

	if( Pawn != none && KFWeapon(Pawn.Weapon) != none )
	{

        AnimSeq = KFWeapon(Pawn.Weapon).MySkelMesh.FindAnimSequence( CameraAnimName );

        if( AnimSeq != none )
        {
        	for(i=0; i<AnimSeq.Notifies.length; i++)
        	{
        		CameraAnim = KFAnimNotify_CameraAnim(AnimSeq.Notifies[i].Notify);
                // Set the CameraAnimScale
        		if( CameraAnim != none)
        		{
        			CameraAnim.CameraAnimScale = NewScale;
        		}
        	}
    	}
	}
}

simulated function RestoreWeaponCameraAnimScale(name CameraAnimName)
{
    local AnimSequence AnimSeq;
    local int i;
    local KFAnimNotify_CameraAnim CameraAnim;

	if( Pawn != none && KFWeapon(Pawn.Weapon) != none )
	{

        AnimSeq = KFWeapon(Pawn.Weapon).MySkelMesh.FindAnimSequence( CameraAnimName );

        if( AnimSeq != none )
        {
        	for(i=0; i<AnimSeq.Notifies.length; i++)
        	{
        		CameraAnim = KFAnimNotify_CameraAnim(AnimSeq.Notifies[i].Notify);
                // Set the CameraAnimScale
        		if( CameraAnim != none)
        		{
        			CameraAnim.CameraAnimScale = CameraAnim.default.CameraAnimScale;
        		}
        	}
    	}
	}
}

simulated exec function DramaEvent(float Chance, optional float Duration=3.f, optional bool bPartial)
{
	if( KFGameInfo(WorldInfo.Game) != none )
	{
		ClientMessage("DramaEvent Chance = "$Chance$" Duration = "$Duration, CheatType );

		KFPlayerController(Outer).bForcePartialZedTime = bPartial;
		KFGameInfo(WorldInfo.Game).DramaticEvent(Chance, Duration);
		KFPlayerController(Outer).bForcePartialZedTime = KFPlayerController(Outer).default.bForcePartialZedTime;
	}
}

exec function TestCheat()
{
    `log("Cheat Manager works!");
}

exec function ImRich()
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
	if ( KFPRI != None )
	{
		KFPRI.AddDosh( 1000000 );
	}
}

exec function DoshMe(int NewDoshAmount)
{
    local KFPlayerReplicationInfo KFPRI;
    KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
    if ( KFPRI != None )
    {
        NewDoshAmount = NewDoshAmount - KFPRI.Score;
        KFPRI.AddDosh( NewDoshAmount );
    }
}

//SHOPPINGSPREE COMMAND BY DISNEY NGUYEN -
//for speeding up the buying of tier 4 weapons for boss testing
//and grants a realistic amount of 5000 dosh to prevent spamming dosh throws
exec function ShoppingSpree()
{
	//Give player 5000 dosh:

	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
	if (KFPRI != None)
	{
		KFPRI.AddDosh(5000);
	}
	//Open trader menu:
	KFPlayerController(Outer).OpenTraderMenu(true);
}

exec function HurtMe(optional int DamageAmount=50)
{
	if ( Pawn != none  )
	{
		Pawn.TakeDamage(DamageAmount, none, vect(0,0,0), vect(0,0,0), none);
	}
}

exec function DoTMe(optional int DamageAmount=50)
{
    KFPawn(Pawn).ApplyDamageOverTime(DamageAmount, Pawn.Controller, class'KFDT_Fire');
}

/* Heal Player */
exec function HealMe( optional int HealAmount=50 )
{
	if ( Pawn != none )
	{
		Pawn.HealDamage(HealAmount, Pawn.Controller, none);
	}
}

/* Armor Player */
exec function ArmorMe( optional int ArmorAmount=50 )
{
	if ( Pawn != none && KFPawn_Human(Pawn) != none )
	{
		KFPawn_Human(Pawn).AddArmor( ArmorAmount );
	}
}

exec function PlayMuzzleFlash()
{
	local KFPawn KFP;

	KFP = KFPawn(Pawn);
	if ( KFP != None )
	{
		KFP.WeaponAttachment.MuzzleFlash.CauseMuzzleFlash();
	}
}

exec function PlayShellEject()
{
	local KFWeapon KFW;

	KFW = KFWeapon(Pawn.Weapon);
	if ( KFW != None )
	{
		if (KFW.MuzzleFlash != None )
		{
			KFW.MuzzleFlash.CauseShellEject();
		}
	}
}

exec function SpamShellEject(float LifeParam=0.f, float interval=0.05)
{
	local KFWeapon KFW;

	if (IsTimerActive(nameof(PlayShellEject), self))
	{
		ClearTimer(nameof(PlayShellEject), self);
		return;
	}

	KFW = KFWeapon(Pawn.Weapon);
	if ( KFW != None )
	{
		if (KFW.MuzzleFlash == None)
		{
			KFW.AttachMuzzleFlash();
		}

		if (KFW.MuzzleFlash != None && LifeParam > 0.f)
		{
			KFW.MuzzleFlash.SetShellEjectLife(LifeParam);
		}
	}

	SetTimer(interval,true,nameof(PlayShellEject),self);
}

simulated exec function TestHitZones()
{
    local Actor TestActor;
    local vector HitLocation, HitNormal, TraceStart, TraceEnd;
    local TraceHitInfo		CurrentImpact;

    TraceStart = PlayerCamera.CameraCache.POV.Location;
    TraceEnd = PlayerCamera.CameraCache.POV.Location+vector(PlayerCamera.CameraCache.POV.Rotation)*2000;

	foreach Pawn.TraceActors( class'Actor', TestActor, HitLocation, HitNormal, TraceEnd, TraceStart,,CurrentImpact, TRACEFLAG_Bullet )
	{
		if ( (TestActor.bBlockActors || TestActor.bProjTarget)  )
		{
            `log("Hit this: "$TestActor$" "$CurrentImpact.HitComponent$" "$CurrentImpact.BoneName);
		}
	}
}

/* Throws a dynamic light component out in front of the player.  Used for testing lighting in KF2 maps*/
exec simulated function SpawnFlare(optional float NewBrightness=1.f, optional float NewRadius=512.f, optional byte R=255, optional byte G=255, optional byte B=255)
{
    local KFDebugFlare NewFlare;

    if(Pawn == none || Pawn.Weapon == none)
    {
        return;
    }

    NewFlare = Pawn.Spawn(class 'KFDebugFlare',,,Pawn.Weapon.GetPhysicalFireStartLoc());
    if(NewFlare != none)
    {
        NewFlare.Velocity = (500.f * Vector(Pawn.Rotation)) + (vect(0,0,1) * 150.f) ;
        NewFlare.FlareLight.SetLightProperties(NewBrightness,MakeColor(R,G,B));
        NewFlare.FlareLight.Radius = NewRadius;
    }
}

/* Clears out all flares from the map */
exec function KillFlares()
{
    local KFDebugFlare Flare;

    foreach Pawn.DynamicActors(class 'KFDebugFlare',Flare)
    {
        Flare.Destroy();
    }
}

/** Sets maximum ammo on all weapons */
exec function AllAmmo()
{
	local KFWeapon KFW;

	if (Pawn == None)
		return;

	ForEach Pawn.InvManager.InventoryActors(class'KFWeapon', KFW)
	{
		KFW.AmmoCount[0] = KFW.MagazineCapacity[0];
        KFW.AddAmmo(KFW.GetMaxAmmoAmount(0));
        KFW.AddSecondaryAmmo(KFW.MagazineCapacity[1]);

	}

	if( KFInventoryManager(Pawn.InvManager) != none )
	{
	   KFInventoryManager(Pawn.InvManager).AddGrenades(100);
	}
}

exec function UberAmmo()
{
	local KFWeapon KFW;

	if (Pawn == None)
		return;

	ForEach Pawn.InvManager.InventoryActors(class'KFWeapon', KFW)
	{
		KFW.SpareAmmoCount[0] = KFW.GetMaxAmmoAmount(0) * 3;
		KFW.AmmoCount[0] = KFW.MagazineCapacity[0];
		KFW.AmmoCount[1] = KFW.MagazineCapacity[1];
		KFW.bInfiniteAmmo = true;
	}

	if( KFInventoryManager(Pawn.InvManager) != none )
	{
	   KFInventoryManager(Pawn.InvManager).GrenadeCount = 255;
	}
}

exec function NoAmmo ()
{
    local KFWeapon KFW;

    if (Pawn == None)
        return;

    ForEach Pawn.InvManager.InventoryActors(class'KFWeapon', KFW)
    {
        KFW.SpareAmmoCount[0] = 0;
        KFW.AmmoCount[0] = 0;
        KFW.AmmoCount[1] = 0;
        KFW.bInfiniteAmmo = false;
    }

    if( KFInventoryManager(Pawn.InvManager) != none )
    {
       KFInventoryManager(Pawn.InvManager).GrenadeCount = 0;
    }
}

/** Turns weapon pausibility on/off */
exec function ToggleWeapCanPause()
{
	local KFWeapon KFW;
	KFW = KFWeapon(Pawn.Weapon);
	if( KFW != none )
	{
		KFW.bPauseWithPlayersOnly = !KFW.bPauseWithPlayersOnly;
	}
}

/** Turns weapon recoil on/off */
exec function SetDebugRecoil3d(bool bNewDebug)
{
	local KFWeapon KFW;
	KFW = KFWeapon(Pawn.Weapon);
	if( KFW != none )
	{
		KFW.bDebugRecoilPosition = bNewDebug;
	}
}

exec function SetIronIdleAnims( bool bNewUseAnims )
{
	local KFWeapon KFW;
	KFW = KFWeapon(Pawn.Weapon);
	if( KFW != none )
	{
		if( bNewUseAnims )
		{
            KFW.IdleSightedAnims[0]='';
		}
		else
		{
            KFW.IdleSightedAnims[0]=KFW.default.IdleSightedAnims[0];
		}
	}
}

/** Turns weapon recoil on/off */
exec function SetISMeshCompScale(float DebugScale)
{
	local KFWeapon KFW;
	KFW = KFWeapon(Pawn.Weapon);
	if( KFW != none )
	{
		KFW.IronSightMeshFOVCompensationScale = DebugScale;
	}
}

/** Turns weapon recoil on/off */
exec function NoRecoil()
{
	local KFWeapon KFW;
	KFW = KFWeapon(Pawn.Weapon);
	if( KFW != none )
	{
		KFW.maxRecoilPitch = 0;
		KFW.minRecoilPitch = 0;
		KFW.maxRecoilYaw = 0;
		KFW.minRecoilYaw = 0;
		ClientMessage("Recoil Disabled", CheatType );
	}
}

/** Turns weapon recoil on/off */
exec function GoRecoil()
{
	local KFWeapon KFW;
	KFW = KFWeapon(Pawn.Weapon);
	if( KFW != none )
	{
		KFW.maxRecoilPitch = KFW.default.maxRecoilPitch;
		KFW.minRecoilPitch = KFW.default.minRecoilPitch;
		KFW.maxRecoilYaw = KFW.default.maxRecoilYaw;
		KFW.minRecoilYaw = KFW.default.minRecoilYaw;
		ClientMessage("Recoil Enabled", CheatType );
	}
}

exec function ShowTraderPath()
{
	KFGameInfo(WorldInfo.Game).MyKFGRI.OpenedTrader.ShowTraderPath();
}

exec function HideTraderPath()
{
	KFGameInfo(WorldInfo.Game).MyKFGRI.OpenedTrader.HideTraderPath();
}

exec function OpenTrader()
{
	KFGameInfo(WorldInfo.Game).MyKFGRI.bTraderIsOpen = true;
	KFGameInfo(WorldInfo.Game).MyKFGRI.OpenTrader(300);
}

exec function OpenTraderNext()
{
	KFGameInfo(WorldInfo.Game).MyKFGRI.bTraderIsOpen = true;
	KFGameInfo(WorldInfo.Game).MyKFGRI.OpenTraderNext(300);
}

exec function OpenTraderMenu()
{
	KFPlayerController(Outer).OpenTraderMenu( true );
}

/**
 * Abbreviated FlushPersistentDebugLines
 */
exec function FPDL()
{
	FlushPersistentDebugLines();
}

// Debug exec to teleport player to location of actor with specified name
exec function GotoActor( name ActorName )
{
	local Actor A;

	foreach allactors( class'Actor', A )
	{
		if( A.Name == ActorName )
		{
			Ghost();
			Pawn.SetLocation( A.Location );
		}
	}
}

exec function AIHelp()
{
	`log( "--------------------------------------------------------------------------------------------", true );
	`log( "AI Debug Commands", true );
	`log( "--------------------------------------------------------------------------------------------", true );
	`log( "	AIDEBUG					Makes AI non-aggressive and ready to receive debug commands", true );
	`log( " AISETCANATTACK True/False Sets whether the debug mode pawn should be capable of attacking you", true );
	`log( "	TOGGLEALLNPCDEBUG		Renders names, some vital info, and a health bar above NPC heads", true );
	`log( "	AISTEPASIDE				Forces StepAside AI Command", true );
	`log( "	AITOGGLEHEADTRACKING	Toggles AI HeadTracking", true );
	`log( "	AIDEBUGTURNINPLACE		Starts TurnInPlace debug command - AI will constantly turn to player", true );
	`log( "	AITAUNT					Forces AI to execute a taunt command", true );
	`log( "	AIPATHTO <name>			AI will attempt to move/path to KFPathnode with DebugTagName matching <name>", true );
	`log( "--------------------------------------------------------------------------------------------", true );
}

/** Forces the Husk you're aiming at to become suicidal */
exec function AIHuskFlamethrower()
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim();
	if( KFAIC != none && KFAIC.Pawn != none && KFAIC.Pawn.Health > 0 && KFAIC.Pawn.IsA('KFPawn_ZedHusk') )
	{
		KFAIC.MovementPlugin.DisablePlugin();
		KFPawn(KFAIC.Pawn).DoSpecialMove(SM_HoseWeaponAttack, true, Pawn, 255);
	}
	else
	{
		ClientMessage( "You must be aiming toward a living Husk to execute this command.", CheatType );
	}
}

/** Renders debug sphere at NPC you're aiming at, draws a debug line from the NPC "Length" units in front if it.
	Why? I forget. */
exec function DrawLineFromNPC( optional float Length=500.f )
{
	local KFDebugLines KFDL;
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim();

	if( KFAIC != none && KFAIC.Pawn != none )
	{
		KFDL = class'KFDebugLines'.static.GetDebugLines();
		KFDL.AddDebugSphere( KFAIC.Pawn.Location, 32, 8, 0, 255, 0, true );
		KFDL.AddDebugLine( KFAIC.Pawn.Location, KFAIC.Pawn.Location + vector(KFAIC.Pawn.Rotation) * Length, 255, 0, 0, true );
		KFDL.AddDebugText3D( KFAIC.Pawn.Location + (vector(KFAIC.Pawn.Rotation) * (Length * 0.5f)), Length@"Units", true, 0, 0, 255, true );
	}
}

exec function AllZedsTaunt(optional bool bSlow = true)
{
	local KFPawn_Monster KFPM;
	local bool bFound;

	foreach WorldInfo.AllPawns(class'KFPawn_Monster', KFPM)
	{
		if (KFPM.MyKFAIC != none && KFPM.IsAliveAndWell())
		{
			class'AICommand_TauntEnemy'.static.Taunt(KFPM.MyKFAIC, KFPawn(Pawn), TAUNT_EnemyKilled);
			bFound = TRUE;
		}
	}

	if (bFound && bSlow)
	{
		SetTimer(2.5f, false, nameof(ZedTauntTimer), self);
	}
}

/** The best cheat ever. In fact you should consider removing every cheat in the game except this one just to
	save them from the humiliation of being so ridiculously inferior. That's assuming that this still works (it might
	not anymore).  Nevertheless, let it stand as a monument and never be forgotten. */
exec function SlasherTaunt( optional bool bSlow=true )
{
	local KFPawn_Monster KFPM;
	local bool bFound;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.MyKFAIC != none && KFPM.IsA('KFPawn_ZedClot_Slasher') && KFPM.IsAliveAndWell() )
		{
			class'AICommand_TauntEnemy'.static.Taunt(KFPM.MyKFAIC, KFPawn(Pawn), TAUNT_EnemyKilled );
			bFound = TRUE;
		}
	}

	if ( !bFound )
	{
		// Try to create one and give it one more try
		SpawnDebugAI( "ClotS" );
		foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
		{
			if( KFPM.MyKFAIC != none && KFPM.IsA('KFPawn_ZedClot_Slasher') && KFPM.IsAliveAndWell() )
			{
				class'AICommand_TauntEnemy'.static.Taunt(KFPM.MyKFAIC, KFPawn(Pawn), TAUNT_EnemyKilled );
				bFound = TRUE;
			}
		}
	}

	if( bFound && bSlow )
	{
		SetTimer(2.5f, false, nameof(SlasherTauntTimer), self);
	}
}

/** Called by SlasherTaunt */
function ZedTauntTimer()
{
	KFGameInfo(WorldInfo.Game).DramaticEvent(1.f, 13);
}

/** Called by SlasherTaunt */
function SlasherTauntTimer()
{
	KFGameInfo(WorldInfo.Game).DramaticEvent(1.f, 13);
}

/** Toggles NPC debug line continually updated and pointing to its current anchor. */
exec function AIShowAnchor()
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim();

	if( KFAIC != none && KFAIC.Pawn != none )
	{
		KFAIC.bDebug_DrawAnchor = !KFAIC.bDebug_DrawAnchor;
		if( KFAIC.bDebug_DrawAnchor )
		{
			ClientMessage( "Rendering line to "$KFAIC.Pawn$"'s anchor.", CheatType );
		}
	}
}

/** Renders a line going "up" from the NPC's current floor, with a sphere at the end of the line */
exec function AIDebugFloor()
{
	local KFAIController KFAIC;
	local vector Start, End;

	KFAIC = GetKFAICFromAim();

	if( KFAIC != none && KFAIC.Pawn != none )
	{
		Start = KFAIC.Pawn.Location + vector(KFAIC.Pawn.Rotation) * 64.f;
		End = Start + Pawn.Floor * 512.f;
		DrawDebugLine( Start, End, 0, 0, 255, TRUE );
		DrawDebugSphere( End, 24, 8, 0, 0, 255, TRUE );
	}
}

/** I have no idea what this does. Why can't anyone name their functions properly? */
exec function Puke( optional int SeqNum, optional bool bLooping=true )
{
	local KFPawn_Monster KFPM;
	local name SeqName;

	if( SeqNum == 1 )
	{
		SeqName = 'Atk_Vomit_V3';
	}
	else if( SeqNum == 2 )
	{
		SeqName = 'Atk_Vomit_Move_V1';
	}
	else
	{
		SeqName = 'Atk_Vomit_V1';
	}

	foreach WorldInfo.AllPawns(class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsA('KFPawn_ZedBloat') && KFPM.IsAliveAndWell() && KFPM.MyKFAIC != none && KFPM.MyKFAIC.bHasDebugCommand && KFPM.PawnAnimInfo != none )
		{
			KFPM.PlayBodyAnim( SeqName, EAS_FullBody,,,, bLooping );
		}
	}
}

/** Forces all living Zeds to begin acting as if they just lost their head. The head might be there visibly, but
	otherwise they are headless. */
exec function AIHeadlessWander()
{
	local KFPawn_Monster KFPM;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsAliveAndWell() && KFPM.MyKFAIC != none )
		{
 			KFPM.Health = 15.f;
			KFPM.CauseHeadTrauma();
		}
	}
}

/** Shows paths in-game which are currently blocked for an NPC of the type you are currently looking at.
	i.e, SpawnDebugAI FP, then ShowBlockedPath while aiming at him. Now you should see all pathnode connections
	which he would not be permitted to use (due to size, etc.). */
exec function ShowBlockedPaths( optional bool bSkipWalls=true, optional bool bRenderResult=true, optional bool bLogResult=true, optional float WithinPawnRadius=0.f )
{
	local KFPawn_Monster	KFMP;
	local KFAIController	KFAIC;
	local NavigationPoint	N;
	local int				SpecIdx, LocalBlockedSpecIdx, RouteCacheIdx, Cost, BlockedCount, Total;
	local bool				bInBlockedPathList;
	local string			BlockedStr;
	local float				BlockedTimeRemaining;

	if( !bRenderResult && !bLogResult )
	{
		bRenderResult = true;
	}

	KFMP = GetKFMPFromAim();

	if( KFMP != none && KFMP.MyKFAIC != none )
	{
		KFAIC = KFMP.MyKFAIC;

		if( bLogResult )
		{
			`log( "===============================================================================" );
			`log( "Blocked paths for "$KFMP$" <"$KFMP.MyKFAIC$"> at "$KFMP.Location$" [NPC Radius: "$KFMP.GetCollisionRadius()$" Height: "$KFMP.GetCollisionHeight()$"] Time: "$WorldInfo.TimeSeconds );
			`log( " " );
		}

		foreach WorldInfo.AllNavigationPoints( class'NavigationPoint', N )
		{
			if( (WithinPawnRadius > 0.f) && (VSize(N.Location - KFMP.Location) > WithinPawnRadius) )
			{
				continue;
			}

			// Log info about current NavPoint
			if( bLogResult )
			{
				`log( "   Checking "$N );
				`log( "    bBlocked:"$N.bBlocked$" bOneWayPath:"$N.bOneWayPath$" ExtraCost: "$N.ExtraCost );
				if( N.AnchoredPawn != none )
				{
					`log( "    AnchoredPawn:"$N.AnchoredPawn$" LastAnchoredPawnTime:"$N.LastAnchoredPawnTime );
				}
			}
			// Render sphere on Nav if it's blocked for all NPCs
			if( N.bBlocked && bRenderResult )
			{
				DrawDebugSphere( N.Location, 24, 6, 255, 0, 0, TRUE );
			}

			// Check blocked status of Nav's outgoing path connections
			for( SpecIdx = 0; SpecIdx < N.PathList.Length; SpecIdx++ )
			{
				bInBlockedPathList		= false;
				BlockedTimeRemaining	= 0.f;

				Total++;
				// Check the cost for Pawn type
				Cost = N.PathList[SpecIdx].GetCostFor(KFMP);

				// Check the KFMonsterPawn's local blocked path list (these stay blocked up to 30 seconds)
				for( LocalBlockedSpecIdx = 0; LocalBlockedSpecIdx < KFAIC.BlockedPathList.Length; LocalBlockedSpecIdx++ )
				{
					if( N.PathList[SpecIdx] == KFAIC.BlockedPathList[LocalBlockedSpecIdx].BlockedReachSpec )
					{
						bInBlockedPathList = true;
						BlockedTimeRemaining = KFAIC.BlockedPathList[LocalBlockedSpecIdx].BlockedTime;
						break;
					}
				}

				if( bInBlockedPathList || N.bBlocked || (Cost >= N.PathList[SpecIdx].BLOCKEDPATHCOST) )
				{
					BlockedCount++;
					if( bLogResult )
					{

						`log( "  Found blocked path for "$KFMP$" in NavPoint "$N$" [bBlocked:"$N.bBlocked$"][OneWay:"$N.bOneWayPath$"][ExtraCost:"$N.ExtraCost$"]" );
						if( N.AnchoredPawn != none )
						{
							`log( "   "$N$"'s anchored pawn is "$N.AnchoredPawn );
						}

						BlockedStr = "		**** Path from "$N$" to "$N.PathList[SpecIdx].End.Actor$" [Cost:"$Cost$" Start:"$N.PathList[SpecIdx].Start$" End:"$N.PathList[SpecIdx].End.Actor$" ReachFlags:"$N.PathList[SpecIdx].reachFlags$"] is blocked ";
						if( bInBlockedPathList )
						{
							BlockedStr = BlockedStr$"(ReachSpec Found In "$KFAIC$" BlockedPathList [TimeRemaining:"$BlockedTimeRemaining$" seconds]) ";
						}
						if( N.bBlocked )
						{
							BlockedStr = BlockedStr$"("$N$" bBlocked is TRUE) ";
						}
						`log( BlockedStr );

						`log( "		  Max Radius:"$N.PathList[SpecIdx].CollisionRadius$" Max Height:"$N.PathList[SpecIdx].CollisionHeight$" MaxLandingVelocity:"$N.PathList[SpecIdx].MaxLandingVelocity$" bCanCutCorners:"$N.PathList[SpecIdx].bCanCutCorners );
						for( RouteCacheIdx = 0; RouteCacheIdx < KFAIC.RouteCache.Length; RouteCacheIdx++ )
						{
							if( KFAIC.RouteCache[RouteCacheIdx] == N )
							{
								`log( "		  Found "$N$" in "$KFAIC$"'s routecache [Slot "$RouteCacheIdx$"]" );
								break;
							}
						}
					}
					if( bRenderResult )
					{
						DrawDebugLine( N.PathList[SpecIdx].Start.Location, N.PathList[SpecIdx].End.Actor.Location, 255, 0, 0, TRUE );
					}
				}
			}
			if( bLogResult )
			{
				`log( "-------------------------------------------------------------------------------" );
			}
		}
		if( bLogResult )
		{
			`log( " " );
			`log( "	  Found "$BlockedCount$" blocked paths (out of "$Total$" checked) for "$KFMP );
			`log( "===============================================================================" );
		}
	}
}

/** Currently only works for FP or CR, but easy to add more. Spawns a braindead Zed to use
	as a reference, then renders all pathnode connections which are navigable by Zeds of the
	type you specified. */
exec function ShowReachSpecsFor( name ZedType, optional bool bShowBlocked=true )
{
	local NavigationPoint N;
	local int SpecIdx;
	local float Radius, Height;
	local KFPawn Spawned;
	local bool bShowWallPaths;

	switch( ZedType )
	{
		case 'FP':
			Spawned = SpawnZed( "FP",, true );
			break;
		default:
			bShowWallPaths = true;
			Spawned = SpawnZed( "CR",, true );
	}

	if( Spawned != none )
	{
		Radius = Spawned.GetCollisionRadius();
		Height = Spawned.GetCollisionHeight();
	}

	foreach WorldInfo.AllNavigationPoints( class'NavigationPoint', N )
	{
		if( !bShowWallPaths && KFWallPathNode(N) != none )
		{
			continue;
		}

		for( SpecIdx = 0; SpecIdx < N.PathList.Length; SpecIdx++ )
		{
			if( (N.PathList[SpecIdx].CollisionRadius >= Radius && N.PathList[SpecIdx].CollisionHeight >= Height) )
			{
				//DrawDebugLine( N.PathList[SpecIdx].Start.Location, N.PathList[SpecIdx].End.Actor.Location, 255, 0, 0, true );
				DrawDebugLine( N.PathList[SpecIdx].Start.Location, N.PathList[SpecIdx].End.Actor.Location, 0, 255, 0, true );
			}
			else if( bShowBlocked )
			{
				DrawDebugLine( N.PathList[SpecIdx].Start.Location, N.PathList[SpecIdx].End.Actor.Location, 255, 0, 0, true );
			}
		}
	}
	if( Spawned != none )
	{
		Spawned.Destroy();
	}
}

/** Dumps KFPathnodes with DebugTags to the log file. */
exec function DumpDebugNodes()
{
	local KFPathnode KFPN;

	foreach WorldInfo.AllActors( class'KFPathnode', KFPN )
	{
		if( KFPN.DebugTag != '' )
		{
			`log( "Found "$KFPN$" with DebugTag "$KFPN.DebugTag$" at "$KFPN.Location );
		}
	}
}

/** Attempts to safely teleport you to the KFPathnode with a DebugTag matching TagName */
exec function GotoDebugNode( name TagName )
{
	local KFPathnode KFPN;

	foreach WorldInfo.AllActors( class'KFPathnode', KFPN )
	{
		if( KFPN.DebugTag != '' && KFPN.DebugTag == TagName )
		{
			if( bCollideWorld )
			{
				Ghost();
			}
			if( !Pawn.SetLocation(KFPN.Location + vect(0,0,32)) )
			{
				ClientMessage( "Ghost mode is on, but I failed to set your location!", CheatType );
			}
			else
			{
				ClientMessage( "Teleported to "$KFPN$"'s location ["$KFPN.Location$"] - Ghost Mode is on", CheatType );
			}
		}
	}
}

/** Renders any KFPathnodes with DebugTags, along with their DebugTags. KFDebugLines must be
	enabled either in the .ini (bAdvDebugLines=true) or by using the "KFDL" cheat to turn them on. */
exec function ShowDebugNodes( bool bOn=true )
{
	local KFDebugLines KFDL;
	local KFPathNode NP;
	local float WidestRadius;
	local int i;

	KFDL = class'KFDebugLines'.static.GetDebugLines();

	if( KFDL != none )
	{
		foreach allactors( class'KFPathNode', NP )
		{
			if( NP.DebugTag != '' && NP.DebugTag != NP.Class.Name )
			{
				if( bOn )
				{
					for( i = 0; i < NP.PathList.Length; i++ )
					{
						if( WidestRadius == 0.f || (NP.PathList[i].CollisionRadius < WidestRadius) )
						{
							WidestRadius = NP.PathList[i].CollisionRadius;
						}
					}

					KFDL.AddDebugSphere( NP.Location, WidestRadius, 8, 0, 255, 0, false, 120.f );
					KFDL.AddDebugText3D( NP.Location + vect(0,0,12), NP$": "$NP.DebugTag, true, 20, 70, 150, false, 120.f );
					WidestRadius = 0.f;
				}
				else
				{
					KFDL.ClearAll();
				}
			}
		}
	}
}

/** Overrides peripheral vision of the NPC you are aiming at */
exec function AISetPeriph( float NewPeripheralVision )
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim();

	KFAIC.MyKFPawn.PeripheralVision = NewPeripheralVision;
	ClientMessage( KFAIC.MyKFPawn$"'s peripheral vision is now "$KFAIC.MyKFPawn.PeripheralVision, CheatType );
}

exec function AIDebugVision()
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim( true );

	if( !KFAIC.bHasDebugCommand )
	{
		ClientMessage( KFAIC.MyKFPawn$" must have a controller in debug mode first!", CheatType );
	}
	AICommand_Debug(KFAIC.GetActiveCommand()).Debug_Vision( Pawn );
}

exec function AISetSightRadius( float NewSightRadius )
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim();

	KFAIC.MyKFPawn.SightRadius = NewSightRadius;
	ClientMessage( KFAIC.MyKFPawn$"'s sightradius is now "$KFAIC.MyKFPawn.PeripheralVision, CheatType );
}

/** Show when paths were last built */
exec function PathInfo()
{
	ClientMessage( "Paths last built: "$WorldInfo.LastSuccessfulPathBuildTime, CheatType );
}

/** Sends all active NPCs and not-yet-spawned NPCs into or out of debug mode */ 
exec function AIDebugMode( optional bool bDebugMode=true )
{
	local KFGameInfo KFG;
	local KFAIDirector AIManager;

	KFG = KFGameInfo( WorldInfo.Game );

	if( KFG != none )
	{
		AIManager = KFG.GetAIDirector();

		if( AIManager != none )
		{
			AIManager.SetAIDebug( bDebugMode );
			if( bDebugMode )
			{
				ClientMessage( "Debug mode turned on for active NPCs, and new NPCs will spawn in debug mode.", CheatType );
			}
			else
			{
				ClientMessage( "Debug mode turned off for active NPCs, and new NPCs will no longer spawn in debug mode.", CheatType );
			}
		}
	}
}

/** Draw the melee attack ranges of zeds*/
exec function ShowDebugStrikeRanges( optional bool bShowAll=false )
{
    ConsoleCommand("SETNOPEC KFAIController bDebug_ShowStrikeRange true");
    if( bShowAll )
    {
        ConsoleCommand("SETNOPEC KFAIController bDebug_ShowAllStrikeRange true");
    }
    else
    {
        ConsoleCommand("SETNOPEC KFAIController bDebug_ShowAllStrikeRange false");
    }
}

/** Hide the melee attack ranges of zeds */
exec function HideDebugStrikeRanges()
{
    ConsoleCommand("SETNOPEC KFAIController bDebug_ShowStrikeRange false");
    ConsoleCommand("SETNOPEC KFAIController bDebug_ShowAllStrikeRange false");
}

/** Sends all NPCs, or just the NPC aimed at, into debug mode */
exec function AIDebug( optional bool bAllZeds=false )
{
	local KFAIController KFAIC;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		if( KFAIC.Pawn != none && KFAIC.Pawn.IsAliveAndWell() )
		{
			if( bAllZeds || (IsAimingAt(KFAIC.Pawn, 0.95f)) )
			{
				KFAIC.StopAllLatentMovement();
				KFAIC.AbortMovementCommands();
				KFAIC.AbortMovementPlugIns();
				KFAIC.BeginDebugCommand();
			}
		}
	}
}

/** Begins AICommand_flee */
exec function AIFlee( optional float FleeDuration, optional float FleeDistance=5000.f )
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim();
	if( KFAIC != none )
	{
		KFAIC.DoFleeFrom( GetMyPawn(), FleeDuration, FleeDistance );
	}
}

/** Begins AICommand_wander */
exec function AIWander( optional bool bWanderTowardMe, optional bool bWanderAwayFromMe, optional float WanderDuration=-1.f, optional float MaxWanderDistance=10000.f )
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim();
	if( KFAIC != none )
	{
		if( bWanderTowardMe || bWanderAwayFromMe )
		{
			KFAIC.DoWander( GetMyPawn(), WanderDuration, bWanderAwayFromMe, MaxWanderDistance );
		}
		else
		{
			KFAIC.DoWander( , WanderDuration, false, MaxWanderDistance );
		}
	}
}

exec function AIDebugSteering()
{
	local AICommand_Debug DebugCommand;

	DebugCommand = GetDebugAICommand();

	if( DebugCommand != none )
	{
		DebugCommand.Debug_Steering();
	}
}

exec function AIDebugStepAside( optional bool bOn = true )
{
	local AICommand_Debug DebugCommand;

	DebugCommand = GetDebugAICommand();

	if( DebugCommand != none )
	{
		DebugCommand.Debug_StepAside( bOn );
	}
}

exec function ShowAIStuckNpcsToggle()
{
	local KFAIController KFAIC;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		KFAIC.ShowStuckNpcsToggle();
	}
}

exec function ToggleShowVisualStuckZedDebugInfo()
{
	local KFAIController KFAIC;
	local KFGameInfo kfGameInfo;

    if ( KFGameInfo( WorldInfo.Game ) == none )
    {
		return;
    }

    kfGameInfo = KFGameInfo( WorldInfo.Game );

	kfGameInfo.AIDirector.bShowVisualStuckZedDebugInfo = !kfGameInfo.AIDirector.bShowVisualStuckZedDebugInfo;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		KFAIC.bShowVisualStuckZedDebugInfo = !KFAIC.bShowVisualStuckZedDebugInfo;
		`log("ToggleShowVisualStuckZedDebugInfo - " @ KFAIC.bShowVisualStuckZedDebugInfo);

	}
}

exec function ToggleShowMovePointsDebugInfo()
{
	local KFAIController KFAIC;
	local KFGameInfo kfGameInfo;

    if ( KFGameInfo( WorldInfo.Game ) == none )
    {
		return;
    }

    kfGameInfo = KFGameInfo( WorldInfo.Game );

	kfGameInfo.AIDirector.bShowMovePointsDebugInfo = !kfGameInfo.AIDirector.bShowMovePointsDebugInfo;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		KFAIC.bShowMovePointsDebugInfo = !KFAIC.bShowMovePointsDebugInfo;
		`log("ToggleShowMovePointsDebugInfo - " @ KFAIC.bShowMovePointsDebugInfo);

	}
}

exec function ToggleShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState()
{
	local KFAIController KFAIC;
	local KFGameInfo kfGameInfo;

    if ( KFGameInfo( WorldInfo.Game ) == none )
    {
		return;
    }

    kfGameInfo = KFGameInfo( WorldInfo.Game );

	kfGameInfo.AIDirector.bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState = !kfGameInfo.AIDirector.bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		KFAIC.bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState = !KFAIC.bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState;
		`log("ToggleShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState - " @ KFAIC.bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState);
	}
}

exec function ToggleShowHighDetailCombatMovementDebugInfo()
{
	local KFAIController KFAIC;
	local KFGameInfo kfGameInfo;

    if ( KFGameInfo( WorldInfo.Game ) == none )
    {
		return;
    }

    kfGameInfo = KFGameInfo( WorldInfo.Game );

	kfGameInfo.AIDirector.bShowHighDetailCombatMovementDebugInfo = !kfGameInfo.AIDirector.bShowHighDetailCombatMovementDebugInfo;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		KFAIC.bShowHighDetailCombatMovementDebugInfo = !KFAIC.bShowHighDetailCombatMovementDebugInfo;
		`log("ToggleShowVisualStuckZedDebugInfo - " @ KFAIC.bShowHighDetailCombatMovementDebugInfo);

	}
}

exec function ToggleShowLeapDownDebugArtifacts()
{
	local KFAIController KFAIC;
	local KFGameInfo kfGameInfo;

    if ( KFGameInfo( WorldInfo.Game ) == none )
    {
		return;
    }

    kfGameInfo = KFGameInfo( WorldInfo.Game );

	kfGameInfo.AIDirector.bShowLeapDownDebugArtifacts = !kfGameInfo.AIDirector.bShowLeapDownDebugArtifacts;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		KFAIC.bShowLeapDownDebugArtifacts = !KFAIC.bShowLeapDownDebugArtifacts;
		`log( GetFuncName() @ " - " @ KFAIC.bShowLeapDownDebugArtifacts);

	}
}

exec function ToggleShowDoorNavigationDebugArtifacts()
{
	local KFAIController KFAIC;
	local KFGameInfo kfGameInfo;

    if ( KFGameInfo( WorldInfo.Game ) == none )
    {
		return;
    }

    kfGameInfo = KFGameInfo( WorldInfo.Game );

	kfGameInfo.AIDirector.bShowDoorNavigationDebugArtifacts = !kfGameInfo.AIDirector.bShowDoorNavigationDebugArtifacts;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		KFAIC.bShowDoorNavigationDebugArtifacts = !KFAIC.bShowDoorNavigationDebugArtifacts;
		`log( GetFuncName() @ " - " @ KFAIC.bShowDoorNavigationDebugArtifacts);

	}
}

exec function ToggleShowDestructibleNavigationDebugArtifacts()
{
	local KFAIController KFAIC;
	local KFGameInfo kfGameInfo;

    if ( KFGameInfo( WorldInfo.Game ) == none )
    {
		return;
    }

    kfGameInfo = KFGameInfo( WorldInfo.Game );

	kfGameInfo.AIDirector.bShowDestructibleNavigationDebugArtifacts = !kfGameInfo.AIDirector.bShowDestructibleNavigationDebugArtifacts;

	foreach AllActors( class'KFAIController', KFAIC )
	{
		KFAIC.bShowDestructibleNavigationDebugArtifacts = !KFAIC.bShowDestructibleNavigationDebugArtifacts;
		`log( GetFuncName() @ " - " @ KFAIC.bShowDestructibleNavigationDebugArtifacts);

	}
}

exec function CheckReachSpecs()
{
	local NavigationPoint NP;
	local int i, x, iCount;
	local array<NavigationPoint> Templist;
	foreach WorldInfo.AllNavigationPoints( class'NavigationPoint', NP )
	{
		for( i = 0; i < NP.PathList.Length; i++ )
		{
			if( NP.PathList[i].End.Actor == none )
			{
				`log( NP$" FOUND NO END FOR REACHSPEC "$NP.PathList[i]$" in slot "$i );
			}
			TempList.AddItem( NavigationPoint( NP.PathList[i].End.Actor) );
		}
		for( x = 0; x < NP.PathList.Length; x++ )
		{
			iCount = 0;
			for( i = 0; i < Templist.Length; i++ )
			{
				if( NavigationPoint( NP.PathList[x].End.Actor ) == Templist[ i ] )
				{
					if( iCount > 0 )
					{
						`log( "FOUND DUPE REACHSPEC ("$NP.PathList[x]$" IN "$NP$" LEADING TO "$Templist[ i ] );
					}
					iCount++;
				}
			}
		}
		TempList.Length = 0;
	}
}

/**
 * Gets KFAIController from player's aim
 * @param	bOnlyPawnsWithDebug	(Optional)
 * @return	Aimed-at KFPawn_Monster's KFAIController
 */
function KFAIController GetKFAICFromAim( optional bool bOnlyPawnsWithDebug, optional float Epsilon=0.92f )
{
	local KFPawn_Monster KFPM;

	foreach DynamicActors( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsAliveAndWell() && KFPM.MyKFAIC != none && IsAimingAt( KFPM, Epsilon ) )
		{
			if( bOnlyPawnsWithDebug && !KFPM.MyKFAIC.bHasDebugCommand )
			{
				continue;
			}

			return KFPM.MyKFAIC;
		}
	}
	return none;
}

/**
 * Gets KFPawn_Monster from player's aim
 * @param	bOnlyPawnsWithDebug	(Optional)
 * @return	Aimed-at KFPawn_Monster
 */
function KFPawn_Monster GetKFMPFromAim( optional bool bOnlyPawnsWithDebug )
{
	local KFPawn_Monster KFPM;

	foreach DynamicActors( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsAliveAndWell() && IsAimingAt( KFPM, 0.95f ) )
		{
			if( KFPM.MyKFAIC != none && (bOnlyPawnsWithDebug && !KFPM.MyKFAIC.bHasDebugCommand) )
			{
				continue;
			}

			return KFPM;
		}
	}
	return none;
}

exec function ToggleDebugCamera( optional bool bDrawDebugText=true )
{
	//ToggleAllOnScreenText();
	bGodMode = true;
	super.ToggleDebugCamera( bDrawDebugText );
}

/** Same as above, but abbreviated name */
exec function TDC( optional bool bDrawDebugText=true )
{
	ToggleDebugCamera( bDrawDebugText );
}

function EnableDebugCamera( bool bEnableDebugText )
{
	Super.EnableDebugCamera( bEnableDebugText );
	KFDebugCameraController(DebugCameraControllerRef).bDebugSceneEnabled = bDebugSceneEnabled;
	KFDebugCameraController(DebugCameraControllerRef).DebugSceneCamera = DebugSceneCamera;
	KFDebugCameraController(DebugCameraControllerRef).DebugTarget = DebugTarget;
}

exec function DumpInfoForAI( optional bool bOutputToConsole=true )
{
	local float TimeSinceLastRender;
	local string Info;
	local KFAIController KFAIC;

	foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
	{
		TimeSinceLastRender = `TimeSince( KFAIC.Pawn.LastRenderTime );
		Info = Info$" \n... "$KFAIC@KFAIC.Pawn$"(ActvCmd:"$KFAIC.GetActionString()$")  -- TimeSinceLastRender:"@TimeSinceLastRender@"Enemy:"@KFAIC.Enemy@"AILoc:"@KFAIC.Pawn.Location$"\n";
	}
	if( bOutputToConsole && Player != none && LocalPlayer(Player) != none )
	{
		LocalPlayer(Player).ViewportClient.ViewportConsole.OutputText( Info );
		//SendToConsole( Info );
	}
	`log( Info );
}

exec function ViewSelf( optional bool bQuiet )
{
	// TODO: Remove from local hud postrendered list instead
	if( ViewTarget != none && KFPawn_Monster(ViewTarget) != none )
	{
		KFPawn_Monster(ViewTarget).SetDebugTextRendering( false );
		SetNPCDebugCategory( false, 'AICommands' );
	}

	super.ViewSelf( bQuiet );
}

exec function ViewZed( optional bool bLogBugItInfo )
{
	local actor First;
	local bool bFound;
	local KFAIController C;

	foreach WorldInfo.AllControllers( class'KFAIController', C )
	{
		if( C.Pawn != None && C.Pawn.Health > 0 )
		{
			if( bFound || First == none )
			{
				First = C.Pawn;
				if( bFound )
				{
					break;
				}
			}
			if( C.PlayerReplicationInfo == RealViewTarget || C.Pawn == ViewTarget )
			{
				bFound = true;
			}
		}
	}

	if ( first != None )
	{
		`log("view "$first);
		SetViewTarget(First);
		SetCameraMode( 'FreeCam' );
		KFPawn_Monster(First).SetDebugTextRendering( true );
		SetNPCDebugCategory( true, 'AICommands' );
		FixFOV();
		if( bLogBugItInfo )
		{
			BugItAI( "Viewing from "$First$", health: "$Pawn(First).Health$" command: "$KFPawn_Monster(First).MyKFAIC.GetActiveCommand() );
		}
		ClientMessage( "Viewing from "$first$", type 'ViewSelf' to return to your body. Type 'Camera first' to switch to first-person.", CheatType );
	}
	else
		ViewSelf( true );
}

exec function TeleportPawnToCamera(optional bool bToggleDebugCameraOff = false)
{
	super.TeleportPawnToCamera( bToggleDebugCameraOff );
}

exec function AIMoveForward()
{
	GetDebugAICommand().Debug_MoveForward();
}

exec function AIHide_Debug()
{
	local KFPawn_Monster KFPM;
	foreach DynamicActors( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsAliveAndWell() && KFPM.MyKFAIC != none && IsAimingAt(KFPM, 0.88f) )
		{
			if( KFPM.MyKFAIC.bHasDebugCommand )
			{
				KFPM.MyKFAIC.SetEnemy( Pawn );
				AICommand_Debug( KFPM.MyKFAIC.GetActiveCommand() ).Debug_Hide();
			}
		}
	}
}

exec function AIFPRoam()
{
	local KFPawn_Monster KFPM;
	local KFAIController KFAIC;
	foreach DynamicActors( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsAliveAndWell() && KFPM.MyKFAIC != none )
		{
			if( KFPM.IsA( 'KFPawn_ZedFleshpound' ) )
			{
				KFAIC = KFPM.MyKFAIC;
				if( KFAIC.bHasDebugCommand )
				{
					AICommand_Debug(KFAIC.GetActiveCommand()).GotoState( 'Roaming' );
					break;
				}
			}
		}
	}
}

exec function EnterZedVictoryState()
{
    local KFAIController AI;
    foreach WorldInfo.AllControllers(class'KFAIController',AI)
    {
        AI.EnterZedVictoryState();
    }
}

exec function AddAIFilter( coerce string Filter )
{
	local KFAIController AI;
	local int Idx;
	local Name N;
	N = Name(Filter);
	foreach WorldInfo.AllControllers(class'KFAIController',AI)
	{
		Idx = AI.AILogFilter.Find( N );
		if( Idx < 0 )
		{
			AI.AILogFilter[AI.AILogFilter.Length] = N;
		}
	}
}

exec function RemoveAIFilter( coerce string Filter )
{
	local KFAIController AI;
	local int Idx;
	local Name N;
	N = Name(Filter);
	foreach WorldInfo.AllControllers(class'KFAIController',AI)
	{
		Idx = AI.AILogFilter.Find( N );
		if( Idx >= 0 )
		{
			Pawn.MessagePlayer( "Removed Filter"@Filter );
			AI.AILogFilter.Remove( Idx, 1 );
		}
	}
}

exec function FlushAILogs()
{
	local KFAIController GAI;

	if(!WorldInfo.bPlayersOnly)
	{
		DebugFreezeGame();
	}
	foreach WorldInfo.AllControllers(class'KFAIController', GAI)
	{
		if(GAI.AILogFile != none)
		{
			GAI.AILogFile.CloseLog();
			GAI.AILogFile.Destroy();
			GAI.AILogFile = none;
		}
	}
}

exec function AIFPEnrage()
{
	local KFPawn_Monster KFPM;
	local KFAIController KFAIC;
	//	local AICommand_Debug AID;

	foreach DynamicActors( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsAliveAndWell() && KFPM.MyKFAIC != none )
		{
			if( KFPM.IsA( 'KFPawn_ZedFleshpound' ) )
			{
				KFPM.MyKFAIC.Enemy = Pawn;
				KFAIC = KFPM.MyKFAIC;
				KFAIC.SetEnemy( Pawn );
				KFAIC.MyKFPawn.SetEnraged( true );
			}
		}
	}
}

exec function AIScream()
{
	local KFPawn_Monster KFPM, Siren;

	foreach DynamicActors( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsA('KFPawn_ZedSiren') && KFPM.IsAliveAndWell() && KFPM.MyKFAIC != none )
		{
			Siren = KFPM;
			KFPM.DoSpecialMove( SM_SonicAttack, true );
		}
	}
	foreach DynamicActors( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsA('KFPawn_ZedClot') )
		{
			KFPM.MyKFAIC.Focus = Siren;
			KFPM.LookAtPawn( Siren );
		}
	}
}


/** Toggles debug info rendering for the Zed, if any, player is aiming at */
exec function ToggleNPCDebug( optional name Category='All' )
{
	local KFPawn_Monster	KFPM;
	local bool				bNPCDebugIsOn;

	if( Category == '' )
	{
		Category = 'All';
	}

    // Clear out 'All' if we set something different
    if( Category != 'All' )
    {
        SetNPCDebugCategory( False, 'All' );
    }

    // Clear out 'AllVerbose' if we set something different
    if( Category != 'AllVerbose' )
    {
        SetNPCDebugCategory( False, 'AllVerbose' );
    }

	// See if player is aiming toward a Zed and get the Zed's controller if so.
	KFPM = GetKFMPFromAim();
	if( KFPM != none && KFPM.IsAliveAndWell() )
	{
		bNPCDebugIsOn = KFPM.bDebug_DrawOverheadInfo;
		// Toggle it
		bNPCDebugIsOn = !bNPCDebugIsOn;
		ClientMessage( "Turning "$(bNPCDebugIsOn?"on":"off")$" debug text rendering for "$KFPM, CheatType );
		KFPM.SetDebugTextRendering( bNPCDebugIsOn );
		SetNPCDebugCategory( bNPCDebugIsOn, Category );
	}
	else
	{
		ClientMessage( "You must be aiming toward a living NPC to use this command, or use 'ToggleAllNPCDebug' for ALL NPCs.", CheatType );
	}
}

exec function AIStepAside( optional bool bForMe )
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim();
	if( KFAIC != none && KFAIC.MyKFPawn != none && KFAIC.MyKFPawn.IsAliveAndWell() )
	{
		if( !bForMe )
		{
			ClientMessage( KFAIC.MyKFPawn$" stepping aside.", CheatType );
			KFAIC.StepAsideFor(KFAIC.MyKFPawn, Vector(KFAIC.MyKFPawn.Rotation) );
		}
		else
		{
			ClientMessage( KFAIC.MyKFPawn$" stepping out of your way.", CheatType );
			KFAIC.StepAsideFor(Pawn, Vector(Pawn.Rotation));
		}
	}
}

exec function ShowAIInfo( optional bool bOn=true )
{
	local KFPawn_Monster KFMP;

	KFMP = GetKFMPFromAim();

	if( DebugTarget != none && !DebugTarget.bDeleteMe && DebugTarget.Health > 0 && DebugTarget.MyKFAIC != none )
	{
		DebugTarget.SetDebugTextRendering( false );
		SetNPCDebugCategory( false, 'AICommands' );
		ClientMessage( "Turning off AICommand debugging for "$KFMP, CheatType );
		DebugTarget = none;
		return;
	}

	if( KFMP != none && KFMP.Health > 0 )
	{
		DebugTarget = KFMP;
		KFMP.SetDebugTextRendering( bOn );
		SetNPCDebugCategory( bOn, 'AICommands' );
		ClientMessage( "Turning on AICommand debugging for "$KFMP, CheatType );
	}
}

/** Toggles debug info rendering for ALL living Zeds and any who spawn later in the game session */
exec function ToggleAllNPCDebug( optional name Category='All' )
{
	local KFGameInfo		KFGI;
	local KFAIDirector		Director;
	local KFPawn_Monster	KFPM;
	local bool				bNPCDebugIsOn;

	if( Category == '' )
	{
		Category = 'All';
	}

    // Clear out 'All' if we set something different
    if( Category != 'All' )
    {
        SetNPCDebugCategory( False, 'All' );
    }

    // Clear out 'AllVerbose' if we set something different
    if( Category != 'AllVerbose' )
    {
        SetNPCDebugCategory( False, 'AllVerbose' );
    }

	KFGI = KFGameInfo( WorldInfo.Game );
	if( KFGI != none )
	{
		// Check the current AllNPCDebug status, stored in the KFAIDirector in order to set the debug mode for any NPCs spawned later
		Director = KFGI.GetAIDirector();
		if( Director != none )
		{
			// Toggle it
			Director.bShowAINames	= !Director.bShowAINames;
			bNPCDebugIsOn			= Director.bShowAINames;
			ClientMessage( "bShowAINames [Director] is now "$Director.bShowAINames, CheatType );
			ClientMessage( "bNPCDebugIsOn is "$bNPCDebugIsOn, CheatType );
		}
	}

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsAliveAndWell() )
		{
			KFPM.SetDebugTextRendering( bNPCDebugIsOn );
		}
	}

    SetNPCDebugCategory( bNPCDebugIsOn, Category );

	ClientMessage( "Turning "$(bNPCDebugIsOn?"on":"off")$" debug text rendering for NPCs", CheatType );
}

/** Sets debug info rendering for ALL living Zeds and any who spawn later in the game session */
exec function SetAllNPCDebug( bool bTurnOn, optional name Category='All' )
{
	local KFGameInfo		KFGI;
	local KFAIDirector		Director;
	local KFPawn_Monster	KFPM;

	if( Category == '' )
	{
		Category = 'All';
	}

    // Clear out 'All' if we set something different
    if( Category != 'All' )
    {
        SetNPCDebugCategory( False, 'All' );
    }

    // Clear out 'AllVerbose' if we set something different
    if( Category != 'AllVerbose' )
    {
        SetNPCDebugCategory( False, 'AllVerbose' );
    }

	KFGI = KFGameInfo( WorldInfo.Game );
	if( KFGI != none )
	{
		// Check the current AllNPCDebug status, stored in the KFAIDirector in order to set the debug mode for any NPCs spawned later
		Director = KFGI.GetAIDirector();
		if( Director != none )
		{
			// Toggle it
			Director.bShowAINames	= bTurnOn;
			ClientMessage( "bShowAINames [Director] is now "$Director.bShowAINames, CheatType );
			ClientMessage( "bTurnOn is "$bTurnOn, CheatType );
		}
	}

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.IsAliveAndWell() )
		{
			KFPM.SetDebugTextRendering( bTurnOn );
		}
	}

    SetNPCDebugCategory( bTurnOn, Category );

	ClientMessage( "Turning "$(bTurnOn?"on":"off")$" debug text rendering for NPCs", CheatType );
}

simulated function SetNPCDebugCategory( bool bTurnOn, optional name Category='All' )
{
	local PlayerController PC;
	local KFHUDBase KFHud;

	// final local player's hud object
	ForEach LocalPlayerControllers(class'PlayerController', PC)
	{
		KFHud = KFHUDBase(PC.MyHUD);
	}

	if ( KFHud != None )
	{
		// remove debugtype if already in array
		if (INDEX_NONE != KFHud.DebugDisplay.RemoveItem(Category))
		{
			KFHud.SaveConfig();
		}

		if( bTurnOn )
		{
            KFHud.ShowDebug(Category);
		}
		KFHud.bShowDebugInfo = false; // Otherwise PostRenderFor is not called
	}
}

// Abbreviated ToggleAllNPCDebug
exec function TAND( optional name Category='All' )
{
	ToggleAllNPCDebug( Category );
}


/** Show AI overhead text debug info (TODO: optional category filtering) */
exec function ShowAiDebugText( optional bool bAffectAllZeds=false, optional name DebugCategory ='All')
{
	local KFAIController KFAIC;
	local KFGameInfo KFGI;
	local KFAIDirector Director;

	if( DebugCategory == '' )
	{
		DebugCategory = 'All';
	}

    // Clear out 'All' if we set something different
    if( DebugCategory != 'All' )
    {
        SetNPCDebugCategory( False, 'All' );
    }

    // Clear out 'AllVerbose' if we set something different
    if( DebugCategory != 'AllVerbose' )
    {
        SetNPCDebugCategory( False, 'AllVerbose' );
    }

	if( bAffectAllZeds )
	{
		KFGI = KFGameInfo( WorldInfo.Game );
		if( KFGI != none )
		{
			Director = KFGI.GetAIDirector();
			Director.bShowAINames = !Director.bShowAINames;
			SetNPCDebugCategory( Director.bShowAINames, DebugCategory );

    		foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
    		{
    			KFAIC.bDebug_PostRenderInfo = !KFAIC.bDebug_PostRenderInfo;
    			KFAIC.bDebug_DrawOverheadInfo = KFAIC.bDebug_PostRenderInfo;
    			KFAIC.SetPostRendering( KFAIC.bDebug_PostRenderInfo );

                if( KFPawn_Monster(KFAIC.Pawn) != none && KFPawn_Monster(KFAIC.Pawn).IsAliveAndWell() )
                {
                    KFPawn_Monster(KFAIC.Pawn).SetDebugTextRendering( Director.bShowAINames );
                }
    		}
		}
	}
	else
	{
        // See if player is aiming toward a Zed and get the Zed's controller if so.
		KFAIC = GetKFAICFromAim();
		if( KFAIC != none && KFAIC.Pawn != none )
		{
			KFAIC.bDebug_PostRenderInfo = !KFAIC.bDebug_PostRenderInfo;
			KFAIC.bDebug_DrawOverheadInfo = KFAIC.bDebug_PostRenderInfo;
			SetNPCDebugCategory( KFAIC.bDebug_DrawOverheadInfo, DebugCategory );
			KFAIC.SetPostRendering( KFAIC.bDebug_PostRenderInfo );
            if( KFPawn_Monster(KFAIC.Pawn) != none && KFPawn_Monster(KFAIC.Pawn).IsAliveAndWell() )
            {
                KFPawn_Monster(KFAIC.Pawn).SetDebugTextRendering( KFAIC.bDebug_DrawOverheadInfo );
            }
		}
	}
}

exec function AIShowNames( optional bool bOff=false )
{
	local KFAIController KFAIC;
	local KFGameInfo KFGI;
	local KFAIDirector Director;

	KFGI = KFGameInfo( WorldInfo.Game );

	if( KFGI != none )
	{
		Director = KFGI.GetAIDirector();

		if( Director.bShowAINames && bOff )
		{
			ClientMessage( "Turning off AIShowNames...", CheatType );
			Director.bShowAINames = false;
		}
		else
		{
			if( Director.bShowAINames )
			{
				ClientMessage( "AIShowNames is already on, enter 'AIShowNames false' to turn off.", CheatType );
			}
			else
			{
				ClientMessage( "Turning on AIShowNames...", CheatType );
			}
			Director.bShowAINames = true;
		}

		foreach allactors( class'KFAIController', KFAIC )
		{
			KFAIC.bDebug_PostRenderInfo = Director.bShowAINames;
			KFAIC.bDebug_DrawOverheadInfo = Director.bShowAINames;
			//KFAIC.SetPostRendering( Director.bShowAINames );
		}
	}
}

exec function AIShowDebug()
{
	local KFAIController KFAIC;

	foreach allactors( class'KFAIController', KFAIC )
	{
		if( DebugKFAIC != none )
		{
			KFAIC.bDebug_DrawAIDebug = false;
			KFAIC.SetupDebug();
			DebugKFAIC = none;
		}
		if( KFAIC.Pawn != none && IsAimingAt( KFAIC.Pawn, 0.95f ) )
		{
			KFAIC.bDebug_DrawAIDebug = true;
			DebugKFAIC = KFAIC;
			KFAIC.SetupDebug();
		}
	}
}

function AICommand_Debug GetDebugAICommand()
{
	local KFAIController KFAIC;

	foreach allactors( class'KFAIController', KFAIC )
	{
		if( IsAimingAt(KFAIC.Pawn, 0.92f) )
		{
			if( KFAIC.GetActiveCommand().IsA( 'AICommand_Debug' ) )
			{
				return AICommand_Debug( KFAIC.GetActiveCommand() );
			}
		}
	}

	ClientMessage( "You need to be aiming at a DebugMode Zed in order for this to work.", CheatType );
	return none;
}

exec function MarkLocation()
{
	local vector SphereLocation;

	if( Pawn == none && DebugCameraController(Outer) != none )
	{
		SphereLocation = Outer.Location;
	}
	else
	{
		SphereLocation = Pawn.Location;
	}
	DrawDebugSphere( SphereLocation, 36, 8, 255, 255, 0, true );
}

exec function AISetEnemyToMe( optional bool bAllAI=false )
{
	local KFAIController KFAIC;

	if( !bAllAI )
	{
		KFAIC = GetKFAICFromAim();
		if( KFAIC != none )
		{
			KFAIC.SetEnemy( Outer.Pawn );
		}
	}
	else
	{
		foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
		{
			if( KFAIC.Pawn != none && KFAIC.Pawn.IsAliveAndWell() )
			{
				KFAIC.SetEnemy( Outer.Pawn );
			}
		}
	}
}

/** Change value of debug AI command bCanAttack flag */
exec function AISetCanAttack( bool bCanAttack )
{
	GetDebugAICommand().bAllowedToAttack = bCanAttack;
	ClientMessage( GetDebugAIController().Pawn$" "$GetDebugAICommand()$" bAllowedToAttack is now "$bCanAttack, CheatType );
}

exec function GetYawRate()
{
	local KFAIController KFAIC;

	KFAIC = GetDebugAIController();

	if( KFAIC != none )
	{
		ClientMessage( KFAIC.Pawn$"'s RotationRate.Yaw is "$KFAIC.Pawn.RotationRate.Yaw, CheatType );
	}
}


exec function AIDisableBump()
{
	local KFAIController KFAIC;

	KFAIC = GetDebugAIController();

	if( KFAIC != none && KFAIC.MyKFPawn != none )
	{
		KFAIC.Disable( 'NotifyBump' );
		ClientMessage( KFAIC.Pawn$" Bump Disabled", CheatType );
	}
}

exec function AIEnableBump()
{
	local KFAIController KFAIC;

	KFAIC = GetDebugAIController();

	if( KFAIC != none && KFAIC.MyKFPawn != none )
	{
		KFAIC.Enable( 'NotifyBump' );
		ClientMessage( KFAIC.Pawn$" Bump Enabled", CheatType );
	}
}

exec function AIToggleHeadTracking()
{
	local KFAIController KFAIC;

	KFAIC = GetDebugAIController();

	if( KFAIC != none && KFAIC.MyKFPawn != none )
	{
		if( KFAIC.MyKFPawn.bIsHeadTrackingActive )
		{
			KFAIC.MyKFPawn.ClearHeadTrackTarget( GetALocalPlayerController().Pawn, 0.25 );
		}
		else
		{
			KFAIC.MyKFPawn.LookAtPawn( GetALocalPlayerController().Pawn );
		}
	}
}

exec function TestScreamEffect()
{
	Pawn.TakeDamage( 1, outer, Pawn.Location, vect(0,0,0), class'KFDT_Sonic' );
}

function KFAIController GetDebugAIController( optional bool bGetClosest=false, optional name inFunctionName )
{
	local KFAIController KFAIC, ClosestKFAIC;

	if( inFunctionName == '' )
	{
		inFunctionName = GetFuncName();
	}

	foreach allactors( class'KFAIController', KFAIC )
	{
		if( KFAIC.GetActiveCommand().IsA( 'AICommand_Debug' ) )
		{
			if( bGetClosest )
			{
				if( ClosestKFAIC == none )
				{
					ClosestKFAIC = KFAIC;
				}
				else
				{
					if( VSize( KFAIC.Pawn.Location - Pawn.Location ) < VSize( ClosestKFAIC.Pawn.Location - Pawn.Location ) )
					{
						ClosestKFAIC = KFAIC;
					}
				}
			}
			else
			{
				if( IsAimingAt(KFAIC.Pawn, 0.8f) )
				{
					ClosestKFAIC = KFAIC;
					break;
				}
			}
		}
	}

	if( ClosestKFAIC == none )
	{
		ClientMessage( inFunctionName$" : You need to be aiming at a valid NPC to do this.", CheatType );
	}
	return ClosestKFAIC;
}

exec function AIDebugTurnInPlace( optional bool bEnableMelee = false )
{
	local KFAIController KFAIC;

	foreach allactors( class'KFAIController', KFAIC )
	{
		KFAIC.DoDebugTurnInPlace( KFPlayerController(Outer), bEnableMelee );
	}
}

exec function AIToggleTurnInPlace()
{
	local KFAIController KFAIC;

	KFAIC = GetDebugAIController();

	if( KFAIC != none && KFAIC.MyKFPawn != none )
	{
		KFAIC.MyKFPawn.bDisableTurnInPlace = !KFAIC.MyKFPawn.bDisableTurnInPlace;
	}

	if( KFAIC.MyKFPawn.bDisableTurnInPlace )
	{
		ClientMessage( KFAIC.Pawn$" TurnInPlace disabled", CheatType );
	}
	else
	{
		ClientMessage( KFAIC.Pawn$" TurnInPlace enabled", CheatType );
	}
}

/** Toggles ability to render KFDebugLines */
exec function ToggleKFDebugLines()
{
	KFDL();
}

/** Abbreviated name, toggles ability to render KFDebugLines */
exec function KFDL()
{
	local KFGameEngine KFGEngine;

	KFGEngine = KFGameEngine(Class'KFGameEngine'.static.GetEngine());
	if( KFGEngine != none )
	{
		class'KFGameEngine'.default.bEnableAdvDebugLines = !class'KFGameEngine'.default.bEnableAdvDebugLines;
		ClientMessage( "KFDebugLines on: "$class'KFGameEngine'.default.bEnableAdvDebugLines, CheatType );
	}
}

exec function ClearDebugLines()
{
	local KFDebugLines KFDL;

	KFDL = class'KFDebugLines'.static.GetDebugLines();
	if( KFDL != none )
	{
		KFDL.ClearAll();
	}
}

exec function AIShowDropDowns( bool bOn=true )
{
	local KFDebugLines KFDL;
	local KFWallPathNode NP;
	local int i;

	KFDL = class'KFDebugLines'.static.GetDebugLines();
	if( KFDL != none )
	{
		foreach allactors( class'KFWallPathNode', NP )
		{
			if( bOn )
			{
				if( NP.DropDownNode != none )
				{
					for( i = 0; i < NP.PathList.Length; i++ )
					{
						if( KFPathnode(NP.PathList[i].End.Actor) == NP.DropDownNode && NP.PathList[i].IsA('WallToFloorReachSpec') )
						{
							KFDL.AddDebugSphere( NP.Location, 24, 8, 0, 255, 0, true, 250.f, NP.Name, 0 );
							if( WallToFloorReachSpec(NP.PathList[i]).bJumpDownTo )
							{
								KFDL.AddDebugLine( NP.Location, NP.DropDownNode.Location, 0, 200, 0, true, 220, NP.Name, i );
							}
							else
							{
								KFDL.AddDebugLine( NP.Location, NP.DropDownNode.Location, 255, 255, 0, true, 220, NP.Name, i );
							}
						}
					}
				}
			}
			else
			{
				KFDL.RemoveOwnedDebugLines( NP.Name, 0 );
				KFDL.RemoveOwnedDebugSpheres( NP.Name, 0 );
			}
		}
	}
}

exec function AIShowFloorToWallNodes( bool bOn=true )
{
	local KFDebugLines KFDL;
	local KFPathnode NP;
	local int i;

	KFDL = class'KFDebugLines'.static.GetDebugLines();
	if( KFDL != none )
	{
		foreach allactors( class'KFPathnode', NP )
		{
			if( NP.bWallNode )
			{
				continue;
			}
			if( bOn )
			{
				for( i = 0; i < NP.PathList.Length; i++ )
				{
					if( NP.PathList[i].IsA('FloortoWallReachSpec') )
					{
						KFDL.AddDebugSphere( NP.Location, 24, 8, 0, 255, 0, true, 250.f, NP.Name, 0 );
						KFDL.AddDebugLine( NP.Location, NP.PathList[i].End.Actor.Location, 100, 200, 150, true, 220, NP.Name, i );
					}
				}
			}
			else
			{
				for( i = 0; i < NP.PathList.Length; i++ )
				{
					KFDL.RemoveOwnedDebugLines( NP.Name, i );
					KFDL.RemoveOwnedDebugSpheres( NP.Name, i );
				}
			}
		}
	}
}

exec function AIShowForcedSpecs( bool bOn=true )
{
	local KFDebugLines KFDL;
	local KFPathnode NP;
	local int i;

	KFDL = class'KFDebugLines'.static.GetDebugLines();
	if( KFDL != none )
	{
		foreach allactors( class'KFPathnode', NP )
		{
			if( NP.bWallNode )
			{
				continue;
			}
			if( bOn )
			{
				for( i = 0; i < NP.PathList.Length; i++ )
				{
					if( NP.PathList[i].IsA('KFForcedReachSpec') )
					{
						KFDL.AddDebugSphere( NP.Location, 24, 8, 0, 255, 0, true, 250.f, NP.Name, 0 );
						KFDL.AddDebugLine( NP.Location, NP.PathList[i].End.Actor.Location, 100, 200, 150, true, 220, NP.Name, i );
					}
				}
			}
			else
			{
				for( i = 0; i < NP.PathList.Length; i++ )
				{
					KFDL.RemoveOwnedDebugLines( NP.Name, i );
					KFDL.RemoveOwnedDebugSpheres( NP.Name, i );
				}
			}
		}
	}
}

exec function AIShowLitNodes()
{
	local NavigationPoint NP;
	local float ColorScale;
	local float TempFloat;

	FlushPersistentDebugLines();

	foreach allactors( class'NavigationPoint', NP )
	{
		TempFloat = ( NP.Intensity.R + NP.Intensity.G + NP.Intensity.B ) / 3.f;
		ColorScale = Clamp( TempFloat * 255.f, 30, 255 );
		DrawDebugSphere( NP.Location, 32, 8, ColorScale, ColorScale, 0, true );
	}
}

exec function AIPlayTaunt( byte TauntType )
{
	local KFAIController KFAIC;

	foreach allactors( class'KFAIController', KFAIC )
	{
		if( IsAimingAt( KFAIC.Pawn, 0.88f ) )
		{
			class'AICommand_TauntEnemy'.static.Taunt( KFAIC, KFPawn(Pawn), ETauntType(TauntType) );
		}
	}
}

exec function DebugNextPhase()
{
    local KFAIController_ZedBoss KFAICB;

    foreach AllActors( class'KFAIController_ZedBoss', KFAICB )
	{
        KFAICB.DebugNextPhase();
    }
}

exec function HansNextPhase()
{
    DebugNextPhase();
}

exec function HansGas()
{
    local KFPawn_ZedHansBase HansPawn;

	foreach allactors( class'KFPawn_ZedHansBase', HansPawn )
	{
        HansPawn.ANIMNOTIFY_AoENerveGas();
	}
}

exec function AISummonZeds(int BattlePhase, int DifficultyIndex)
{
	local KFAIController KFAIC;
    local KFInterface_MonsterBoss BossRef;

	foreach allactors( class'KFAIController', KFAIC )
	{
        BossRef = KFInterface_MonsterBoss(KFAIC.MyKFPawn);

        if(BossRef == none )
        {
            return;
        }

		class'AICommand_SummonZeds'.static.Summon( KFAIC, BossRef.GetWaveInfo(BattlePhase, DifficultyIndex), BossRef.GetNumMinionsToSpawn() );
	}
}

exec function ShowBlockedPathnodes( optional bool bOn=true )
{
	local KFDebugLines KFDL;
	local int i;

	local NavigationPoint NP;
	KFDL = class'KFDebugLines'.static.GetDebugLines();

	foreach allactors( class'NavigationPoint', NP )
	{
		if( bOn && NP.bBlocked )
		{
			i++;
			KFDL.AddDebugSphere( NP.Location, 24, 12, 0, 255, 0, true,, NP.Name, i );
			//DrawDebugSphere( NP.Location, 24, 12, 0, 255, 0, true );
		}
		else
		{
			KFDL.RemoveOwnedDebugSpheres( NP.Name );
		}

		//NP.GoodSprite.SetHiddenGame( false );
	}
}

exec function ShowPathnodes( optional bool bOn=true )
{
	local KFDebugLines KFDL;
	local int i;

	local NavigationPoint NP;
	KFDL = class'KFDebugLines'.static.GetDebugLines();

	foreach allactors( class'NavigationPoint', NP )
	{
		if( bOn )
		{
			i++;
			KFDL.AddDebugSphere( NP.Location, 24, 12, 0, 255, 0, true,, NP.Name, i );
			//DrawDebugSphere( NP.Location, 24, 12, 0, 255, 0, true );
		}
		else
		{
			KFDL.RemoveOwnedDebugSpheres( NP.Name );
		}

		//NP.GoodSprite.SetHiddenGame( false );
	}
}

exec function AIMoveToMeAsEnemy()
{
	local KFAIController KFAIC;

	foreach allactors( class'KFAIController', KFAIC )
	{
		if( KFAIC.IsInDebugMode() )
		{
			KFAIC.bIsProbingMeleeRangeEvents = false;
			KFAIC.SetEnemy( Pawn );
			KFAIC.Enemy = Pawn;
			AICommand_Debug( KFAIC.GetActiveCommand() ).LastDebugGoal = KFAIC.Enemy;
			KFAIC.SetEnemyMoveGoal( none, true,,, false );
		}
	}
}

exec function AIEnableMeleeEvents()
{
	local KFAIController KFAIC;
	KFAIC = GetKFAICFromAim();
	KFAIC.EnableMeleeRangeEventProbing();
}

exec function AIDisableMeleeEvents()
{
	local KFAIController KFAIC;
	KFAIC = GetKFAICFromAim();
	KFAIC.DisableMeleeRangeEventProbing();
}

exec function AIPathTo( name DebugGoalName, optional float OffsetDistance=0.f, optional bool bMarkGoalLocation )
{
	local KFPathNode CheckNode;
	local actor DebugGoal;
	local KFAIController KFAIC;
	local KFPawn KFP;

	if( DebugGoalName == '' )
	{
		ClientMessage( "Use the Tag property in KFPathNodes, and specify that name to have AI path to a specific node. Exampe: AIPathTo TestGoal.  PLAYER is also a valid argument.", CheatType );
		return;
	}

	if( DebugGoalName != 'Player' )
	{
		foreach WorldInfo.AllNavigationPoints( class'KFPathnode', CheckNode )
		{
			if( CheckNode.DebugTag == DebugGoalName )
			{
				DebugGoal = CheckNode;
				break;
			}
		}
	}
	else
	{
		DebugGoal = GetALocalPlayerController().Pawn;
	}

	if( DebugGoal == none )
	{
		foreach allactors( class'KFPawn', KFP )
		{
			if( KFP.Controller == None || !KFP.Controller.IsA( 'KFAIController' ) )
			{
				DebugGoal = KFP;
				break;
			}
		}
		if( DebugGoal == none )
		{
			ClientMessage( "Cannot find a valid goal for '"$DebugGoalName$".", CheatType );
			return;
		}
	}

	foreach allactors( class'KFAIController', KFAIC )
	{
		if( KFAIC.IsInDebugMode() )
		{
			AICommand_Debug( KFAIC.GetActiveCommand() ).LastDebugGoal = DebugGoal;
			ClientMessage( KFAIC.Pawn$" Moving to "$DebugGoal$" with an offset distance of "$OffsetDistance, CheatType );
		}
	}
	if( bMarkGoalLocation )
	{
		ClientMessage( "Type 'FlushPersistentDebugLines' to remove the debug sphere at goal location", CheatType );
		DrawDebugSphere( DebugGoal.Location, 32, 8, 189, 183, 107, TRUE );
	}
}

exec function AIDebugCrawler()
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim( true );

	if( KFAIC == none || !KFAIC.IsA('KFAIController_ZedCrawler') )
	{
		ClientMessage( "You must be aiming at a debug-mode NPC!" );
		return;
	}

	KFAIC.Pawn.bDebugCrawlerPhysics = !KFAIC.Pawn.bDebugCrawlerPhysics;
	ClientMessage( "DebugCrawler is now "$KFAIC.Pawn.bDebugCrawlerPhysics$" for "$KFAIC.Pawn, CheatType );
	if( KFAIC.Pawn.bDebugCrawlerPhysics )
	{
		ClientMessage( "Warning - PlayersOnly will be activated throughout "$KFAIC.Pawn$"'s moves.", CheatType, 13.f );
	}
}

exec function AITestCrawler()
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim( true );

	if( KFAIC == none )
	{
		ClientMessage( "You must be aiming at a debug-mode NPC!", CheatType );
	}

	if( !KFAIC.bHasDebugCommand )
	{
		ClientMessage( KFAIC.MyKFPawn$" must have a controller in debug mode first!", CheatType );
	}
	AICommand_Debug(KFAIC.GetActiveCommand()).Debug_DebugNodes();
}

exec function AITestCrawlers()
{
	local KFAIController_ZedCrawler KFAIC;

	foreach WorldInfo.AllControllers(class'KFAIController_ZedCrawler', KFAIC )
	{
		if( KFAIC.bHasDebugCommand )
		{
			AICommand_Debug(KFAIC.GetActiveCommand()).Debug_DebugNodes();
		}
	}
}

exec function AITestCrawlerAttack()
{
	local KFAIController_ZedCrawler KFAIC;

	foreach WorldInfo.AllControllers(class'KFAIController_ZedCrawler', KFAIC )
	{
		if( KFAIC.bHasDebugCommand )
		{
			AICommand_Debug(KFAIC.GetActiveCommand()).Debug_CrawlerAttack();
		}
	}
}

exec function AITestGrab()
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim( false, 0.9f );

	if( KFAIC != none )
	{
		if( AICommand_Debug(KFAIC.GetActiveCommand()) != none )
		{
			AICommand_Debug(KFAIC.GetActiveCommand()).bAllowedToAttack = true;
		}
		KFAIC.DoGrabAttack( Pawn, 5.f );
		if( AICommand_Debug(KFAIC.GetActiveCommand()) != none )
		{
			AICommand_Debug(KFAIC.GetActiveCommand()).bAllowedToAttack = false;
		}
	}
}

exec function AIHansTestGrenadeTrajectory( optional float Speed=2500, optional float ZPct=0.45f )
{
	local KFAIController_Hans KFAIC;
	local vector EstimatedStartThrowLocation, TossVelocity;

	foreach WorldInfo.AllControllers( class'KFAIController_Hans', KFAIC )
	{
		if( KFAIC != none )
		{
			EstimatedStartThrowLocation = KFAIC.Pawn.GetPawnViewLocation() + (vect(15,32,-12) >> KFAIC.Pawn.GetViewRotation());
			if( !KFAIC.Pawn.SuggestTossVelocity( TossVelocity, GetMyPawn().Location, EstimatedStartThrowLocation, Speed,, ZPct ) )
			{
				ClientMessage( "FAIL for Speed:"$Speed$" ZPCt:"$ZPct$" 2DDist: "$VSize2D(KFAIC.Pawn.Location - GetMyPawn().Location)$" ZDiff:"$abs(KFAIC.Pawn.Location.Z - GetMyPawn().Location.Z), CheatType );
			}
			else
			{
				ClientMessage( "SUCCESS for Speed:"$Speed$" ZPCt:"$ZPct$" 2DDist: "$VSize2D(KFAIC.Pawn.Location - GetMyPawn().Location)$" ZDiff:"$abs(KFAIC.Pawn.Location.Z - GetMyPawn().Location.Z), CheatType );
			}
		}
	}
}

/** Make Hans, if you're looking at him, attempt to do his grenade attack */
exec function AIHansGrenade( optional bool bGrenadeBarrage )
{
	local KFAIController_Hans KFAIC;

	KFAIC = KFAIController_Hans( GetKFAICFromAim(false, 0.9f) );

	if( KFAIC != none )
	{
		KFAIC.Enemy = GetMyPawn();
		KFAIC.DoGrenadeThrow( bGrenadeBarrage );
	}
}

/** Same as AITestGrab but doesn't require aiming at the NPC (in order to test code which auto-rotates player to face the NPC */
exec function AITestHansGrab()
{
	local KFAIController_Hans KFAIC;

	foreach WorldInfo.AllControllers( class'KFAIController_Hans', KFAIC )
	{
		if( AICommand_Debug(KFAIC.GetActiveCommand()) != none )
		{
			AICommand_Debug(KFAIC.GetActiveCommand()).bAllowedToAttack = true;
		}
		KFAIC.DoGrabAttack( Pawn, 5.f );
		if( AICommand_Debug(KFAIC.GetActiveCommand()) != none )
		{
			AICommand_Debug(KFAIC.GetActiveCommand()).bAllowedToAttack = false;
		}
	}
}

exec function AISetDebugColor( byte R, byte G, byte B )
{
	local KFAIController KFAIC;
	foreach allactors( class'KFAIController', KFAIC )
	{
		KFAIC.Debug_TextColorOverride = MakeColor(R,G,B,255);
	}
}

exec function AISetDebugColorR( byte R )
{
	local KFAIController KFAIC;
	foreach allactors( class'KFAIController', KFAIC )
	{
		KFAIC.Debug_TextColorOverride.R = R;
	}
}

exec function AISetDebugColorG( byte G )
{
	local KFAIController KFAIC;
	foreach allactors( class'KFAIController', KFAIC )
	{
		KFAIC.Debug_TextColorOverride.G = G;
	}
}

exec function AISetDebugColorB( byte B )
{
	local KFAIController KFAIC;
	foreach allactors( class'KFAIController', KFAIC )
	{
		KFAIC.Debug_TextColorOverride.B = B;
	}
}

exec function AISetDebugColorA( byte A )
{
	local KFAIController KFAIC;
	foreach allactors( class'KFAIController', KFAIC )
	{
		KFAIC.Debug_TextColorOverride.A = A;
	}
}

exec function AIDebugEnemy()
{
	GetDebugAICommand().Debug_Enemy(Pawn);
}

exec function DumpReachSpecs()
{
	local int i, Count;
	local NavigationPoint Nav, StartNav, EndNav;
	local float Length, TotalDist;

	foreach WorldInfo.AllNavigationPoints( class'NavigationPoint', Nav )
	{
		`log( "--------------------------------------------------------------------------------" );
		`log( "Checking Nav: "$Nav );

		for( i = 0; i < Nav.PathList.Length; i++ )
		{
			StartNav = Nav;
			EndNav = Nav.PathList[i].GetEnd();

			if( !Nav.PathList[i].IsA( 'ProscribedReachSpec' ) )
			{
				Count++;
				if( StartNav != none && EndNav!= none )
				{
					Length = VSize( EndNav.Location - Nav.Location );

					`log( "		"$Nav.PathList[i]$" connected to "$EndNav$" "$Length$" length" );
					TotalDist += Length;
				}
			}
		}
	}

	`log( "Avg Dist: "$TotalDist / Count );
}

/** Kill all zeds except the one I'm currently aiming at */
exec function KillOtherZeds()
{
	local KFPawn_Monster AIP;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', AIP)
	{
		if ( AIP.Health > 0 && !IsAimingAt(AIP, 0.98f) )
		{
			AIP.TakeDamage(20000, Outer, AIP.Location, Vect(0,0,0),class'KFDamageType');
		}
	}
}

`if(`notdefined(ShippingPC))
exec function DoActionScriptVoidOnMenu(String VoidCommand)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Outer);

	if (KFPC != none && KFPC.MyGFxManager != none && KFPC.MyGFxManager.CurrentMenu != none)
	{
		KFPC.MyGFxManager.CurrentMenu.ActionScriptVoid(VoidCommand);
	}
}
`endif

exec function KillZeds( optional float KillDistance=0.f, optional bool LogKilledZedInfo=true )
{
	local PlayerController		KFPC;
	local DebugCameraController	DCC;
	local KFPawn_Monster		AIP;
	local Pawn					MyPawn;
`if(`notdefined(ShippingPC))
    local string                GoString, LocString;
	local PlayerController		PC;
`endif

	KFPC = Outer;

	if ( KFPC != none )
	{
		DumpInfoForAI();

		ForEach WorldInfo.AllPawns(class'KFPawn_Monster', AIP)
		{
			if( !AIP.IsAliveAndWell() )
			{
				continue;
			}

			if( KillDistance > 0.f )
			{
				if( Pawn != none )
				{
					MyPawn = Pawn;
				}
				// If in DebugCameraController mode
				else if( DebugCameraController(KFPC) != none )
				{
					DCC = DebugCameraController(KFPC);
					if( DCC != none && DCC.OriginalControllerRef != none && DCC.OriginalControllerRef.Pawn != none )
					{
						MyPawn = DCC.OriginalControllerRef.Pawn;
					}
				}

				if( MyPawn != none && (VSizeSq(AIP.Location - MyPawn.Location) > (KillDistance * KillDistance)) )
				{
					`log( self$" Not killing "$AIP$" who is "$VSize( AIP.Location - MyPawn.Location)$" units away" );
					continue;
				}
			}

			if ( AIP.Health > 0 )
			{
`if(`notdefined(ShippingPC))
				// Send a bugit string to the log file, dump the AI command history if possible and log some other info - in case motivation was to kill stragglers to end a wave
				if( LogKilledZedInfo && AIP.MyKFAIC != none )
				{
					AIP.MyKFAIC.AIBugItStringCreator( AIP.Location, AIP.Rotation, GoString, LocString );
					`log( GetFuncName()$"() Killing "$AIP$" at "$AIP.Location$", MySpawnVolume:"$AIP.MyKFAIC.MySpawnVolume$" Health:"$AIP.Health$" Velocity:"$AIP.Velocity$" Phys:"$AIP.GetPhysicsName()$" MoveTarget:"$AIP.MyKFAIC.MoveTarget!=none?AIP.MyKFAIC.MoveTarget.name:'None' );
				//	AIP.MyKFAIC.DumpCommandHistory();
					//DumpInfoForAI( false );
				}
`endif
				if( PlayerController(AIP.Controller) == none )
				{
				AIP.Died(none , none, AIP.Location);
			}
		}
		}
`if(`notdefined(ShippingPC))
		foreach WorldInfo.AllControllers(class'PlayerController', PC)
		{
			if( PC == outer )
			{
				if( KillDistance > 0.f )
				{
					PC.ClientMessage( "You killed all Zeds within "$KillDistance$" units.", CheatType );
				}
				else
				{
					PC.ClientMessage( "You killed all Zeds.", CheatType );
				}
			}
			else if( KillDistance > 0.f )
			{
				PC.ClientMessage( Pawn$" Killed all Zeds", CheatType );
			}
			else
			{
				PC.ClientMessage( Pawn$" Killed all Zeds within "$KillDistance$" units.", CheatType );
			}
		}
`endif
	}
}

/** force all fleshpounds to toggle rage */
exec function AIRage()
{
	local KFPawn_Monster P;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', P )
	{
		if( P.IsAliveAndWell() && P.IsA('KFPawn_ZedFleshpound') && !P.IsEnraged() && IsAimingAt(P, 0.95) )
		{
			P.MyKFAIC.SetEnemy( Pawn );
			P.SetEnraged( true );
		}
	}
}

exec function ShowCrawlerPath( optional bool bAllowPartial=false, optional int OverrideFloorCostMin, optional int OverrideFloorCostMax )
{
	local KFPawn_Monster KFPM;
	local actor Result;
	local KFGameEngine KFGEngine;
	local KFDebugLines KFDL;

	KFGEngine = KFGameEngine( Class'KFGameEngine'.static.GetEngine() );
	if( KFGEngine != none )
	{
		class'KFGameEngine'.default.bEnableAdvDebugLines = true;
	}

//	foreach WorldInfo.AllNavigationPoints( class'KFPathnode', KFPN )
//	{
//		KFPN.ForceClearForPathfinding();
//	}

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.Health > 0 && KFPM.bCrawler && KFPM.MyKFAIC != none && KFPM.MyKFAIC.bHasDebugCommand )
		{
			KFPM.MyKFAIC.RouteCache.Length = 0;

			if( OverrideFloorCostMin > 0 && OverrideFloorCostMax > 0 )
			{
				//ClientMessage( "Using "$OverrideFloorCost$" floor cost instead of "$KFAIController_ZedCrawler(KFPM.MyKFAIC).ExtraCostForFloorNodes, CheatType );
				KFAIController_ZedCrawler(KFPM.MyKFAIC).MinExtraCostForFloorNodes = OverrideFloorCostMin;
				KFAIController_ZedCrawler(KFPM.MyKFAIC).MaxExtraCostForFloorNodes = OverrideFloorCostMax;
			}

			KFDL = class'KFDebugLines'.static.GetDebugLines();

			Result = KFPM.MyKFAIC.GeneratePathTo( GetMyPawn(),, bAllowPartial );
			if( Result == none )
			{
				ClientMessage( KFPM$" failed to build path", CheatType );
			}
			KFDL.ClearAll();
			KFPM.MyKFAIC.KFDebug_DrawMyPath();
		}
	}
}

exec function AIDebugLOS()
{
	local KFPawn_Monster KFPM;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
		if( KFPM.MyKFAIC.bHasDebugCommand && KFPM.IsAliveAndWell() )
		{
			AICommand_Debug(KFPM.MyKFAIC.GetActiveCommand()).Debug_LOS();
		}
	}
}

/** Logs the AI command stack for each existing AI in the level */
exec function DumpAICommands()
{
	local KFAIController AI;
	foreach WorldInfo.AllControllers(class'KFAIController', AI )
	{
		AI.DumpCommandStack();
	}
}

exec function TestSpecDist( optional bool bOnlyPathNodes = false)
{
	local NavigationPoint NP, StartNav, EndNav;
	local int i;
	local array<float> Distances;
	local float Total;

	foreach allactors( class'NavigationPoint', NP )
	{
		for( i = 0; i < NP.PathList.Length; i++ )
		{
			StartNav = NP.PathList[ i ].Start;
			EndNav = NP.PathList[ i ].GetEnd();

			if( StartNav != none && EndNav != none )
			{
				if( bOnlyPathNodes )
				{
					if( StartNav.Class != class'Engine.PathNode' || EndNav.Class != class'Engine.PathNode' )
					{
						continue;
					}
				}

				Distances.AddItem( VSize( NP.PathList[ i ].Start.Location - NP.PathList[ i ].GetEnd().Location ) );
			}
		}
	}

	for( i = 0; i < Distances.Length; i++ )
	{
		`log( "DISTANCES["$i$"] : "$Distances[ i ] );
		Total += Distances[ i ];
	}

	`log( "TOTAL: "$Total$" LENGTH: "$Distances.Length$" AVG: "$Total/Distances.Length );
}

simulated exec function BigHeadMode()
{
	local Pawn P;
	local KFPawn KFPawn;

	for( P = WorldInfo.PawnList; P != none; P = P.NextPawn )
	{
		KFPawn = KFPawn( P );

		if( KFPawn != none )
		{
			KFPawn.SetHeadScale(3.f, KFPawn.CurrentHeadScale);
		}
	}
}

simulated exec function BigZedMode( optional float scale=2.0, optional bool bScaleCollision )
{
    local Pawn P;
    local KFPawn_Monster Zed;

    for( P = WorldInfo.PawnList; P != none; P = P.NextPawn )
    {
        Zed = KFPawn_Monster( P );
        if( Zed != none )
        {
            Zed.SetDrawScale( scale );
            if( bScaleCollision )
            {
                Zed.SetCollisionSize( Zed.CylinderComponent.default.CollisionRadius * scale, Zed.CylinderComponent.default.CollisionHeight * scale );
            }
        }
    }
}

/**
 * This will set all active AIControllers InUseNodeCostMultiplier to 10 (or 0, toggling) for testing & sprint review
 **/
simulated exec function AISetInUseCost( optional float NewCost=10.f )
{
	local KFAIController KFAIC;

	foreach allactors( class'KFAIController', KFAIC )
	{
		if( KFAIC.InUseNodeCostMultiplier == 0 )
		{
			KFAIC.InUseNodeCostMultiplier = 10;
		}
		else
		{
			KFAIC.InUseNodeCostMultiplier = 0;
		}
		ClientMessage( KFAIC.Pawn$" InUseNodeCostMultiplier is now "$KFAIC.InUseNodeCostMultiplier, CheatType );
	}
}

simulated exec function AILookAtMe( bool bEnabled )
{
	local Pawn P;
	local KFPawn_Monster KFP;

	for( P = WorldInfo.PawnList; P != none; P = P.NextPawn )
	{
		KFP = KFPawn_Monster( P );
		if( KFP != none && KFP.bCanHeadTrack && IsAimingAt(KFP, 0.88f ) )
		{
			if( bEnabled )
			{
				KFP.IK_Look_Head		= SkelControlLookAt(KFP.Mesh.FindSkelControl('HeadLook'));
				KFP.bIsHeadTrackingActive = true;
				KFP.SetHeadTrackTarget( Outer.Pawn, vect(0,0,0), 1.f, false );
			}
			else
			{
				KFP.ClearHeadTrackTarget( KFP.MyLookAtInfo.LookAtTarget, 0.5f );
				KFP.bIsHeadTrackingActive = false;
			}
		}
	}
}

exec function InjureZedArm()
{
	local KFPawn_Monster AIP;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', AIP)
	{
		AIP.RagdollArm(false);
	}
}

exec function CrippleZeds()
{
	local KFPawn_Monster AIP;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', AIP)
	{
		AIP.CauseHeadTrauma(AIP.HeadlessBleedOutTime);
	}
}

/** Cripple only the Zed you're aiming at */
exec function CrippleZed()
{
	local KFPawn_Monster AIP;

	AIP = GetKFMPFromAim();
	if( AIP != none )
	{
		AIP.CauseHeadTrauma(AIP.HeadlessBleedOutTime);
	}
}

exec function EnableLivingGore()
{
	local KFPawn_Monster AIP;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', AIP)
	{
		AIP.InitPartialKinematics();
	}
}

exec function PlayRandomStumble()
{
	local KFPawn_Monster P;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', P)
	{
		P.DoSpecialMove(SM_Stumble,,, class'KFSM_Stumble'.static.PackRandomSMFlags(P));
	}
}

exec function PlayTaunt()
{
	local KFPawn_Monster P;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', P)
	{
		P.WalkBlendList.QueueTauntWalk();
	}
}

exec function PlayKnockdown(optional vector LinearVelocity = vect(0,0,0) )
{
	local KFPawn_Monster P;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', P)
	{
		P.Knockdown(LinearVelocity, vect(1, 1, 1), Pawn.Location, 1000, 100);
	}
}

exec function PlayStunned()
{
	local KFPawn_Monster P;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', P)
	{
		if( P.IsAliveAndWell() )
		{
			// transition to the Stunned state
			P.DoSpecialMove(SM_Stunned );
		}
	}
}

exec function EMPWander(bool bEnable)
{
	local KFPawn_Monster P;

	ForEach WorldInfo.AllPawns(class'KFPawn_Monster', P)
	{
		if( P.IsAliveAndWell() && P.MyKFAIC != none )
		{
			if( bEnable )
			{
                // transition to the panicked state
    			P.CausePanicWander();
    			P.AfflictionHandler.ToggleEffects(AF_EMP, True, false);
			}
			else
			{
                P.EndPanicWander();
                P.AfflictionHandler.ToggleEffects(AF_EMP, False, false);
			}
		}
	}
}

exec function EMPValTest(float EMPValue)
{
	local KFPawn P;
	local MaterialInstanceConstant MIC;

	ForEach WorldInfo.AllPawns(class'KFPawn', P)
	{
		if( P.IsAliveAndWell() )
		{
            foreach P.CharacterMICs(MIC)
            {
                MIC.SetScalarParameterValue('Scalar_EMP',EMPValue);
            }
		}
	}
}

exec function BurnValTest(float BurnValue)
{
	local KFPawn P;
	local MaterialInstanceConstant MIC;

	ForEach WorldInfo.AllPawns(class'KFPawn', P)
	{
		if( P.IsAliveAndWell() )
		{
            foreach P.CharacterMICs(MIC)
            {
    			MIC.SetScalarParameterValue('Scalar_Burnt',BurnValue);
            }
		}
	}
}

/**
 * Spawn and possess a ZED
 * Zeds aren't available to Kismet AI Factories (due to HideDropDown). To get around this, use Kismet console
 * events to spawn Zeds, using the SpawnAtTag parameter if you want the Zed to spawn at a specific KFPathnode.
 * @param	ZedName		Type of Zed (ClotA,ClotC,ClotS,GF,FP,Crawler,etc.)
 * @param	Distance	(optional) AI will be spawned this many units in front of you
 * @param	SpawnAtTag	(optional) Spawn at a KFPathnode location if its DebugTagName matches SpawnAtTag
 **/
simulated exec function SpawnAI(string ZedName, optional float Distance = 500.f, optional name SpawnAtTag)
{
	local KFPawn Zed;

	Zed = SpawnAIZed( ZedName, Distance, SpawnAtTag );

	if ( Zed != None )
	{
		Zed.SpawnDefaultController();
		if( KFAIController(Zed.Controller) != none )
		{
			KFAIController( Zed.Controller ).SetTeam(1);
		}
	}
}

exec function SpawnAIV( string ZedName, optional float Distance = 500.f )
{
    local class<KFPawn_Monster> MonsterClass;
    local vector SpawnLoc;
    local rotator SpawnRot;
    local KFAIController KFAIC;
    local KFPawn KFP;

    if( !WorldInfo.Game.IsA('KFGameInfo_VersusSurvival') )
    {
        ClientMessage("This cheat command is only valid in Versus Survival mode!", CheatType );
        return;
    }

    MonsterClass = LoadMonsterByName( ZedName, true );

    if( MonsterClass != none )
    {
        // The ZED should be spawned X units in front of the view location
        if( Pawn != None )
        {
            SpawnLoc = Pawn.Location;
        }
        else
        {
            SpawnLoc = Location;
        }

        SpawnLoc += Distance * vector(Rotation) + vect(0,0,1) * 15.f;
        SpawnRot.Yaw = Rotation.Yaw + 32768;

        KFP = Spawn( MonsterClass,,, SpawnLoc, SpawnRot,, false );
        if( KFP != none )
        {
            KFP.SetPhysics( PHYS_Falling );
            if( KFP.ControllerClass != None )
            {
                KFAIC = KFAIController( KFP.Spawn(KFP.ControllerClass) );
                if( KFAIC != none )
                {
                    KFAIC.bIsSimulatedPlayerController = true;
                    KFAIC.SetTeam( 1 );
                    KFAIC.Possess( KFP, false );
                }
                return;
            }
        }
    }

    ClientMessage(" Could not spawn AI Versus ZED ["$ZedName$"]. Please make sure that the ZED name to archetype mapping is set up correctly.", CheatType );
}

/**
 * SpawnDebugAI()
 * Spawns the specified Zed in a non-aggressive debug state which can accept various
 * cheat commands to pathfind to specific locations, attack, charge, etc. The default
 * base Zed AICommand is replaced with an AICommand_Debug. KFAIController.bDebugMode
 * can be checked to see if an NPC is in debug mode.
 * @param	ZedName		 	Zed type (just like SpawnZed and SpawnAI)
 * @param	Distance	 	(Optional) Distance
 * @param	SpawnAtTag   	(Optional) SpawnAtTag (Spawns at a KFPathNode with a DebugTag matching this name.
 * @param	bShowDebugTxt	(Optional) Spawn with debug text rendering over NPC's head
 */
simulated exec function SpawnDebugAI( string ZedName, optional float Distance = 200.f, optional name SpawnAtTag, optional bool bShowDebugTxt=false )
{
	local KFPawn Zed;
//	local KFAIDirector AIManager;

	Zed = SpawnAIZed( ZedName, Distance, SpawnAtTag );
	if ( Zed != None )
	{
		Zed.SpawnDefaultController();
		if( Zed.Controller != none )
		{
			// Spawns with debug text overhead, even if the global setting in KFAIDirector is off
			if( bShowDebugTxt )
			{
 				KFPawn_Monster(Zed).SetDebugTextRendering( true );
 				SetNPCDebugCategory( true, 'all' );
			}
			KFAIController( Zed.Controller ).BeginDebugCommand();
			KFAIController( Zed.Controller ).DefaultCommandClass = class'KFGame.AICommand_Debug';
			KFAIController( Zed.Controller ).MeleeCommandClass = class'KFGame.AICommand_Debug';
		}
	}
}

simulated exec function AIShowAttackAnims( optional bool bSetEnemyForDebugModeAI=true )
{
	local KFAIController KFAIC;

	foreach WorldInfo.AllControllers(class'KFAIController', KFAIC )
	{
		if( KFAIC.Pawn != none && KFAIC.Pawn.IsAliveAndWell() )
		{
			if( IsAimingAt(KFAIC.Pawn, 0.95f) )
			{
				// NPCs in debug mode don't auto-acquire an enemy, so set it to the player here. They won't be aggressive in debug mode, though.
				if( bSetEnemyForDebugModeAI )
				{
					KFAIC.SetEnemy( Pawn );
				}

				if( KFAIC.bDebug_DrawAttackAnimInfo )
				{
					KFAIC.bDebug_DrawAttackAnimInfo = false;
					//KFAIC.SetPostRendering( false );
					//KFAIC.bDebug_PostRenderInfo = false;
					ClientMessage( "Turning off attack animation info for "$KFAIC.Pawn, CheatType );
					return;
				}
				else
				{
					KFAIC.bDebug_DrawAttackAnimInfo = true;
					KFAIC.SetPostRendering( true );
					KFAIC.bDebug_PostRenderInfo = true;
					ClientMessage( "Now showing attack animation info for "$KFAIC.Pawn, CheatType );
					return;
				}
			}
		}
	}

	ClientMessage( "You need to be aiming at an NPC first!", CheatType );
}

simulated function KFPawn SpawnAIZed(string ZedName, float Distance, optional name SpawnAtTag)
{
	local KFPawn Zed;

	Zed = SpawnZed(ZedName, Distance,, SpawnAtTag);

	`log( GetFuncName()$"() Spawned: "$Zed );

	return Zed;
}

/** Spawns a versus zed with name ZedName, and possess them with a player controller so we can test functionality that requires a player controlled versus zed */
exec function SpawnZedVC(string ZedName)
{
	local KFPlayerController KFPC;
    local class<KFPawn_Monster> MonsterClass;
    local vector SpawnLoc;
    local rotator SpawnRot;
    local KFPawn KFP;

    if( !WorldInfo.Game.IsA('KFGameInfo_VersusSurvival') )
    {
        ClientMessage("This cheat command is only valid in Versus Survival mode!", CheatType );
        return;
    }

    MonsterClass = LoadMonsterByName( ZedName, true );

    if( MonsterClass != none )
    {
        // The ZED should be spawned X units in front of the view location
        if( Pawn != None )
        {
            SpawnLoc = Pawn.Location;
        }
        else
        {
            SpawnLoc = Location;
        }

        SpawnLoc += 200.f * vector(Rotation) + vect(0,0,1) * 15.f;
        SpawnRot.Yaw = Rotation.Yaw + 32768;

        KFP = Spawn( MonsterClass,,, SpawnLoc, SpawnRot,, false );
        if( KFP != none )
        {
        	// Create a new Controller for this Bot
        	KFPC = Spawn(class'KFPlayerController');

        	// Silly name for now
        	WorldInfo.Game.ChangeName(KFPC, "Braindead Human", false);

        	KFPC.Possess(KFP, false);

            KFP.SetPhysics( PHYS_Falling );
        }
        else
        {
            ClientMessage(" Could not spawn Versus ZED ["$ZedName$"] with a PC. Please make sure that the ZED name to archetype mapping is set up correctly.", CheatType );
        }
    }
}

/** Spawns a versus zed with name ZedName, and optionally possesses them */
exec function SpawnZedV( string ZedName, optional bool bPossess=true )
{
    local class<KFPawn_Monster> MonsterClass;
    local vector SpawnLoc;
    local rotator SpawnRot;
    local KFPawn KFP;

    if( !WorldInfo.Game.IsA('KFGameInfo_VersusSurvival') )
    {
        ClientMessage("This cheat command is only valid in Versus Survival mode!", CheatType );
        return;
    }

    MonsterClass = LoadMonsterByName( ZedName, true );

    if( MonsterClass != none )
    {
        // The ZED should be spawned X units in front of the view location
        if( Pawn != None )
        {
            SpawnLoc = Pawn.Location;
        }
        else
        {
            SpawnLoc = Location;
        }

        SpawnLoc += 200.f * vector(Rotation) + vect(0,0,1) * 15.f;
        SpawnRot.Yaw = Rotation.Yaw + 32768;

        KFP = Spawn( MonsterClass,,, SpawnLoc, SpawnRot,, false );
        if( KFP != none )
        {
            if( bPossess )
            {
                if( Pawn != none )
                {
                    Pawn.Destroy();
                }

                if( KFP.Controller != none )
                {
                    KFP.Controller.Destroy();
                }
                KFGameInfo(WorldInfo.Game).SetTeam( KFPlayerController(Outer), KFGameInfo(WorldInfo.Game).Teams[1] );
                Possess( KFP, false );
                ServerCamera( 'ThirdPerson' );
            }

            KFP.SetPhysics( PHYS_Falling );
        }
        else
        {
            ClientMessage(" Could not spawn Versus ZED ["$ZedName$"]. Please make sure that the ZED name to archetype mapping is set up correctly.", CheatType );
        }
    }
}

exec function GoHumanV()
{
    local class<KFPawn_Human> HumanClass;
    local KFPawn_Human KFPH;
    local vector SpawnLoc;
    local rotator SpawnRot;

    if( !WorldInfo.Game.IsA('KFGameInfo_VersusSurvival') )
    {
        ClientMessage("This cheat command is only valid in Versus Survival mode!", CheatType );
        return;
    }

    if( Pawn != none )
    {
        SpawnLoc = Pawn.Location;
        Pawn.Destroy();
    }
    else
    {
        SpawnLoc = Location;
    }

    SpawnRot.Yaw = Rotation.Yaw + 32768;

    HumanClass = class<KFPawn_Human>(DynamicLoadObject("KFGameContent.KFPawn_Human_Versus", class'Class'));

    KFPH = Spawn( HumanClass,,, SpawnLoc, SpawnRot,, false );

    if( KFPH != none )
    {
        KFGameInfo(WorldInfo.Game).SetTeam( KFPlayerController(Outer), KFGameInfo(WorldInfo.Game).Teams[0] );
        KFPH.AddDefaultInventory();
        Possess( KFPH, false );
        ServerCamera( 'FirstPerson' );
        KFPH.SetPhysics( PHYS_Falling );
    }
    else
    {
        ClientMessage("Could not spawn Versus Human.", CheatType );
    }
}

exec function SetBossNum( int PosInBossArray )
{
    ConsoleCommand("SETNOPEC KFAISpawnManager ForcedBossNum"@PosInBossArray);
}

/** Get a zed class from the name */
function class<KFPawn_Monster> LoadMonsterByName(string ZedName, optional bool bIsVersusPawn )
{
    local string VersusSuffix;
    local class<KFPawn_Monster> SpawnClass;

    VersusSuffix = bIsVersusPawn ? "_Versus" : "";

	// Get the correct archetype for the ZED
	if( Left(ZedName, 5) ~= "ClotA" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_Alpha"$VersusSuffix, class'Class'));
	}
    else if( Left(ZedName, 4) ~= "EAlp")
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_AlphaKing"$VersusSuffix, class'Class'));
    }
    else if( Left(ZedName, 4) ~= "ECra")
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedCrawlerKing"$VersusSuffix, class'Class'));
    }
	else if( Left(ZedName, 5) ~= "ClotS" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_Slasher"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 5) ~= "ClotC" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_Cyst"$VersusSuffix, class'Class'));
	}
	else if( ZedName ~= "CLOT" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedClot_Cyst"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 3) ~= "FHa" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHansFriendlyTest"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 3) ~= "FHu" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHuskFriendlyTest"$VersusSuffix, class'Class'));
	}
    else if ( Left(ZedName,5) ~= "KingF" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshpoundKing"$VersusSuffix, class'Class'));
    }
    else if ( Left(ZedName,5) ~= "MiniF" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshpoundMini"$VersusSuffix, class'Class'));
    }
	else if( Left(ZedName, 1) ~= "F" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedFleshpound"$VersusSuffix, class'Class'));
	}
    else if( Left(ZedName, 3) ~= "GF2" )
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedGorefastDualBlade"$VersusSuffix, class'Class'));
    }
	else if( Left(ZedName, 1) ~= "G" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedGorefast"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 2) ~= "St" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedStalker"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 1) ~= "B" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedBloat"$VersusSuffix, class'Class'));
	}
    else if (Left(ZedName, 5) ~= "KingB")
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedBloatKing"$VersusSuffix, class'Class'));
    }
	else if (Left(ZedName, 4) ~= "Poop")
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedBloatKingSubspawn", class'Class'));
	}
	else if( Left(ZedName, 2) ~= "Sc" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedScrake"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 2) ~= "Pa" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedPatriarch"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 2) ~= "Cr" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedCrawler"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 2) ~= "Hu" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHusk"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 8) ~= "TestHusk" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHusk_New"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 2) ~= "Ha" )
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedHans"$VersusSuffix, class'Class'));
	}
	else if( Left(ZedName, 2) ~= "Si" )
	{
		return class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedSiren"$VersusSuffix, class'Class'));
	}
    else if( Left(ZedName, 1) ~= "P")
    {
        SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedPatriarch"$VersusSuffix, class'Class'));
    }
	else if (Left(ZedName, 3) ~= "Emp")
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedDAR_EMP" $ VersusSuffix, class'Class'));
	}
	else if (Left(ZedName, 5) ~= "Laser")
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedDAR_Laser" $ VersusSuffix, class'Class'));
	}
	else if (Left(ZedName, 4) ~= "Rock")
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedDAR_Rocket" $ VersusSuffix, class'Class'));
	}
	else if (Left(ZedName, 1) ~= "M")
	{
		SpawnClass = class<KFPawn_Monster>(DynamicLoadObject("KFGameContent.KFPawn_ZedMatriarch" $ VersusSuffix, class'Class'));
	}

    if( SpawnClass != none )
    {
        SpawnClass = SpawnClass.static.GetAIPawnClassToSpawn();
    }

    if( SpawnClass == none )
    {
    	ClientMessage("Could not spawn ZED ["$ZedName$"]. Please make sure you specified a valid ZED name (ClotA, ClotS, ClotC, etc.) and that the ZED has a valid archetype setup.", CheatType );
        return none;
    }
    return SpawnClass;
}

native function int GetAITypeByName(string ZedName);

exec function SpawnHumanPawn(optional bool bEnemy, optional bool bUseGodMode, optional int CharIndex)
{
	local KFAIController KFBot;
	local KFPlayerReplicationInfo KFPRI;
	local vector					CamLoc;
	local rotator					CamRot;
	Local KFPawn_Human KFPH;
	local Vector HitLocation, HitNormal;
	local Actor TraceOwner;


	GetPlayerViewPoint(CamLoc, CamRot);

    if( Pawn != none )
	{
		TraceOwner = Pawn;
	}
	else
	{
		TraceOwner = Outer;
	}

	TraceOwner.Trace( HitLocation, HitNormal, CamLoc + Vector(CamRot) * 250000, CamLoc, TRUE, vect(0,0,0) );

	HitLocation.Z += 100;
//	FlushPersistentDebugLines();
//    DrawDebugSphere( HitLocation, 100, 12, 0, 255, 0, TRUE );

	KFPH = Spawn(class'KFPawn_Human', , , HitLocation);
	KFPH.SetPhysics(PHYS_Falling);

	// Create a new Controller for this Bot
	KFBot = Spawn(class'KFAIController');

	// Silly name for now
	WorldInfo.Game.ChangeName(KFBot, "Braindead Human", false);

	// Add them to the Team they selected
	if( !bEnemy )
	{
	   KFGameInfo(WorldInfo.Game).SetTeam(KFBot, KFGameInfo(WorldInfo.Game).Teams[0]);
	}

	KFBot.Possess(KFPH, false);

	if( bUseGodMode )
	{
	   KFBot.bGodMode = true;
	}

    KFPRI = KFPlayerReplicationInfo( KFBot.PlayerReplicationInfo );

	// Set perk stuff
    //KFPRI.SetCharacter(CharIndex);
	KFPRI.CurrentPerkClass = Class'KFPlayerController'.default.PerkList[1].PerkClass;
	KFPRI.NetPerkIndex = 1;

	if( KFPRI != none )
	{
		KFPRI.PLayerHealthPercent = FloatToByte( float(KFPH.Health) / float(KFPH.HealthMax) );
        KFPRI.PLayerHealth = KFPH.Health;
	}
	//KFPRI.CurrentPerkLevel = 0;

	KFPH.AddDefaultInventory();
}

exec function KillBots()
{
	local Controller P;

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		if( KFAIController(P) != none && KFAIController(P).bIsPlayer )
		{
			P.Pawn.KilledBy(P.Pawn);
			P.Destroy();
		}
	}
}

/**
 * Spawn a ZED for debugging, shooting at, etc
 **/
simulated exec function KFPawn SpawnZed(string ZedName, optional float Distance = 200.f, optional bool bNoCollisionFail, optional name SpawnAtTag)
{
	local class<KFPawn> SpawnClass;
	local vector SpawnLoc;
	local rotator SpawnRot;
	local KFPawn KFP;
	local KFPathnode KFPN;

    SpawnClass = LoadMonsterByName(ZedName);
    if ( SpawnClass == none )
    {
     	return none;
    }

	if( SpawnAtTag != '' )
	{
		foreach WorldInfo.AllNavigationPoints( class'KFPathnode', KFPN )
		{
			if( KFPN.DebugTag != '' )
			{
				if(KFPN.DebugTag == SpawnAtTag )
				{
					SpawnLoc = KFPN.Location;
				}
			}
		}
	}
	else
	// The ZED should be spawned X units in front of the view location
	if ( Pawn != None )
		SpawnLoc = Pawn.Location;
	else
		SpawnLoc = Location;

	SpawnLoc += Distance * Vector(Rotation) + vect(0,0,1) * 15;
	SpawnRot.Yaw = Rotation.Yaw + 32768;

	KFP = Spawn(SpawnClass, , , SpawnLoc, SpawnRot,, bNoCollisionFail);
	if ( KFP != None )
	{
		if (KFPawn_Monster(KFP) != none)
		{
			KFPawn_Monster(KFP).bDebug_SpawnedThroughCheat = true;
		}
		KFP.SetPhysics(PHYS_Falling);
		KFGameInfo(WorldInfo.Game).SetMonsterDefaults( KFPawn_Monster(KFP));
        if( KFP.Controller != none && KFAIController(KFP.Controller) != none )
        {
            KFGameInfo(WorldInfo.Game).GetAIDirector().AIList.AddItem( KFAIController(KFP.Controller) );
        }
	}
	else
	{
		ClientMessage("Could not spawn ZED ["$ZedName$"]. Please make sure that the ZED name to archetype mapping is set up correctly.", CheatType );
	}

	return KFP;
}

/**
* Spawn a group of ZEDs for profiling, shooting, etc.
**/
simulated exec function SpawnZedAIGroup(
	string ZedName,
	int NumRows,
	int NumCols,
	optional float Spacing = 100.f)
{
	local class<KFPawn> SpawnClass;
	local vector StartLoc, SpawnLoc, RightDir, FaceDir;
	local rotator SpawnRot;
	local KFPawn KFP;

	local int i, j;


	SpawnClass = LoadMonsterByName(ZedName);
	if (SpawnClass == none)
	{
		return;
	}

	// The ZED should be spawned X units in front of the view location
	if (Pawn != None)
		StartLoc = Pawn.Location;
	else
		StartLoc = Location;

	FaceDir = normal(GetRotatorAxis(Rotation, 0));
	RightDir = normal(GetRotatorAxis(Rotation, 1));

	for (i = 0; i<NumRows; i++)
	{
		for (j = 0; j<NumCols; j++)
		{
			SpawnLoc = StartLoc + (i + 1)*Spacing*FaceDir + (j - NumCols / 2)*Spacing*RightDir + vect(0, 0, 1) * 15;
			SpawnRot.Yaw = Rotation.Yaw + 32768;

			KFP = Spawn(SpawnClass, , , SpawnLoc, SpawnRot, , false);
			if (KFP != None)
			{
				if (KFPawn_Monster(KFP) != none)
				{
					KFPawn_Monster(KFP).bDebug_SpawnedThroughCheat = true;
				}
				KFP.SetPhysics(PHYS_Falling);
				KFGameInfo(WorldInfo.Game).SetMonsterDefaults(KFPawn_Monster(KFP));
				if (KFP.Controller != none && KFAIController(KFP.Controller) != none)
				{
					KFGameInfo(WorldInfo.Game).GetAIDirector().AIList.AddItem(KFAIController(KFP.Controller));
				}
				KFP.SpawnDefaultController();
				if (KFAIController(KFP.Controller) != none)
				{
					KFAIController(KFP.Controller).SetTeam(1);
				}
			}
			else
			{
				ClientMessage("Could not spawn ZED ["$ZedName$"]. Please make sure that the ZED name to archetype mapping is set up correctly.", CheatType);
			}
		}
	}
}

/**
 * Spawn a group of ZEDs for profiling, shooting, etc.
 **/
simulated exec function SpawnZedGroup(
	string ZedName,
	int NumRows,
	int NumCols,
	optional float Spacing = 100.f,
	optional bool bUseGoreLOD = false,
	optional int ForcedLOD = 0)
{
	local class<KFPawn> SpawnClass;
	local vector StartLoc, SpawnLoc, RightDir, FaceDir;
	local rotator SpawnRot;
	local KFPawn KFP;
	local KFPawn_Monster KFPM;
	local int i, j;

    SpawnClass = LoadMonsterByName(ZedName);
    if ( SpawnClass == none )
    {
     	return;
    }

	// The ZED should be spawned X units in front of the view location
	if ( Pawn != None )
		StartLoc = Pawn.Location;
	else
		StartLoc = Location;

	FaceDir = normal(GetRotatorAxis(Rotation, 0));
	RightDir = normal(GetRotatorAxis(Rotation, 1));

	for( i =0; i<NumRows; i++ )
	{
		for( j=0; j<NumCols; j++ )
		{
			SpawnLoc = StartLoc + (i+1)*Spacing*FaceDir + (j - NumCols/2)*Spacing*RightDir + vect(0,0,1)*15;
			SpawnRot.Yaw = Rotation.Yaw + 32768;

			KFP = Spawn(SpawnClass, , , SpawnLoc, SpawnRot);
			if ( KFP != None )
			{
				KFP.SetPhysics(PHYS_Falling);

                if( KFP.Controller != none && KFAIController(KFP.Controller) != none )
                {
                    KFGameInfo(WorldInfo.Game).GetAIDirector().AIList.AddItem( KFAIController(KFP.Controller) );
                }

				if( bUseGoreLOD )
				{
					KFPM = KFPawn_Monster(KFP);
					if( KFPM != none )
					{
                        KFPM.SwitchToGoreMesh();
					}
					else
					{
						ClientMessage("Failed to switch to gore LOD", CheatType);
					}
				}

				if( ForcedLOD != 0 )
				{
					KFP.mesh.ForcedLODModel = ForcedLOD;
				}
			}
		}
	}
}

/**
 * Spawn a group of ZEDs for profiling, shooting, etc.
 **/
simulated exec function SpawnZedLODs(string ZedName)
{
	local class<KFPawn> SpawnClass;
	local vector StartLoc, SpawnLoc, RightDir, FaceDir;
	local rotator SpawnRot;
	local KFPawn KFP;

    SpawnClass = LoadMonsterByName(ZedName);
    if ( SpawnClass == none )
    {
     	return;
    }

	// The ZED should be spawned X units in front of the view location
	if ( Pawn != None )
		StartLoc = Pawn.Location;
	else
		StartLoc = Location;

	FaceDir = normal(GetRotatorAxis(Rotation, 0));
	RightDir = normal(GetRotatorAxis(Rotation, 1));

	SpawnLoc = StartLoc + 200*FaceDir - 200*RightDir + vect(0,0,1)*15;
	SpawnRot.Yaw = Rotation.Yaw + 32768;
	KFP = Spawn(SpawnClass, , , SpawnLoc, SpawnRot);
	KFP.mesh.ForcedLODModel = 1;

	SpawnLoc = StartLoc + 200*FaceDir - 100*RightDir + vect(0,0,1)*15;
	SpawnRot.Yaw = Rotation.Yaw + 32768;
	KFP = Spawn(SpawnClass, , , SpawnLoc, SpawnRot);
	KFP.mesh.ForcedLODModel = 2;

	SpawnLoc = StartLoc + 200*FaceDir + 0*RightDir + vect(0,0,1)*15;
	SpawnRot.Yaw = Rotation.Yaw + 32768;
	KFP = Spawn(SpawnClass, , , SpawnLoc, SpawnRot);
	KFP.mesh.ForcedLODModel = 3;

	SpawnLoc = StartLoc + 200*FaceDir + 100*RightDir + vect(0,0,1)*15;
	SpawnRot.Yaw = Rotation.Yaw + 32768;
	KFP = Spawn(SpawnClass, , , SpawnLoc, SpawnRot);
	KFP.mesh.ForcedLODModel = 4;
}

/** returns a any random clot AIType */
function string GetRandomClotType()
{
	switch ( rand(2) )
	{
	case 0:
		return "KFGameContent.KFPawn_ZedClot_Alpha";
	case 1:
		return "KFGameContent.KFPawn_ZedClot_Slasher";
	case 2:
		return "KFGameContent.KFPawn_ZedClot_Cyst";
	}

	`warn("GetRandomClotType no type selected");
}

/** Sets a KFSpawner active with a test group of AI */
exec function TestPortalNearby( string ZedName, optional int NumSpawns=1 )
{
	local KFSpawner Spawner, Best;
	local vector MyLocation;
	local float BestDist;

	foreach WorldInfo.AllActors( class'KFSpawner', Spawner )
	{
		MyLocation = (Pawn != None) ? Pawn.Location : Location;
		if( Best == none || VSize(Spawner.Location - MyLocation) < BestDist )
		{
			Best = Spawner;
			BestDist = VSize(Best.Location - MyLocation);
		}
	}

	if( Best != none )
	{
		Best.TestSpawn(LoadMonsterByName(ZedName), NumSpawns, true);
	}
}

/** Sets a KFSpawner active with a test group of AI */
exec function TestPortalAll( optional string ZedName )
{
	local KFSpawner Spawner;

	foreach WorldInfo.AllActors( class'KFSpawner', Spawner )
	{
	   	Spawner.TestSpawn(LoadMonsterByName(ZedName), 1, true);
		Spawner.bIgnoreChildren = true;
	}
}

exec function TestPortalActive( optional string ZedName )
{
	local KFSpawner ActiveSpawner;

	ActiveSpawner = KFGameInfo(WorldInfo.Game).SpawnManager.ActiveSpawner;
	if ( ActiveSpawner != none )
	{
		ActiveSpawner.TestSpawn(LoadMonsterByName( ZedName ), 1, true);
	}
	else
	{
		ClientMessage( "Warning - No spawn volume has been activated.", CheatType , 13.f );
		`log("Say No spawn volume has been activated");
	}
}


/**
 * Test a Spawn Volume - currently only [ToDo: Remove bCrawlersOnly & allow ability to specify any type]
 */
exec function TestSpawnVolume( int SpawnAmount, optional bool bCrawlersOnly, optional bool bBloatsOnly )
{
	local KFSpawnVolume			SpawnVolume, ClosestSpawnVolume;
	local array< class<KFPawn_Monster> >	FakeSpawnList;
	local int i;
	local class<KFPawn_Monster>			TempPawn;

	for( i = 0; i < SpawnAmount; i++ )
	{
		if( bCrawlersOnly )
		{
			TempPawn = class<KFPawn_Monster>(DynamicLoadObject( "KFGameContent.KFPawn_ZedCrawler", class'Class' ) );
		}
		else if( bBloatsOnly )
		{
			TempPawn = class<KFPawn_Monster>(DynamicLoadObject( "KFGameContent.KFPawn_ZedBloat", class'Class' ) );
		}
		else
		{
			TempPawn = class<KFPawn_Monster>(DynamicLoadObject( GetRandomClotType(), class'Class' ) );
		}
		FakeSpawnList.AddItem( TempPawn );
	}

	for( i = 0; i < SpawnAmount; i++ )
	{
		`log( "FakeSpawnList "$i$" is "$FakeSpawnList[ i ] );
	}

	foreach allactors( class'KFSpawnVolume', SpawnVolume )
	{
		if( ClosestSpawnVolume == none )
		{
			ClosestSpawnVolume = SpawnVolume;
		}
		else
		{
			if( Pawn != none )
			{
				if( VSize( SpawnVolume.Location - Pawn.Location ) < VSize( ClosestSpawnVolume.Location - Pawn.Location ) )
				{
					ClosestSpawnVolume = SpawnVolume;
				}
			}
			else
			{
				// This looks odd since Outer is a Controller and it's usually a mistake to get the Controller's location, but this
				// is specifically for ToggleDebugCamera mode. Your PlayerController and Pawn are left behind and you are a pawnless
				// free-floating DebugCameraController which has valid locations (see EnableDebugCamera() in GameCheatManager).
				// Your old pawn is still accessible through the DebugCameraController, using OriginalControllerRef.Pawn , but in this
				// case it's assumed you want to be checking the closest volume to where your free floating view is, rather than the
				// the old location where you first turned on ToggleDebugCamera.
				if( VSize( SpawnVolume.Location - Outer.Location ) < VSize( ClosestSpawnVolume.Location - Outer.Location ) )
				{
					ClosestSpawnVolume = SpawnVolume;
				}
			}
		}
	}

	ClosestSpawnVolume.SpawnWave( FakeSpawnList, false );
}

/**
 * Test a Spawn Volume - currently only
 */
exec function SetSpawnVolumeDebug(bool bSpawnDebug, optional bool bDebugRating, optional bool bDebugVisibility)
{
	local KFSpawnVolume			SpawnVolume;
	local KFSpawner             Spawner;

	foreach allactors( class'KFSpawnVolume', SpawnVolume )
	{
        SpawnVolume.bDebugSpawning = bSpawnDebug;
        SpawnVolume.bDebugRatingChecks = bDebugRating;
        SpawnVolume.bDebugVisibilityChecks = bDebugVisibility;
	}

	foreach allactors( class'KFSpawner', Spawner )
	{
        Spawner.bDebugSpawning = bSpawnDebug;
	}

    ClientMessage("Setting bDebugSpawning to "$bSpawnDebug$" for Spawn Volumes and Portal Spawns", CheatType );
}

/**
 * Test a Spawn Volume - currently only
 */
exec function SetSpawnVolumeMinDebug(bool bNewMinDebug)
{
	local KFSpawnVolume			SpawnVolume;

	foreach allactors( class'KFSpawnVolume', SpawnVolume )
	{
        SpawnVolume.bMinimalDebugRatingChecks = bNewMinDebug;
	}

    ClientMessage("Setting bMinimalDebugRatingChecks to "$bNewMinDebug$" for Spawn Volumes", CheatType );
}

/**
 * Test zed spawning
 */
exec function SpawnTest( int SpawnAmount, optional bool bSimSpawn, optional bool bSpawnZeds )
{
	local KFSpawnVolume			SpawnVolume;
	local array< class<KFPawn_Monster> >	FakeSpawnList;
	local int i;
	local class<KFPawn_Monster>			TempPawn;

    FlushPersistentDebugLines();
    RemoveAllDebugStrings();

	for( i = 0; i < SpawnAmount; i++ )
	{
		TempPawn = class<KFPawn_Monster>(DynamicLoadObject( GetRandomClotType(), class'Class' ) );
		FakeSpawnList.AddItem( TempPawn );
	}

	for( i = 0; i < SpawnAmount; i++ )
	{
		`log( "FakeSpawnList "$i$" is "$FakeSpawnList[ i ] );
	}

    if( KFGameInfo(WorldInfo.Game) != none )
	{
        //EST_Small,
        //EST_Crawler,
        KFGameInfo(WorldInfo.Game).SpawnManager.DesiredSquadType = EST_Crawler;
        SpawnVolume = KFGameInfo(WorldInfo.Game).SpawnManager.GetBestSpawnVolume( FakeSpawnList );
        if( bSimSpawn && !bSpawnZeds )
        {
            SpawnVolume.SetLastSpawnTime(WorldInfo.TimeSeconds);
            KFGameInfo(WorldInfo.Game).MyKFGRI.AddRecentSpawnVolume(SpawnVolume.Location);
        }
	}

    ClientMessage("Checking Spawns, best volume = "$SpawnVolume, CheatType );

    if( bSpawnZeds )
    {
        SpawnVolume.SpawnWave(FakeSpawnList, true);
    }
}

/**
 * Test zed spawning
 */
exec function SpawnBloatTest( int SpawnAmount, optional bool bSimSpawn, optional bool bSpawnZeds )
{
	local KFSpawnVolume			SpawnVolume;
	local array< class<KFPawn_Monster> >	FakeSpawnList;
	local int i;
	local class<KFPawn_Monster>			TempPawn;

    FlushPersistentDebugLines();
    RemoveAllDebugStrings();

	for( i = 0; i < SpawnAmount; i++ )
	{
		TempPawn = class<KFPawn_Monster>(DynamicLoadObject( "KFGameContent.KFPawn_ZedBloat", class'Class' ) );
		FakeSpawnList.AddItem( TempPawn );
	}

	for( i = 0; i < SpawnAmount; i++ )
	{
		`log( "FakeSpawnList "$i$" is "$FakeSpawnList[ i ] );
	}

    if( KFGameInfo(WorldInfo.Game) != none )
	{
        //EST_Small,
        //EST_Crawler,
        KFGameInfo(WorldInfo.Game).SpawnManager.DesiredSquadType = EST_Crawler;
        SpawnVolume = KFGameInfo(WorldInfo.Game).SpawnManager.GetBestSpawnVolume( FakeSpawnList );
        if( bSimSpawn && !bSpawnZeds )
        {
            SpawnVolume.SetLastSpawnTime(WorldInfo.TimeSeconds);
            KFGameInfo(WorldInfo.Game).MyKFGRI.AddRecentSpawnVolume(SpawnVolume.Location);
        }
	}

    ClientMessage("Checking Spawns, best volume = "$SpawnVolume, CheatType );

    if( bSpawnZeds )
    {
        SpawnVolume.SpawnWave(FakeSpawnList, true);
    }
}

exec function FocusOnZed( optional bool bTextOnly=false )
{
	local class<Actor> FocusClass;
	local Actor PotentialFocusActor, FirstActor;
	local bool bFound;

	FocusClass = class'KFGame.KFPawn_Monster';

	ForEach AllActors( FocusClass, PotentialFocusActor )
	{
		if( KFPawn(PotentialFocusActor) != none && !KFPawn(PotentialFocusActor).IsAliveAndWell() )
		{
			continue;
		}
		if( bFound || ( FirstActor == None ) )
		{
			FirstActor = PotentialFocusActor;

			if( bFound )
			{
				break;
			}
		}
		if( DebugSceneCamera != none && PotentialFocusActor == DebugSceneCamera.FocusActor )
		{
			bFound = true;
		}
	}

	// Found an actor to focus on, so initialize the debug scene...
	if( FirstActor != none )
	{
		ClientMessage( "Focusing on Zed: "$FirstActor.Name$" [Note: For additional debug scene window, add TRUE to the command ( FocusOnZed TRUE )]", CheatType );
		InitDebugScene( FirstActor, bTextOnly );
	}
}

/** Focus on an actor by class type - handled like ViewClass command */
exec function FocusOn( class<Actor> FocusClass, optional bool bTextOnly=false )
{
	local Actor PotentialFocusActor, FirstActor;
	local bool bFound;

	// Might restrict this more, as it currently will include controllers and other invisible
	// objects. Some of that might be useful, though...
	ForEach AllActors( FocusClass, PotentialFocusActor )
	{
		if( Pawn(PotentialFocusActor) != none && !Pawn(PotentialFocusActor).IsAliveAndWell() )
		{
			continue;
		}

		if( bFound || ( FirstActor == None ) )
		{
			FirstActor = PotentialFocusActor;

			if( bFound )
			{
				break;
			}
		}
		if( DebugSceneCamera != none && PotentialFocusActor == DebugSceneCamera.FocusActor )
		{
			bFound = true;
		}
	}

	// Found an actor to focus on, so initialize the debug scene...
	if( FirstActor != none )
	{
		ClientMessage( "DebugView from: "$FirstActor.Name, CheatType );
		InitDebugScene( FirstActor, bTextOnly );
	}
}

function InitDebugScene( actor ActorToWatch, optional bool bTextOnly )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( Outer );

	if( KFPC != none )
	{
		if( DebugSceneCamera == none )
		{
			DebugSceneCamera = Spawn( class'KFSceneCaptureDebugCam', Pawn,, Pawn.Location, Pawn.Rotation,, true );
			DebugSceneCamera.bTextOnly = bTextOnly;
		}

		/** Debug view window is drawn in PostRender, which requires bShowOverlays to be true and the debug camera must
			be in the HUD's list of actors to receive the PostRender event */
		myHUD.bShowOverlays = true;
		myHUD.AddPostRenderedActor( DebugSceneCamera );

		bDebugSceneEnabled = DebugSceneCamera.InitDebugScene( KFPC, ActorToWatch );
	}
}

exec function WeldDoors( optional int inNewIntegrity=-1 )
{
	local KFDoorActor KFDA;
	local int NewIntegrity;

	foreach WorldInfo.AllActors( class'KFDoorActor', KFDA )
	{
		if( inNewIntegrity == -1 )
		{
			NewIntegrity = KFDA.MaxWeldIntegrity;
		}
		else
		{
			NewIntegrity = inNewIntegrity;
		}
		KFDA.WeldIntegrity = NewIntegrity;
	}
}

exec function DestroyDoors( optional byte Reverse )
{
	local KFDoorActor KFDA;

	foreach WorldInfo.AllActors( class'KFDoorActor', KFDA )
	{
		KFDA.HitCount++;
		if ( Reverse != 0 )
		{
            // Set the last bit to indicate the hit direction
            KFDA.HitCount = KFDA.HitCount | KFDA.HIT_DIRECTION_FLAG;
        }
        else
        {
            // Clear out the last bit to indicate the hit direction
            KFDA.HitCount = KFDA.HitCount & byte(~KFDA.HIT_DIRECTION_FLAG);
        }

		KFDA.PlayDestroyed();
	}
}

exec function ResetLevel()
{
    WorldInfo.Game.ResetLevel();
}

exec function ResetDoors()
{
	local KFDoorActor KFDA;

	foreach WorldInfo.AllActors( class'KFDoorActor', KFDA )
	{
		KFDA.ResetDoor();
	}
}

exec function AISetFocalPoint( optional bool bClear=false )
{
	local KFAIController KFAIC;

	foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
	{
		if( KFAIC != none && FastTrace( KFAIC.Pawn.Location, Pawn.Location ) )
		{
			if( KFAIC.GetActiveCommand().IsA( 'AICommand_Debug' ) )
			{
				if( bClear )
				{
					SetFocalPoint( vect(0,0,0) );
				}
				else
				{
					KFAIC.SetFocalPoint( Pawn.Location );
				}
			}
		}
	}

	ClientMessage(KFAIC.Pawn$"'s FocalPoint is now "$KFAIC.GetFocalPoint(), CheatType );
}

exec function AIClearFocus( optional bool bResetDesiredRot, optional bool bResetFocus, optional bool bResetFocalPoint )
{
	local KFAIController KFAIC;
	local String msg;

	KFAIC = GetKFAICFromAim( false );
	if( KFAIC != none )
	{
		msg = Pawn$" [ClearFocus]";
		if( bResetDesiredRot )
		{
			msg = msg$"[Resetting DesiredRotation]";
			KFAIC.MyKFPawn.ResetDesiredRotation();
		}
		if( bResetFocalPoint )
		{
			msg = msg$"[Resetting FocalPoint]";
			KFAIC.SetFocalPoint(vect(0,0,0));
		}
		if( bResetFocus )
		{
			msg = msg$"[Resetting Focus]";
			KFAIC.Focus = none;
		}
	}
}

exec function AIUnlockDesiredRotation()
{
	local KFAIController KFAIC;
	KFAIC = GetKFAICFromAim( false );
	if( KFAIC != none && KFAIC.MyKFPawn != none )
	{
		KFAIC.MyKFPawn.LockDesiredRotation( false );
	}
}

exec function AILockDesiredRotation( optional bool bLock=true )
{
	local KFAIController KFAIC;

	KFAIC = GetKFAICFromAim( false );
	if( KFAIC != none && KFAIC.MyKFPawn != none )
	{
		KFAIC.MyKFPawn.LockDesiredRotation( bLock );
	}
}

exec function AISetFocus( optional bool bFocusOnMe, optional bool bSetFocalPoint, optional bool bSetDesiredRot, optional bool bLockDesiredRot )
{
	local KFAIController KFAIC;
	local String msg;
	KFAIC = GetKFAICFromAim( false );
	if( KFAIC != none && KFAIC.MyKFPawn != none )
	{
		msg = KFAIC.Pawn$" [SetFocus]";
		if( bSetDesiredRot )
		{
			KFAIC.MyKFPawn.SetDesiredRotation( rotator(GetMyPawn().Location - KFAIC.Pawn.Location), bLockDesiredRot  );
			msg = msg$"[DesiredRot: "$KFAIC.MyKFPawn.DesiredRotation$"]";
		}
		if( bSetFocalPoint )
		{
			KFAIC.SetFocalPoint(GetMyPawn().Location);
			msg = msg$"[FocalPoint: "$KFAIC.GetFocalPoint()$"]";
		}
		if( bFocusOnMe )
		{
			KFAIC.Focus = GetMyPawn();
			msg = msg$"[Focus: "$Focus$"]";
		}
		ClientMessage( msg, CheatType );
	}
}

/** Turn off the debug scene camera view */
exec function FocusOff()
{
	DestroyDebugScene();
}

/** Destroy the debug scene, remove the camera from the HUD's post render list, etc. */
function DestroyDebugScene()
{
	bDebugSceneEnabled = false;
	myHUD.bShowOverlays = false; // Change this if we ever use overlays for anything else!

	if( DebugSceneCamera != none )
	{
		myHUD.RemovePostRenderedActor( DebugSceneCamera );
		DebugSceneCamera.DestroyDebugScene();
		DebugSceneCamera = none;
	}
}

/** Toggle the KFSceneCaptureDebugCam orbiting behavior. Orbiting is especially helpful if the focus
	actor is moving. */
exec function ToggleDebugSceneOrbit()
{
	if( DebugSceneCamera != none )
	{
		DebugSceneCamera.ToggleDebugSceneOrbit();
	}
}

/** Pause debug scene updating - the view remains but won't update until it's unpaused */
exec function PauseDebugSceneUpdate()
{
	if( DebugSceneCamera != none )
	{
		DebugSceneCamera.PauseDebugSceneUpdate();
	}
}

/** Override the scene capture view mode (wireframe, unlit, lit no shadows, etc.) */
function SetDebugSceneViewMode( ESceneCaptureViewMode NewViewMode )
{
	if( bDebugSceneEnabled && DebugSceneCamera != none )
	{
		DebugSceneCamera.SetDebugSceneViewMode( NewViewMode );
	}
}

/** This will override the KFSceneCaptureDebugCam behavior by stopping its movement and shifting
	its focus to match the player's viewpoint at the time the command was issued */
exec function SetDebugSceneView()
{
	if( bDebugSceneEnabled && DebugSceneCamera != none )
	{
		DebugSceneCamera.MoveToMyPawnLocation();
	}
}
`if(`notdefined(ShippingPC))
exec function StartFireTimer(float TimerInterval = 1.0f)
{
	if (TimerInterval <= 0)
	{
		ClearTimer(nameof(FireIntervalTimer), self);
	}
	else
	{
		SetTimer(TimerInterval, true, nameOf(FireIntervalTimer), self);
	}
}

function FireIntervalTimer()
{
	ConsoleCommand("StartFire 0");
}
`endif
exec function ToggleSplatterGun()
{
	local KeyBind TempKeyBind;
    local KFPlayerInput KFInput;

	TempKeyBind.Name = 'LeftMouseButton';

    KFInput = KFPlayerInput(PlayerInput);
    if( KFInput != none )
    {
        if(!bUsingSplatterGun && KFPlayerInput(PlayerInput) != none)
        {
            KFInput.RemoveCommandFromBind(TempKeyBind, "GBA_Fire");
            KFInput.SetKeyBind(TempKeyBind, "SplatterFire", false);
			KFInput.SaveConfig();
            bUsingSplatterGun = true;
        }
        else
        {
            KFInput.RemoveCommandFromBind(TempKeyBind, "SplatterFire");
            KFInput.SetKeyBind(TempKeyBind, "GBA_Fire", false);
			KFInput.SaveConfig();
            bUsingSplatterGun = false;
        }
    }
}

exec function SplatterFire()
{
	//why you no work
	if (IsTimerActive(nameof(DoSplatterFire), self))
	{
		StopSplatterFire();
	}
	else
	{
		DoSplatterFire();

		SetTimer(0.1, true, nameof(DoSplatterFire), self);
	}
}

exec function StopSplatterFire()
{
	ClearTimer(nameof(DoSplatterFire), self);
}

function DoSplatterFire()
{
	local KFGoreManager GoreManager;
	local vector StartTrace, TraceDir;

	if (!bUsingSplatterGun) {
		StopSplatterFire();
	}

	// Grab the gore manager
	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if (GoreManager == none)
	{
		`warn("##### Could not find gore manager #####");
		return;
	}

	// Leave a splat on level geometry along the direction being shot at
	StartTrace = Pawn.GetWeaponStartTraceLocation();
	TraceDir = vector(Pawn.Weapon.GetAdjustedAim(StartTrace));
	GoreManager.LeaveAPersistentBloodSplat(StartTrace, TraceDir);

	//Trace(OutHitLocation, OutHitNormal, EndTrace, StartTrace);
	//DrawDebugLine(StartTrace, OutHitLocation, 255, 0, 0, true);
	//DrawDebugStar(OutHitLocation, 10, 255, 255, 255, true);
}

exec function ClearSplatters()
{
	local KFGoreManager GoreManager;

	// Grab the gore manager
	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager == none )
	{
		`warn("##### Could not find gore manager #####");
		return;
	}

	// Clear the splats
	GoreManager.ClearPersistentBloodSplats();
}

exec function ClearCorpses()
{
	local int i;
	local KFGoreManager GoreManager;

	// Grab the gore manager
	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	if( GoreManager == none )
	{
		return;
	}

	// remove all humans from the corpse pool during respawn
	for (i = GoreManager.CorpsePool.Length-1; i >= 0; i--)
	{
		GoreManager.RemoveAndDeleteCorpse(i);
	}
}

exec function EndRound( optional bool bSkipResults )
{
    if( WorldInfo.Game != none )
    {
        WorldInfo.Game.GotoState( 'RoundEnded', bSkipResults ? 'ForceEnded' : 'Begin' );
    }
}

exec function CameraBlood()
{
	Outer.ClientSpawnCameraLensEffect(class'KFCameraLensEmit_BloodBase');
}

exec function HeadShotPing (bool value)
{
}

exec function CameraPuke()
{
	Outer.ClientSpawnCameraLensEffect(class'KFCameraLensEmit_Puke');
}

exec function EnableAtkAnimDifficultyScaling()
{
	ConsoleCommand("SETNOPEC KFPawnAnimInfo bEnableDifficultyScaling true");
}

exec function DisableAtkAnimDifficultyScaling()
{
	ConsoleCommand("SETNOPEC KFPawnAnimInfo bEnableDifficultyScaling false");
}

`if(`notdefined(ShippingPC))
exec function FindAllCollectibles()
{
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);

	KFGI.FindCollectibles();
}

exec function SetDoshScalarValue(float Poop)
{
	if (KFGameInfo_Entry(WorldInfo.Game) != none)
	{
		KFGameInfo_Entry(WorldInfo.Game).InitDoshLitter(Poop);
	}
}

exec function DoshVaultAmount(int DoshVaultAmount, bool bMatchCurrentAndLast)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Outer);

	if (bMatchCurrentAndLast)
	{
		KFPC.DebugLastSeenDoshVaultValue = DoshVaultAmount;
		KFPC.DebugCurrentDoshVaultValue = DoshVaultAmount;
		KFPC.DebugCurrentDoshVaultTier = DoshVaultAmount;
	}
	else
	{
		KFPC.DebugLastSeenDoshVaultValue = DoshVaultAmount - KFPC.GetDoshVaultTierValue();
		KFPC.DebugCurrentDoshVaultValue = DoshVaultAmount;
		KFPC.DebugCurrentDoshVaultTier = DoshVaultAmount - KFPC.GetDoshVaultTierValue();
	}

	if (KFPC != none && KFPC.MyGFxManager != none && KFPC.MyGFxManager.DoshVaultMenu != none)
	{
		if (KFPC.MyGFxManager.CurrentMenuIndex == UI_Dosh_Vault)
		{
			if (KFGameInfo_Entry(WorldInfo.Game) != none)
			{
				KFGameInfo_Entry(WorldInfo.Game).SpawnDoshPilesForAmount(KFPC.DebugLastSeenDoshVaultValue);
			}
			KFPC.MyGFxManager.DoshVaultMenu.SendDoshInfo(KFPC.DebugLastSeenDoshVaultValue, KFPC.DebugCurrentDoshVaultValue, KFPC.DebugCurrentDoshVaultTier, KFPC.GetDoshVaultTierValue(), 0);
		}
	}
}

exec function EnableForceSpecialZeds()
{
    ConsoleCommand("SETNOPEC KFMonsterDifficultyInfo bForceSpecialSpawn true");
}
exec function DisableForceSpecialZeds()
{
    ConsoleCommand("SETNOPEC KFMonsterDifficultyInfo bForceSpecialSpawn false");
}

exec function SetVaultParams()
{

}
`endif

/** Prints out a pawns modifier and final default values when spawned */
exec function ToggleAIDefaultsLog()
{
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);
  	if( KFGI != none )
	{
       KFGI.bLogAIDefaults = !KFGI.bLogAIDefaults;
	}
}

/** Forces the game to think this many players are alive */
exec function SetLivingPlayers( byte NewLivingPlayers, optional bool bSoloMode = false )
{
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);
  	if( KFGI != none )
	{
       KFGI.bOnePlayerAtStart = bSoloMode;
       KFGI.ForceLivingPlayerCount( NewLivingPlayers );
	}
}

`if(`notdefined(ShippingPC))
/** Tells the Versus spawn manager to simulate X number of zed players using AI */
exec function SetAISimulatedPlayersV( byte NewSimulatedAIPlayers, optional byte NewSimulatedMercPlayers=0 )
{
    ConsoleCommand( "SETNOPEC KFAISpawnManager_Versus bUsingAISimulatedPlayers" @ NewSimulatedAIPlayers > 0 ? "true" : "false" );
    ConsoleCommand( "SETNOPEC KFAISpawnManager_Versus AISimulatedPlayerNum" @ NewSimulatedAIPlayers );
    if( NewSimulatedMercPlayers > 0)
    {
        SetLivingPlayers( NewSimulatedMercPlayers );
    }
}
`endif

/** converts a legacy 4/3 aspect ratio FOV to a 16/9 FOV */
exec function ConvertFOV(float InFOV)
{
	local float AspectRatio, OriginalAspectRatio;
	local float NewFOV;

	// 16/9 resolution scaled to 4/3 FOV
	AspectRatio = 16/9;
	OriginalAspectRatio = 4/3;
	NewFOV = (ATan2((Tan((InFOV*Pi)/360.0)*(AspectRatio/OriginalAspectRatio)),1)*360.0)/Pi;

	`log("FOV --- Original:"@InFOV@"New:"@NewFOV);
}

/** Ignore this - it's a very specific function called by Kismet in a test level which has a toggleable pointlight with a
 *  light animation. Toggling the light on the normal way doesn't work unless I update the light's last render time. Rather
 *  than editing the lighting code, I'm just going to use this cheat command (invoked by Kismet) to do so. */
exec function TurnOnAIArenaLight()
{
	local PointLightToggleable PLT;

	foreach WorldInfo.AllActors( class'PointLightToggleable', PLT )
	{
		PLT.bEnabled = true;
		PLT.LightComponent.SetEnabled( true );
		PLT.LastRenderTime = WorldInfo.TimeSeconds;
	}
}

exec function SetNadeRadiusDebug(bool bShowRadius)
{
	class'KFExplosionActor'.default.bDrawDebug = bShowRadius;
	class'KFExplosionActor'.static.StaticSaveConfig();
}

/** Spawn explosion fragment chunks for testing */
exec function LaunchChunks( int NumChunks, bool bNoSpread )
{
	local vector SpawnPos, BaseChunkDir;
	local rotator rot;
	local int i;
	local Projectile NewChunk;
	local vector ViewLocation;
	Local rotator ViewRotation;
	local KFPerk MyPerk;

	MyPerk = KFPawn(Pawn).GetPerk();

	GetPlayerViewPoint(ViewLocation, ViewRotation);

	SpawnPos = ViewLocation;

	if ( Pawn != none && Pawn.Role == ROLE_Authority )
	{
		BaseChunkDir = vector(ViewRotation);

		for (i = 0; i < NumChunks; i++)
		{
            if ( bNoSpread )
            {
                rot = rotator(BaseChunkDir);
            }
            else
            {
                rot = rotator(8 * BaseChunkDir + VRand());
            }

			NewChunk = Pawn.Weapon.Spawn(MyPerk.GrenadeClass.default.ExplosionTemplate.ShardClass,Pawn.Weapon != none ? Pawn.Weapon : Pawn,, SpawnPos, rot);

			if (NewChunk != None)
			{
				NewChunk.Init(vector(rot));
			}
		}
	}
}

exec function ShowMeleeCollision(bool bEnable=true)
{
	ConsoleCommand("SETNOPEC KFMeleeHelperBase bDebugShowCollision"@bEnable);
}

exec function Chris()
{
	ConsoleCommand("SUPPRESS DevPhysics");
	God();
	AllWeapons();
	Uberammo();
	ConsoleCommand("ToggleSpawning");
}

exec function TestGameSearch(optional bool bSearchLan)
{
	local KFDataStore_OnlineGameSearch	SearchDataStore;
	local DataStoreClient DataStoreManager;
	local bool succeed;
	local OnlineGameSearch GameSearch;

	DataStoreManager = class'UIInteraction'.static.GetDataStoreClient();
	if (DataStoreManager == None)
	{
		`log("No data store manager");
		ClientMessage("No data store manager", CheatType );
		return;
	}
	SearchDataStore = KFDataStore_OnlineGameSearch(DataStoreManager.FindDataStore('KFGameSearch', LocalPlayer(Player)));
	if (SearchDataStore == None)
	{
		`log("No search data store found");
		ClientMessage("No search data store found", CheatType );
		return;
	}
	GameSearch = SearchDataStore.GetCurrentGameSearch();
	if (GameSearch == None)
	{
		`log("No current game search found");
		ClientMessage("No current game search found", CheatType );
		return;
	}
	GameSearch.bIsLanQuery = bSearchLan;
	succeed = SearchDataStore.SubmitGameSearch(0);
	if (succeed)
	{
		`log("Search start succeeded");
		ClientMessage("Search start succeeded", CheatType );
	}
	else
	{
		`log("Search start failed");
		ClientMessage("Search start failed", CheatType );
	}
}

exec function ShowLevelUpPopUp( bool bTierUnlock )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( Outer );

	if( KFPC != none && KFPC.MyGFxHUD != none &&  KFPC.MyGFxHUD.LevelUpNotificationWidget != none )
	{
		KFPC.MyGFxHUD.LevelUpNotificationWidget.ShowLevelUpNotification(KFPC.CurrentPerk.Class, KFPC.GetLevel(), bTierUnlock);
	}
}

exec function GetCurrentPerkXP()
{
	ClientMessage("Perk:" @ Mid(KFPawn(Pawn).GetPerk(), 7) @ "XP:" @ KFPlayerController(Outer).GetPerkXP(KFPawn(Pawn).GetPerk().Class), CheatType );
}

/** Simulate radius damage falloff for balance tweaks */
exec function TestFalloffDamage(float Distance, float MaxRadius, float FalloffExponent)
{
	local float DamageScale;

	DamageScale = FClamp(1.f - Distance/MaxRadius, 0.f, 1.f);
	DamageScale = DamageScale ** FalloffExponent;

	`log(GetFuncName()@"Result:"$DamageScale);
}

/** Zed time testing */
exec function ZedTimeTest(float NewCustomTimeDilation)
{
    GetMyPawn().CustomTimeDilation = NewCustomTimeDilation;
    GetMyPawn().Weapon.CustomTimeDilation = NewCustomTimeDilation;
}

exec function FakeDramaEvent()
{
    DramaEvent(1.0);
    ZedTimeTest(5.0);

    SetTimer(0.6,false,nameof(ClearFakeDramaEvent),self);
}

simulated function ClearFakeDramaEvent()
{
    GetMyPawn().CustomTimeDilation = 1.0;
    GetMyPawn().Weapon.CustomTimeDilation = 1.0;
}

/** Simulated a double shotgun shot momentum */
exec function DBJump()
{
    local vector UsedKickMomentum;

	// Push the player back when they fire both barrels
    if (Pawn != none )
	{
        UsedKickMomentum.X = -1000;

        if( Pawn.Physics == PHYS_Falling  )
        {
            UsedKickMomentum = UsedKickMomentum >> Pawn.GetViewRotation();
            UsedKickMomentum *= 0.5;
        }
        else
        {
            UsedKickMomentum = UsedKickMomentum >> Pawn.Rotation;
            UsedKickMomentum.Z = 0;
		}

        Pawn.AddVelocity(UsedKickMomentum,Pawn.Location,none);
	}
}

exec function ShowKFGameVersion()
{
	`log( "Current KFGame version:" @ class'KFGameEngine'.static.GetKFGameVersion() );
}


//Ammo
exec function LogAmmoPickups()
{
    local KFGameinfo KFGI;
    local float NumTotalAmmoPickups,
                NumActiveAmmoPickups,
                NumSleepingAmmoPickups,
                NumDisabledAmmoPickups;
    local int i;

    KFGI = KFGameInfo(WorldInfo.Game);
    if( KFGI != none )
    {
        `log( "~~LogAmmoPickups START~~~" );
        for( i = 0; i < KFGI.AmmoPickups.Length; i++ )
        {
            NumTotalAmmoPickups += 1.f;
            if( KFGI.AmmoPickups[i].IsInState( 'Disabled' ) )
            {
                NumDisabledAmmoPickups += 1.f;
                `log( "~~LogAmmoPickups: AmmoPickup" @ i @  "is disabled! Location:" @ KFGI.AmmoPickups[i].Location );
            }
            else if( KFGI.AmmoPickups[i].IsInState( 'sleeping' ) )
            {
                NumSleepingAmmoPickups += 1.f;
                `log( "~~LogAmmoPickups: AmmoPickup" @ i @  "is sleeping! Location:" @ KFGI.AmmoPickups[i].Location @ "; Time until respawn: " @ KFGI.AmmoPickups[i].GetRemainingTimeForTimer(nameof(KFGI.AmmoPickups[i].Reset)));
            }
            else if( KFGI.AmmoPickups[i].IsInState( 'pickup' ) )
            {
                NumActiveAmmoPickups += 1.f;
                `log( "~~LogAmmoPickups: AmmoPickup" @ i @  "is ACTIVE! Location:" @ KFGI.AmmoPickups[i].Location );
            }
        }
        `log( "~~LogAmmoPickups ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" );
        `log( "~~LogAmmoPickups: Total num ammo pickup ups:   " @ Round( NumTotalAmmoPickups ) );
        `log( "~~LogAmmoPickups: Disabled ammo pickup ups:    " @ Round( NumDisabledAmmoPickups ) );
        `log( "~~LogAmmoPickups: Sleeping ammo pickup ups:    " @ Round( NumSleepingAmmoPickups ) );
        `log( "~~LogAmmoPickups: Active ammo pickup ups:      " @ Round( NumActiveAmmoPickups ) );
        `log( "~~LogAmmoPickups: Percentages: Disabled:" @ (100 / NumTotalAmmoPickups) * NumDisabledAmmoPickups $ "%" @ "Sleeping:" @ (100 / NumTotalAmmoPickups) * NumSleepingAmmoPickups $ "%" @ "Active:" @ (100 / NumTotalAmmoPickups) * NumActiveAmmoPickups $ "%" );
        `log( "~~LogAmmoPickups END~~~" );
    }
}

exec function LogItemPickups()
{
    local KFGameinfo KFGI;
    local float NumTotalItemPickups,
                NumActiveItemPickups,
                NumSleepingItemPickups,
                NumDisabledItemPickups;
    local int i;

    KFGI = KFGameInfo(WorldInfo.Game);
    if( KFGI != none )
    {
       `log( "~~LogItemPickups ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" );
       `log( "~~LogItemPickups START~~~" );
       `log( "~~LogItemPickups ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" );
        for( i = 0; i < KFGI.ItemPickups.Length; i++ )
        {
            NumTotalItemPickups += 1.f;
            if( KFGI.ItemPickups[i].IsInState( 'Disabled' ) )
            {
                NumDisabledItemPickups += 1.f;
                `log( "~~LogItemPickups: ItemPickup" @ i @  "is disabled! Location:" @ KFGI.ItemPickups[i].Location );
            }
            else if( KFGI.ItemPickups[i].IsInState( 'sleeping' ) )
            {
                NumSleepingItemPickups += 1.f;
                `log( "~~LogItemPickups -------------------------------------" );
                `log( "~~LogItemPickups: ItemPickup" @ i @  "is sleeping! Location:" @ KFGI.ItemPickups[i].Location );
            }
            else if( KFGI.ItemPickups[i].IsInState( 'pickup' ) )
            {
                NumActiveItemPickups += 1.f;
                `log( "~~LogItemPickups -------------------------------------" );
                `log( "~~LogItemPickups: ItemPickup" @ i @  "is ACTIVE! Location:" @ KFGI.ItemPickups[i].Location );
                `log( "~~LogItemPickups: ItemPickup" @ i @  "item is a" @ KFPickupFactory_Item(KFGI.ItemPickups[i]).ItemPickups[ KFPickupFactory_Item(KFGI.ItemPickups[i]).PickupIndex ].ItemClass.name );
            }
        }
        `log( "~~LogItemPickups ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" );
        `log( "~~LogItemPickups: Total num item pickups:   " @ Round( NumTotalItemPickups ) );
        `log( "~~LogItemPickups: Disabled item pickups:    " @ Round( NumDisabledItemPickups ) );
        `log( "~~LogItemPickups: Sleeping item pickups:    " @ Round( NumSleepingItemPickups ) );
        `log( "~~LogItemPickups: Active item pickups:      " @ Round( NumActiveItemPickups ) );
        `log( "~~LogItemPickups: Percentages: Disabled:" @ (100 / NumTotalItemPickups) * NumDisabledItemPickups $ "%" @ "Sleeping:" @ (100 / NumTotalItemPickups) * NumSleepingItemPickups $ "%" @ "Active:" @ (100 / NumTotalItemPickups) * NumActiveItemPickups $ "%" );
        `log( "~~LogItemPickups END~~~" );
    }
}

exec function LogStatValue(int StatId)
{
    KFPlayerController(Outer).LogStatValue(StatId);
}

/** Brute force hide/unhide actors that are ignored for pawn relevancy */
exec function ToggleRelevancyView()
{
	local Actor A;
	foreach AllActors(class'Actor', A)
	{
		if( A.bIgnoreNetRelevancyCollision )
		{
			A.SetHidden( !A.bHidden );
		}
	}
}

/** Brute force hide/unhide actors that are ignored for RB visibility */
exec function ToggleVisibilityView()
{
	local Actor A;
	local StaticMeshActor SM;
	local StaticMeshComponent SMC;

	foreach AllActors(class'Actor', A)
	{
		SM = StaticMeshActor(A);
		if ( SM != None )
		{
			SMC = SM.StaticMeshComponent;
			if( !SMC.RBCollideWithChannels.Visibility )
			{
				SMC.SetHidden( !SMC.HiddenGame );
			}
		}
		else
		{
			// Unsupported Type - For a more complete view use 'show visibility'
			A.SetHidden( !A.bHidden );
		}
	}
}

/** Debugging */
exec function LogServerMovementVars()
{
	if ( Pawn != None )
	{
		`log(Pawn@"Velocity:" @ Pawn.Velocity);
		`log(Pawn@"Acceleration:" @ Pawn.Acceleration);
		`log(Pawn@"Physics:" @ Pawn.Physics);
		`log(Pawn@"bIsWalking:" @ Pawn.bIsWalking);
		`log(Pawn@"bIsSprinting:" @ KFPawn(Pawn).bIsSprinting);
		`log(Pawn@"bIsCrouched:" @ Pawn.bIsCrouched);
		`log(Pawn@"WeaponEncumbrance:" @ KFInventoryManager(Pawn.InvManager).GetEncumbranceSpeedMod());
		`log(Pawn@"GroundSpeed:" @ Pawn.GroundSpeed);
		`log(Pawn@"Speed:" @ VSize(Pawn.Velocity));
		`log(Pawn@"MovementSpeedModifier:" @ Pawn.MovementSpeedModifier);
        `log(Pawn@"Controller State:"@Outer.GetStateName());
	}
}

// respawns all spectating players
exec function RespawnSpectators()
{
    if( KFGameInfo(WorldInfo.Game) != none )
    {
        KFGameInfo(WorldInfo.Game).StartHumans();
    }
}

exec function WeaponGotoState( name StateName )
{
    if( Pawn != none && Pawn.Weapon != none )
    {
        Pawn.Weapon.GotoState( Statename );
    }
}

/** SDK - Weapon skin preview */
exec function SetWeaponSkin(int MaterialIndex, string MaterialName)
{
    local MaterialInterface NewMat;

    if( Pawn != none && Pawn.Weapon != none )
    {
        NewMat = MaterialInterface(DynamicLoadObject(MaterialName, class'MaterialInterface'));
        Pawn.Weapon.Mesh.SetMaterial(MaterialIndex, NewMat);
    }
}

/** DemiGod Mode (prevents death, but not damage) */
exec function DemiGod()
{
`if(`__TW_SDK_)
    if ( bDemiGodMode )
    {
        bDemiGodMode = false;
        ClientMessage("Demi God mode off");
        return;
    }

    bDemiGodMode = true;
    ClientMessage("Demi God Mode on");
`endif
}

/** Play grapple move if available */
exec function TestGrapple()
{
    local KFPawn_Monster P;

    foreach WorldInfo.AllPawns( class'KFPawn_Monster', P )
    {
        if ( P.CanDoSpecialMove(SM_GrappleAttack) )
        {
            P.DoSpecialMove(SM_GrappleAttack, true, Pawn);
        }
    }
}

exec function SpawnHumanPawnV(optional bool bEnemy, optional bool bUseGodMode, optional int CharIndex)
{
    local KFAIController KFBot;
    local KFPlayerReplicationInfo KFPRI;
    local vector                    CamLoc;
    local rotator                   CamRot;
    local class<KFPawn_Human> PawnClass;
    Local KFPawn_Human KFPH;
    local Vector HitLocation, HitNormal;
    local Actor TraceOwner;

    GetPlayerViewPoint(CamLoc, CamRot);

    if( Pawn != none )
    {
        TraceOwner = Pawn;
    }
    else
    {
        TraceOwner = Outer;
    }

    TraceOwner.Trace( HitLocation, HitNormal, CamLoc + Vector(CamRot) * 250000, CamLoc, TRUE, vect(0,0,0) );

    HitLocation.Z += 100;
//  FlushPersistentDebugLines();
//    DrawDebugSphere( HitLocation, 100, 12, 0, 255, 0, TRUE );

    PawnClass = class<KFPawn_Human>( DynamicLoadObject("KFGameContent.KFPawn_Human_Versus", class'Class') );
    KFPH = Spawn(PawnClass, , , HitLocation);
    KFPH.SetPhysics(PHYS_Falling);

    // Create a new Controller for this Bot
    KFBot = Spawn(class'KFAIController');

    // Silly name for now
    WorldInfo.Game.ChangeName(KFBot, "Braindead Vs. Human", false);

    // Add them to the Team they selected
    if( !bEnemy )
    {
       KFGameInfo(WorldInfo.Game).SetTeam(KFBot, KFGameInfo(WorldInfo.Game).Teams[0]);
    }

    KFBot.Possess(KFPH, false);

    if( bUseGodMode )
    {
       KFBot.bGodMode = true;
    }

    KFPRI = KFPlayerReplicationInfo( KFBot.PlayerReplicationInfo );

    // Set perk stuff
    //KFPRI.SetCharacter(CharIndex);
    KFPRI.CurrentPerkClass = Class'KFPlayerController'.default.PerkList[1].PerkClass;
    KFPRI.NetPerkIndex = 1;

    if( KFPRI != none )
    {
        KFPRI.PLayerHealthPercent = FloatToByte( float(KFPH.Health) / float(KFPH.HealthMax) );
        KFPRI.PLayerHealth = KFPH.Health;
    }
    //KFPRI.CurrentPerkLevel = 0;

    KFPH.AddDefaultInventory();
}

/** For Accessory Testing, stop player on Gear Menu */
`if(`notdefined(ShippingPC))
exec function StopPawnOnGearMenu( optional bool bTickDisabled = true )
{
    local KFPawn_Human KFPH;

    foreach WorldInfo.AllActors( class'KFPawn_Human', KFPH )
    {
        if ( KFPH != none )
        {
            KFPH.SetTickIsDisabled( bTickDisabled );
        }
        else
        {
            `log( GetFuncName() @ "Notice: No KFPawn_Human" );
        }
    }
}
`endif

// NVCHANGE_BEGIN - RLS - Debugging Effects (do not merge)
`if(`notdefined(ShippingPC))
exec function NVZedTime(bool bImmediate = false, float Chance = 100.0, float Duration = 5.0)
{
	if( KFGameInfo(WorldInfo.Game) != none )
	{
		if (bImmediate)
		{
			KFGameInfo(WorldInfo.Game).DramaticEvent(Chance, Duration);
		}
		else
		{
		KFGameInfo(WorldInfo.Game).bNVAlwaysDramatic = !KFGameInfo(WorldInfo.Game).bNVAlwaysDramatic;
		}

		if (KFGameInfo(WorldInfo.Game).bNVAlwaysDramatic)
			ClientMessage("NV: Always ZedTime ENABLED!");
		else
			ClientMessage("NV: Always ZedTime DISABLED.");
	}
}

exec function NVEnableZedTime(bool bEnable = true)
{
	if( KFGameInfo(WorldInfo.Game) != none )
	{
		KFGameInfo(WorldInfo.Game).bNVBlockDramatic = !bEnable;

		if (KFGameInfo(WorldInfo.Game).bNVBlockDramatic)
			ClientMessage("NV: ZedTime BLOCKED!");
		else
			ClientMessage("NV: ZedTime UNBLOCKED.");
	}
}

exec function NVHeadshot()
{
	if( KFGameInfo(WorldInfo.Game) != none )
	{
		KFGameInfo(WorldInfo.Game).bNVAlwaysHeadshot = !KFGameInfo(WorldInfo.Game).bNVAlwaysHeadshot;

		if (KFGameInfo(WorldInfo.Game).bNVAlwaysHeadshot)
			ClientMessage("NV: Always Headshot ENABLED!");
		else
			ClientMessage("NV: Always Headshot DISABLED.");
	}
}

exec function NVDamage()
{
	if( KFGameInfo(WorldInfo.Game) != none )
	{
		KFGameInfo(WorldInfo.Game).bNVDebugDamage = !KFGameInfo(WorldInfo.Game).bNVDebugDamage;

		if (KFGameInfo(WorldInfo.Game).bNVDebugDamage)
			ClientMessage("NV: Debug Damage ENABLED!");
		else
			ClientMessage("NV: Debug Damage DISABLED.");
	}
}

exec function NVGod()
{
	AllWeapons();
	Flame();
	Uberammo();
	KillRecoil();
	NVZedTime();
}

exec function NVSpawnFlex( optional int EffectNumber = 0, optional name BoneName)
{
	local ParticleSystem FlexPSCTemplate;
	local KFPawn KFP;
	local matrix KMatrix;
	local vector KLoc;
	local rotator KRot;
	local ParticleSystemComponent PSC;

	KFP = KFPawn(Pawn);
	if (KFP != none)
	{
		if (EffectNumber == 0)
		{
			EffectNumber = rand(5) + 1;
		}

		if (BoneName == '')
		{
			BoneName = 'head';
		}

		switch ( EffectNumber )
		{
		case 1:
			FlexPSCTemplate=ParticleSystem'FX_Gore_EMIT.FX_Obliteration_Explode';
			break;
		case 2:
			FlexPSCTemplate=ParticleSystem'FX_Gore_EMIT.FX_Spine_Jet_01';
			break;
		case 3:
			FlexPSCTemplate=ParticleSystem'ZED_Bloat_EMIT.FX_Bloat_Explode';
			break;
		case 4:
			FlexPSCTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_scream_01';
			break;
		default:
			FlexPSCTemplate=ParticleSystem'ZED_Bloat_EMIT.FX_Bloat_Barf';
			break;
		}

		KMatrix = KFP.Mesh.GetBoneMatrix( KFP.Mesh.MatchRefBone(BoneName) );
		KLoc = MatrixGetOrigin( KMatrix );
		KMatrix = MakeRotationMatrix( rot(0, -16383, 16383) ) * KMatrix;
		KRot = MatrixGetRotator( KMatrix );

	    PSC = WorldInfo.MyEmitterPool.SpawnEmitter(FlexPSCTemplate, KLoc, KRot, KFP);
		PSC.SetLightingChannels(KFP.PawnLightingChannel);
	}
}
`endif
// NVCHANGE_END - RLS - Debugging Effects

exec function ShowPostRoundMenu ()
{
    local KFPlayerController KFPC;
    KFPC = KFPlayerController(Outer);

    KFPC.ClientOpenRoundSummary();
}

exec function Hats()
{
    ConsoleCommand("set kfunlockmanager bdebugunlocks true");
}

// Playfab debugging Begin
/////////////////////////////////////////////////////////////
exec function LoginSelf()
{
	TestLogin( PlayerReplicationInfo.PlayerName );
}


exec function TestLogin( string InName )
{
	`log("Logging in"@InName);
	class'GameEngine'.static.GetPlayfabInterface().AddOnLoginCompleteDelegate( OnLoginComplete );
	class'GameEngine'.static.GetPlayfabInterface().Login( InName );
}


function OnLoginComplete(bool bWasSuccessful, string SessionTicket, string PlayfabId)
{
	class'GameEngine'.static.GetPlayfabInterface().ClearOnLoginCompleteDelegate( OnLoginComplete );
	`log("Login complete with success"@bWasSuccessful@"and playfab ID"@PlayfabId@"and session ticket"@SessionTicket);
}


exec function TestPlayfabGameSearch()
{
	local KFDataStore_OnlineGameSearch SearchDataStore;

	SearchDataStore = KFDataStore_OnlineGameSearch(class'UIInteraction'.static.GetDataStoreClient().FindDataStore('KFGameSearch'));
	SearchDataStore.ActiveSearchIndex = 0;

	class'GameEngine'.static.GetPlayfabInterface().AddFindOnlineGamesCompleteDelegate( OnFindOnlinePlayfabGamesComplete );
	class'GameEngine'.static.GetPlayfabInterface().FindOnlineGames( SearchDataStore.GameSearchCfgList[0].Search );
}


function OnFindOnlinePlayfabGamesComplete( bool bSuccess )
{
	local int i;
	local KFDataStore_OnlineGameSearch SearchDataStore;
	local KFOnlineGameSettings GS;

	SearchDataStore = KFDataStore_OnlineGameSearch(class'UIInteraction'.static.GetDataStoreClient().FindDataStore('KFGameSearch'));
	class'GameEngine'.static.GetPlayfabInterface().ClearFindOnlineGamesCompleteDelegate( OnFindOnlinePlayfabGamesComplete );
	`log("Search finished with success"@bSuccess);

	for( i = 0; i < SearchDataStore.GameSearchCfgList[0].Search.Results.Length; i++ )
	{
		GS = KFOnlineGameSettings(SearchDataStore.GameSearchCfgList[0].Search.Results[i].GameSettings);
		`log("Listing result with region"@GS.Region@"and join string"@GS.JoinString@"and gamemode"@GS.Mode@"and lobby ID"@GS.LobbyId@"and num open connections"@GS.NumOpenPublicConnections@"and max players"@GS.NumPublicConnections);
	}
}


exec function TestServerInfoQuery(string LobbyId)
{
	class'GameEngine'.static.GetPlayfabInterface().AddQueryServerInfoCompleteDelegate( OnQueryServerInfoComplete );
	class'GameEngine'.static.GetPlayfabInterface().QueryServerInfo( LobbyId );
}


function OnQueryServerInfoComplete(bool bWasSuccessful, string LobbyId, string ServerIp, int ServerPort, string AuthTicket)
{
	class'GameEngine'.static.GetPlayfabInterface().ClearQueryServerInfoCompleteDelegate( OnQueryServerInfoComplete );
	`log("OnQueryServerInfoComplete complete with succcess"@bWasSuccessful@"and lobby ID"@LobbyId@"and server IP"@ServerIp@"and port"@ServerPort@"and auth ticket"@AuthTicket);
}


exec function StartupServer( optional string ServerCommandline )
{
	class'GameEngine'.static.GetPlayfabInterface().AddOnServerStartedDelegate( OnServerStarted );
	class'GameEngine'.static.GetPlayfabInterface().StartNewServerInstance( ServerCommandline );
}


function OnServerStarted( bool bWasSuccessful, string ServerLobbyId, string ServerIp, int ServerPort, string ServerTicket )
{
	local string OpenCommand;

	`log("Server started with success flag"@bWasSuccessful@"and with lobby id"@ServerLobbyId@"and server IP"@ServerIp@"and port"@ServerPort@"and ticket"@ServerTicket);
	class'GameEngine'.static.GetPlayfabInterface().ClearOnServerStartedDelegate( OnServerStarted );

	if( bWasSuccessful )
	{
		OpenCommand = "open"@ServerIp$":"$ServerPort;
		OpenCommand $= "?AuthTicket="$ServerTicket;
		OpenCommand $= "?PlayfabPlayerId="$class'GameEngine'.static.GetPlayfabInterface().CachedPlayfabId;

		`log("Going to connect with URL:"@OpenCommand);
		ConsoleCommand( OpenCommand );
	}
}


exec function SetMatchmakingRegion( string InRegion )
{
	class'GameEngine'.static.GetPlayfabInterface().CurrRegionName = InRegion;
}


exec function ReadPFStoreData()
{
	class'GameEngine'.static.GetPlayfabInterface().AddStoreDataReadCompleteDelegate( OnPlayfabStoreReadComplete );
	class'GameEngine'.static.GetPlayfabInterface().ReadStoreData();
}


function OnPlayfabStoreReadComplete( bool bSuccessful )
{
	class'GameEngine'.static.GetPlayfabInterface().ClearStoreDataReadCompleteDelegate( OnPlayfabStoreReadComplete );
	`log("store catalog read with success"@bSuccessful);
}


exec function ReadPFUserInventory()
{
	class'GameEngine'.static.GetPlayfabInterface().AddInventoryReadCompleteDelegate( OnPlayfabInventoryReadComplete );
	class'GameEngine'.static.GetPlayfabInterface().ReadInventory();
}


function OnPlayfabInventoryReadComplete( bool bSuccessful )
{
	class'GameEngine'.static.GetPlayfabInterface().ClearInventoryReadCompleteDelegate( OnPlayfabInventoryReadComplete );
	`log("Inventory read with success"@bSuccessful);
}


exec function UnlockContainer( string ContainerItemID )
{
	class'GameEngine'.static.GetPlayfabInterface().UnlockContainer( ContainerItemID );
}


exec function DumpItemDefinitions()
{
	local int i;
	local OnlineSubsystem OSS;

	OSS = Class'GameEngine'.static.GetOnlineSubsystem();

	for( i = 0; i < OSS.ItemPropertiesList.Length; i++ )
	{
		`log("Listing item"@OSS.ItemPropertiesList[i].Definition@"with name"@OSS.ItemPropertiesList[i].Name@"and type"@OSS.ItemPropertiesList[i].Type@"and price"@OSS.ItemPropertiesList[i].Price@"and URL"@OSS.ItemPropertiesList[i].IconURL@OSS.ItemPropertiesList[i].IconURLLarge);
		`log("   and short description"@OSS.ItemPropertiesList[i].ShortDescription);
		`log("   and description"@OSS.ItemPropertiesList[i].Description);
		`log("   and bundle"@OSS.ItemPropertiesList[i].Bundle);
		`log("   and exchange"@OSS.ItemPropertiesList[i].Exchange);
	}
}


exec function DumpInventory()
{
	local int i;
	local OnlineSubsystem OSS;

	OSS = Class'GameEngine'.static.GetOnlineSubsystem();

	for( i = 0; i < OSS.CurrentInventory.Length; i++ )
	{
		`log("Listing item"@OSS.CurrentInventory[i].Definition@"and quantity"@OSS.CurrentInventory[i].Quantity);
	}
}


exec function DumpExchangeRules()
{
	local int i, j;
	local OnlineSubsystem OSS;

	OSS = Class'GameEngine'.static.GetOnlineSubsystem();

	for( i = 0; i < OSS.ExchangeRuleSetList.Length; i++ )
	{
		`log("For target"@OSS.ExchangeRuleSetList[i].Target@"and item type"@OSS.ExchangeRuleSetList[i].Type);
		for( j = 0; j < OSS.ExchangeRuleSetList[i].Sources.Length; j++ )
		{
			`log("	"$OSS.ExchangeRuleSetList[i].Sources[j].Definition@"x"$OSS.ExchangeRuleSetList[i].Sources[j].Quantity);
		}
	}
}

exec function DebugUpdateInternalData( string InKey, string InValue )
{
	local array<string> Keys, Values;
	Keys.AddItem( InKey );
	Values.AddItem( InValue );
	class'GameEngine'.static.GetPlayfabInterface().ServerUpdateInternalUserData( class'GameEngine'.static.GetPlayfabInterface().CachedPlayfabId, Keys, Values );
}


exec function DebugUpdateServerData()
{
	class'GameEngine'.static.GetPlayfabInterface().CreateGameSettings( class'KFOnlineGameSettings' );
	class'GameEngine'.static.GetPlayfabInterface().ServerUpdateOnlineGame();
}


exec function DebugRetrieveInternalData( string InKey )
{
	local array<string> Keys;
	Keys.AddItem( InKey );
	class'GameEngine'.static.GetPlayfabInterface().ServerRetrieveInternalUserData( class'GameEngine'.static.GetPlayfabInterface().CachedPlayfabId, Keys );
}


exec function DebugAddCurrency( int Amount )
{
	class'GameEngine'.static.GetPlayfabInterface().ServerAddVirtualCurrencyForUser( class'GameEngine'.static.GetPlayfabInterface().CachedPlayfabId, Amount );
}


exec function DebugRemoveCurrency( int Amount )
{
	class'GameEngine'.static.GetPlayfabInterface().ServerRemoveVirtualCurrencyForUser( class'GameEngine'.static.GetPlayfabInterface().CachedPlayfabId, Amount );
}


exec function DebugGrantItem( string ItemId )
{
	local array<string> ItemIds;
	ItemIds.AddItem( ItemId );
	class'GameEngine'.static.GetPlayfabInterface().ServerGrantItemsForUser( class'GameEngine'.static.GetPlayfabInterface().CachedPlayfabId, ItemIds );
}


exec function DebugConsumeEntitlements()
{
	class'GameEngine'.static.GetPlayfabInterface().ConsumeEntitlements();
}


exec function TestTutorialRewards()
{
	class'GameEngine'.static.GetPlayfabInterface().ExecuteCloudScript( "ClaimTutorialRewards", none );
}


exec function DeleteXboxSaveData()
{
	OnlineSub.ContentInterface.DeleteSaveGame( LocalPlayer(Player).ControllerId, 0, "", "ProfileData" );
}


exec function ShowXboxProductDetails( optional string ProductId )
{
	OnlineSub.PlayerInterfaceEx.ShowProductDetailsUI( LocalPlayer(Player).ControllerId, ProductId );
}


exec function ShowXboxStoreUI()
{
	 OnlineSub.PlayerInterfaceEx.ShowContentMarketplaceUI( LocalPlayer(Player).ControllerId, 1, 1, "65656f5b-117f-43d2-ae4c-74aea578c32d");
}


exec function DumpGameProducts() { DumpStoreCatalog(MIT_Game); }
exec function DumpApplicationProducts() { DumpStoreCatalog(MIT_Application); }
exec function DumpDurables() { DumpStoreCatalog(MIT_GameContent); }
exec function DumpConsumables() { DumpStoreCatalog(MIT_GameConsumable); }
exec function DumpSubscriptions() { DumpStoreCatalog(MIT_Subscription); }
exec function DumpFullCatalog()
{
	`log("Dumping Game Products");
	DumpGameProducts();
	`log("Dumping Application Products");
	DumpApplicationProducts();
	`log("Dumping Durable Products");
	DumpDurables();
	`log("Dumping Consumable Products");
	DumpConsumables();
	`log("Dumping Subscription Products");
	DumpSubscriptions();
}

exec function DumpStoreCatalog(EMediaItemType MediaType)
{
	local int i, j, k;
	local array<MarketplaceProductDetails> AvailableProducts;

	OnlineSub.MarketplaceInterface.GetAvailableProducts(LocalPlayer(Player).ControllerId, MediaType, AvailableProducts);

	`log("Dumping products now... size"@AvailableProducts.Length);

	for (i = 0; i < AvailableProducts.Length; i++)
	{
		`log(i@"StandardId"@AvailableProducts[i].StandardId);
		`log(i@"MediaItemType"@AvailableProducts[i].MediaItemType);
		`log(i@"ProductName"@AvailableProducts[i].ProductName);
		`log(i@"ProductId"@AvailableProducts[i].ProductId);
		`log(i@"SandboxId"@AvailableProducts[i].SandboxId);
		`log(i@"TitleId"@AvailableProducts[i].TitleId);
		`log(i@"IsBundle"@AvailableProducts[i].bIsBundle);
		`log(i@"IsPartOfAnyBundle"@AvailableProducts[i].bIsPartOfAnyBundle);
		`log(i@"ReducedName"@AvailableProducts[i].ReducedName);
		`log(i@"DetailsReadState"@AvailableProducts[i].DetailsReadState);
		`log(i@"ProductDescription"@AvailableProducts[i].ProductDescription);

		`log(i@"images length"@AvailableProducts[i].Images.Length);
			for (j = 0; j < AvailableProducts[i].Images.Length; j++)
			{
				`log("  Id"@AvailableProducts[i].Images[j].Id);
				`log("  Height"@AvailableProducts[i].Images[j].Height);
				`log("  Width"@AvailableProducts[i].Images[j].Width);
				`log("  Purpose"@AvailableProducts[i].Images[j].Purpose);
				`log("  ResizeURL"@AvailableProducts[i].Images[j].ResizeURL);
				`log("  purposes length"@AvailableProducts[i].Images[j].Purposes.Length);
				for (k = 0; k < AvailableProducts[i].Images[j].Purposes.Length; k++)
				{
					`log("      "@AvailableProducts[i].Images[j].Purposes[k]);
				}
			}

		`log(i@"availabilities length"@AvailableProducts[i].Availabilities.Length);
			for (j = 0; j < AvailableProducts[i].Availabilities.Length; j++)
			{
				`log("  Title"@AvailableProducts[i].Availabilities[j].Title);
				`log("  Description"@AvailableProducts[i].Availabilities[j].Description);
				`log("  ContentId"@AvailableProducts[i].Availabilities[j].ContentId);
				`log("  CurrencyCode"@AvailableProducts[i].Availabilities[j].CurrencyCode);
				`log("  DisplayListPrice"@AvailableProducts[i].Availabilities[j].DisplayListPrice);
				`log("  DisplayPrice"@AvailableProducts[i].Availabilities[j].DisplayPrice);
				`log("  DistributionType"@AvailableProducts[i].Availabilities[j].DistributionType);
				`log("  bIsPurchasable"@AvailableProducts[i].Availabilities[j].bIsPurchasable);
				`log("  ListPrice"@AvailableProducts[i].Availabilities[j].ListPrice);
				`log("  Price"@AvailableProducts[i].Availabilities[j].Price);
				`log("  PromotionalText"@AvailableProducts[i].Availabilities[j].PromotionalText);
				`log("  OfferId"@AvailableProducts[i].Availabilities[j].OfferId);
				`log("  SignedOffer"@AvailableProducts[i].Availabilities[j].SignedOffer);

				`log("  AcceptablePaymentInstrumentTypes length"@AvailableProducts[i].Availabilities[j].AcceptablePaymentInstrumentTypes.Length);
				for (k = 0; k < AvailableProducts[i].Availabilities[j].AcceptablePaymentInstrumentTypes.Length; k++)
				{
					`log("      "@AvailableProducts[i].Availabilities[j].AcceptablePaymentInstrumentTypes[k]);
				}
			}
	}
}


exec function RefreshXboxInventory()
{
	OnlineSub.MarketplaceInterface.ResetInventoryItems( LocalPlayer(Player).ControllerId, MIT_All );
	OnlineSub.MarketplaceInterface.ReadInventoryItems( LocalPlayer(Player).ControllerId, MIT_All );
}


exec function ReadPlayfabTitleData()
{
	class'GameEngine'.static.GetPlayfabInterface().AddTitleDataReadCompleteDelegate( OnTitleDataRead );
	class'GameEngine'.static.GetPlayfabInterface().ReadTitleData();
}


exec function OnTitleDataRead()
{
	`log("Title data read");
}


exec function GetTitleDataValueForKey( string Key )
{
	class'GameEngine'.static.GetPlayfabInterface().ClearTitleDataReadCompleteDelegate( OnTitleDataRead );
	`log("title data value for key"@Key@"is"@class'GameEngine'.static.GetPlayfabInterface().GetTitleDataForKey( Key ) );
}


exec function DebugEndGameRewards(float GameplayTime, optional bool bFinal)
{
	local JsonObject Parms;

	Parms = new class'JsonObject';
	Parms.SetIntValue("UpdateTime", GameplayTime);
	Parms.SetBoolValue("bGameEnd", bFinal);
	PlayfabInter.ExecuteCloudScript("UpdatePlayRewards", Parms);
}


exec function DebugSetSafeFrame(float NewScale)
{
	KFGameEngine(class'Engine'.static.GetEngine()).SafeFrameScale = NewScale;
}

// Playfab debugging End
/////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------
// Mixer Debugging
exec function StartMixer()
{
    KFPlayerController(Outer).InitializeMixer();
}

exec function StopMixer()
{
    KFPlayerController(Outer).ShutdownMixer();
}

exec function TestGaveAmmo (string Username)
{
    KFPlayerController(Outer).MyGFxHUD.ShowNonCriticalMessage( Username @class'KFCommon_LocalizedStrings'.default.MixerGaveAmmoString);
}

exec function TestMixerButton(string Button, string metadata, int amount, int cooldown)
{
    local array<string> MetaKeys, MetaProps;

    if (metadata != "")
    {
        MetaKeys.AddItem("Type");
        MetaProps.AddItem(metadata);
    }

    if (amount > 0)
    {
        MetaKeys.AddItem("Amount");
        MetaProps.AddItem(string(amount));
    }

    if (cooldown > 0)
    {
        MetaKeys.AddItem("Cooldown");
        MetaProps.AddItem(string(cooldown));
    }

    KFPlayerController(Outer).TestMixerCall(Button, MetaKeys, MetaProps);
}

exec function ForceMixerScene(string VersionNumber, string ShareCode)
{
	class'MixerIntegration'.static.ForceMixerScene(VersionNumber, ShareCode);
}

//-----------------------------------------------------------------------------
// LED Debugging
exec function InitLEDEffects()
{
    local LogitechLEDInterface LogtitechLED;
    local RazerLEDInterface RazerFXLED;
    local AlienFXLEDInterface AlienFXLED;

    AlienFXLED = class'PlatformInterfaceBase'.static.GetAlienFXIntegration();
    RazerFXLED = class'PlatformInterfaceBase'.static.GetRazerIntegration();
    LogtitechLED = class'PlatformInterfaceBase'.static.GetLogitechIntegration();

    if (RazerFXLED == none)
    {
       `log("RazerFXLED == none");
    }

    if (LogtitechLED == none)
    {
        `log("LogtitechLED == none");
    }

    if(AlienFXLED == none)
    {
        `log("AlienFXLED == none");
    }
    else
    {
        AlienFXLED.Activate();
    }
}

exec function SetLEDRGB(byte RedPercent, byte GreenPercent, byte BluePercent)
{
    local LogitechLEDInterface LogtitechLED;
    local RazerLEDInterface RazerFXLED;
    local AlienFXLEDInterface AlienFXLED;

    LogtitechLED = class'PlatformInterfaceBase'.static.GetLogitechIntegration();
    RazerFXLED = class'PlatformInterfaceBase'.static.GetRazerIntegration();
    AlienFXLED = class'PlatformInterfaceBase'.static.GetAlienFXIntegration();

    if (LogtitechLED != none)
    {
       LogtitechLED.SetColor(RedPercent, GreenPercent, BluePercent);
    }

    if(RazerFXLED != none)
    {
        RazerFXLED.SetColor(RedPercent, GreenPercent, BluePercent);
    }

    if (AlienFXLED != none)
    {
        if(!AlienFXLED.SetColor(RedPercent, GreenPercent, BluePercent))
        {
            `log("Failed to set color for AlienFX");
        }
    }
}

exec function LEDSetFlashingRBG (int RedPercent, int GreenPercent, int BluePercent,
int MilliSecondsDuration, int MilliSecondsInterval)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Outer);

	if (KFPC.LEDEffectsManager != none)
	{
		//KFPC.LEDEffectsManager.LEDSetFlashingRBG(RedPercent, GreenPercent, BluePercent, MilliSecondsDuration, MilliSecondsInterval);
		KFPC.LEDEffectsManager.PlayEffectPuke(0);
	}
}


exec function LEDPulseLighting(int RedPercent, int GreenPercent, int BluePercent, int
MilliSecondsDuration, int MilliSecondsInterval)
{
	local LogitechLEDInterface LogtitechLED;
	local RazerLEDInterface RazerFXLED;
	local AlienFXLEDInterface AlienFXLED;

	LogtitechLED = class'PlatformInterfaceBase'.static.GetLogitechIntegration();
	RazerFXLED = class'PlatformInterfaceBase'.static.GetRazerIntegration();
	AlienFXLED = class'PlatformInterfaceBase'.static.GetAlienFXIntegration();

    if (LogtitechLED != none)
    {
       LogtitechLED.LEDPulseLighting(RedPercent, GreenPercent, BluePercent,
        MilliSecondsDuration, MilliSecondsInterval);
    }

    if(RazerFXLED != none)
    {
        RazerFXLED.LEDPulseLighting(RedPercent, GreenPercent, BluePercent,
        MilliSecondsDuration, MilliSecondsInterval);
    }

	if (AlienFXLED != none)
	{
		AlienFXLED.LEDPulseLighting(RedPercent, GreenPercent, BluePercent,
			MilliSecondsDuration, MilliSecondsInterval);
	}
}


exec function LedStopEffects()
{
    local LogitechLEDInterface LogtitechLED;
    local RazerLEDInterface RazerFXLED;

    LogtitechLED = class'PlatformInterfaceBase'.static.GetLogitechIntegration();
    RazerFXLED = class'PlatformInterfaceBase'.static.GetRazerIntegration();

    if (LogtitechLED != none)
    {
       LogtitechLED.LedStopEffects();
    }

    if(RazerFXLED != none)
    {
        RazerFXLED.LedStopEffects();
    }
}


exec function LedRestoreLighting ()
{
    local LogitechLEDInterface LogtitechLED;
    LogtitechLED = class'PlatformInterfaceBase'.static.GetLogitechIntegration();

    if (LogtitechLED != none)
    {
       LogtitechLED.LedRestoreLighting();
    }
    else
    {
        `log("LogtitechLED == none");
    }
}

exec function SetMissionObjectiveActive(bool bActive)
{
    local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxHUD != none )
    {
        KFPC.MyGFxHUD.WaveInfoWidget.ObjectiveContainer.SetActive(bActive);
    }
}

exec function SetMissionFailState(bool bFailed)
{
	local Pawn P;
	local KFPlayerController KFPC;

	P = GetMyPawn();
	KFPC = KFPlayerController(Outer);

	if (P == none || KFPC == None)
	{
		return;
	}

	if (KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.WaveInfoWidget.ObjectiveContainer.SetFailState(bFailed);
	}
}

exec function SetMissionObjectiveVisible(bool bVisible)
{
    local Pawn P;
    local KFPlayerController KFPC;

    P = GetMyPawn();
    KFPC = KFPlayerController(Outer);

    if(P == none || KFPC == None)
    {
        return;
    }

    if(KFPC.MyGFxHUD != none )
    {
        KFPC.MyGFxHUD.WaveInfoWidget.ObjectiveContainer.SetVisible(bVisible);
    }
}

exec function UpgradeWeapon()
{
	local KFPawn MyPawn;

	MyPawn = KFPawn(GetMyPawn());
	if (MyPawn != none && MyPawn.MyKFWeapon != none)
	{
		MyPawn.MyKFWeapon.UpgradeWeapon();
	}
}

exec function ForceSpecialWave(optional string ZedTypeName)
{
	local int AIType;

	if (KFGameInfo(WorldInfo.Game) != none)
	{
		KFGameInfo(WorldInfo.Game).bForceSpecialWave = true;
		if(ZedTypeName != "")
		{
			AIType = GetAITypeByName(ZedTypeName);
			if (AIType != INDEX_NONE)
			{
				KFGameInfo(WorldInfo.Game).DebugForceSpecialWaveZedType = AIType;
			}
			else
			{
				ClientMessage( ZedTypeName @ "is not a valid special wave type.", CheatType);
			}
		}
	}
}

exec function ForceOutbreakWave(optional int OutbreakIdx = INDEX_NONE)
{
	if (KFGameInfo(WorldInfo.Game) != none)
	{
		KFGameInfo(WorldInfo.Game).bForceOutbreakWave = true;
		if (OutbreakIdx != INDEX_NONE)
		{
			KFGameInfo(WorldInfo.Game).DebugForcedOutbreakIdx = OutbreakIdx;
		}
	}
}

exec function ForceNextObjective()
{
	if (KFGameInfo(WorldInfo.Game) != none && KFGameInfo(WorldInfo.Game).MyKFGRI != none)
	{
		KFGameInfo(WorldInfo.Game).MyKFGRI.bForceNextObjective = true;
	}
}

exec function ActivateAllPickups()
{
	local int i;

	if (KFGameInfo(WorldInfo.Game) != none)
	{
		for (i = 0; i < KFGameInfo(WorldInfo.Game).ItemPickups.Length; ++i)
		{
			KFGameInfo(WorldInfo.Game).ActivateNextPickup(KFGameInfo(WorldInfo.Game).ItemPickups[i], 1);
		}
	}
}

//-----------------------------------------------------------------------------
// Discord Debugging
exec function ForceUpdateDiscordPresence()
{
	//KFPlayerController(Outer).UpdateDiscordRichPresence();
}

defaultproperties
{
	CheatType="KFCheat"
}

