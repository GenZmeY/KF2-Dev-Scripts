//=============================================================================
// KFInventoryManager
//=============================================================================
// Interface to control and interact with the Pawn's inventory
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFInventoryManager extends InventoryManager
	native;

`include(KFGame\KFGameAnalytics.uci);

/** LIFO (aka stack) history of previously equipped weapons */
var transient Weapon PreviousEquippedWeapons[2];

/** reference to the currently equipped healer weapon */
var transient KFWeap_HealerBase HealerWeapon;

/** Localized message for quick heal */
var localized string FullHealthMsg;

/** The number of grenades the character is carrying */
var byte GrenadeCount;

/** The carrying capacity (or blocks) available */
var byte CurrentCarryBlocks;
var byte MaxCarryBlocks;

var byte SelectedGroup;
var byte SelectedIndex;

/** Ignore our carrying capacity if this is set to true */
var bool bInfiniteWeight;

/** Suppress pickup messages if this is set to true */
var bool bSuppressPickupMessages;

/** (Server) Whether or not this player has the trader menu open */
var bool bServerTraderMenuOpen;

/** Sound to play when we receive ammo from an already owned weapon */
var() AkEvent AmmoPickupSound;
/** Sound to play when a new weapon is picked up */
var() AkEvent ItemPickupSound;
/** Sound to play when we pick up armor */
var() AkEvent ArmorPickupSound;
/** Sound to play when toggling fire modes */
var AkEvent SwitchFireModeEvent;

/** The time at which we were last given a weapon */
var float LastCreatedWeaponTime;
/** This stores any GFxMoviePlayers that are inventory may be using */
var array<GFxMoviePlayer> OpticsUIMovies;

var bool bAutoswitchWeapon;

var const float StartedWithWeaponPriceModifier;	// The selling price reduction for a weapon that we were given at the start of the game
var const float SellPriceModifier;	// Multiplied by the original price to get the sell cost
var const float DoshinegunSellModifier;

/** Cost scale for weapons not on the active perk */
var float OffPerkCostScale;

/** An item that will be given once we've finished using the trader */
struct native TransactionItem
{
	var string DLOString;
	var name ClassName;
	var int AddedAmmo[2];
	var int AddedWeight; //comes from weapon upgrade
	var int WeaponUpgradeLevel;
};

/** Keeps track of the items we are planning on buying, while in the trader */
var array<TransactionItem> TransactionItems;

/** Whether to log all the Inventory stuff */
var bool bLogInventory;

/** Keeps track of what our controller weapon select index is for each group - HSL */
var int SelectedGroupIndicies[4];

//
// Network replication.
//
replication
{
	if( bNetDirty && bNetOwner )
		GrenadeCount, CurrentCarryBlocks, MaxCarryBlocks, OffPerkCostScale;

	if( bNetDirty && bNetOwner && bNetInitial )
		HealerWeapon;
}

native function bool AddWeaponToGroup( out KFWeapon AddedWeapon );

/** returns full concatenated string for analytics logging */
simulated function string DumpInventory()
{
	local Inventory InventoryItem;
	local KFWeapon Weapon;
	local string InventoryLabel;

	InventoryItem = InventoryChain;
	while( InventoryItem != none )
	{
		Weapon = KFWeapon( InventoryItem );
		if ( Weapon != none )
		{
			InventoryLabel $= Weapon.Class.Name $":"$ string(Weapon.GetTotalAmmoAmount(0)) $ ",";
		}

		InventoryItem = InventoryItem.Inventory;
	}

	// drop the trailing comma
	if ( Len(InventoryLabel) > 0 )
	{
		InventoryLabel = Left( InventoryLabel, Len(InventoryLabel) - 1 );
	}

	return InventoryLabel;
}

/** Get what percentage of ammo is left for the primary weapons */
simulated function float GetPrimaryAmmoPercentage()
{
	local Inventory InventoryItem;
	local KFWeapon Weapon;
	local float TotalAmmo, MaxAmmo;

	InventoryItem = InventoryChain;
	while( InventoryItem != none )
	{
		Weapon = KFWeapon( InventoryItem );
		if ( Weapon != none && !Weapon.bIsBackupWeapon && Weapon.InventoryGroup != IG_None
            && Weapon.InventoryGroup != IG_Equipment )
		{
        	// For weapons that have no primary ammo such as melee weapons, just return 1/1.
        	// That basically means they are "full" since they don't run out of ammo
            if( Weapon.GetMaxAmmoAmount(0) == 0 )
        	{
        		TotalAmmo += 1.0;
        		MaxAmmo += 1.0;
        	}
        	else
        	{
        	   TotalAmmo += Weapon.GetTotalAmmoAmount(0);
        	   MaxAmmo += Weapon.GetMaxAmmoAmount(0);
        	}
		}

		InventoryItem = InventoryItem.Inventory;
	}

    if( MaxAmmo > 0 )
    {
        return TotalAmmo / MaxAmmo;
    }
    else
    {
        return 0;
    }
}

/** Create a GFxMoviePlayer for weapon optics if it doesn't exist, otherwise grab the existing GFxMoviePlayer */
simulated function GFxMoviePlayer GetOpticsUIMovie(class<GFxMoviePlayer> OpticsClass)
{
	local byte OpticsIndex;

	for (OpticsIndex = 0; OpticsIndex < OpticsUIMovies.Length; OpticsIndex++)
	{
		if (OpticsUIMovies[OpticsIndex].class == OpticsClass)
		{
			return OpticsUIMovies[OpticsIndex];
		}
	}

	// Create the screen's UI piece
	OpticsUIMovies.AddItem(new( self ) OpticsClass);

	// Initialize the new movie
	OpticsIndex = OpticsUIMovies.length - 1;
	OpticsUIMovies[OpticsIndex].Init();
	OpticsUIMovies[OpticsIndex].Start();

	return OpticsUIMovies[OpticsIndex];
}

/** Create a GFxMoviePlayer for weapon optics if it doesn't exist, otherwise grab the existing GFxMoviePlayer */
simulated function RemoveOpticsUIMovie(class<KFGFxWorld_MedicOptics> OpticsClass)
{
	local byte OpticsIndex;

	for (OpticsIndex = 0; OpticsIndex < OpticsUIMovies.Length; OpticsIndex++)
	{
		if (OpticsUIMovies[OpticsIndex].class == OpticsClass)
		{
			OpticsUIMovies[OpticsIndex].Close();
			OpticsUIMovies.Remove(OpticsIndex, 1);
		}
	}
}

/**
 * InitFOV. Handle setting FOV values for inventory when the resolution changes
 *
 * @param SizeX the X resolution of the screen
 * @param SizeY the Y resolution of the screen
 */
simulated function InitFOV(float SizeX, float SizeY, float DefaultPlayerFOV)
{
	local KFWeapon KFWP;

	if( InventoryChain == None )
	{
		return;
	}

	// Have each weapon initialize its FOV settings
	foreach InventoryActors(class'KFWeapon', KFWP)
	{
		KFWP.InitFOV(SizeX, SizeY, DefaultPlayerFOV);
	}
}

simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate)
{
	local KFWeapon KFW;
	KFW = KFWeapon(NewItem);
	if ( KFW != none )
	{
		if ( Role == Role_Authority )
		{
			AddWeaponToGroup(KFW);
		}
		NewItem.SetOwner( Instigator );
		NewItem.Instigator = Instigator;
		NewItem.InvManager = Self;
		NewItem.GivenTo( Instigator, bDoNotActivate);

		// Trigger inventory event
		Instigator.TriggerEventClass(class'SeqEvent_GetInventory', NewItem);

		return true;
	}
	else
	{
		return super.AddInventory(NewItem, bDoNotActivate);
	}
}

/** Same as InventoryManager.CreateInventory, but accepts a Archtype(template) instance */
simulated function Inventory CreateInventoryArchetype(Inventory NewInventoryTemplate, optional bool bDoNotActivate)
{
	local Inventory	Inv;

	if( NewInventoryTemplate != None )
	{
		inv = Spawn(NewInventoryTemplate.Class, Owner,,,, NewInventoryTemplate);
		if( inv != None )
		{
			if( !AddInventory(Inv, bDoNotActivate) )
			{
				`warn("InventoryManager::CreateInventory - Couldn't Add newly created inventory" @ Inv);
				Inv.Destroy();
				Inv = None;
			}
		}
		else
		{
			`warn("InventoryManager::CreateInventory - Couldn't spawn inventory" @ NewInventoryTemplate);
		}
	}

	return Inv;
}

/** Overridden to check carrying capacity and pop the weapon switch when a new weapon is given */
simulated function Inventory CreateInventory(class<Inventory> NewInventoryItemClass, optional bool bDoNotActivate)
{
	local KFWeapon KFWeap;
	local class<KFWeapon> KFWeapClass;

	if( bPendingDelete )
	{
		return none;
	}

	KFWeapClass = class<KFWeapon>(NewInventoryItemClass);
	if (KFWeapClass != none)
	{
		if (CanCarryWeapon(KFWeapClass))
		{
			KFWeap = KFWeapon( super.CreateInventory(NewInventoryItemClass, bDoNotActivate) );
			//may want to do a flicker here for the weapon to show selected
			UpdateHUD();

			// Only play sounds and send messages after we've spawned
			if (!bSuppressPickupMessages && `TimeSince(CreationTime) > 1)
			{
				PlayerController(Instigator.Owner).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_PickedupItem,,, KFWeap );
				if (`TimeSince(LastCreatedWeaponTime) > 1)
				{
					PlayGiveInventorySound( ItemPickupSound );
					LastCreatedWeaponTime = WorldInfo.TimeSeconds;
				}
			}

            if (KFWeap != none)
            {
                CheckForExcessRemoval(KFWeap);
            }

			return KFWeap;
		}
		else
		{
			if( !bSuppressPickupMessages )
			{
				PlayerController(Instigator.Owner).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_TooMuchWeight );
			}
			return none;
		}
	}

	return super.CreateInventory(NewInventoryItemClass, bDoNotActivate);
}

simulated function RemoveFromInventory(Inventory ItemToRemove)
{
	local Inventory Item;
	local bool		bFound;
	local KFPlayerController KFPC;

	if( ItemToRemove == none )
	{
		return;
	}

	// make sure we're not holding old refs from GC
	if ( PreviousEquippedWeapons[0] == ItemToRemove )
	{
		PreviousEquippedWeapons[0] = none;
	}
	if ( PreviousEquippedWeapons[1] == ItemToRemove )
	{
		PreviousEquippedWeapons[1] = none;
	}

	if ( PendingWeapon == ItemToRemove )
	{
	    PendingWeapon = none;
	}

	if( Instigator != none && Instigator.Weapon == ItemToRemove )
	{
		Instigator.Weapon = None;
	}

	if( InventoryChain == ItemToRemove )
	{
		bFound = TRUE;
		InventoryChain = ItemToRemove.Inventory;
	}
	else
	{
		// If this item is in our inventory chain, unlink it.
		for(Item = InventoryChain; Item != None; Item = Item.Inventory)
		{
			if( Item.Inventory == ItemToRemove )
			{
				bFound = TRUE;
				Item.Inventory = ItemToRemove.Inventory;
				break;
			}
		}
	}

	if( bFound )
	{
		ItemToRemove.ItemRemovedFromInvManager();
		ItemToRemove.SetOwner(None);
		ItemToRemove.Inventory = None;
	}

	if (Instigator != none && Instigator.Health > 0 && Instigator.Controller != none)
	{
		if ( WorldInfo.NetMode == NM_DedicatedServer || (WorldInfo.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()) )
		{
			ClientRemoveFromInventory(ItemToRemove);
		}
		else if( Instigator.Weapon == None )
		{
			if (PendingWeapon != None && PendingWeapon != ItemToRemove)
			{
				`LogInv("Removed current weapon while changing weapons, call ChangedWeapon");
				// @NOTE: ChangedWeapon() doesn't tell the server anything, so as a client
				// we'll use SetCurrentWeapon(). -MattF
				if( Role < ROLE_Authority )
				{
					SetCurrentWeapon( PendingWeapon );
				}
				else
				{
					ChangedWeapon();
				}
			}
			else if(Instigator.Controller != None)
			{
				`LogInv("Calling SwitchToBestWeapon to make sure a weapon is brought up");
				Instigator.Controller.SwitchToBestWeapon(TRUE);
			}
		}
	}

	// We should update the weapon select HUD immediately after discarding a weapon
	if( Instigator != none && Instigator.IsLocallyControlled() )
	{
		KFPC = KFPlayerController( Instigator.Controller );
		if( KFPC != none && KFPC.MyGFxHUD != none && KFPC.MyGFxHUD.WeaponSelectWidget != none
			&& KFPC.IsTimerActive(nameOf(KFPC.MyGFxHUD.WeaponSelectWidget.RefreshTimer), KFPC.MyGFxHUD.WeaponSelectWidget) )
		{
			KFPC.MyGFxHUD.WeaponSelectWidget.RefreshTimer();
		}
	}
}

reliable server final function ServerRemoveFromInventory(Inventory ItemToRemove)
{
   	if (Role == ROLE_Authority)
    {
		RemoveFromInventory(ItemToRemove);

		/* __TW_ Analytics */
		`BalanceLog(class'KFGameInfo'.const.GBE_Sell, Instigator.PlayerReplicationInfo, ItemToRemove.Class);
		`AnalyticsLog(("sell", Instigator.PlayerReplicationInfo, ItemToRemove.Class));
	}
}

reliable client function ClientRemoveFromInventory(Inventory ItemToRemove)
{
	RemoveFromInventory(ItemToRemove);
}

/** checks whether requested item is actually in inventory */
function bool ItemIsInInventory( Inventory Item )
{
	local Inventory Inv;

	for( Inv = InventoryChain; Inv != None; Inv = Inv.Inventory)
	{
		if( Inv == Item )
		{
			return true;
		}
	}

	return false;
}

/** checks whether instance of requested class is actually in inventory */
function bool ClassIsInInventory( class<Inventory> ItemClass, out Inventory out_Inventory )
{
	local Inventory Inv;

	for( Inv = InventoryChain; Inv != None; Inv = Inv.Inventory)
	{
		if( Inv.Class == ItemClass )
		{
			out_Inventory = Inv;
			return true;
		}
	}

	return false;
}

function bool ClassNameIsInInventory(name ItemClassName, out Inventory out_Inventory)
{
	local Inventory Inv;

	for (Inv = InventoryChain; Inv != None; Inv = Inv.Inventory)
	{
		if (Inv.Class.name == ItemClassName)
		{
			out_Inventory = Inv;
			return true;
		}
	}

	return false;
}

/**
 * returns the best weapon for this Pawn in loadout
 */
simulated function Weapon GetBestWeapon( optional bool bForceADifferentWeapon, optional bool allow9mm )
{
	local KFWeapon	W, BestWeapon;
	local float		Rating, BestRating;

	ForEach InventoryActors( class'KFWeapon', W )
	{
		if( w.HasAnyAmmo() )
		{
			if( bForceADifferentWeapon &&
				W == Instigator.Weapon )
			{
				continue;
			}

			Rating = W.GetWeaponRating();
			if( BestWeapon == None ||
				Rating > BestRating )
			{
				if (allow9mm == false)
				{
					if (W.bIsBackupWeapon && !W.IsMeleeWeapon())
					{
						continue;
					}
				}

				BestWeapon = W;
				BestRating = Rating;
			}
		}
	}

	if (BestWeapon == none && allow9mm == false)
	{
		ForEach InventoryActors( class'KFWeapon', W )
		{
			if( w.HasAnyAmmo() )
			{
				if( bForceADifferentWeapon &&
					W == Instigator.Weapon )
				{
					continue;
				}

				Rating = W.GetWeaponRating();
				if( BestWeapon == None ||
					Rating > BestRating )
				{
					BestWeapon = W;
					BestRating = Rating;
				}
			}
		}
	}

	return BestWeapon;
}

/**
 * Switch to best weapon available in loadout
 * Network: LocalPlayer
 */
simulated function SwitchToBestWeapon( optional bool bForceADifferentWeapon, optional bool check_9mm_logic = false )
{
	local Weapon BestWeapon;
	local PlayerController PC;
	local KFPlayerInput KFPI;
	local bool bCanSwapTo9mm;
	
	if (check_9mm_logic)
	{
		// Default behaviour is you can't swap to 9mm
		bCanSwapTo9mm = false;

		PC = PlayerController(Instigator.Controller);
		if ( PC != None )
		{
			KFPI = KFPlayerInput(PC.PlayerInput);
			if (KFPI != None)
			{
				bCanSwapTo9mm = KFPI.bAllowSwapTo9mm;
			}
		}
	}
	else
	{
		bCanSwapTo9mm = true;
	}

	`LogInv("bForceADifferentWeapon:" @ bForceADifferentWeapon);

	// if we don't already have a pending weapon,
	if( bForceADifferentWeapon ||
		PendingWeapon == None ||
		(AIController(Instigator.Controller) != None) )
	{
		// figure out the new weapon to bring up
		BestWeapon = GetBestWeapon( bForceADifferentWeapon, bCanSwapTo9mm );

		if( BestWeapon == None )
		{
			return;
		}

		// if it matches our current weapon then don't bother switching
		if( BestWeapon == Instigator.Weapon )
		{
			BestWeapon = None;
			PendingWeapon = None;
			Instigator.Weapon.Activate();
		}
	}

	// stop any current weapon fire
	Instigator.Controller.StopFiring();

	// and activate the new pending weapon
	SetCurrentWeapon(BestWeapon);
}

