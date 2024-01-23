//=============================================================================
// KFWeap_DualBase
//=============================================================================
// Dual weapon base class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//=============================================================================

class KFWeap_DualBase extends KFWeap_PistolBase
	native; // trader needs this to be native for now (6/10/15) so we can access SingleClass

/** Animations to play when the weapon is fired */
var(Animations) const editconst name    	LeftFireAnim;

/** Animation to play when the weapon is fired */
var(Animations) const editconst	array<name>	LeftFireSightedAnims;

/** A muzzle flash instance for left weapon */
var KFMuzzleFlash LeftMuzzleFlash;

/** Holds an offest for spawning protectile effects for left weapon */
var() vector LeftFireOffset;

/** Whether we should fire from the right-side weapon (alternates right and left fire) */
var transient bool bFireFromRightWeapon;

/** class of the single variant of this weapon */
var class<KFWeapon> SingleClass;

/*********************************************************************************************
 * @name	Animations (Using const anim names to reduce instanced data cost)
********************************************************************************************* */

/** Cached anim nodes */
var AnimNodeBlendPerBone		EmptyMagBlendNode_L;
/** array of bones to lock when out of ammo */
var array<name> 				BonesToLockOnEmpty_L;

/** Anims for ironsight and alternate ironsight mode **/
var(Animations) const editconst name IdleToIronSightAnim;
var(Animations) const editconst name IdleToIronSightAnim_Alt;
var(Animations) const editconst name IronSightToIdleAnim;
var(Animations) const editconst name IronSightToIdleAnim_Alt;
var(Animations) const editconst array<name> IdleSightedAnims_Alt;
var(Animations) const editconst name FireSightedAnim_Alt;
var(Animations) const editconst	name LeftFireSightedAnim_Alt;
var(Animations) const editconst name EquipAnimIS;
var(Animations) const editconst name EquipAnimISAlt;

var(Animations) const editconst name LeftFireLastAnim;
var(Animations) const editconst name LeftFireLastSightedAnim;
var(Animations) const editconst name FireLastSightedAnim_Alt;
var(Animations) const editconst name LeftFireLastSightedAnim_Alt;

const ReloadOneEmptyAnim = 'Reload_Empty_Half';
const ReloadOneEmptyEliteAnim = 'Reload_Empty_Half_Elite';

/*********************************************************************************************
 * @name	Revolver vars
********************************************************************************************* */

var CylinderRotationInfo CylinderRotInfo_L;

cpptext
{
	virtual void PreBeginPlay();
	virtual void RefreshSkinItemId();

	// cylinder is incrementally rotated
	virtual void TickSpecial( FLOAT DeltaSeconds );
};

/** Cache Anim Nodes from the tree
* 	@note: skipped on server because AttachComponent/AttachWeaponTo is not called
*/
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	local KFGameEngine KFGEngine;
	super.PostInitAnimTree( SkelComp );

	EmptyMagBlendNode_L = AnimNodeBlendPerBone(SkelComp.FindAnimNode('EmptyMagBlend_L'));
	if( EmptyMagBlendNode_L != none && BonesToLockOnEmpty_L.Length > 0 )
	{
		BuildEmptyMagNodeWeightList( EmptyMagBlendNode_L, BonesToLockOnEmpty_L );
	}

	KFGEngine = KFGameEngine(Class'KFGameEngine'.static.GetEngine());

	if(KFGEngine != none)
	{
		bUseAltFireMode = KFGEngine.bUseAltAimOnDual;
	}

	if( !bRevolver )
	{
		return;
	}

	CylinderRotInfo_L.Control = SkelControlSingleBone( SkelComp.FindSkelControl('CylinderControl_L') );
	if( CylinderRotInfo_L.Control != none )
	{
		CylinderRotInfo_L.Control.SetSkelControlActive( true );
	}
}

/**
 * Called on a client, this function Attaches the WeaponAttachment
 * to the Mesh.
 *
 * Overridden to attach LeftMuzzleFlash
 */
