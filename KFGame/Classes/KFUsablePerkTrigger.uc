class KFUsablePerkTrigger extends Trigger_PawnsOnly
	native
	implements(KFInterface_Usable);

var int InteractionIndex;

cpptext
{
	virtual UBOOL ShouldTrace( UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags );
};

simulated function bool GetIsUsable( Pawn User )
{
	return GetCanInteract( User );
}

function SetInteractionIndex( int Index )
{
	InteractionIndex = Index;
}

function int GetInteractionIndex( Pawn User )
{
	return InteractionIndex;
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local KFPawn_Human KFP;

	Super.Touch(Other, OtherComp, HitLocation, HitNormal);

	KFP = KFPawn_Human(Other);
	if( KFP != none && KFP.Controller != none && KFP != Owner )
	{
		KFPlayerController(KFP.Controller).SetPendingInteractionMessage();
	}
}

event UnTouch(Actor Other)
{
	local KFPawn_Human KFP;

	super.UnTouch( Other );

	KFP = KFPawn_Human(Other);
	if( KFP != none && KFP.Controller != none && KFP != Owner )
	{
		KFPlayerController(KFP.Controller).SetPendingInteractionMessage();
	}
}

function bool GetCanInteract( Pawn User, optional bool bInteractIfTrue = false)
{
	local KFPawn_Human OwnerPawn;
	local KFPawn_Human UserPawn;
	local KFPerk CurrentPerk;

	OwnerPawn = KFPawn_Human(Owner);
	UserPawn = KFPawn_Human(User);
	if ( OwnerPawn != none && UserPawn != none && UserPawn.Controller != none && OwnerPawn != UserPawn )
	{
		CurrentPerk = OwnerPawn.GetPerk();
		if ( CurrentPerk != none &&
			 CurrentPerk.CanInteract(UserPawn) )
		{
			if( bInteractIfTrue )
			{
				CurrentPerk.Interact(UserPawn);
				KFPlayerController(UserPawn.Controller).SetPendingInteractionMessage();
			}
			return true;
		}
	}
	return false;
}

simulated function DestroyTrigger()
{
	local KFPawn_Human Toucher;
	//notify all touching actors that they are not touching this non existing trigger anymore
	
	foreach TouchingActors(class'KFPawn_Human', Toucher)
	{
		UnTouch(Toucher);
	}

	Destroy();
}

function bool UsedBy(Pawn User)
{
	return GetCanInteract( User, true );
}

DefaultProperties
{
	bStatic=FALSE
	bNoDelete=FALSE

	Begin Object Name=CollisionCylinder
		CollisionRadius=+00200.000000
		CollisionHeight=+00100.000000
	End Object
}