/**
 * Switches to Previous weapon
 * Network: Client
 */
simulated function SwitchToLastWeapon()
{
	local Weapon CurrentWeapon;
	local Weapon DesiredWeapon;
    local KFWeapon CheckedWeapon;
    local KFWeapon DesiredKFWeapon;
    local int WeaponIndex;

	// Check to see if we are in the process of switching to a new weapon during this move
	CurrentWeapon = (PendingWeapon != none) ? PendingWeapon : Instigator.Weapon;

	// Choose best from inventory history.  We need two because of auto-use equipement.  For example:
	// GunA -> cycle to GunB -> quick heal to Healer -> auto return to GunB -> press switch last to GunA (not healer)
	if ( PreviousEquippedWeapons[0] != None
		&& PreviousEquippedWeapons[0] != CurrentWeapon )
	{
		DesiredWeapon = PreviousEquippedWeapons[0];
	}
	else if ( PreviousEquippedWeapons[1] != None
		&& PreviousEquippedWeapons[1] != CurrentWeapon )
	{
		DesiredWeapon = PreviousEquippedWeapons[1];
	}
	else
	{
		return;
	}

	bAutoswitchWeapon = true;
	//ShowAllHUDGroups();
	SetCurrentWeapon(DesiredWeapon);
	bAutoSwitchWeapon = false;

    //Reset selected weapon index
    DesiredKFWeapon = KFWeapon(DesiredWeapon);
    WeaponIndex = 0;
    if (DesiredKFWeapon != none)
    {
        foreach InventoryActors(class'KFWeapon', CheckedWeapon)
        {
            if (CheckedWeapon.InventoryGroup == DesiredKFWeapon.InventoryGroup)
            {
                if (CheckedWeapon == DesiredKFWeapon)
                {
                    SelectedGroupIndicies[CheckedWeapon.InventoryGroup] = WeaponIndex;
                }
                ++WeaponIndex;
            }
        }
    }
}

/**
 * @brief Picks the best next available and per weapon with ammo
 *
 * @param PerkClass Currently selected perk
 * @param bBackupIfEmpty Return the backup pistol if no perk weapon available
 * @return Next best weapon with ammo
 */
simulated function KFWeapon GetBestPerkWeaponWithAmmo( class<KFPerk> PerkClass, optional bool bBackupIfEmpty=false )
{
	local KFWeapon PerkWeapon, NextWeapon, BackupWeapon;

	if( InventoryChain == none )
	{
		return none;
	}

	foreach InventoryActors( class'KFWeapon', NextWeapon )
	{
		if( NextWeapon.GetWeaponPerkClass( PerkClass ) == PerkClass && NextWeapon.HasAmmo( 0 ) && !NextWeapon.IsMeleeWeapon() )
		{
			PerkWeapon = NextWeapon;
			break;
		}
		else if( NextWeapon.bIsBackupWeapon && !NextWeapon.IsMeleeWeapon() && NextWeapon.HasAmmo( 0 ) )
		{
			BackupWeapon = NextWeapon;
		}
	}


	return PerkWeapon != none ? PerkWeapon : BackupWeapon;
}

/** Get the next weapon in the specified group */
simulated function KFWeapon GetNextGroupedWeapon(byte GroupID, optional bool bGetFirstWeapon, optional bool bGamePadWeaponSelectOpen)
{
	local KFWeapon EquippedWeapon, NewWeapon;
	local int WeaponIndex;

	WeaponIndex = 0;

	if (Instigator == none)
	{
		return none;
	}

	// If we are in the process of changing weapons, switch to the next pending weapon before our current
	if ( PendingWeapon != none )
	{
		EquippedWeapon = KFWeapon( PendingWeapon );
	}
	else
	{
		EquippedWeapon = KFWeapon( Instigator.Weapon );
	}

	// If we are going through the same group increment our selected index for this group.
	if( EquippedWeapon != none && EquippedWeapon.InventoryGroup == GroupID && !bGetFirstWeapon)
	{
		SelectedGroupIndicies[GroupID] +=1;
	}

	// If we are switching from a different group, we want to grab the first weapon in that group
	if ((EquippedWeapon == none || EquippedWeapon.InventoryGroup != GroupID) && !bGamePadWeaponSelectOpen)
	{
     	bGetFirstWeapon = true;
	}

	foreach InventoryActors(class'KFWeapon', NewWeapon)
	{
		if (GroupID == NewWeapon.InventoryGroup)
		{
			// If this weapon index is the same as our saved weapon or we want the 1st one send it otherwise keep going
			if (SelectedGroupIndicies[GroupID] == WeaponIndex || bGetFirstWeapon)
			{
				return NewWeapon;
			}
			WeaponIndex++;
		}
	}

	// If we are on the last weapon in this group, grab the first weapon in the group
	if ( !bGetFirstWeapon )
	{
		SelectedGroupIndicies[GroupID] = 0;
	    return GetNextGroupedWeapon( GroupID, true, bGamePadWeaponSelectOpen );
    }
    return none;
}