simulated function AttachMuzzleFlash()
{
	super.AttachMuzzleFlash();

	if ( MySkelMesh != none )
	{
		if (MuzzleFlashTemplate != None)
		{
			LeftMuzzleFlash = new(self) Class'KFMuzzleFlash'(MuzzleFlashTemplate);
			LeftMuzzleFlash.AttachMuzzleFlash(MySkelMesh, 'MuzzleFlash_L', 'ShellEject_L');
		}
	}
}

/*********************************************************************************************
 * State Active
 * A Weapon this is being held by a pawn should be in the active state.  In this state,
 * a weapon should loop any number of idle animations, as well as check the PendingFire flags
 * to see if a shot has been fired.
 *********************************************************************************************/
simulated state Active
{
	simulated function ZoomIn(bool bAnimateTransition, float ZoomTimeToGo)
	{
		GotoState('ActiveIronSights');
	}

	simulated function PlayIdleAnim()
	{
		local int IdleIndex;

		if ( Instigator.IsFirstPerson() )
		{
			if( bUsingSights && IdleSightedAnims.Length > 0 )
			{
				if( bUseAltFireMode )
				{
					IdleIndex = Rand(IdleSightedAnims_Alt.Length);
					PlayAnimation(IdleSightedAnims_Alt[IdleIndex], 0.0, true, 0.1);
				}
				else
				{
					IdleIndex = Rand(IdleSightedAnims.Length);
					PlayAnimation(IdleSightedAnims[IdleIndex], 0.0, true, 0.1);
				}
			}
			else if ( IdleAnims.Length > 0 )
			{
				IdleIndex = Rand(IdleAnims.Length);
				PlayAnimation(IdleAnims[IdleIndex], 0.0, true, 0.2);
			}

			StartIdleFidgetTimer();
			ToggleAdditiveBobAnim(!bUsingSights);
		}
	}

	simulated function bool CanPlayIdleFidget(optional bool bOnReload)
	{
		// Make sure we can't play idle fidget if one of the pistols is empty.
		if(AmmoCount[0] < 2)
		{
			return false;
		}

		return Super.CanPlayIdleFidget(bOnReload);
	}
}

/*********************************************************************************************
 * State WeaponEquipping
 * The Weapon is in this state while transitioning from Inactive to Active state.
 * Typically, the weapon will remain in this state while its selection animation is being played.
 * While in this state, the weapon cannot be fired.
*********************************************************************************************/

/** Get equip anim name (overridden as necessary) */
simulated function name GetEquipAnimName()
{
	// since duals use anims to get into / out of iron sights,
	// we need to play equip anims that blend to iron sight idle (including alt iron)
	if( bIronSightOnBringUp )
	{
		return bUseAltFireMode ? EquipAnimISAlt : EquipAnimIS;
	}
	else
	{
		return EquipAnim;
	}
}

/*********************************************************************************************
 * State ActiveIronSights
 * Only duals play an animation when transitioning to or from iron sights, but this animation
 * should only be played in the "Active" state. This state allows us to encapsulate this
 * functionality.
 *********************************************************************************************/
simulated state ActiveIronSights extends Active
{
	simulated function ZoomOut(bool bAnimateTransition, float ZoomTimeToGo)
	{
		local name IronToIdleAnimName;

		IronToIdleAnimName = GetIronToIdleAnim();

		ZoomTimeToGo = MySkelMesh.GetAnimLength(IronToIdleAnimName);

		Global.ZoomOut( true, ZoomTimeToGo );

		PlayAnimation( IronToIdleAnimName, ZoomTime, false );

		GotoState('Active');
	}

	simulated function BeginState( Name PreviousStateName )
	{
		local float ZoomTimeToGo;
		local name IdleToIronAnimName;

		IdleToIronAnimName = GetIdleToIronAnim();

		ZoomTimeToGo = MySkelMesh.GetAnimLength(IdleToIronAnimName);

		Global.ZoomIn( true, ZoomTimeToGo );

		PlayAnimation( IdleToIronAnimName, ZoomTime, false );
	}
}

