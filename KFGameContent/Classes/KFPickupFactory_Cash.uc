//=============================================================================
// KFPickupFactory_Cash
//=============================================================================
// Pickup that gives some ammo for all weapons in inventory
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFPickupFactory_Cash extends KFPickupFactory;

/** Sound to play when picºng up cash */
var() AkEvent CashPickupSound;
var() int CashAmount;
var() StaticMeshComponent CashMeshComponent;

simulated function InitializePickup()
{

}

/** Bypass PickupFactory implementation. This class doesn't use InventoryType. */
simulated event SetInitialState()
{
	super.SetInitialState();

	bScriptInitialized = true;
}

/** give pickup to player */
function GiveTo( Pawn P )
{
	local KFPawn_Human KFPH;
	local KFPlayerReplicationInfo KFPRI;

	if ( P.PlayerReplicationInfo != none )
	{
		KFPH = KFPawn_Human(P);
		KFPRI = KFPlayerReplicationInfo(P.PlayerReplicationInfo);

		// @todo (?): for now, play "catch dosh" dialog whenever you pick some up
		if( KFPRI != none && KFPH != none )
		{
			KFPH.UpdateDoshCaught( CashAmount, none );
		}

		if( KFPRI != none )
		{
			KFPRI.AddDosh( CashAmount );
			`AnalyticsLog(("dosh_picked_up", KFPRI, "#"$CashAmount));
		}

		bForceNetUpdate = true;
		P.PlaySoundBase(CashPickupSound);
	}

	SetPickupHidden();
	GotoState('Disabled');
	SetCollision(false, false);
}

function bool CurrentPickupIsCash()
{
	return true;
}

defaultproperties
{
	CashPickupSound=AkEvent'WW_UI_PlayerCharacter.Play_UI_Pickup_Ammo'

	Begin Object Class=StaticMeshComponent Name=MyStaticMeshComponent
		StaticMesh=StaticMesh'ENV_Horzine_MESH.crates.ENV_Horzine_Equiptment_Crate_02'
		bCastDynamicShadow=FALSE
		CollideActors=FALSE
  	End Object

  	CashMeshComponent=MyStaticMeshComponent
	PickupMesh=MyStaticMeshComponent
	Components.Add(MyStaticMeshComponent)

	Begin Object NAME=CollisionCylinder
		CollisionRadius=100.f
		CollisionHeight=50.f
	End Object

	bNotBased=TRUE
	bEnabledAtStart=true
	bKismetDriven=true
}