/**
 * Switches to Previous weapon
 * Network: Client
 */
simulated function HighlightPrevWeapon()
{
	local Weapon	CandidateWeapon, StartWeapon, W;
	StartWeapon = Instigator.Weapon;
	if ( PendingWeapon != None )
	{
		StartWeapon = PendingWeapon;
	}

	// Get previous
	ForEach InventoryActors(class'Weapon', W)
	{
		if ( W == StartWeapon )
		{
			break;
		}
		if ( !ShouldSkipCycleWeapon(W, false) )
		{
			CandidateWeapon = W;
		}
	}

	// if none found, get last
	if ( CandidateWeapon == None )
	{
		ForEach InventoryActors(class'Weapon', W)
		{
			if ( !ShouldSkipCycleWeapon(W, false) )
			{
				CandidateWeapon = W;
			}
		}
	}
	HighlightWeapon(CandidateWeapon);
}

/**
 * Switches to Previous weapon
 * Network: Client
 */
simulated function PrevWeapon()
{
	InternalPrevWeapon(false);
}

/**
 * Switches to Next weapon
 * Network: Client
 */
simulated function NextWeapon()
{
	InternalNextWeapon(false);
}

/**
 * Switches to Next weapon
 * Network: Client
 */
simulated function GamepadNextWeapon()
{
	InternalNextWeapon(true);
}

simulated function InternalPrevWeapon(bool bGamepad)
{
	local Weapon	CandidateWeapon, StartWeapon, W;

	StartWeapon = Instigator.Weapon;
	if ( PendingWeapon != None )
	{
		StartWeapon = PendingWeapon;
	}

	// Get previous
	ForEach InventoryActors( class'Weapon', W )
	{
		if ( W == StartWeapon )
		{
			break;
		}
		if ( !ShouldSkipCycleWeapon(W, bGamepad) )
		{
			CandidateWeapon = W;
		}
	}

	// if none found, get last
	if ( CandidateWeapon == None )
	{
		ForEach InventoryActors( class'Weapon', W )
		{
			if ( !ShouldSkipCycleWeapon(W, bGamepad) )
			{
				CandidateWeapon = W;
			}
		}
	}

	// If same weapon, do not change
	if ( CandidateWeapon == Instigator.Weapon )
	{
		return;
	}

	SetCurrentWeapon(CandidateWeapon);
}

simulated function InternalNextWeapon(bool bGamepad)
{
	local Weapon	StartWeapon, CandidateWeapon, W;
	local bool		bBreakNext;

	StartWeapon = Instigator.Weapon;
	if( PendingWeapon != None )
	{
		StartWeapon = PendingWeapon;
	}

	ForEach InventoryActors( class'Weapon', W )
	{
		if( bBreakNext || (StartWeapon == None) )
		{
			if( !ShouldSkipCycleWeapon(W, bGamepad) )
			{
				CandidateWeapon = W;
				break;
			}
		}
		if( W == StartWeapon )
		{
			bBreakNext = true;
		}
	}

	if( CandidateWeapon == None )
	{
		ForEach InventoryActors( class'Weapon', W )
		{
			if( !ShouldSkipCycleWeapon(W, bGamepad) )
			{
				CandidateWeapon = W;
				break;
			}
		}
	}

	// If same weapon, do not change
	if( CandidateWeapon == Instigator.Weapon )
	{
		return;
	}

	SetCurrentWeapon(CandidateWeapon);
}

/** Returns true if we should skip over the candidate weapon while cycling through inventory */
simulated function bool ShouldSkipCycleWeapon(Weapon CandidateWeapon, bool bGamepad)
{
	local KFWeapon KFW;
	local PlayerController PC;
	local KFPlayerInput KFPI;
	local bool bCanSwapTo9mm;

	// Default behaviour is you can't swap to 9mm
	bCanSwapTo9mm = false;

	PC = PlayerController(Instigator.Controller);
	if ( PC != None )
	{
		KFPI = KFPlayerInput(PC.PlayerInput);
		if (KFPI != None)
		{
			bCanSwapTo9mm = KFPI.bAllowSwapTo9mm;
		}
	}
	
	KFW = KFWeapon(CandidateWeapon);

	if(KFW != none)
	{
		if(KFW.InventoryGroup == IG_None)
		{
			return true;
		}

		if (bGamepad)
		{
			if(KFW.InventoryGroup == IG_Equipment)
			{
				return true;
			}

			if (KFW.bIsBackupWeapon && (!bCanSwapTo9mm || KFW.IsMeleeWeapon()))
			{
				return true;
			}

			if(!KFW.HasAnyAmmo())
			{
				return true;
			}
		}
	}
	//out of ammo or equipment
	return false;
}

/**
 * Switches to Next weapon
 * Network: Client
 */
simulated function HighlightNextWeapon()
{
	local Weapon	StartWeapon, CandidateWeapon, W;
	local bool		bBreakNext;
	StartWeapon = Instigator.Weapon;
	if( PendingWeapon != None )
	{
		StartWeapon = PendingWeapon;
	}

	ForEach InventoryActors( class'Weapon', W )
	{
		if( bBreakNext || (StartWeapon == None) )
		{
			if ( !ShouldSkipCycleWeapon(W, false) )
			{
				CandidateWeapon = W;
			}
			break;
		}
		if( W == StartWeapon )
		{
			bBreakNext = true;
		}
	}

	if( CandidateWeapon == None )
	{
		ForEach InventoryActors( class'Weapon', W )
		{
			if ( !ShouldSkipCycleWeapon(W, false) )
			{
				CandidateWeapon = W;
			}
			break;
		}
	}

	HighlightWeapon( CandidateWeapon );
}

simulated function HighlightWeapon( Weapon CandidateWeapon )
{
	SetPendingWeapon(CandidateWeapon);
    UpdateHUD();
}

/**
 * ServerSetCurrentWeapon begins the Putdown sequence on the server.  This function makes
 * the assumption that if TryPutDown succeeded on the client, it will succeed on the server.
 * This function shouldn't be called from anywhere except SetCurrentWeapon
 *
 * Overridden to check if desired weapon is actually in inventory (possible client/server mismatch due to lag)
 *
 * Network: Dedicated Server
 */
