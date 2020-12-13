//=============================================================================
// KFPawn_Customization
//=============================================================================
// Customization pawn, allows previewing characters before play
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_Customization extends KFPawn_Human
	native(Pawn);

struct native sReplicatedMovementData
{
	var vector NewLocation;
	var rotator NewRotation;
};

var bool bPlayingEmote;

/** Post-spawn replicated location (we skip actor property replication, this allows us to update after spawn) */
var repnotify sReplicatedMovementData ReplicatedMovementData;

/** Post-spawn replicated hidden status, controlled by the server */
var repnotify bool bServerHidden;

/** Local hidden variable, OR'd with bServerHidden */
var bool bLocalHidden;

var AnimSet MaleCustomizationAnimSet;
var AnimSet FemaleCustomizationAnimSet;

var bool bUsingCustomizationPoint; // This is true if we have been placed on a KFCustomizationPoint

cpptext
{
	virtual UBOOL IsAliveAndWell() const;
	virtual void PostNetReceiveLocation();
    UBOOL SetDesiredRotation( FRotator TargetDesiredRotation,UBOOL InLockDesiredRotation=FALSE,UBOOL InUnlockWhenReached=FALSE,FLOAT InterpolationTime=-1.000000,UBOOL bResetRotationRate=TRUE );
}

replication
{
	if( bNetInitial || bNetDirty )
		ReplicatedMovementData, bServerHidden;
}

/** Updates visiblity of surrounding customization pawns so that none overlap */
native function UpdateCustomizationPawnVisibility();

/** Updates location and rotation on client */
simulated event ReplicatedEvent( name VarName )
{
	if( VarName == nameOf(ReplicatedMovementData) )
	{
		OnMovementDataUpdated();
	}
	else if( VarName == nameOf(bServerHidden) )
	{
		SetHidden( bServerHidden || bLocalHidden );
		UpdateCustomizationPawnVisibility();
	}
	else
	{
		super.ReplicatedEvent( VarName );
	}
}

/** Sets our post-spawn location and rotation */
function SetUpdatedMovementData( vector NewLoc, rotator NewRot )
{
	ReplicatedMovementData.NewLocation = NewLoc;
	ReplicatedMovementData.NewRotation = NewRot;

	// Set directly on listen server
	OnMovementDataUpdated();

	// Update on network immediately
	bForceNetUpdate = true;
}

/** Sets our updated movement data on client/listen server */
simulated function OnMovementDataUpdated()
{
	SetLocation( ReplicatedMovementData.NewLocation );
	SetRotation( ReplicatedMovementData.NewRotation );

	// Update visibility on listen server/clients
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		UpdateCustomizationPawnVisibility();
	}
}

/** Sets the server-controlled hidden status (we only care about bServerHidden=true) */
function SetServerHidden( bool bNewHidden )
{
	bServerHidden = bNewHidden;

	// Set directly on listen server
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// Only hide if the server tells us to
		SetHidden( bServerHidden || bLocalHidden );
		UpdateCustomizationPawnVisibility();
	}

	// Update on network immediately
	bForceNetUpdate = true;
}

/** Overridden, we don't want anything to stomp on SetUpdatedMovementData() */
function ClientSetRotation( rotator NewRotation ) {}
simulated function FaceRotation(rotator NewRotation, float DeltaTime) {}

/*********************************************************************************************
Initialization
********************************************************************************************* */
/** Disable foot IK */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	// Disable foot IK so we have have straight legs for this character.  When
	// bAllowStretching is set the knees must be bent a little.
	if ( IKFootLeft != None )
	{
		IKFootLeft.SetSkelControlActive(false);
	}
	if ( IKFootRight != None )
	{
		IKFootRight.SetSkelControlActive(false);
	}

    SetHeadScale(IntendedHeadScale, CurrentHeadScale);
}

/** Always use the customization anim set */
simulated function SetCharacterAnimationInfo()
{
	local KFCharacterInfo_Human CharInfoHuman;

 	super.SetCharacterAnimationInfo();

	// Character Animation
	CharInfoHuman = KFCharacterInfo_Human( GetCharacterInfo() );
	if( CharInfoHuman != none && CharInfoHuman.bIsFemale )
	{
		Mesh.AnimSets.AddItem(FemaleCustomizationAnimSet);
	}
	else
	{
    	Mesh.AnimSets.AddItem(MaleCustomizationAnimSet);
	}

	Mesh.UpdateAnimations();
	PlayRandomIdleAnimation(true);
}

function AttachWeaponByItemDefinition( int ItemDefinition )
{
	local class<KFWeaponDefinition> WeaponDef;
	local int ItemINdex;
	local KFWeaponAttachment WeaponPreview;

	//find weapon def
	ItemIndex = class'KFWeaponSkinList'.default.Skins.Find('Id', ItemDefinition);

	if(ItemIndex ==  INDEX_NONE)
	{
		`log("Could not find item" @ItemDefinition);
		return;
	}

	WeaponDef = class'KFWeaponSkinList'.default.Skins[ItemIndex].WeaponDef;

	if(WeaponDef == none)
	{
		`log("Weapon def NONE for : " @ItemDefinition);
		return;
	}

	//load in and add object .
	WeaponPreview = KFWeaponAttachment ( DynamicLoadObject( WeaponDef.default.AttachmentArchtypePath, class'KFWeaponAttachment' ) );

	//attatch it to player
	WeaponAttachmentTemplate = WeaponPreview;

	WeaponAttachmentChanged();

	//setweapon skin
	WeaponAttachment.SetWeaponSkin(ItemDefinition);

}

