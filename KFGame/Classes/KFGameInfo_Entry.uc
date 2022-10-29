//=============================================================================
// KFGameInfo_Entry
//=============================================================================
// The main menu's game info class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFGameInfo_Entry extends KFGameInfo;

var bool bInitialized;
var int LastSystemTimeMinutes;
var array<KFActor_DoshPile> DoshVaultStacks;

var array<MaterialInstanceActor> TierLights;

var bool bInitPiles;
var int FrontPilesInWorld;
var int FrontPilesActive;

var array<int> TierThreshold;

var string LightMICTagName;
var string LightConeTagName;
var string LightBulbTagName;
var string DoshLitterMICTagName;
var string CustomPawnSpawnPointTagName;

var int FilledPalletCount;

var int LastUpdateDoshAmount;

var() LinearColor WhiteColor;
var() LinearColor OffColor;

var KFPawn_Customization VaultCustomPawn;

var int CalcultedTierValue;

static function PreloadContentClasses();

function bool NeedPlayers();
function Pawn SpawnDefaultPawnFor(Controller NewPlayer, NavigationPoint StartSpot) {}
function InitSpawnManager();
function InitTraderList();

function InitVault()
{
    local KFPlayerController KFPC;
    local LocalPlayer LP;
	local int i;

    // To fix custom post processing effect not showing up in main menu
	KFPC = KFPlayerController(WorldInfo.GetALocalPlayerController());
	if (KFPC == none)
	{
		return;
	}

	LP = LocalPlayer(KFPC.Player);
	if (LP != None)
	{
		LP.RemoveAllPostProcessingChains();
		LP.InsertPostProcessingChain(LP.Outer.GetWorldPostProcessChain(), INDEX_NONE, true);
	}	

	if (KFPC.myHUD != None)
	{
		KFPC.myHUD.NotifyBindPostProcessEffects();
	}
	SetDoshTier(GetTotalDoshTier(KFPC));
	InitDoshPiles(KFPC);
	SpawnVaultCustomizationPawn(KFPC);

	if(!bInitialized)
	{
		for (i = 0; i < TierThreshold.length; i++)
		{
			ActiveLightActorsForTier(i, i == 0);
		}
	}
}