reliable server function ServerSetCurrentWeapon(Weapon DesiredWeapon)
{
	local KFWeapon PendingKFW;

	if( !ItemIsInInventory(DesiredWeapon) )
	{
		`LogInv(DesiredWeapon$" is not in inventory!");
		return;
	}

	// let weapons know when they were pending for equip and then removed from that queue
	if (PendingWeapon != none && DesiredWeapon != PendingWeapon)
	{
		PendingKFW = KFWeapon(PendingWeapon);
		if (PendingKFW != none)
		{
			PendingKFW.NotifyRemovedPending();
		}
	}

	super.ServerSetCurrentWeapon(DesiredWeapon);
}

/** Overridden to give a temporary equip message */
reliable client function SetCurrentWeapon(Weapon DesiredWeapon)
{
	local KFWeapon CurrentKFW;
	local bool bCurrentWeaponUsingSights;
	local KFWeapon DesiredKFW;
	local KFWeapon PendingKFW;

	CurrentKFW = Instigator != none ? KFWeapon(Instigator.Weapon) : none;
	if ( CurrentKFW != none )
	{
		// Set the flag to switch to ironsights when the weapon is brought up
        bCurrentWeaponUsingSights = CurrentKFW.bUsingSights;
    }

	// let weapons know when they were pending for equip and then removed from that queue
	if (PendingWeapon != none && DesiredWeapon != PendingWeapon)
	{
		PendingKFW = KFWeapon(PendingWeapon);
		if (PendingKFW != none)
		{
			PendingKFW.NotifyRemovedPending();
		}
	}

	// Only change your weapon if it is different or we weant to equip the weapon we are currently putting down
	DesiredKFW = KFWeapon(DesiredWeapon);
	if( DesiredKFW != none &&
		Instigator != none &&
		(DesiredKFW != Instigator.Weapon || Instigator.Weapon.IsInState('WeaponPuttingDown')) )
	{
		if ( DesiredKFW.bHasIronSights )
		{
			if ( bCurrentWeaponUsingSights && !IsUsingIronsightHoldKey() )
			{
				DesiredKFW.bIronSightOnBringUp = true;
			}
			else
			{
				DesiredKFW.bIronSightOnBringUp = false;
			}
		}

		// Store last two uniqiue, non-equipment, equipped weapons (see SwitchToLastWeapon)
		if ( CurrentKFW != none && 
			(CurrentKFW.InventoryGroup < IG_Equipment || CurrentKFW.bStorePreviouslyEquipped)&&
			 CurrentKFW != PreviousEquippedWeapons[0] )
		{
			PreviousEquippedWeapons[1] = PreviousEquippedWeapons[0];
			PreviousEquippedWeapons[0] = CurrentKFW;
		}

		super.SetCurrentWeapon(DesiredWeapon);
		UpdateHUD();
	}
}

/** Helper for bIronSightOnBringUp */
simulated function bool IsUsingIronsightHoldKey()
{
	local PlayerController PC;

	if ( Instigator.IsLocallyControlled() )
	{
		PC = PlayerController(Instigator.Controller);
		if ( PC != None && PC.PlayerInput != None )
		{
			if ( KFPlayerInput(PC.PlayerInput).bIronsightsHeld )
			{
				return true;
			}
		}
	}

	return false;
}

/**
 * Weapon just given to a player, check if player should switch to this weapon
 * Network: LocalPlayer
 * Called from Weapon.ClientWeaponSet()
 */
simulated function ClientWeaponSet(Weapon NewWeapon, bool bOptionalSet, optional bool bDoNotActivate)
{
	local KFWeapon KFW;

	super.ClientWeaponSet(NewWeapon, bOptionalSet, bDoNotActivate);
	KFW = KFWeapon(NewWeapon);
	if ( Role != Role_Authority )
	{
		AddWeaponToGroup(KFW);
		UpdateHUD();
	}
}

simulated event ShowOnlyHUDGroup( byte GroupIndex )
{
	local KFGFxMoviePlayer_HUD KFGFxHUD;
	KFGFxHUD = KFPlayerController(Instigator.Controller).MyGFxHUD;
	if (KFGFxHUD != none && KFGFxHUD.WeaponSelectWidget != none)
	{
		KFGFxHUD.WeaponSelectWidget.ShowOnlyHUDGroup( GroupIndex );
	}
}

simulated function ShowAllHUDGroups()
{
	local KFGFxMoviePlayer_HUD KFGFxHUD;
	if( Instigator != none && Instigator.Controller != none )
	{
		KFGFxHUD = KFPlayerController(Instigator.Controller).MyGFxHUD;
		if (KFGFxHUD != none && KFGFxHUD.WeaponSelectWidget != none)
		{
			KFGFxHUD.WeaponSelectWidget.ShowAllHUDGroups();
		}
	}
}

/** Update the huds weapon select with our current weapon */
simulated function UpdateHUD()
{
	local KFGFxMoviePlayer_HUD KFGFxHUD;
	local KFWeapon KFW, KFPendingWeapon;
	local byte WeaponIndex;

	WeaponIndex = 0;
	if( PendingWeapon != none && !PendingWeapon.bDeleteMe && PendingWeapon.Instigator == Instigator )
	{
		KFPendingWeapon = KFWeapon( PendingWeapon );
	}
	else  // Use your starting weapon when spawning in
	{
		KFPendingWeapon = KFWeapon( Instigator.Weapon );
	}

	// IG_None should be ignored by all UI!  Passing this through to the widget will break selection highlights.
	if ( KFPendingWeapon == none || KFPendingWeapon.InventoryGroup == IG_None )
	{
		return;
	}

	// Get the index of this weapon in its group
	ForEach InventoryActors( class'KFWeapon', KFW )
	{
		if ( KFW.InventoryGroup == KFPendingWeapon.InventoryGroup )
		{
			if ( KFW == KFPendingWeapon )
			{
				break;
			}

			WeaponIndex++;
		}
	}

    if( KFPlayerController(Instigator.Controller) != none )
    {
        KFGFxHUD = KFPlayerController(Instigator.Controller).MyGFxHUD;
	}
	if (KFGFxHUD != none && KFGFxHUD.WeaponSelectWidget != none)
	{
		// Update our pending weapons ammo
		if(!bAutoswitchWeapon && !(KFPendingWeapon == HealerWeapon && HealerWeapon.bQuickHealMode))
		{
			KFGFxHUD.WeaponSelectWidget.SetSelectedWeapon(KFPendingWeapon.InventoryGroup, WeaponIndex);
			KFGFxHUD.WeaponSelectWidget.RefreshWeaponSelect();

			// Save the index for the group when we select it to keep things in sync - HSL
			SelectedGroupIndicies[KFPendingWeapon.InventoryGroup] = WeaponIndex;
		}
	}
}

/** Set our current weapon based on its group and index in the inventory list */
function SelectCurrentWeapon( byte GroupIndex, byte WeaponIndex )
{
	local KFWeapon KFW;
	local byte CurrentWeaponIndex;

	ForEach InventoryActors( class'KFWeapon', KFW )
	{
		if ( KFW.InventoryGroup == GroupIndex )
		{
			if ( CurrentWeaponIndex == WeaponIndex )
			{
				break;
			}
			CurrentWeaponIndex++;
		}
	}

	if ( KFW != none )
	{
		SetCurrentWeapon( KFW );
	}
}

/**
 * Attempt to heal self using the quick heal key
 * Network: Local Player
 */
simulated function AttemptQuickHeal()
{
	local KFWeap_HealerBase W;
	local KFPlayerController KFPC;

	// Do not heal if we have full health
	if ( Instigator.Health >= Instigator.HealthMax )
	{
		KFPC = KFPlayerController(Instigator.Owner);
		if ( KFPC != None && KFPC.MyGFxHUD != None )
		{
			KFPC.MyGFxHUD.ShowNonCriticalMessage(FullHealthMsg);
		}
	 	return;
	}
	
	// Do not heal if the player is affected by a power up that negates healing
	KFPC = KFPlayerController(Instigator.Owner);
	if( KFPC != none )
	{
		if(!KFPC.CanUseHealObject())
		{
			return;
		}
	}

	// if the healer is equipped already just fire it
	if ( KFWeap_HealerBase(Instigator.Weapon) != None && !Instigator.Weapon.IsFiring() )
	{
		Instigator.Weapon.StartFire(1);
		return;
	}

	// otherwise try to equip one
	ForEach InventoryActors( class'KFWeap_HealerBase', W )
	{
		if ( W != Instigator.Weapon && W.HasAmmo(1) )
		{
			W.bQuickHealMode = true;
			SetCurrentWeapon(W);
			//ShowAllHUDGroups();
		}
	}
}

/** Equip the welder immediately */
simulated function bool QuickWeld()
{
	local KFWeapon KFW;
	local KFInterface_Usable UsableTrigger;
	local KFDoorTrigger DoorTrigger;
	local KFRepairableActorTrigger RepairableTrigger;
	local KFWeldableTrigger WeldableTrigger;
	local KFPlayerController KFPC;

	if( Instigator == none || Instigator.Owner == none )
	{
		return false;
	}

	// make sure player is actually allowed to switch weapons
	KFW = KFWeapon( Instigator.Weapon );
	if( KFW != none && !KFW.CanSwitchWeapons() )
	{
		return false;
	}

	KFPC = KFPlayerController(Instigator.Owner);
	if( KFPC != none )
	{
		UsableTrigger = KFPC.GetCurrentUsableActor( Instigator );
		if( UsableTrigger != none )
		{
			if( CanUseWelder(UsableTrigger, DoorTrigger, RepairableTrigger, WeldableTrigger) )
			{
				// Close the door if it's open already
				if( DoorTrigger != none && DoorTrigger.DoorActor.bIsDoorOpen && !DoorTrigger.DoorActor.bIsDestroyed )
				{
					KFPC.Use();
				}

				// return success if we already have the welder
				if ( Instigator.Weapon != None && Instigator.Weapon.IsA('KFWeap_Welder') )
				{
					return true;
				}

				// attempt to equip the welder from our inventory
				foreach InventoryActors( class'KFWeapon', KFW )
				{
					if( KFW.IsA('KFWeap_Welder') )
					{
						SetCurrentWeapon(KFW);
						ShowAllHUDGroups();
						return true;
					}
				}
			}
		}
	}

	return false;
}

simulated function bool CanUseWelder(KFInterface_Usable BaseTrigger, out KFDoorTrigger out_DoorTrigger, out KFRepairableActorTrigger out_RepairableTrigger, out KFWeldableTrigger out_WeldableTrigger)
{
	out_DoorTrigger = KFDoorTrigger(BaseTrigger);
	out_RepairableTrigger = KFRepairableActorTrigger(BaseTrigger);
	out_WeldableTrigger = KFWeldableTrigger(BaseTrigger);

	return ((out_DoorTrigger != none && out_DoorTrigger.DoorActor != none) || (out_RepairableTrigger != none && out_RepairableTrigger.RepairableActor != none) || (out_WeldableTrigger != none && out_WeldableTrigger.WeldableComponent != none));
}

/** Equip the welder immediately */
simulated function bool DoshActivate()
{
	local KFInterface_Usable UsableTrigger;
	local KFTrigger_DoshActivated DoshActivatedTrigger;
	local KFPlayerController KFPC;

	if (Instigator == none || Instigator.Owner == none)
	{
		return false;
	}

	KFPC = KFPlayerController(Instigator.Owner);
	if (KFPC != none)
	{
		UsableTrigger = KFPC.GetCurrentUsableActor(Instigator);
		if (UsableTrigger != none)
		{
			DoshActivatedTrigger = KFTrigger_DoshActivated(UsableTrigger);
			if (DoshActivatedTrigger != none)
			{
				KFPC.Use();
			}
		}
	}

	return false;
}

/** Set the GrenadeCount to the starting amount. Returns true if any ammo was added */
function bool GiveInitialGrenadeCount()
{
    local byte OriginalGrenadeCount;

    OriginalGrenadeCount = GrenadeCount;

    if( KFPawn(Instigator) != none )
    {
        GrenadeCount = KFPawn(Instigator).GetPerk().InitialGrenadeCount;
    }

    if (KFGameInfo(WorldInfo.Game) != none)
    {
        GrenadeCount = KFGameInfo(WorldInfo.Game).AdjustStartingGrenadeCount(GrenadeCount);
    }

    return GrenadeCount > OriginalGrenadeCount;
}

/** Add grenades to the player's Inventory */
function bool AddGrenades(int AmountToAdd)
{
	if( KFPawn(Instigator) != none )
	{
		if( GrenadeCount < KFPawn(Instigator).GetPerk().MaxGrenadeCount )
		{
			GrenadeCount = Min(KFPawn(Instigator).GetPerk().MaxGrenadeCount, GrenadeCount + AmountToAdd);
			return true;
		}
	}

	return false;
}

/** Use/Consume/Remove grenades from the player's Inventory. Returns true if any ammo was removed */
function bool ConsumeGrenades(optional int AmountToSubtract=1)
{
    local byte OriginalGrenadeCount;

    OriginalGrenadeCount = GrenadeCount;
    GrenadeCount = Max(0, GrenadeCount - AmountToSubtract);

    return GrenadeCount < OriginalGrenadeCount;
}

/**
 * @see Weapon::HasAmmo
 */
simulated event bool HasGrenadeAmmo( optional int Amount=1 )
{
	// Assume we ask for at least 1 grenade to be there.
	if( Amount == 0 )
	{
		Amount = 1;
	}

	return (GrenadeCount - Amount) >= 0;
}

/* ThrowWeapon()
Throw out current weapon, and switch to a new weapon
*/
simulated function ThrowMoney()
{
	ServerThrowMoney();
}

reliable server function ServerThrowMoney()
{
	local Inventory Inv;

	if ( Instigator != none )
	{
		// find the dosh.  Use DroppedPickupClass because KFInventory_Money is in KFGameContent
		foreach InventoryActors(class'Inventory', Inv)
		{
			if ( Inv.DroppedPickupClass == class'KFDroppedPickup_Cash' )
			{
				Instigator.TossInventory(Inv);
				return;
			}
		}
	}
}

/** Returns whether or not we have the carrying capacity to pickup this weapon */
simulated function bool CanCarryWeapon( class<KFWeapon> WeaponClass, optional int WeaponUpgradeIndex )
{
	local class<KFWeap_DualBase> DualWeaponClass;
	local int DualAdjustedWeight, SingleAdjustedWeight, AdjustedWeight;
	local Inventory InventoryItem;
	local TransactionItem TransactionWeapon;
	local KFWeapon WeaponItemSingle;

	// If the trader menu is open, check if this weapon is already part of our weapon transactions
	if( bServerTraderMenuOpen && IsTransactionWeapon(WeaponClass.Name, TransactionWeapon) )
	{
		return false;
	}

	WeaponUpgradeIndex = Clamp(WeaponUpgradeIndex, 0, WeaponClass.default.WeaponUpgrades.length - 1);

	// if trying to add a second single, make sure player can carry dual (minus weight of first single
	if( WeaponClass.default.DualClass != none && ClassIsInInventory(WeaponClass, InventoryItem) )
	{
		WeaponItemSingle = KFWeapon(InventoryItem);
		WeaponUpgradeIndex = Max(WeaponUpgradeIndex, WeaponItemSingle.CurrentWeaponUpgradeIndex);

		DualAdjustedWeight = WeaponClass.default.DualClass.static.GetDefaultModifiedWeightValue(WeaponUpgradeIndex);
		SingleAdjustedWeight = WeaponItemSingle.GetModifiedWeightValue();

		// check weight of dual minus weight of single because we remove single when adding dual
		if( ((CurrentCarryBlocks + DualAdjustedWeight - SingleAdjustedWeight) <= MaxCarryBlocks) || bInfiniteWeight)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	// if trying to add a dual, make sure player can carry it (minus weight of owned single)
	DualWeaponClass = class<KFWeap_DualBase>(WeaponClass);
	if( DualWeaponClass != none && DualWeaponClass.default.SingleClass != none && ClassIsInInventory(DualWeaponClass.default.SingleClass, InventoryItem) )
	{
		WeaponItemSingle = KFWeapon(InventoryItem);
		WeaponUpgradeIndex = Max(WeaponUpgradeIndex, WeaponItemSingle.CurrentWeaponUpgradeIndex);

		DualAdjustedWeight = WeaponItemSingle.default.DualClass.static.GetDefaultModifiedWeightValue(WeaponUpgradeIndex);
		SingleAdjustedWeight = WeaponItemSingle.GetModifiedWeightValue();

		`log(self @ "-" @ GetFuncName() @ "- CurrentCarryBlocks:" @ CurrentCarryBlocks @ "DualWeaponClass:" @ DualWeaponClass @ "SingleClass:" @ DualWeaponClass.default.SingleClass @ "DualInventorySize:" @ DualAdjustedWeight @ "SingleInventorySize:" @ SingleAdjustedWeight, bLogInventory);
		// check weight of dual minus weight of single because we remove single when adding dual
		if( ((CurrentCarryBlocks + DualAdjustedWeight - SingleAdjustedWeight) <= MaxCarryBlocks) || bInfiniteWeight)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

	AdjustedWeight = WeaponClass.static.GetDefaultModifiedWeightValue(WeaponUpgradeIndex);
	if( WeaponClass.default.InventorySize <= 0 || CurrentCarryBlocks + AdjustedWeight <= MaxCarryBlocks || bInfiniteWeight)
	{
	 	return true;
	}

	return false;
}

//Remove any invalid weapons that showed up in the inventory before this weapon was created.
//      Best Ex: Bought dual->someone threw you a single->exited menu->now have both
simulated function CheckForExcessRemoval(KFWeapon NewWeap)
{
    local KFWeap_DualBase DualWeap;
    local Inventory RemoveInv, Inv;

    DualWeap = KFWeap_DualBase(NewWeap);
    if (DualWeap != None)
    {
            for (Inv = InventoryChain; Inv != None; Inv = Inv.Inventory)
            {
                if (Inv.Class == DualWeap.default.SingleClass)
                {
                    RemoveInv = Inv;
                    Inv = Inv.Inventory;
                    RemoveFromInventory(RemoveInv);
                }
            }
    }
}

/** Returns whether or not we are currently in the process of buying this weapon */
simulated function bool IsTransactionWeapon( name WeaponClassName, out TransactionItem TransactionWeapon)
{
	local int i;

	// If this was bought in a pending transaction, do not carry it
	for(i = TransactionItems.Length - 1; i >= 0; i--)
	{
		if( TransactionItems[i].ClassName == WeaponClassName )
		{
			TransactionWeapon = TransactionItems[i];
			return true;
		}
	}
	return false;
}

/**
 * Finds out if player is carrying weapon, and adds ammunition if so.
 * Returns TRUE if successful
 */
function bool AddAmmoFromPickup(KFWeapon KFW, optional Inventory Pickup)
{
    if (GiveWeaponAmmo(KFW))
    {
		PlayerController(Instigator.Owner).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_PickedupWeaponAmmo, , , KFW.class );
		PlayGiveInventorySound( AmmoPickupSound );
		return true;
    }
	return false;
}