simulated function PlayRandomIdleAnimation(optional bool bNewCharacter)
{
	local byte AnimIndex;
	local name AnimName;
	local AnimSet AnimSet;
	local float BlendInTime;

	AnimSet =  Mesh.AnimSets[Mesh.AnimSets.Length - 1];
	AnimIndex = Rand(AnimSet.Sequences.Length);
	AnimName = AnimSet.Sequences[AnimIndex].SequenceName;

	BlendInTime = (bNewCharacter) ? 0.f : 0.4;

	// Briefly turn off notify so that PlayCustomAnim won't call OnAnimEnd (e.g. character swap)
	BodyStanceNodes[EAS_FullBody].SetActorAnimEndNotification( FALSE );

	BodyStanceNodes[EAS_FullBody].PlayCustomAnim(AnimName, 1.f, BlendInTime, 0.4, false, true);
	BodyStanceNodes[EAS_FullBody].SetActorAnimEndNotification( TRUE );

	// Since the emote is being cancelled clear this flag too; lets the player queue up another emote again if they want
	bPlayingEmote = false;
}

simulated function PlayEmoteAnimation(optional bool bNewCharacter)
{
	local name AnimName;
	local float BlendInTime;

	if (bPlayingEmote)
	{
		return;
	}

	bPlayingEmote = true;

	AnimName = class'KFEmoteList'.static.GetUnlockedEmote( class'KFEmoteList'.static.GetEquippedEmoteId() );

	BlendInTime = (bNewCharacter) ? 0.f : 0.4;

	// Briefly turn off notify so that PlayCustomAnim won't call OnAnimEnd (e.g. character swap)
	BodyStanceNodes[EAS_FullBody].SetActorAnimEndNotification( FALSE );

	BodyStanceNodes[EAS_FullBody].PlayCustomAnim(AnimName, 1.f, BlendInTime, 0.4, false, true);
	BodyStanceNodes[EAS_FullBody].SetActorAnimEndNotification( TRUE );
}

/** Called from SkeletalMeshComponent::PlayParticleEffect() */
simulated function OnAnimNotifyParticleSystemSpawned( const AnimNotify_PlayParticleEffect AnimNotifyData, ParticleSystemComponent PSC )
{
	if (bPlayingEmote)
	{
		PSC.bUseAsOccluder = true;
	}
}

simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	bPlayingEmote = false;
	PlayRandomIdleAnimation();
}

simulated function NotifyTeamChanged()
{
	// Applies Character Info for < ROLE_Authority
	if( PlayerReplicationInfo != none && CharacterArch == none )
	{
		SetCharacterArch(GetCharacterInfo());
	}
}

/** If the customization point is created after the pawn, relocate our customization pawn to a customization point */
function bool MoveToCustomizationPoint()
{
	local NavigationPoint BestStartSpot;
	local KFGameInfo KFGI;
	local PlayerController PC;

    KFGI = KFGameInfo( WorldInfo.Game );

    PC = PlayerController( Controller );

	if( PC != none )
	{
		BestStartSpot = KFGI.FindCustomizationStart( PC );

		// If a customization point wasn't found or if SetLocation fails, exit.
		if( BestStartSpot == none )
		{
		 	return false;
		}

		// Update our location/rotation data
		SetUpdatedMovementData( BestStartSpot.Location, BestStartSpot.Rotation );

		// initialize and start it up
		KFPlayerCamera(PC.PlayerCamera).CustomizationCam.bInitialize = false;

		bUsingCustomizationPoint = true;

		return true;
	}

	return false;
}

/** Customization Pawns cannot take damage */
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	return;
}

/*********************************************************************************************
Customizing
********************************************************************************************* */

/** Set basic variables for the newly created Customization Pawn, derived from RestartPlayer */
function InitializeCustomizationPawn( PlayerController NewController, NavigationPoint BestStartSpot )
{
	if (Controller != None)
	{
		Controller.UnPossess();
	}

	PossessedBy( NewController, false );
    NewController.SetViewTarget( self );
	NewController.SetCameraMode( 'Customization' );

	// initialize and start it up
	bUsingCustomizationPoint = ( KFCustomizationPoint( BestStartSpot ) != none );

	// Need to update our client-side movement data
	SetUpdatedMovementData( BestStartSpot.Location, BestStartSpot.Rotation );
}

function Reset();

defaultproperties
{
	MaleCustomizationAnimSet=AnimSet'CHR_BaseMale_ANIM.CS_Male'
	FemaleCustomizationAnimSet=AnimSet'CHR_BaseFemale_ANIM.CS_Female'
	bDisableTurnInPlace=true
	bEnableAimOffset=false
	bSkipActorPropertyReplication=true
	bReplicateMovement=false
	bDisableMeshRotationSmoothing=true

	// Default the customization pawn to walking so that IK is enabled
	Physics=PHYS_Walking

    // artificial nudge -3uu to align to floor w/o IK
	Begin Object Name=KFPawnSkeletalMeshComponent
		Translation=(Z=-89)
	End Object
}