function SpawnVaultCustomizationPawn(KFPlayerController KFPC)
{
    local KFGameInfo KFGI;
    local NavigationPoint BestStart;

    if(VaultCustomPawn != none)
    {
        return;
    }

    KFGI = KFGameInfo( WorldInfo.Game );
    if( KFGI == none || KFGI.bRestartLevel && WorldInfo.NetMode!=NM_DedicatedServer && WorldInfo.NetMode!=NM_ListenServer )
    {
        `warn("bRestartLevel && !server, abort from RestartPlayer"@WorldInfo.NetMode);
        return;
    }

    BestStart = GetVaultCustomizationSpawnPoint( KFGI );

    VaultCustomPawn = KFPawn_Customization( KFGI.SpawnCustomizationPawn( BestStart ) );

    if ( VaultCustomPawn != none )
    {
        VaultCustomPawn.InitializeCustomizationPawn( KFPC, BestStart );
    }
}

function NavigationPoint GetVaultCustomizationSpawnPoint( KFGameInfo KFGI )
{
    local NavigationPoint BestStartSpot;
    foreach AllActors(class'NavigationPoint', BestStartSpot)
    {
        if(string(BestStartSpot.Tag) == CustomPawnSpawnPointTagName)
        {
            return BestStartSpot;
        }
    }
    return BestStartSpot;
}

event InitDoshPiles(KFPlayerController KFPC)
{
    if (KFPC == none)
    {
        return;
    }
    CalcultedTierValue = GetTotalDoshTier(KFPC);
    CollectDoshPiles();
    SortDoshPiles();
    SpawnDoshPilesForAmount(KFPC.GetLastSeenDoshCount());
	InitDoshLitter(CalcultedTierValue);
    bInitPiles = true;
}

function InitDoshLitter(int DoshTier)
{
	local MaterialInstanceActor DoshLitterMICActor;
	local MaterialInstanceConstant MICInst;

	foreach AllActors(class'MaterialInstanceActor', DoshLitterMICActor)
	{
		if (string(DoshLitterMICActor.Tag) == (DoshLitterMICTagName))
		{
			//DoshLitterMICActor.StaticMeshComponent.CreateAndSetMaterialInstanceConstant(0);
			//MaterialInstanceConstant(DoshLitterMICActor.StaticMeshComponent.GetMaterial(0)).SetScalarParameterValue('Dosh_Amount', (float(CalcultedTierValue) / float(TierThreshold.length - 1)));
			MICInst = new(self) class'MaterialInstanceConstant';
			MICInst.SetParent(DoshLitterMICActor.MatInst);
			MICInst.SetScalarParameterValue('Dosh_Amount', (float(CalcultedTierValue)/float(TierThreshold.length-1)) );
			DoshLitterMICActor.MatInst = MICInst;
		}
	}
	//DoshLitterMIC.SetScalarParameterValue('Dosh_Amount', 1);
}

function CollectDoshPiles()
{
    local KFActor_DoshPile DoshPile;
	local int Index;

	Index = 0;
    DoshVaultStacks.length = 0;

    foreach AllActors(class'KFActor_DoshPile', DoshPile)
    {
        DoshVaultStacks.AddItem(DoshPile);
        DoshPile.SetHidden(true);
		DoshPile.PileIndexID = Index;
        DoshPile.SetValue(0);
		Index++;
    }
}

function SortDoshPiles()
{
    DoshVaultStacks.Sort(CompareItemTags);
}

function int CompareItemTags(Actor Actor1, Actor Actor2)
{
    local string Tag1, Tag2;
    Tag1 = string(Actor1.Tag);
    Tag2 = string(Actor2.Tag);
    if(Tag1 == Tag2)
    {
        return 0;
    }
    if( Len(Tag1) != Len(Tag2) )
    {
        return Len(Tag1) > Len(Tag2) ? -1 : 1;
    }

    return Tag1 > Tag2 ? -1 : 1;
}

function int GetTotalDoshTier(KFPlayerController KFPC)
{
    local int TierValue;
    local int NumPiles;
    local int i;

    NumPiles = int(KFPC.GetTotalDoshCount() / class'KFActor_DoshPile'.default.DoshPileMax);

    for (i = 0; i < TierThreshold.length; i++)
    {
        if(NumPiles >= TierThreshold[i])
        {
            TierValue = i;
        }
    }
	
    return TierValue;
}

function FinalAnimationPlayed(KFPlayerController KFPC)
{
	SetDoshTier(GetTotalDoshTier(KFPC), true);
}

function SetDoshTier(int TierValue, optional bool bFinalAnimation = false)
{
	local array<SequenceObject> ActivationEvents;
	local KFSeqEvent_DoshVault ActivationEvent;
	local int i;
	
	/*for (i = 0; i < TierValue; i++)//Giving this back to kismet for now. -ZG
	{
		ActiveLightActorsForTier(i, i <= TierValue);
	}*/
	/*if (bFinalAnimation)
	{*/
		WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'KFSeqEvent_DoshVault', true, ActivationEvents);
		for (i = 0; i < ActivationEvents.Length; i++)
		{
			ActivationEvent = KFSeqEvent_DoshVault(ActivationEvents[i]);
			if (ActivationEvent != none)
			{
				ActivationEvent.SetDoshTier(TierValue);
			}
		}
	//}
}

//spawn crates up to remaining value
function SpawnDoshPilesForAmount(int LastSeenDoshAmount)
{
    local int NumPiles;
    local int DoshAccountedFor;
    local int i, UpdateID;
    local KFActor_DoshPile DoshPile;

    NumPiles = int(LastSeenDoshAmount / class'KFActor_DoshPile'.default.DoshPileMax);
    FrontPilesActive = (NumPiles % FrontPilesInWorld) + 1;

    //Initial dosh count that we have to visually set.
    DoshAccountedFor = LastSeenDoshAmount;

    //make front piles always visible and give their values first
    for (i = 0; i < DoshVaultStacks.length; i++)
    {
        if(i < FrontPilesInWorld)
        {
            DoshVaultStacks[i].SetHidden(false);
        }
        else
        {
            DoshVaultStacks[i].SetHidden(true);
        }
        DoshVaultStacks[i].SetValue(0);
    }

    UpdateID = FrontPilesInWorld;

    //fill back rows
    while(DoshAccountedFor >= (FrontPilesActive * class'KFActor_DoshPile'.default.DoshPileMax) && DoshAccountedFor > 0 )
    {
        DoshPile = DoshVaultStacks[UpdateID];
        DoshPile.SetHidden(false);

        DoshPile.SetValue(FMin(DoshAccountedFor, class'KFActor_DoshPile'.default.DoshPileMax) / class'KFActor_DoshPile'.default.DoshPileMax);
        //Remove accounted for dosh so future piles get the correct amount.  If we go under 0, set it to 0 and we'll start with a bunch of empty piles
        DoshAccountedFor -= class'KFActor_DoshPile'.default.DoshPileMax;
        DoshAccountedFor = FMax(DoshAccountedFor, 0.f);

        UpdateID++;
    }

    //front piles
    UpdateID = 1;

    while(DoshAccountedFor > 0)
    {
        if(DoshAccountedFor >= class'KFActor_DoshPile'.default.DoshPileMax)
        {
            DoshPile = DoshVaultStacks[UpdateID];
        }
        else
        {
            DoshPile = DoshVaultStacks[0];
        }

        DoshPile.SetValue(FMin(DoshAccountedFor, class'KFActor_DoshPile'.default.DoshPileMax) / class'KFActor_DoshPile'.default.DoshPileMax);
        //Remove accounted for dosh so future piles get the correct amount.  If we go under 0, set it to 0 and we'll start with a bunch of empty piles
        DoshAccountedFor -= class'KFActor_DoshPile'.default.DoshPileMax;
        DoshAccountedFor = FMax(DoshAccountedFor, 0.f);

        UpdateID++;
    }
}


exec function ActiveLightActorsForTier(int LightTier, optional bool bActive = true)
{
	local Light LightActor;
    local MaterialInstanceActor LightMIC;
    local StaticMeshActor LightCone;
    local MaterialInstanceConstant MICInst;

    //emissive (MIC)
    foreach AllActors(class'MaterialInstanceActor', LightMIC)
    {
        if(string(LightMIC.Tag) == (LightMICTagName $ LightTier) )
        {
            MICInst = new(self) class'MaterialInstanceConstant';
            MICInst.SetParent(LightMIC.MatInst);
            MICInst.SetVectorParameterValue('Emissive_Color', bActive ? WhiteColor : OffColor);
            LightMIC.MatInst = MICInst;
        }
    }
    //cones
    foreach AllActors(class'StaticMeshActor', LightCone)
    {
        if(string(LightCone.Tag) == (LightConeTagName $ LightTier) )
        {
            LightCone.SetHidden(!bActive);
        }
	}
	//lights
	foreach AllActors(class'Light', LightActor)
	{
		if (string(LightActor.Tag) == (LightBulbTagName $ LightTier))
		{
			LightActor.LightComponent.SetEnabled(bActive);
		}
	}
}

function UpdateDoshPiles(int NewDoshAmount)
{
    local int UpdateID, Idx, i;
    local int ValueMultiple;

    if(!bInitPiles)
    {
        InitVault();
    }

    if(LastUpdateDoshAmount == NewDoshAmount)
    {
        return;
    }

    //return;

    if(NewDoshAmount <= 0)
    {
        return; //no reason to update
    }

    ValueMultiple = int(NewDoshAmount / class'KFActor_DoshPile'.default.DoshPileMax);
    UpdateID = (ValueMultiple % FrontPilesInWorld) + 1; //can never be 0

    //check for complete row
    if(NewDoshAmount % (class'KFActor_DoshPile'.default.DoshPileMax * FrontPilesInWorld) == 0 && LastUpdateDoshAmount != INDEX_NONE)
    {
        //reset the rows because we are starting a new row
        for (i = 0; i < FrontPilesInWorld; i++)
        {
            DoshVaultStacks[i].SpawnCompleteParticleEffects(false);
        }
        VaultCustomPawn.PlayEmoteAnimation();
        //add the reset row the back piles <-maybe
        SpawnDoshPilesForAmount(NewDoshAmount);
    }
    //check for complete stack
    else if( NewDoshAmount % class'KFActor_DoshPile'.default.DoshPileMax == 0 && LastUpdateDoshAmount != INDEX_NONE)
    {
        if( UpdateID > 1 )
        {
            //fill the last id up!
            DoshVaultStacks[0].SetValue(0);
            DoshVaultStacks[0].SpawnCompleteParticleEffects(false);
            DoshVaultStacks[UpdateID - 1].SpawnCompleteParticleEffects();
            VaultCustomPawn.PlayEmoteAnimation();
        }
    }

    for (Idx = 0; Idx <= UpdateID; ++Idx)
    {
        if (Idx == (UpdateID) )
        {
            DoshVaultStacks[0].SetValue( (NewDoshAmount % class'KFActor_DoshPile'.default.DoshPileMax) / class'KFActor_DoshPile'.default.DoshPileMax);
        }
        else
        {
            DoshVaultStacks[Idx].SetValue(1.0);
        }
    }

    LastUpdateDoshAmount = NewDoshAmount;
}

// Parse options for this game...
event InitGame( string Options, out string ErrorMessage )
{
	if ( ParseOption( Options, "PerformUnitTests" ) ~= "1" )
	{
		if ( MyAutoTestManager == None )
		{
			MyAutoTestManager = spawn(AutoTestManagerClass);
		}
		MyAutoTestManager.InitializeOptions(Options);
	}

	// Refresh online game data when returning to main menu
	// Leaving main menu, aka GameEnded(), happening too late
	if ( HasOption( Options, "Closed" ) )
	{
		class'KFGameEngine'.static.RefreshOnlineGameData();
	}

	LastSystemTimeMinutes = GetSystemTimeMinutes();
	BroadcastHandler = spawn(BroadcastHandlerClass);

    InitVault();
}

/**
 * Helper for periodic online game data update
 * note: Not 100% precise, because we don't bother with days rolling into months
 */
private function int GetSystemTimeMinutes()
{
	local int year,month,dayofweek,day,hour,minute,second,msec;
	GetSystemTime(year,month,dayofweek,day,hour,minute,second,msec);
	return minute + (hour * 60) + (day * 60 * 24);
}

function Tick( float DeltaTime )
{
	super.Tick(DeltaTime);

    // Quick fix to get the music playing after the startup movies
	if( !bInitialized )
	{
		ForceMenuMusicTrack();
		bInitialized = true;
	}
}

exec function FinishCraft ()
{
	local KFPlayerController KFPC;

	foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
	{
		if(KFPC.MyGfxManager != none && KFPC.MyGFxManager.InventoryMenu != none)
		{
			KFPC.MyGFxManager.InventoryMenu.FinishCraft();
		}
	}
}

auto State PendingMatch
{
	function RestartPlayer(Controller aPlayer)
	{
	}

	function Timer()
    {
   		local int SystemTimeMinutes;

		// Update every minute using system clock for suspend mode.
		// Originally tried using GameEnding(), but the TitleData response
		// doesn't come back in time for the new map.
		SystemTimeMinutes = GetSystemTimeMinutes();
		if ( (SystemTimeMinutes - LastSystemTimeMinutes) >= 1 )
		{
			class'KFGameEngine'.static.RefreshOnlineGameData();
			LastSystemTimeMinutes = SystemTimeMinutes;
		}
    }

    function BeginState(Name PreviousStateName)
    {
		bWaitingToStartMatch = true;
    }

	function EndState(Name NextStateName)
	{
	}
}

DefaultProperties
{
    LastUpdateDoshAmount=INDEX_NONE
    LightMICTagName="TierMIC_"
    LightConeTagName="TierCone_"
    LightBulbTagName="TierLight_"
	DoshLitterMICTagName="DoshLitter"
    CustomPawnSpawnPointTagName="KFCustomizationPoint_Vault"

    FrontPilesInWorld=10
    TierThreshold(0)=0
    TierThreshold(1)=30
    TierThreshold(2)=70
    TierThreshold(3)=100
    TierThreshold(4)=130
    WhiteColor=(R=1.0f,G=1.0f,B=1.0f)
    OffColor=(R=0f,G=0f,B=0f)

    SupportedEvents.Empty
    SupportedEvents.Add(class'KFSeqEvent_DoshVault')
}