/** Gives a weapon a generic amount of both primary and secondary ammo */
function bool GiveWeaponAmmo(KFWeapon KFW)
{
	local bool bAddedAmmo;

	if( KFW.AddAmmo(Max(KFW.AmmoPickupScale[0] * KFW.MagazineCapacity[0], 1)) > 0 )
	{
		bAddedAmmo = true;
	}

    if( KFW.CanRefillSecondaryAmmo() )
    {
    	if ( KFW.AddSecondaryAmmo(Max(KFW.AmmoPickupScale[1] * KFW.MagazineCapacity[1], 1)) > 0 )
    	{
    		bAddedAmmo = true;
    	}
    }

    return bAddedAmmo;
}

/** Gives all applicable weapons a generic amount of both primary and secondary ammo */
function bool GiveWeaponsAmmo( bool bIncludeGrenades )
{
	local KFWeapon W;
	local bool bAddedAmmo;

	foreach InventoryActors( class'KFWeapon', W )
	{
		if( !W.bInfiniteSpareAmmo && GiveWeaponAmmo(W) )
		{
			bAddedAmmo = true;
		}
	}

	if( bIncludeGrenades )
	{
		if( AddGrenades(1) )
		{
			bAddedAmmo = true;
		}
	}

	if( bAddedAmmo )
	{
		PlayerController( Instigator.Owner ).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_Ammo );
		PlayGiveInventorySound( AmmoPickupSound );
	}
	else
	{
		PlayerController( Instigator.Owner ).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_AmmoIsFull );
	}

	return bAddedAmmo;
}

/**
 * Give the player a full set of armor
 * Returns TRUE if successful
 */
function bool AddArmorFromPickup()
{
	local KFPawn_Human KFPH;

	KFPH = KFPawn_Human(Instigator);
	if ( KFPH.Armor != KFPH.GetMaxArmor() )
	{
		PlayerController(Instigator.Owner).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_PickedupArmor );
		PlayGiveInventorySound( ArmorPickupSound );
  		KFPH.GiveMaxArmor();
  		return true;
	}
	else
	{
    	PlayerController( Instigator.Owner ).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_FullArmor);
    	return false;
	}
}

function bool AddArmor(int Amount)
{
    local KFPawn_Human KFPH;

    KFPH = KFPawn_Human(Instigator);
    if (KFPH.Armor != KFPH.GetMaxArmor())
    {
        PlayerController(Instigator.Owner).ReceiveLocalizedMessage(class'KFLocalMessage_Game', GMT_PickedupArmor);
        PlayGiveInventorySound(ArmorPickupSound);
        KFPH.AddArmor(Amount);
        return true;
    }
    else
    {
        PlayerController(Instigator.Owner).ReceiveLocalizedMessage(class'KFLocalMessage_Game', GMT_FullArmor);
        return false;
    }
}

function PlayGiveInventorySound( AkEvent SoundEvent )
{
	Instigator.PlaySoundBase( SoundEvent );
}

/** Get GroundSpeed modifer (1.f - Penalty) based on current inventory size */
simulated function float GetEncumbranceSpeedMod()
{
	local float CarryPercent;
	CarryPercent = FMin(float(CurrentCarryBlocks) / MaxCarryBlocks, 1.f);
	return Lerp(1.f, 0.92, CarryPercent);
}

/** Combines ammo and removes singles / creates dual as necessary. */
function KFWeapon CombineWeaponsOnPickup( KFWeapon AddedWeapon )
{
	local KFWeapon InvWeap;
	local KFWeap_DualBase AddedDual, NewDual;
	local int ExtraAmmo;
	local bool bEquipNewDual;
	local int CurrentUpgrade, NewDualUpgradeIndex;

	AddedDual = KFWeap_DualBase( AddedWeapon );

	// if AddedWeapon is dual, remove singles
	if( AddedDual != none )
	{
		foreach InventoryActors( class'KFWeapon', InvWeap )
		{
			if( InvWeap.Class == AddedDual.SingleClass )
			{
				CurrentUpgrade = InvWeap.CurrentWeaponUpgradeIndex;
				RemoveFromInventory( InvWeap );

				AddedDual.SetWeaponUpgradeLevel(CurrentUpgrade);

				// add single ammo to dual
				AddedDual.AmmoCount[0] += InvWeap.AmmoCount[0];

				// remove ammo beyond capacity to add to spare ammo
				ExtraAmmo = Max( AddedDual.AmmoCount[0] - AddedDual.default.MagazineCapacity[0], 0 );
				AddedDual.AmmoCount[0] -= ExtraAmmo;

				AddedDual.AmmoCount[1] += InvWeap.AmmoCount[1];

				AddedDual.SpareAmmoCount[0] += InvWeap.SpareAmmoCount[0] + ExtraAmmo;

				// remove spare ammo beyond capacity
				AddedDual.SpareAmmoCount[0] = Min( AddedDual.SpareAmmoCount[0], AddedDual.default.SpareAmmoCapacity[0] );

				AddedDual.ClientForceAmmoUpdate(AddedDual.AmmoCount[0],AddedDual.SpareAmmoCount[0]);
				AddedDual.ClientForceSecondaryAmmoUpdate(AddedDual.AmmoCount[1]);

				AddedDual.bGivenAtStart = AddedWeapon.bGivenAtStart;

				break;
			}
		}
	}
	else if( AddedWeapon.DualClass != none ) // AddedWeapon is single, combine with another single if possible to create dual
	{
		foreach InventoryActors( class'KFWeapon', InvWeap )
		{
			if( InvWeap != AddedWeapon && InvWeap.Class == AddedWeapon.Class )
			{
				// check instigator weapon before we remove it
				bEquipNewDual = Instigator.Weapon == InvWeap;

				// remove singles before creating dual, because this function will be called again from CreateInventory
				RemoveFromInventory( InvWeap );
				RemoveFromInventory( AddedWeapon );

				NewDual = KFWeap_DualBase( CreateInventory(AddedWeapon.DualClass, true) );
				if( NewDual != none )
				{
					// set dual ammo to combined ammo of singles
					NewDual.AmmoCount[0] = InvWeap.AmmoCount[0] + AddedWeapon.AmmoCount[0];

					// remove ammo beyond capacity to add to spare ammo
					ExtraAmmo = Max( NewDual.AmmoCount[0] - NewDual.default.MagazineCapacity[0], 0 );
					NewDual.AmmoCount[0] -= ExtraAmmo;

					NewDual.AmmoCount[1] = InvWeap.AmmoCount[1] + AddedWeapon.AmmoCount[1];

					NewDual.SpareAmmoCount[0] = Min( InvWeap.SpareAmmoCount[0] + AddedWeapon.SpareAmmoCount[0] + ExtraAmmo, NewDual.SpareAmmoCapacity[0] );

					NewDual.bGivenAtStart = AddedWeapon.bGivenAtStart;

					NewDual.ClientForceAmmoUpdate(NewDual.AmmoCount[0],NewDual.SpareAmmoCount[0]);
					NewDual.ClientForceSecondaryAmmoUpdate(NewDual.AmmoCount[1]);

					NewDualUpgradeIndex = max(InvWeap.CurrentWeaponUpgradeIndex, AddedWeapon.CurrentWeaponUpgradeIndex);
					NewDual.SetWeaponUpgradeLevel(NewDualUpgradeIndex);
					if (NewDual.CurrentWeaponUpgradeIndex > 0)
					{
						AddCurrentCarryBlocks(NewDual.static.GetUpgradeWeight(NewDual.CurrentWeaponUpgradeIndex));
						KFPawn(NewDual.Instigator).NotifyInventoryWeightChanged();
					}

					// if we've added a single and our current weapon is a similar single, then equip the dual
					if( bEquipNewDual )
					{
						SetCurrentWeapon( NewDual );
					}

					AddedWeapon = NewDual;
				}

				break;
			}
		}
	}

	return AddedWeapon;
}

/*********************************************************************************************
`* Trader
********************************************************************************************* */

