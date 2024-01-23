//=============================================================================
// KFPickupFactory_Item
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 1/22/2014
//=============================================================================

class KFPickupFactory_Item extends KFPickupFactory
	placeable
	native
	nativereplication;

struct native ItemPickup
{
	/** A list of all possible weapon pickups. These classes are used to
		populate the path names but will not actually load the weapon class*/
	var() class<Inventory> 	ItemClass;

    /** Chance relative to other valid attacks (Works like AnimNodeRandom) */
	var() float 					Priority<ClampMin=0.0>;

	structdefaultproperties
	{
		Priority=1.f
	}
};

/** The list of possible pickups that could spawn from this factory */
var() array<ItemPickup> ItemPickups;

/** The name of the class we're using for armor */
var name ArmorClassName;

/** The index of the pickup we want to spawn */
var repnotify byte	PickupIndex;

cpptext
{
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
}

replication
{
	// Things the server should send to the client.
	if ( bNetDirty && (Role == ROLE_Authority) )
		PickupIndex;
}

function bool CanUsePickup()
{
	local int i;
	local bool has_armour;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo( WorldInfo.GRI );

	if (KFGRI != none && KFGRI.IsGunGameMode())
	{
		has_armour = false;

		for (i = 0 ; i < ItemPickups.Length ; i++)
		{
			if (ItemPickups[i].ItemClass.Name == ArmorClassName)
			{
				has_armour = true;
				break;
			}
		}

		if (has_armour == false)
		{
			return false;
		}
	}

	return super.CanUsePickup();
}

simulated event PreBeginPlay()
{
	local KFGameInfo KFGI;

	// For Scavenger weekly, we need to treat the factory items as non kismet items.
	KFGI = KFGameInfo( WorldInfo.Game );
	if (KFGI != none && KFGI.OutbreakEvent != none && KFGI.OutbreakEvent.ActiveEvent.bUnlimitedWeaponPickups)
	{
		if (bKismetDriven && bEnabledAtStart)
		{
			bKismetDriven=false;
		}
	}

	super.PreBeginPlay();
}

simulated event ReplicatedEvent(name VarName)
{
	super.ReplicatedEvent( VarName );
	if ( VarName == nameof(PickupIndex) )
	{
		SetPickupMesh();
	}
}

/** Overloaded to add this pickup to its proper list in the gameinfo */
simulated function InitializePickup()
{
	local KFGameInfo KFGI;

	if( bKismetDriven )
	{
		return;
	}

	KFGI = KFGameInfo( WorldInfo.Game );
	if ( KFGI != none )
	{
     	KFGI.ItemPickups.AddItem( self );
	}
}

simulated event SetInitialState()
{
    //Make sure to set the pickup weapon if we're level spawned
    if (bKismetDriven && bEnabledAtStart)
    {
        PickupIndex = ChooseWeaponPickup();
        SetPickupMesh();
    }

	super.SetInitialState();

	bScriptInitialized = true;
}

/** Pick a weapon from 'ItemPickups' and enable it in the world */
function Reset()
{
	super.Reset();
	PickupIndex = ChooseWeaponPickup();
	bNetDirty = true;
	SetPickupMesh();
}

simulated event OverridePickup()
{
	PickupIndex = ChooseWeaponPickup();
	bNetDirty=true;
	SetPickupMesh();
}

function SetRespawn()
{
	local KFGameInfo KFGI;

    //For ones that spawn in the world on timer, reset info here.
    if (bKismetDriven && bEnabledAtStart)
    {
        PickupIndex = ChooseWeaponPickup();
        SetPickupMesh();
    }
	else
	{
		KFGI = KFGameInfo( WorldInfo.Game );
		if (KFGI != none && KFGI.OutbreakEvent != none && KFGI.OutbreakEvent.ActiveEvent.bUnlimitedWeaponPickups)
		{
			StartSleeping();
			return;
		}
	}

    super.SetRespawn();
}