/** Gets idle-to-iron anim with regard to "stance" (toggle by alt fire) */
simulated function name GetIdleToIronAnim()
{
	return bUseAltFireMode ? IdleToIronSightAnim_Alt : IdleToIronSightAnim;
}

/** Gets iron-to-idle anim with regard to "stance" (toggle by alt fire) */
simulated function name GetIronToIdleAnim()
{
	return bUseAltFireMode ? IronSightToIdleAnim_Alt : IronSightToIdleAnim;
}

/*********************************************************************************************
 * State WeaponSingleFiring
 * Fire must be released between every shot.
 *
 * Overridden to alternate between right and left fire before calculated muzzle positions, etc.
 *********************************************************************************************/
simulated state WeaponSingleFiring
{
	simulated function FireAmmunition()
    {
    	bFireFromRightWeapon = !bFireFromRightWeapon;
        Super.FireAmmunition();
	}
}

/*********************************************************************************************
 * State Reloading
 * This is the default Reloading State.  It's performed on both the client and the server.
 *
 * Overridden to reset our alternating weapon fire
 *********************************************************************************************/
simulated state Reloading
{
	simulated function BeginState(name PreviousStateName)
	{
		super.BeginState( PreviousStateName );
		bFireFromRightWeapon = false;

		if( bRevolver )
		{
			ResetCylinderLeft();
		}
	}

	simulated function byte GetWeaponStateId()
	{
		local KFPerk Perk;
		local bool bTacticalReload;

		Perk = GetPerk();
		bTacticalReload = (Perk != None && Perk.GetUsingTactialReload(self));

		if( AmmoCount[0] == 1 )
		{
			return bTacticalReload ? WEP_ReloadDualsOneEmpty_Elite : WEP_ReloadDualsOneEmpty;
		}

		return super.GetWeaponStateId();
	}
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName( bool bTacticalReload )
{
	if( AmmoCount[0] == 1 )
	{
		// if one gun is empty (always the right), play our half empty reload
		return bTacticalReload ? ReloadOneEmptyEliteAnim : ReloadOneEmptyAnim;
	}
	else
	{
		return super.GetReloadAnimName( bTacticalReload );
	}
}

/**
 * Increment Pawn's FlashCount variable.
 * This is used to play weapon fire effects on remote clients.
 * Call this on the server and local player.
 *
 * Network: Server and Local Player
 *
 * COMPLETELY OVERRIDDEN to set FlashCount to an even number for left fire.
 * Also copies implementation of Pawn::IncrementFlashCount (usually called from super)
 */
simulated function IncrementFlashCount()
{
	if( Instigator != none )
	{
		if( Instigator.FlashCount > 0 || bFireFromRightWeapon )
		{
			Instigator.FlashCount += 1;
		}
		else
		{
			Instigator.FlashCount += 2;
		}

		//// BEGIN PAWN.INCREMENTFLASHCOUNT
		Instigator.SetFiringMode( Self, CurrentFireMode );

		// This weapon has fired.
		Instigator.FlashCountUpdated( Self, Instigator.FlashCount, FALSE );
		//// END PAWN.INCREMENTFLASHCOUNT
	}
}

/** Return true if this weapon should play the fire last animation for this shoot animation */
simulated function bool ShouldPlayFireLast(byte FireModeNum)
{
	if ( bHasFireLastAnims )
	{
		if( bFireFromRightWeapon )
		{
			if( (!bAllowClientAmmoTracking && Role < ROLE_Authority && AmmoCount[GetAmmoType(FireModeNum)] <= 2)
				|| ((bAllowClientAmmoTracking || Role == ROLE_Authority) && AmmoCount[GetAmmoType(FireModeNum)] == 1) )
			{
				return true;
			}
		}
		else
		{
			if( (!bAllowClientAmmoTracking && Role < ROLE_Authority && AmmoCount[GetAmmoType(FireModeNum)] <= 1)
				|| ((bAllowClientAmmoTracking || Role == ROLE_Authority) && AmmoCount[GetAmmoType(FireModeNum)] == 0) )
			{
				return true;
			}
		}
	}

    return false;
}

/** Get name of the animation to play for PlayFireEffects
  *
  * Overridden to allow for left weapon anims
  */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	local bool bPlayFireLast;

    bPlayFireLast = ShouldPlayFireLast(FireModeNum);

	if( bFireFromRightWeapon )
	{
		if ( bUsingSights )
		{
			if( bPlayFireLast )
			{
				return bUseAltFireMode ? FireLastSightedAnim_Alt : FireLastSightedAnim;
			}
			else
			{
				return bUseAltFireMode ? FireSightedAnim_Alt : FireSightedAnims[Rand(LeftFireSightedAnims.Length)];
			}
		}
		else
		{
			if( bPlayFireLast )
			{
				return FireLastAnim;
			}
			else
			{
				return FireAnim;
			}
		}
	}
	else
	{
		return GetLeftWeaponFireAnim(FireModeNum, bPlayFireLast);
	}
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLeftWeaponFireAnim(byte FireModeNum, bool bPlayFireLast)
{
	// ironsights animations
	if ( bUsingSights )
	{
		if( bPlayFireLast )
		{
			return bUseAltFireMode ?  LeftFireLastSightedAnim_Alt : LeftFireLastSightedAnim;
		}
		else
		{
			return bUseAltFireMode ?  LeftFireSightedAnim_Alt : LeftFireSightedAnims[Rand(LeftFireSightedAnims.Length)];
		}
	}
	else
	{
		if( bPlayFireLast )
		{
			return LeftFireLastAnim;
	}
	else
	{
		return LeftFireAnim;
	}
	}
}

/**
 * This function returns the world location for spawning the visual effects
 *
 * Overridden to allow for left weapon location
 */
simulated event vector GetMuzzleLoc()
{
	if( bFireFromRightWeapon )
	{
		return super.GetMuzzleLoc();
	}
	else
	{
		return GetLeftMuzzleLoc();
	}
}

/**
 * This function returns the world location for spawning the visual effects.
 * Uses both X and Y position of LeftFireOffset.
 */
simulated event vector GetLeftMuzzleLoc()
{
    local Rotator ViewRotation;

	if( Instigator != none )
	{
            ViewRotation = Instigator.GetViewRotation();

        	// Add in the free-aim rotation
        	if ( KFPlayerController(Instigator.Controller) != None )
        	{
        		ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;
        	}

        if( bUsingSights )
        {
            return Instigator.GetWeaponStartTraceLocation() + (LeftFireOffset >> ViewRotation);
		}
		else
		{
            return Instigator.GetPawnViewLocation() + (LeftFireOffset >> ViewRotation);
		}

	}

	return Location;
}

/**
 * Causes the muzzle flash to turn on and setup a time to
 * turn it back off again.
 *
 * Overridden to cause left weapon flash
 */
simulated function CauseMuzzleFlash(byte FireModeNum)
{
	if( MuzzleFlash == None || LeftMuzzleFlash == None )
	{
		AttachMuzzleFlash();
	}

	if( bFireFromRightWeapon )
	{
		if (MuzzleFlash != None )
		{
			MuzzleFlash.CauseMuzzleFlash(FireModeNum);
			if ( MuzzleFlash.bAutoActivateShellEject )
			{
				MuzzleFlash.CauseShellEject();
			}
		}
	}
	else
	{
		if( LeftMuzzleFlash != None )
		{
			LeftMuzzleFlash.CauseMuzzleFlash( FireModeNum );
			if( LeftMuzzleFlash.bAutoActivateShellEject )
			{
				LeftMuzzleFlash.CauseShellEject();
			}
		}
	}
}

/**
 * Remove/Detach the muzzle flash components
 */
simulated function DetachMuzzleFlash()
{
	super.DetachMuzzleFlash();

	if (MySkelMesh != none && LeftMuzzleFlash != None)
	{
		LeftMuzzleFlash.DetachMuzzleFlash(MySkelMesh);
		LeftMuzzleFlash = None;
	}
}

/**
 * Adjust the FOV for the first person weapon and arms.
 */
simulated event SetFOV( float NewFOV )
{
	super.SetFOV( NewFOV );

	if( LeftMuzzleFlash != none )
	{
		LeftMuzzleFlash.SetFOV( NewFOV );
	}
}

simulated function StopFireEffects(byte FireModeNum)
{
	super.StopFireEffects( FireModeNum );

	if (LeftMuzzleFlash != None)
	{
        LeftMuzzleFlash.StopMuzzleFlash();
	}
}

/** Returns ID of muzzle to spawn projectile at / play effects at
  * Overrides super
  */
simulated function byte GetCurrentMuzzleID()
{
	return bFireFromRightWeapon ? 0 : 1;
}

/** Overridden to spawn a single and set the pickup class to single */
function SetupDroppedPickup( out DroppedPickup P, vector StartVelocity )
{
	local KFWeapon NewSingle;
	local KFInventoryManager KFIM;
	local vector X,Y,Z;
	local int NewSingleUpgradeIndex;
	local int SingleSpareAmmoCount;

	// For now, force the dropped single to be un-upgraded by setting this dual's upgrade index to 0.
	// But remember what the upgrade index was so we can give the player a correctly upgraded single.
	// SetWeaponUpgradeLevel(0) must be called before the super, because the pickup mesh is set there.
	NewSingleUpgradeIndex = CurrentWeaponUpgradeIndex;
	SetWeaponUpgradeLevel(0);

	super.SetupDroppedPickup( P, StartVelocity );

	if( Instigator != None && Instigator.InvManager != None )
	{
		KFIM = KFInventoryManager( Instigator.InvManager );
		KFIM.bSuppressPickupMessages = true;
		KFIM.bInfiniteWeight = true; // force CanCarryWeapon() to succeed
		NewSingle = KFWeapon( KFIM.CreateInventory(SingleClass, true) );
		KFIM.bInfiniteWeight = false;
		KFIM.bSuppressPickupMessages = false;
	}

	if( NewSingle != none )
	{
		// divide ammo between make sure we don't lose a round due to truncation.
		NewSingle.AmmoCount[0] = (AmmoCount[0] & 1) == 0 ? (AmmoCount[0] / 2) : (AmmoCount[0] / 2) + 1;
		AmmoCount[0] /= 2;

		SingleSpareAmmoCount = Min(SpareAmmoCount[0], NewSingle.SpareAmmoCapacity[0]);

		NewSingle.SpareAmmoCount[0] = SingleSpareAmmoCount;
		SpareAmmoCount[0] -= SingleSpareAmmoCount;

		// tell client about our modification
		NewSingle.ClientForceAmmoUpdate(NewSingle.AmmoCount[0],NewSingle.SpareAmmoCount[0]);
		NewSingle.ClientForceSecondaryAmmoUpdate(NewSingle.AmmoCount[1]);

		NewSingle.SetWeaponUpgradeLevel(NewSingleUpgradeIndex);
		if(NewSingleUpgradeIndex > 0)
		{
			KFInventoryManager(InvManager).AddCurrentCarryBlocks(NewSingle.static.GetUpgradeWeight(NewSingleUpgradeIndex));
			KFPawn(Instigator).NotifyInventoryWeightChanged();
		}

		NewSingle.bGivenAtStart = bGivenAtStart;

		// Drop second gun on death
		if( Instigator.bPlayedDeath || Instigator.Health <= 0 )
		{
			GetAxes( Instigator.Rotation, X,Y,Z );
			NewSingle.DropFrom( P.Location + Y*20, StartVelocity*(1.f + fRand()*0.1f) );
		}
		else
		{
			Instigator.InvManager.SetCurrentWeapon( NewSingle );
		}
	}

	P.InventoryClass = SingleClass;
}

/*********************************************************************************************
 * @name	Ammo
********************************************************************************************* */

// /** Performs actual ammo reloading */
simulated function PerformReload(optional byte FireModeNum)
{
	super.PerformReload(FireModeNum);

	if( !bRevolver )
	{
		return;
	}

	// reset cylinder rotation
	CylinderRotInfo_L.PrevDegrees = 0;
	CylinderRotInfo_L.NextDegrees = 0;
}

/** Locks the bolt bone in place to the open position (Called by animnotify)
  * Completely overrides super to pick which bolt to lock back
  */
simulated function ANIMNOTIFY_LockBolt()
{
	UpdateOutOfAmmoEffects(0.f);
}

/** Unlocks the bolt bone (Called by animnotify) */
simulated function ANIMNOTIFY_UnLockBolt()
{
	super.ANIMNOTIFY_UnLockBolt();
	EmptyMagBlendNode_L.SetBlendTarget(0, 0);
}

/** Check AmmoCount and update anim tree nodes if needed */
simulated function UpdateOutOfAmmoEffects(float BlendTime)
{
	if ( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	if( EmptyMagBlendNode != None )
	{
		// Differentiate Left/Right
		if ( bAllowClientAmmoTracking && AmmoCount[0] <= 1 )
		{
			EmptyMagBlendNode.SetBlendTarget(1, 0);
			if ( AmmoCount[0] == 0 )
			{
				EmptyMagBlendNode_L.SetBlendTarget(1,0);
			}
		}
	}
}

/*********************************************************************************************
 * @name	Revolver
********************************************************************************************* */

simulated event PostInitAnimTreeRevolver( SkeletalMeshComponent SkelComp )
{
	super.PostInitAnimTreeRevolver( SkelComp );

	CylinderRotInfo_L.Control = SkelControlSingleBone( SkelComp.FindSkelControl('CylinderControl') );
	if( CylinderRotInfo_L.Control != none )
	{
		CylinderRotInfo_L.Control.SetSkelControlActive( true );
	}
}

simulated function ConsumeAmmoRevolver()
{
	// no super

	if( bFireFromRightWeapon )
	{
		CheckCylinderRotation( CylinderRotInfo_L );
		CylinderRotInfo.State = CYLINDERSTATE_PENDING;
	}
	else
	{
		CheckCylinderRotation( CylinderRotInfo );
		CylinderRotInfo_L.State = CYLINDERSTATE_PENDING;
	}
}

/** Initiate cylinder rotation (rotation occurs in tickspecial in native) */
simulated function ANIMNOTIFY_RotateCylinder()
{
	if( bFireFromRightWeapon )
	{
		super.ANIMNOTIFY_RotateCylinder();
		return;
	}

	RotateCylinder( CylinderRotInfo_L );
}

simulated function InitializeReload()
{
	// call kfweapon super so we don't rotate the other cylinder too
	super(KFWeapon).InitializeReload();
	CheckCylinderRotation( CylinderRotInfo_L, true );
}

simulated function ANIMNOTIFY_ResetBulletMeshesLeft()
{
	ResetBulletMeshesLeft();
}

/** Resets cylinder orientation to initial state and repositions bullet meshes to line up with their pre-reset locations */
simulated function ResetCylinder()
{
	local int UsedStartIdx, UsedEndIdx, UsedBullets;

	// reset cylinder rotation
	SetCylinderRotation( CylinderRotInfo, 0 );
	ResetCylinderInfo( CylinderRotInfo );

	// now, we need to make sure the used bullets are still in the correct positions

	// if we fired all our ammo, it doesn't matter where the bullets are, because they're all the same (used)
	if( AmmoCount[DEFAULT_FIREMODE] <= 1 )
	{
		return;
	}

	// find the range of bullets that have been used
	UsedStartIdx = BulletMeshComponents.Length - 2;
	UsedBullets = FCeil( float(MagazineCapacity[DEFAULT_FIREMODE] - AmmoCount[DEFAULT_FIREMODE]) / 2.f );
	UsedEndIdx = UsedStartIdx - UsedBullets * 2;

	RepositionUsedBullets( 0, UsedStartIdx, UsedEndIdx );
}

/** Resets cylinder orientation to initial state and repositions bullet meshes to line up with their pre-reset locations */
simulated function ResetCylinderLeft()
{
	local int UsedStartIdx, UsedEndIdx, UsedBullets;

	// reset cylinder rotation (skel control needs to be reset to initial state while bullet casings are not on screen)
	SetCylinderRotation( CylinderRotInfo_L, 0 );
	ResetCylinderInfo( CylinderRotInfo_L );

	// now, we need to make sure the used bullets are still in the correct positions

	// if we fired all our ammo, it doesn't matter where the bullets are, because they're all the same (used)
	if( AmmoCount[DEFAULT_FIREMODE] <= 0 )
	{
		return;
	}

	// find the range of bullets that have been used
	UsedStartIdx = BulletMeshComponents.Length - 1;
	UsedBullets = FFloor( float(MagazineCapacity[DEFAULT_FIREMODE] - AmmoCount[DEFAULT_FIREMODE]) / 2.f );
	UsedEndIdx = UsedStartIdx - UsedBullets * 2;

	RepositionUsedBullets( 1, UsedStartIdx, UsedEndIdx );
}

/** Sets correct bullet mesh (used/unused) in each slot after resetting cylinder */
simulated function RepositionUsedBullets( int FirstIndex, int UsedStartIdx, int UsedEndIdx )
{
	local int i;

	if (BulletMeshComponents.length == 0)
	{
		return;
	}

	if(FirstIndex >= 0 && FirstIndex < BulletMeshComponents.length)
	{
		// after cylinder reset, top-most bullet will be unused
		BulletMeshComponents[FirstIndex].SetSkeletalMesh( UnusedBulletMeshTemplate );
	}
	else
	{
		`warn(self @ "-" @ GetFuncName() @ "- First Index is out of bounds - FirstIndex:" @ FirstIndex @ "BulletMeshComponents.Length:" @ BulletMeshComponents.length);
	}

	// set used bullets to used mesh
	for( i = UsedStartIdx; i > UsedEndIdx; i-=2 )
	{
		if(i >= 0 && i < BulletMeshComponents.length)
		{
			BulletMeshComponents[i].SetSkeletalMesh( UsedBulletMeshTemplate );
		}
	}

	// set the rest of the bullets to unused
	for( i = UsedEndIdx; i > FirstIndex; i-=2 )
	{
		if (i >= 0 && i < BulletMeshComponents.length)
		{
			BulletMeshComponents[i].SetSkeletalMesh( UnusedBulletMeshTemplate );
		}
	}
}

/** Sets all bullet casing meshes back to unused state */
simulated function ResetBulletMeshes()
{
	local int i;

	for( i = 0; i < BulletMeshComponents.Length; i+=2 )
	{
		BulletMeshComponents[i].SetSkeletalMesh( UnusedBulletMeshTemplate );
	}
}

/** Sets all bullet casing meshes back to unused state */
simulated function ResetBulletMeshesLeft()
{
	local int i;

	for( i = 1; i < BulletMeshComponents.Length; i+=2 )
	{
		BulletMeshComponents[i].SetSkeletalMesh( UnusedBulletMeshTemplate );
	}
}

/*********************************************************************************************
 * State WeaponPuttingDown
 * Putting down weapon in favor of a new one.
 * Weapon is transitioning to the Inactive state.
*********************************************************************************************/

simulated state WeaponPuttingDown
{
	simulated function EndState(Name NextStateName)
	{
		super.EndState( NextStateName );
		CheckCylinderRotation( CylinderRotInfo_L, true );
	}
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Trader
//
///////////////////////////////////////////////////////////////////////////////////////////

/** Adds ammo to (or subtracts ammo from) the trader transaction single that gets created when selling a dual */
native simulated function AddAmmoToSingleOnSell( KFInventoryManager KFIM, int DefaultSingleAmmo, int TraderItemIndex );

/*********************************************************************************************
 * @name	Firing / Projectile
********************************************************************************************* */
/**
 * @brief Checks if weapon should be auto-reloaded - overwritten to allow gunslinger insta switch
 *
 * @param FireModeNum Current fire mode
 * @return auto reload or not
 */
simulated function bool ShouldAutoReload( byte FireModeNum )
{
	return ShouldAutoReloadGunslinger( FireModeNum );
}

/**
 * Toggle between DEFAULT and ALTFIRE
 */
simulated function AltFireMode()
{
	super.AltFireMode();
	PlayIdleAnim();
}

/**
 * @see Weapon::StartFire
 */
simulated function StartFire(byte FireModeNum)
{
	// These weapons only have a mode toggle, so if we have alt-fire
	// bound (e.g. gamepad, custom bindings) then perform the  toggle
	if( FireModeNum == ALTFIRE_FIREMODE )
	{
		AltFireMode();
		return;
	}

	Super.StartFire(FireModeNum);
}

function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	if (ItemClass == class || ItemClass == SingleClass)
	{
		return DenyPickupQuery_Internal(ItemClass, Pickup);
	}

	return false;
}

defaultproperties
{
	InventoryGroup=IG_Primary

	Begin Object Name=FirstPersonMesh
		AnimTreeTemplate=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Dual_Animtree_Master'
	End Object

	bSkipZoomInRotation=true

	BonesToLockOnEmpty_L=(LW_Bolt)

	// Animations
	FireAnim=Shoot_RW
	LeftFireAnim=Shoot_LW

	IdleSightedAnims=(Idle_IronOG)
	FireSightedAnims=(Shoot_IronOG_RW)
	LeftFireSightedAnims=(Shoot_IronOG_LW)
	IdleToIronSightAnim=Idle_To_IronOG
	IronSightToIdleAnim=IronOG_To_Idle
	EquipAnimIS=Equip_IronOG
	// IdleSightedAnims=(Idle_Iron)
	// FireSightedAnims=(Shoot_Iron_RW)
	// LeftFireSightedAnims=(Shoot_Iron_LW)
	// IdleToIronSightAnim=Idle_To_Iron
	// IronSightToIdleAnim=Iron_To_Idle
	// EquipAnimIS=Equip_Iron

	IdleSightedAnims_Alt=(Idle_Iron)
	FireSightedAnim_Alt=Shoot_Iron_RW
	LeftFireSightedAnim_Alt=Shoot_Iron_LW
	IdleToIronSightAnim_Alt=Idle_To_Iron
	IronSightToIdleAnim_Alt=Iron_To_Idle
	EquipAnimISAlt=Equip_Iron
	// IdleSightedAnims_Alt=(Idle_IronOG)
	// FireSightedAnim_Alt=Shoot_IronOG_RW
	// LeftFireSightedAnim_Alt=Shoot_IronOG_LW
	// IdleToIronSightAnim_Alt=Idle_To_IronOG
	// IronSightToIdleAnim_Alt=IronOG_To_Idle
	// EquipAnimISAlt=Equip_IronOG

	FireLastAnim=Shoot_RW_Last
	LeftFireLastAnim=Shoot_LW_Last
	FireLastSightedAnim=Shoot_IronOG_RW_Last
	LeftFireLastSightedAnim=Shoot_IronOG_LW_Last
	FireLastSightedAnim_Alt=Shoot_Iron_RW_Last
	LeftFireLastSightedAnim_Alt=Shoot_Iron_LW_Last

	// DEFAULT_FIREMODE
	FireModeIconPaths[DEFAULT_FIREMODE]=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	FireInterval(DEFAULT_FIREMODE)=+1.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic'
	InstantHitMomentum(DEFAULT_FIREMODE)=1.0
	PenetrationPower(DEFAULT_FIREMODE)=0.0
	PenetrationDamageReductionCurve(DEFAULT_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f)))

	//ALTFIRE_FIREMODE
	FireModeIconPaths[ALTFIRE_FIREMODE]=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	FireInterval(ALTFIRE_FIREMODE)=+1.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic'
	InstantHitMomentum(ALTFIRE_FIREMODE)=1.0
	PenetrationPower(ALTFIRE_FIREMODE)=0.0
	PenetrationDamageReductionCurve(ALTFIRE_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f)))
}