// Tell the server we can no longer buy weapons
reliable server function ServerCloseTraderMenu()
{
	local int i;
	local KFWeapon KFWeap;
	local class<KFWeapon> KFWClass;

	bServerTraderMenuOpen = false;
	bSuppressPickupMessages = true;
	for(i = TransactionItems.Length - 1; i >= 0; i--)
	{
		KFWClass = class<KFWeapon>(DynamicLoadObject(TransactionItems[i].DLOString, class'Class'));
		if( KFWClass != none )
		{
			// Remove the transaction inventory blocks before trying to create the inventory
			AddCurrentCarryBlocks( -1 * (KFWClass.default.InventorySize + TransactionItems[i].AddedWeight) );
			KFWeap = KFWeapon(CreateInventory(KFWClass)); //<---- This is a problem
			if( KFWeap != none )
			{
				AddCurrentCarryBlocks(TransactionItems[i].AddedWeight); //Create inventory add the default size.  add the additional
				KFWeap.AddTransactionAmmo( TransactionItems[i].AddedAmmo[0], TransactionItems[i].AddedAmmo[1] );
				KFWeap.SetWeaponUpgradeLevel(TransactionItems[i].WeaponUpgradeLevel);
			}

	    	/* __TW_ Analytics */
			`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, KFWClass);
			`AnalyticsLog(("buy", Instigator.PlayerReplicationInfo, KFWClass));
		}

		TransactionItems.Remove(i, 1);
	}
	bSuppressPickupMessages = false;
}

/** Find out what type of ammo we are buying and ask the server for it */
simulated function final BuyAmmo( float AmountPurchased, EItemType ItemType, optional byte ItemIndex, optional bool bSecondaryAmmo )
{
	local STraderItem WeaponItem;
	local KFWeapon KFW;
	local byte MagAmmoCount;

	MagAmmoCount = 255;

	if ( ItemType == EIT_Weapon )
	{
		// get the client's ammo count and send it to server (in case they're out of sync)
		if( GetTraderItemFromWeaponLists(WeaponItem, ItemIndex) )
		{
			if( GetWeaponFromClass(KFW, WeaponItem.ClassName) )
			{
				MagAmmoCount = bSecondaryAmmo ? KFW.AmmoCount[1] : KFW.AmmoCount[0];
			}
		}

		ServerBuyAmmo(int(AmountPurchased), MagAmmoCount, ItemIndex, bSecondaryAmmo);
	}
 	else if ( ItemType == EIT_Armor )
 	{
		ServerBuyArmor(AmountPurchased);
 	}
 	else if ( ItemType == EIT_Grenade )
 	{
		ServerBuyGrenade(int(AmountPurchased));
 	}
}

/** Receive weapon ammo */
reliable server final private function ServerBuyAmmo(int AmountPurchased, byte ClientAmmoCount, byte ItemIndex, bool bSecondaryAmmo)
{
	local STraderItem WeaponItem;
	local KFWeapon KFW;
	local int ClientMaxMagCapacity;

	if( Role == ROLE_Authority && bServerTraderMenuOpen )
	{
		if( GetTraderItemFromWeaponLists(WeaponItem, ItemIndex) )
		{
			if( !ProcessAmmoDosh(WeaponItem, AmountPurchased, bSecondaryAmmo) )
			{
				return;
			}

			if( GetWeaponFromClass(KFW, WeaponItem.ClassName) )
			{
				if( bSecondaryAmmo )
				{
		    		KFW.AddSecondaryAmmo( AmountPurchased );

		    		/* __TW_ Analytics */
					`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "S.Ammo,"@KFW.class$","@AmountPurchased);
					`AnalyticsLog(("buy", Instigator.PlayerReplicationInfo, "S.ammo", KFW.class, "#"$AmountPurchased));
				}
				else
				{
					// AddAmmo takes AmmoCount into account, but AmmoCount can be out of sync between client and server,
					// so sync server with passed-in client value
					if( ClientAmmoCount != 255 )
					{
						ClientMaxMagCapacity = KFW.default.MagazineCapacity[0];
						if( KFW.GetPerk() != none )
						{
							// account for perks that potentially increase mag size, like commando
							KFW.GetPerk().ModifyMagSizeAndNumber( KFW, ClientMaxMagCapacity );
						}
						KFW.AmmoCount[0] = Clamp( ClientAmmoCount, 0, ClientMaxMagCapacity );
					}
		    		KFW.AddAmmo( AmountPurchased );

		    		/* __TW_ Analytics */
					`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "Ammo,"@KFW.class$","@AmountPurchased);
					`AnalyticsLog(("buy", Instigator.PlayerReplicationInfo, "ammo", KFW.class, "#"$AmountPurchased));
		    	}
			}
			else
			{
				// Buying ammo for weapon that is pending purchase
				ServerAddTransactionAmmo(AmountPurchased, ItemIndex, bSecondaryAmmo);
			}
		}
	}
}

/** Modifies ammo for a transaction item */
reliable server final private event ServerAddTransactionAmmo( int AmountAdded, byte ItemIndex, bool bSecondaryAmmo )
{
	local STraderItem WeaponItem;
	local byte AmmoTypeIndex;
	local int TransactionIndex;

	if( bServerTraderMenuOpen )
	{
		if( GetTraderItemFromWeaponLists(WeaponItem, ItemIndex) )
		{
			TransactionIndex = GetTransactionItemIndex(WeaponItem.ClassName);
			if( TransactionIndex != INDEX_NONE )
			{
				AmmoTypeIndex = byte(bSecondaryAmmo);
				TransactionItems[TransactionIndex].AddedAmmo[AmmoTypeIndex] += AmountAdded;

				if ( bSecondaryAmmo )
				{
					`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "S.Ammo,"@WeaponItem.ClassName$","@AmountAdded);
					`AnalyticsLog(("buy", Instigator.PlayerReplicationInfo, "S.ammo", WeaponItem.ClassName, "#"$AmountAdded));
				}
				else
				{
					`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "Ammo,"@WeaponItem.ClassName$","@AmountAdded);
					`AnalyticsLog(("buy", Instigator.PlayerReplicationInfo, "ammo", WeaponItem.ClassName, "#"$AmountAdded));
				}
			}
		}
	}
}


//buy upgrade
simulated function final BuyUpgrade(byte ItemIndex, int CurrentUpgradeLevel)
{
	local STraderItem WeaponItem;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Instigator.Owner);

	// get the client's ammo count and send it to server (in case they're out of sync)
	if (GetTraderItemFromWeaponLists(WeaponItem, ItemIndex))
	{
		KFPC.GetPurchaseHelper().AddDosh(-WeaponItem.WeaponDef.static.GetUpgradePrice(CurrentUpgradeLevel)); //client tracking
		KFPC.GetPurchaseHelper().AddBlocks(-GetDisplayedBlocksRequiredFor(WeaponItem));//remove the old weight
		KFPC.GetPurchaseHelper().AddBlocks(GetDisplayedBlocksRequiredFor(WeaponItem, CurrentUpgradeLevel + 1)); //add the new
		ServerBuyUpgrade(ItemIndex, CurrentUpgradeLevel);
	}
}

//server buy upgrade
reliable server final private function ServerBuyUpgrade(byte ItemIndex, int CurrentUpgradeLevel)
{
	local STraderItem WeaponItem;
	local KFWeapon KFW;
	local int NewUpgradeLevel;


	if (Role == ROLE_Authority && bServerTraderMenuOpen)
	{
		//is this a transation item or not?
		if (GetTraderItemFromWeaponLists(WeaponItem, ItemIndex))
		{
			if (!ProcessUpgradeDosh(WeaponItem, CurrentUpgradeLevel))
			{
				return;
			}

			NewUpgradeLevel = CurrentUpgradeLevel + 1;

			if (GetWeaponFromClass(KFW, WeaponItem.ClassName))
			{
				if (KFW != none)
				{
					KFW.SetWeaponUpgradeLevel(NewUpgradeLevel);
					if (CurrentUpgradeLevel > 0)
					{
						AddCurrentCarryBlocks(-KFW.GetUpgradeStatAdd(EWUS_Weight, CurrentUpgradeLevel));
					}

					AddCurrentCarryBlocks(KFW.GetUpgradeStatAdd(EWUS_Weight, NewUpgradeLevel));
					`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "Upgrade," @ KFW.Class $ "," @ NewUpgradeLevel);
					`AnalyticsLog(("upgrade", Instigator.PlayerReplicationInfo, "upgrade", KFW.Class, "#" $ NewUpgradeLevel));
				}
			}
			else
			{
				ServerAddTransactionUpgrade(ItemIndex, NewUpgradeLevel);
			}
		}
	}
}

reliable server final private event ServerAddTransactionUpgrade(int ItemIndex, int NewUpgradeLevel)
{
	if (bServerTraderMenuOpen)
	{
		AddTransactionUpgrade(ItemIndex, NewUpgradeLevel);
	}
}


/** Creates a new transaction item based on a trader item and adds it to transaction list */
final function AddTransactionUpgrade(int ItemIndex, int NewUpgradeLevel)
{
	local STraderItem WeaponItem;
	local int TransactionIndex;

	if (Role < ROLE_Authority || !bServerTraderMenuOpen)
	{
		return;
	}

	if (GetTraderItemFromWeaponLists(WeaponItem, ItemIndex))
	{
		TransactionIndex = GetTransactionItemIndex(WeaponItem.ClassName);
		if (TransactionIndex != INDEX_NONE)
		{
			TransactionItems[TransactionIndex].WeaponUpgradeLevel = NewUpgradeLevel;
			TransactionItems[TransactionIndex].AddedWeight = WeaponItem.WeaponUpgradeWeight[NewUpgradeLevel];
			if (NewUpgradeLevel > 0)
			{
				AddCurrentCarryBlocks(-WeaponItem.WeaponUpgradeWeight[NewUpgradeLevel-1]);
			}
			AddCurrentCarryBlocks(WeaponItem.WeaponUpgradeWeight[NewUpgradeLevel]);
			`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "Upgrade," @ WeaponItem.ClassName $ "," @ NewUpgradeLevel);
			`AnalyticsLog(("upgrade", Instigator.PlayerReplicationInfo, "upgrade", WeaponItem.ClassName, "#" $ NewUpgradeLevel));
		}
	}
}

/** Receive armor */
reliable server final private function ServerBuyArmor( float PercentPurchased )
{
	local KFPawn_Human KFP;
	local int AmountPurchased;
	local float MaxArmor;

    KFP = KFPawn_Human( Instigator );
	if( Role == ROLE_Authority && KFP != none && bServerTraderMenuOpen )
	{
		if( ProcessArmorDosh( PercentPurchased ) )
		{
			// We've passed the percent armor purchased into this function, now get the armor count
			MaxArmor = KFP.GetMaxArmor();
			AmountPurchased = FCeil( MaxArmor * (PercentPurchased / 100.0) );

		    KFP.AddArmor( AmountPurchased );

		    /* __TW_ Analytics */
			`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "Armor,"@PercentPurchased);
			// this is a bit spammy, since it buys armor in increments of '3'
			`AnalyticsLog(("buy", Instigator.PlayerReplicationInfo, "armor", "#"$PercentPurchased));
		}
	}
}