/** Chooses a weighted item pickup */
function int ChooseWeaponPickup()
{
	local int i, DesiredItemIdx;
	local float Weight, TotalWeight, RandomWeight;
	local array<int> IndexList;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo( WorldInfo.GRI );

	if (KFGRI != none && KFGRI.IsGunGameMode())
	{
		DesiredItemIdx = 255;
	}

	// Add up the total weight for all valid attacks
	for(i = 0; i < ItemPickups.Length; i++)
	{
		if (KFGRI != none && KFGRI.IsGunGameMode())
		{
			if (ItemPickups[i].ItemClass.Name != 'KFInventory_Armor')
			{
				continue;
			}
		}

		if ( ItemPickups[i].Priority > 0.f )
		{
			TotalWeight += ItemPickups[i].Priority;
			IndexList.AddItem(i);
		}
	}

	// If we have valid pickup to choose from
	if ( IndexList.Length > 0 && TotalWeight > 0.f )
	{
		RandomWeight = FRand();
		DesiredItemIdx = IndexList[0];

		// select a random attack based on Priority
		for(i = 0; i < (IndexList.Length - 1); i++)
		{
			Weight = ItemPickups[IndexList[i]].Priority / TotalWeight;

			if ( RandomWeight <= Weight )
			{
				break;	// finished
			}
			else
			{
				RandomWeight -= Weight;
				DesiredItemIdx = IndexList[i+1];
			}
		}
	}

	return DesiredItemIdx;
}

simulated native function GetPickupMesh(class<KFWeapon> ItemClass);

/** Use the pickups static mesh for this factory */
simulated function SetPickupMesh()
{
	local KFGameReplicationInfo KFGRI;
	
	if (PickupIndex >= ItemPickups.Length)
	{
		return;
	}

	KFGRI = KFGameReplicationInfo( WorldInfo.GRI );

	if (KFGRI != none && KFGRI.IsGunGameMode())
	{
		if (ItemPickups[PickupIndex].ItemClass.Name != ArmorClassName)
		{
			return;
		}
	}

	if (ItemPickups[PickupIndex].ItemClass.Name == ArmorClassName)
	{
		FinalizePickupMesh(StaticMeshComponent(ItemPickups[PickupIndex].ItemClass.default.PickupFactoryMesh).StaticMesh);
	}
	else
	{
		GetPickupMesh(class<KFWeapon>(ItemPickups[PickupIndex].ItemClass));
	}
}

simulated event FinalizePickupMesh(StaticMesh NewMesh)
{
	local StaticMeshComponent FactoryPickupMesh;

	FactoryPickupMesh = StaticMeshComponent(PickupMesh);
	FactoryPickupMesh.SetStaticMesh(NewMesh);
	// Reset the cull distance for the new mesh
	FactoryPickupMesh.SetCullDistance(3500);
}

/** Give the pickup or its ammo to the player */
function GiveTo( Pawn P )
{
	if (PickupIndex >= ItemPickups.Length)
	{
		return;
	}

	if ( ItemPickups[ PickupIndex ].ItemClass.Name == ArmorClassName )
	{
    	GiveArmor( P );
	}
	else
	{
     	GiveWeapon( P );
	}
}

function GiveArmor( Pawn P )
{
	local KFInventoryManager KFIM;
	KFIM = KFInventoryManager( P.InvManager );
	if (KFIM != none && KFIM.AddArmorFromPickup())
	{
  		ActivateNewPickup(P);
        PickedUpBy(P);
  
		`BalanceLog(class'KFGameInfo'.const.GBE_Pickup, P.PlayerReplicationInfo, "Armor");
		`AnalyticsLog(("pickup", P.PlayerReplicationInfo, "armor"));
	}
}

