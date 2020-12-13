//=============================================================================
// KFAnim_AimOffset
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GearAnim_AimOffset 
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class KFAnim_AimOffset extends AnimNodeAimOffset
	native(Anim);

/** Internal cached pointer to Owner */
var	const transient KFPawn PawnOwner;
/** Internal cached pointers */
var const duplicatetransient KFAnim_TurnInPlace TurnInPlaceNode;

/** Asks to look up the InteractionPawn's aim. Used by hostages. */
var()	bool	bUseInteractionPawnAim;
/** Only update once when it becomes relevant */
var()   bool    bOnlyUpdateOnBecomeRelevant;

/** See if we want to shut down that aimoffset when reloading */
var()	bool	bTurnOffWhenReloadingWeapon;
var()	float	ReloadingBlendTime;
var		transient const bool	bDoingWeaponReloadInterp;
var		transient const float	ReloadingBlendTimeToGo;

/** Interpolation when looping around, so it doesn't look weird */
var transient const vector2d	LastAimOffset, LastPostProcessedAimOffset;
var transient const	FLOAT		TurnAroundTimeToGo;
var()	FLOAT					TurnAroundBlendTime;

enum EAimInput
{
	AI_PawnAimOffset,
	/** Use the VehicleAimOffset in GearVehicle for aiming */
	AI_VehicleAimOffset,
	/** Use Base to retrieve aiming information */
	AI_BasePawn,
	/** Use Custom Aim Offset - override GetCustomAimOffset function in the GearPawn*/
	AI_CustomAimOffset, 
};

/** What we are using as our Aim input. */
var() editconst EAimInput	AimInput;

cpptext
{
	virtual void PostAnimNodeInstance(UAnimNode* SourceNode, TMap<UAnimNode*,UAnimNode*>& SrcToDestNodeMap);
	virtual void		InitAnim(USkeletalMeshComponent* MeshComp, UAnimNodeBlendBase* Parent);
	/** Pull aim information from Pawn */
	virtual FVector2D	GetAim() ;
	virtual void		PostAimProcessing(FVector2D &AimOffsetPct);
	/** Parent node is requesting a blend out. Give node a chance to delay that. */
	virtual UBOOL		CanBlendOutFrom();
	/** parent node is requesting a blend in. Give node a chance to delay that. */
	virtual UBOOL		CanBlendTo();
}

defaultproperties
{
	TurnAroundBlendTime=0.42f
	ReloadingBlendTime=0.33f
	AimInput=AI_PawnAimOffset
}