/** Receive grenades */
reliable server final private function ServerBuyGrenade( int AmountPurchased )
{
    if ( Role == ROLE_Authority && bServerTraderMenuOpen)
    {
		if(ProcessGrenadeDosh(AmountPurchased))
		{
	    	AddGrenades( AmountPurchased );

	    	/* __TW_ Analytics */
			`BalanceLog(class'KFGameInfo'.const.GBE_Buy, Instigator.PlayerReplicationInfo, "Grenades(s),"$","@AmountPurchased);
			`AnalyticsLog(("buy", Instigator.PlayerReplicationInfo, "grenades", "#"$AmountPurchased));
    	}
    }
}

/** Receive our new weapon */
reliable server final function ServerBuyWeapon( byte ItemIndex, optional byte WeaponUpgrade )
{
	local STraderItem PurchasedItem;
	local int BlocksRequired;

	// Find the weapon in the servers TraderItemList
    if (Role == ROLE_Authority && bServerTraderMenuOpen)
    {
        // Get the purchased item info using the item indicies
		if( GetTraderItemFromWeaponLists(PurchasedItem, ItemIndex) )
		{
			BlocksRequired = GetWeaponBlocks(PurchasedItem, WeaponUpgrade);
	    	if(CurrentCarryBlocks > CurrentCarryBlocks + BlocksRequired
	    		|| !ProcessWeaponDosh(PurchasedItem))
	    	{
	    		return;
	    	}

			`log("ServerBuyWeapon: Adding transaction item" @ PurchasedItem.ClassName, bLogInventory);
			AddTransactionItem( PurchasedItem, WeaponUpgrade );
		}
	}
}

/** Single location for adding/subtracting from current carry blocks */
function AddCurrentCarryBlocks( int AddAmount )
{
	CurrentCarryBlocks += AddAmount;
}

/** Creates a new transaction item based on a trader item and adds it to transaction list */
final function AddTransactionItem( const out STraderItem ItemToAdd, optional byte WeaponUpgrade )
{
	local TransactionItem NewTransactionItem;

	if( Role < ROLE_Authority || !bServerTraderMenuOpen )
	{
		return;
	}

	NewTransactionItem.ClassName = ItemToAdd.ClassName;
	NewTransactionItem.DLOString = ItemToAdd.WeaponDef.default.WeaponClassPath;
	NewTransactionItem.AddedAmmo[0] = 0;
	NewTransactionItem.AddedAmmo[1] = 0;
	NewTransactionItem.WeaponUpgradeLevel = WeaponUpgrade;

	TransactionItems.AddItem( NewTransactionItem );

	AddCurrentCarryBlocks( GetWeaponBlocks(ItemToAdd, WeaponUpgrade) );
}

/** Creates a new transaction item based on a trader item and adds it to transaction list */
reliable server final function ServerAddTransactionItem( byte ItemIndex, optional byte WeaponUpgrade)
{
	local STraderItem PurchasedItem;

	// Find the weapon in the servers TraderItemList
    if (Role == ROLE_Authority && bServerTraderMenuOpen)
    {
        // Get the purchased item info using the item indicies
		if( GetTraderItemFromWeaponLists(PurchasedItem, ItemIndex) )
		{
			AddTransactionItem( PurchasedItem, WeaponUpgrade );
		}
	}
}

/** Receive our new weapon */
reliable server final function ServerSellWeapon( byte ItemIndex )
{
	local STraderItem SoldItem;
	local int SellPrice, TransactionIndex;
	local KFWeapon KFW;
	local KFPlayerReplicationInfo KFPRI;

	// Find the weapon in the servers TraderItemList
    if (Role == ROLE_Authority && bServerTraderMenuOpen)
    {
		KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
        // Get the Sold Item info using the Item indicies
		if( KFPRI != none && GetTraderItemFromWeaponLists(SoldItem, ItemIndex) )
		{
            // If the weapon is in our inventory, sell it immediately
	    	if( GetWeaponFromClass(KFW, SoldItem.ClassName) )
	    	{
				`log("ServerSellWeapon: Calling ServerRemoveFromInventory on" @ SoldItem.ClassName, bLogInventory);
	    		SellPrice = GetAdjustedSellPriceFor(SoldItem);

				KFPRI.AddDosh(SellPrice);
		    	ServerRemoveFromInventory(KFW);
		    	KFW.Destroy();
	    	}
	    	else   // Otherwise it's a transaction item that needs to be removed
	    	{
				TransactionIndex = GetTransactionItemIndex(SoldItem.ClassName);
				`log("ServerSellWeapon: SoldItem="$SoldItem.ClassName @ "TransactionIndex="$TransactionIndex, bLogInventory);
				if( TransactionIndex != INDEX_NONE )
				{
					SellPrice = GetAdjustedSellPriceFor( SoldItem );

					KFPRI.AddDosh(SellPrice);

					`log("ServerSellWeapon: Calling RemoveTransactionItem on" @ SoldItem.ClassName, bLogInventory);
					RemoveTransactionItem( SoldItem );
				}
	    	}
		}
	}
}

/** Removes an item from the transaction list */
final function RemoveTransactionItem( const out STraderItem ItemToRemove )
{
	local int TransactionIndex;
	local int i;

	`log("RemoveTransactionItem: ItemToRemove="$ItemToRemove.ClassName, bLogInventory);
	if( Role < ROLE_Authority || !bServerTraderMenuOpen )
	{
		return;
	}

	TransactionIndex = GetTransactionItemIndex( ItemToRemove.ClassName );
	`log("RemoveTransactionItem: TransactionIndex="$TransactionIndex, bLogInventory);
	if (bLogInventory)
	{
		for (i = 0; i < TransactionItems.length; ++i)
		{
			`log("RemoveTransactionItem: TransactionItems["$i$"]="$TransactionItems[i].ClassName, bLogInventory);
		}
	}

	if( TransactionIndex != INDEX_NONE )
	{
		AddCurrentCarryBlocks( -GetDisplayedBlocksRequiredFor(ItemToRemove, TransactionItems[TransactionIndex].WeaponUpgradeLevel) );
		TransactionItems.Remove( TransactionIndex, 1 );
	}

	if (bLogInventory)
	{
		for (i = 0; i < TransactionItems.length; ++i)
		{
			`log("RemoveTransactionItem: TransactionItems["$i$"]="$TransactionItems[i].ClassName, bLogInventory);
		}
	}
}

/** Removes an item from the transaction list */
reliable server final function ServerRemoveTransactionItem( int ItemIndex )
{
	local STraderItem ItemToRemove;
	local KFWeapon InvWeap;

	if( bServerTraderMenuOpen )
	{
		if( GetTraderItemFromWeaponLists(ItemToRemove, ItemIndex) )
		{
			RemoveTransactionItem( ItemToRemove );

			// remove from inventory if necessary (like after buying a dual when owning a single)
			if( GetWeaponFromClass(InvWeap, ItemToRemove.ClassName) )
			{
				RemoveFromInventory( InvWeap );
			}
		}
	}
}

/* Gets the index of the transaction item based on the class name */
final function int GetTransactionItemIndex(name ClassName)
{
	local int i;

	for(i = TransactionItems.Length - 1; i >= 0; i--)
	{
		if( TransactionItems[i].ClassName == ClassName )
		{
			return i;
		}
	}
	return INDEX_NONE;
}

/** Get a KFWeapon from our inventory using its weapon class */
final simulated function bool GetWeaponFromClass( out KFWeapon KFW, name ClassName )
{
	local Inventory Item;
	// Skip if already in the inventory.
	for (Item = InventoryChain; Item != None; Item = Item.Inventory)
	{
		if( Item.class.name == ClassName )
		{
			KFW = KFWeapon(Item);
			return KFW != none;
		}
	}

	return false;
}

private final function bool ProcessWeaponDosh(out STraderItem PurchasedItem)
{
	local int BuyPrice;
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if( KFPRI != none )
	{
		BuyPrice = GetAdjustedBuyPriceFor( PurchasedItem );

		// Check if we can buy this weapon using the servers weapon pricing
		if(KFPRI.Score - BuyPrice >= 0)
		{
			// Deduct the purchase from our score
			KFPRI.AddDosh(-BuyPrice);
			return true;
		}
	}

	`log("Server failed to process " @PurchasedItem.ClassName, bLogInventory);
	return false;
}

private final function bool ProcessAmmoDosh(out STraderItem PurchasedItem, int AdditionalAmmo, optional bool bSecondaryAmmo)
{
	local int BuyPrice;
    local float PricePerMag, MagSize, AmmoCostScale;
	local KFPlayerReplicationInfo KFPRI;
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none)
    {
        AmmoCostScale = KFGRI.GameAmmoCostScale;
    }
    else
    {
        AmmoCostScale = 1.0;
    }

	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if( KFPRI != none )
	{
		if( bSecondaryAmmo )
		{
	    	PricePerMag = AmmoCostScale * PurchasedItem.WeaponDef.default.SecondaryAmmoMagPrice;
	    	MagSize = PurchasedItem.WeaponDef.default.SecondaryAmmoMagSize;

			BuyPrice = FCeil((PricePerMag / MagSize) * float(AdditionalAmmo));
		}
		else
		{
	    	PricePerMag = AmmoCostScale * PurchasedItem.WeaponDef.default.AmmoPricePerMag;
	    	MagSize = PurchasedItem.MagazineCapacity;

			BuyPrice = FCeil((PricePerMag / MagSize) * float(AdditionalAmmo));
		}

		// Check if we can buy this weapon using the servers weapon pricing
		if( KFPRI.Score - BuyPrice >= 0 )
		{
			// Deduct the purchase from our score
			KFPRI.AddDosh(-BuyPrice);
			return true;
		}
	}

	`log("Server failed to process " @PurchasedItem.ClassName @"Ammo", bLogInventory);
	return false;
}

private final function bool ProcessUpgradeDosh(const out STraderItem PurchasedItem, int NewUpgradeLevel)
{
	local int BuyPrice;
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;

	KFPC = KFPlayerController(Instigator.Owner);
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if (KFPC != none && KFPRI != none)
	{
		BuyPrice = PurchasedItem.WeaponDef.static.GetUpgradePrice(NewUpgradeLevel);
		if (BuyPrice <= KFPRI.Score)
		{
			KFPRI.AddDosh(-BuyPrice);
			return true;
		}
	}

	return false;
}

private final function bool ProcessGrenadeDosh(int AmountPurchased)
{
	local int BuyPrice;
	local KFGFxObject_TraderItems TraderItems;
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;

	KFPC = KFPlayerController(Instigator.Owner);
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if( KFPC != none && KFPRI != none )
	{
		TraderItems = KFGameReplicationInfo( WorldInfo.GRI ).TraderItems;
		BuyPrice = TraderItems.GrenadePrice * AmountPurchased;
		if(BuyPrice <= KFPRI.Score)
		{
			KFPRI.AddDosh(-BuyPrice);
			return true;
		}
	}

	`log("Server failed to buy grenades");
	return false;
}

private final function bool ProcessArmorDosh(float PercentPurchased)
{
	local int BuyPrice;
	local KFGFxObject_TraderItems TraderItems;
	local KFPlayerController KFPC;
	local KFPerk CurrentPerk;
	local int ArmorPricePerPercent;
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if( KFPRI != none )
	{
		TraderItems = KFGameReplicationInfo( WorldInfo.GRI ).TraderItems;
		ArmorPricePerPercent = TraderItems.ArmorPrice;

		KFPC = KFPlayerController(Instigator.Owner);
		if( KFPC != none )
		{
			CurrentPerk = KFPC.GetPerk();
			if( CurrentPerk != none )
			{
				ArmorPricePerPercent *= CurrentPerk.GetArmorDiscountMod();
			}
		}

		BuyPrice = FCeil(ArmorPricePerPercent * PercentPurchased);
		if(BuyPrice <= KFPRI.Score)
		{
			KFPRI.AddDosh(-BuyPrice);
			return true;
		}
	}

	`log("Server failed to buy armor");
	return false;
}