function GiveWeapon( Pawn P )
{
	local KFWeapon KFW;
	local class<Inventory> InventoryClass;
	local class<KFWeapon> KFWeaponClass;
	local KFInventoryManager KFIM;
	local Inventory Inv;
	local bool bIsSecondatyPistol;
	local bool bIs9mmInInventory;
	local bool bIsHRG93InInventory;

	// Give us the weapon if we do not have it
	InventoryClass = ItemPickups[ PickupIndex ].ItemClass;

	// Check if we have the weapon
	KFIM = KFInventoryManager( P.InvManager );

	bIsSecondatyPistol = InventoryClass.name == 'KFWeap_HRG_93R'         || 
							InventoryClass.name == 'KFWeap_HRG_93R_Dual' || 
							InventoryClass.name == 'KFWeap_Pistol_9mm'   || 
							InventoryClass.name == 'KFWeap_Pistol_Dual9mm';

	if (bIsSecondatyPistol)
	{
		bIs9mmInInventory = KFIM.Is9mmInInventory();
		bIsHRG93InInventory = KFIM.IsHRG93InInventory();
		if (!(bIs9mmInInventory && bIsHRG93InInventory))
		{
			// For HRG93R and 9mm pistols, if one of the other type is picked just give the one owned
			if (KFIM.Is9mmInInventory())
			{
				if (InventoryClass.name == 'KFWeap_HRG_93R')
				{
					InventoryClass = class<Weapon>(DynamicLoadObject(class'KfWeapDef_9mm'.default.WeaponClassPath, class'Class'));
				}
				else if (InventoryClass.name == 'KFWeap_HRG_93R_Dual')
				{
					InventoryClass = class<Weapon>(DynamicLoadObject(class'KfWeapDef_9mmDual'.default.WeaponClassPath, class'Class'));
				}
			}
			else
			{
				if(InventoryClass.name == 'KFWeap_Pistol_9mm')
				{
					InventoryClass = class<Weapon>(DynamicLoadObject(class'KFWeapDef_HRG_93R'.default.WeaponClassPath, class'Class'));
				}
				else if (InventoryClass.name == 'KFWeap_Pistol_Dual9mm')
				{
					InventoryClass = class<Weapon>(DynamicLoadObject(class'KFWeapDef_HRG_93R_Dual'.default.WeaponClassPath, class'Class'));
				}
			}
		}
	}

	foreach KFIM.InventoryActors( class'KFWeapon', KFW )
	{
		KFWeaponClass = class<KFWeapon>( InventoryClass );
		if ( KFW.class == InventoryClass )
		{
			// if this isn't a dual-wield class, then we can't carry another
			if( KFW.DualClass == none )
			{
				PlayerController(P.Owner).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_AlreadyCarryingWeapon );
				return;
			}
		}
		// if we already have the dual version of this single, then we can't carry another
		else if( KFWeaponClass != none && KFW.Class == KFWeaponClass.default.DualClass )
		{
			PlayerController(P.Owner).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_AlreadyCarryingWeapon );
			return;
		}
	}

	Inv = KFIM.CreateInventory(InventoryClass, true);

	if( Inv != none )
	{
		
        KFW = KFWeapon(Inv);
        if( KFW != none )
        {
            KFW.bGivenAtStart = true;
            KFW = KFIM.CombineWeaponsOnPickup( KFW );
            KFW.NotifyPickedUp();
		}
        ActivateNewPickup(P);
        PickedUpBy(P);

		`BalanceLog(class'KFGameInfo'.const.GBE_Pickup, P.PlayerReplicationInfo, InventoryClass);
		`AnalyticsLog(("pickup", P.PlayerReplicationInfo, InventoryClass));
	}
}

/** Activate a different pickup after the 'RespawnDelay' has finished */
function ActivateNewPickup(Pawn P)
{
	local KFGameInfo KFGI;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
	KFGI = KFGameInfo(WorldInfo.Game);
	
	if (KFGRI != none && KFGRI.IsGunGameMode())
	{
		if (ItemPickups[PickupIndex].ItemClass.Name != ArmorClassName)
		{
			return;
		}
	}

	if( bKismetDriven )
	{
		return;
	}

	if ( KFGI != none )
	{
		KFGI.EnableNewPickup( KFGI.ItemPickups, KFGI.DifficultyInfo.GetWeaponPickupInterval(KFGI.GetLivingPlayerCount()), self );
	}
}

/** Determine what kind of pickup is visible. Used for dialog. */
function bool CurrentPickupIsWeapon()
{
	if( ItemPickups.Length == 0 || ItemPickups.Length <= PickupIndex)
	{
		return false;
	}

	return ItemPickups[ PickupIndex ].ItemClass.name != ArmorClassName;
}

function bool CurrentPickupIsArmor()
{
	if( ItemPickups.Length == 0 || ItemPickups.Length <= PickupIndex)
	{
		return false;
	}

	return ItemPickups[ PickupIndex ].ItemClass.name == ArmorClassName;
}

defaultproperties
{
	PickupIndex=255

	TickGroup=TG_PostAsyncWork

	ArmorClassName=KFInventory_Armor

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'WEP_3P_AR15_9mm_MESH.Wep_AR15_Pickup'
		bCastDynamicShadow=FALSE
		CollideActors=true
		Translation=(Z=-50)
	End Object
	PickupMesh=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.S_Weapon'
	End Object

	Begin Object NAME=CollisionCylinder
		CollisionRadius=100.f
		CollisionHeight=50.f
	End Object

	bNotBased=TRUE
}