private final simulated function int GetWeaponUpgradeLevelFromTransactionItems(const out STraderItem TraderItem)
{
	local int i;

	for (i = 0; i < TransactionItems.length; i++)
	{
		if (TransactionItems[i].ClassName == TraderItem.ClassName)
		{
			return TransactionItems[i].WeaponUpgradeLevel;
		}
	}

	return 0;
}

private final simulated function bool GetTraderItemFromWeaponLists(out STraderItem TraderItem, byte ItemIndex )
{
	local KFGFxObject_TraderItems TraderItemsObject;

	TraderItemsObject = KFGameReplicationInfo( WorldInfo.GRI ).TraderItems;
	if( ItemIndex < TraderItemsObject.SaleItems.Length )
	{
		TraderItem = TraderItemsObject.SaleItems[ItemIndex];
		return true;
	}

	return false;
}

/** Gets buy price for trader item, adjusted for whatever we want to adjust for */
simulated function int GetAdjustedBuyPriceFor( const out STraderItem ShopItem, optional const array<SItemInformation> TraderOwnedItems )
{
	local int AdjustedBuyPrice, i;

    local KFPlayerController KFPC;
    local KFPerk CurrentPerk;
    local KFPlayerReplicationInfo KFPRI;

	AdjustedBuyPrice = ShopItem.WeaponDef.default.BuyPrice;

	// if ShopItem is a dual and we own a single already, then reduce the dual by half
	if( ShopItem.SingleClassName != '' )
	{
		// checks inventory and transaction list
		if( GetIsOwned(ShopItem.SingleClassName) )
		{
			AdjustedBuyPrice *= 0.5;
		}
		// checks trader's owned item list (only used when called from trader)
		// example case: 9mm single could be in owned list but won't be in transaction list because it can't be purchased and might not be in inventory if it was removed when purchasing dual
		else if( TraderOwnedItems.Length > 0 )
		{
			for( i = 0; i < TraderOwnedItems.Length; ++i )
			{
				if( TraderOwnedItems[i].DefaultItem.ClassName == ShopItem.SingleClassName )
				{
					AdjustedBuyPrice *= 0.5;
					break;
				}
			}
		}
	}

	// add other adjustments here

    //Adjust cost if the weapon is off-perk
    KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
    if( KFPRI != none )
    {
        KFPC = KFPlayerController(Instigator.Owner);
        if( KFPC != none )
        {
            CurrentPerk = KFPC.GetPerk();
            if( CurrentPerk != none )
            {
                if (ShopItem.AssociatedPerkClasses.Find(CurrentPerk.class) == INDEX_NONE)
                {
                    AdjustedBuyPrice *= OffPerkCostScale;
                }
            }
        }
    }

	return AdjustedBuyPrice;
}

/** Gets sell price for trader item, adjusted for whatever we want to adjust for */
simulated function int GetAdjustedSellPriceFor(
	const out STraderItem OwnedItem, optional const array<SItemInformation> TraderOwnedItems)
{
	local int AdjustedSellPrice;
	local KFWeapon OwnedWeapon;
	local TransactionItem TransactionWeapon;
	local int OwnedItemIdx, ItemUpgradeLevel;
	local float OverridenSellPriceModifier;

	if (OwnedItem.WeaponDef == class'KFWeapDef_9mm')
	{
		return 0;
	}

	OverridenSellPriceModifier = OwnedItem.WeaponDef == class'KFWeapDef_Doshinegun' ? DoshinegunSellModifier : SellPriceModifier;

	GetWeaponFromClass(OwnedWeapon, OwnedItem.ClassName);
	if( OwnedWeapon != none && OwnedWeapon.bGivenAtStart )
	{
	 	AdjustedSellPrice = OwnedItem.WeaponDef.default.BuyPrice * StartedWithWeaponPriceModifier;
	}
	else
	{
		AdjustedSellPrice = OwnedItem.WeaponDef.default.BuyPrice * OverridenSellPriceModifier;
	}

	OwnedItemIdx = TraderOwnedItems.Find('DefaultItem', OwnedItem);
	if (OwnedItemIdx != INDEX_NONE)
	{
		ItemUpgradeLevel = TraderOwnedItems[OwnedItemIdx].ItemUpgradeLevel;
	}
	else if (IsTransactionWeapon(OwnedItem.ClassName, TransactionWeapon))
	{
		ItemUpgradeLevel = TransactionWeapon.WeaponUpgradeLevel;
	}
	else if (OwnedWeapon != none)
	{
		// fallback to OwnedWeapon last, because it's only reliable for selling (not buying) online
		ItemUpgradeLevel = OwnedWeapon.CurrentWeaponUpgradeIndex;
	}

	if (ItemUpgradeLevel > 0)
	{
		AdjustedSellPrice += OwnedItem.WeaponDef.static.GetUpgradeSellPrice(ItemUpgradeLevel - 1);
	}

	// if OwnedItem is a dual, set sell price to that of a single (because we sell one single and keep one single)
	// Special case for 9mm
	if( OwnedItem.SingleClassName == 'KFWeap_Pistol_9mm')
	{
		// @todo: revisit
		// assume price of single is half the price of dual. might be better to use the actual buy price of the single,
		// but 9mm doesn't have a buy price at the moment
		AdjustedSellPrice *= 0.5;
	}

	return AdjustedSellPrice;
}

simulated function int GetAdjustedUpgradePriceFor(const out STraderItem TraderItem, int UpgradeLevel)
{
	return TraderItem.WeaponDef.static.GetUpgradePrice(UpgradeLevel);
}


simulated function bool ItemEligableForUpgrade(const out STraderItem OwnedItem)
{
	local KFWeapon WeaponToUpgrade;

	if (GetWeaponFromClass(WeaponToUpgrade, OwnedItem.ClassName))
	{
		return WeaponToUpgrade.CanUpgradeWeapon();
	}

	return false;
}

/** Modifies blocks required for the UI (e.g. in the case of dualies) */
simulated function int GetDisplayedBlocksRequiredFor( const out STraderItem ShopItem, optional int OverrideLevelValue = INDEX_NONE )
{
	local int BlocksRequired;

	BlocksRequired = GetWeaponBlocks(ShopItem, OverrideLevelValue);

	// for now, only adjust blocks required for duals, except for dual 9mm since the single 9mm doesn't require any blocks
	// display half weight of dual if player owns single
	if( !(ShopItem.SingleClassName == '' || ShopItem.SingleClassName == 'KFWeap_Pistol_9mm') && GetIsOwned(ShopItem.SingleClassName) )
	{
		BlocksRequired /= 2;
	}

	return BlocksRequired;
}

simulated function int GetWeaponBlocks(const out STraderItem ShopItem, optional int OverrideLevelValue = INDEX_NONE)
{
	local int ItemUpgradeLevel;
	local KFPlayerController KFPC;
	local Inventory InventoryItem;

	KFPC = KFPlayerController(Instigator.Owner);

	// Account for single weapon upgrade level if upgrading to dualies.
	if (ShopItem.SingleClassName != '' && OverrideLevelValue == INDEX_NONE && ClassNameIsInInventory(ShopItem.SingleClassName, InventoryItem))
	{
		ItemUpgradeLevel = KFWeapon(InventoryItem).CurrentWeaponUpgradeIndex;
	}
	else
	{
		ItemUpgradeLevel = OverrideLevelValue != INDEX_NONE ? OverrideLevelValue : KFPC.GetPurchaseHelper().GetItemUpgradeLevelByClassName(ShopItem.ClassName);
	}

	return ShopItem.BlocksRequired + (ItemUpgradeLevel > INDEX_NONE ? ShopItem.WeaponUpgradeWeight[ItemUpgradeLevel] : 0);
}

/** Check if a given class is currently "owned" (in inventory or transaction list) */
simulated function bool GetIsOwned( name ClassName )
{
	local int i;
	local Inventory Inv;

	ForEach InventoryActors(class'Inventory', Inv)
	{
		if( Inv.Class.Name == ClassName )
		{
			`log("GetIsOwned: ClassName="$ClassName @ "InventoryActors true", bLogInventory);
			return true;
		}
	}

	for( i = 0; i < TransactionItems.length; ++i )
	{
		if( TransactionItems[i].ClassName == ClassName )
		{
			`log("GetIsOwned: i="$i @ "ClassName="$ClassName @ "TransactionItems true", bLogInventory);
			return true;
		}
	}

	`log("GetIsOwned: ClassName="$ClassName @ "false", bLogInventory);
	return false;
}

/*******************************************************************************************
 * Player death
 ******************************************************************************************/

/** Overrides super so that players only drop equipped weapon on death */
simulated event DiscardInventory()
{
	local Inventory Inv;
	local KFPawn KFP;

	ForEach InventoryActors(class'Inventory', Inv)
	{
		// only drop equipped weapon on death (if it's allowed to be dropped)
		if( Instigator.Weapon != Inv )
		{
			Inv.bDropOnDeath = false;
		}
	}

	super.DiscardInventory();

	// Clear reference to Weapon
	KFP = KFPawn( Instigator );
	if( KFP != none )
	{
		KFP.MyKFWeapon = none;
	}
}

defaultproperties
{
	PendingFire(0)=0 // DEFAULT_FIREMOD
	PendingFire(1)=0 // ALTFIRE_FIREMODE / BLOCK_FIREMODE
	PendingFire(2)=0 // RELOAD_FIREMODE
	PendingFire(3)=0 // BASH_FIREMODE
	PendingFire(4)=0 // GRENADE_FIREMODE
	PendingFire(5)=0 // HEAVY_ATK_FIREMODE
	PendingFire(6)=0 // CUSTOM_FIREMODE

	bMustHoldWeapon=true
	GrenadeCount=0
	MaxCarryBlocks=15

	SellPriceModifier=0.75f
	StartedWithWeaponPriceModifier=0.5f
    OffPerkCostScale=1.f

	AmmoPickupSound=AkEvent'WW_UI_PlayerCharacter.Play_UI_Pickup_Ammo'
    ItemPickupSound=AkEvent'WW_UI_PlayerCharacter.Play_UI_Pickup_Weapon'
    ArmorPickupSound=AkEvent'WW_UI_PlayerCharacter.Play_UI_Pickup_Armor'
	SwitchFireModeEvent=AkEvent'WW_UI_PlayerCharacter.Play_WEP_ModeSwitch'

	bLogInventory=false
	DoshinegunSellModifier=0.167f
}
