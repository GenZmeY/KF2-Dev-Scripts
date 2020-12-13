//=============================================================================
// BaseAIPawn
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class BaseAIPawn extends GamePawn
	dependson(BaseAITypes)
	config(Game)
	native
	abstract
	notplaceable
	nativereplication;

var transient BaseAIController MyBaseAI;

/** remembers the team we were on pre-death as our PlayerReplicationInfo will be disconnected 
 * mz> reused as simple team number cache, moved from KFPawn.uc
 */
var byte LastTeamNum;

// ----------------------------------------------------------------------- //
// Breadcrumbs
// ----------------------------------------------------------------------- //

// mz> chaning this remember to change 'kBreadCrumbsMax' in BreadCrumbs struct (below)
const kBreadCrumbsMax = 10;

struct native Breadcrumbs
{
	var transient vector Crumbs[kBreadCrumbsMax];
	var transient byte CurrentCrumb;
	var float CrumbDistanceSq;
	
	structcpptext
	{
	// added this way since script consts were unsuable in this case
	enum
	{
		kBreadCrumbsMax = 10
	};

	FBreadcrumbs() 
	{
		appMemzero(this, sizeof(FBreadcrumbs));
	}
	
	FBreadcrumbs(EEventParm) 
	{
		appMemzero(this, sizeof(FBreadcrumbs));
	}

	void Init(const FVector& Location, FLOAT inCrumbDistanceSq=10000.f)
	{
		for(INT i = 0; i < kBreadCrumbsMax; ++i)
		{
			Crumbs[i] = Location;
		}

		CrumbDistanceSq = inCrumbDistanceSq;
	}

	void UpdateCrumbs(const FVector& Location)
	{
		if(Crumbs[CurrentCrumb].DistanceSquared(Location) >= CrumbDistanceSq)
		{
			const BYTE newCrumb = (CurrentCrumb + 1) % kBreadCrumbsMax;
			Crumbs[newCrumb] = Location;
			CurrentCrumb = newCrumb;
		}
	}

	FORCEINLINE FVector GetOldestCrumb() const
	{
		return Crumbs[(CurrentCrumb + 1) % kBreadCrumbsMax];
	}

	FVector GetNthCrumb(INT N) const
	{
		return N >= kBreadCrumbsMax ? GetOldestCrumb() : Crumbs[(CurrentCrumb + kBreadCrumbsMax - N) % kBreadCrumbsMax];
	}
	}

	structdefaultproperties
	{
		CrumbDistanceSq=10000.f
	}
};

var transient BreadCrumbs MyBreadCrumbs;

// ----------------------------------------------------------------------- //
// Target selection/limitation
// ----------------------------------------------------------------------- //

/** Cached value for damage config: AI type */
var transient /*const*/ byte MyAIType;

/** Array of all pawns attacking this controller.*/
var const array<BaseAIPawn> Attackers;
var const array<INT> AttackersPerTypeCount;

// ----------------------------------------------------------------------- //
// Animation related
// ----------------------------------------------------------------------- //

// ----------------------------------------------------------------------- //
// members moved from GearPawn
// ----------------------------------------------------------------------- //

// ----------------------------------------------------------------------- //
// Plugins
// ----------------------------------------------------------------------- //

var transient bool bLeaping;
var transient float TimeStartedLeap;
var transient float TimeImmuneWhileLeaping;

cpptext
{
	virtual void PostBeginPlay();
	virtual void PostScriptDestroyed();
	virtual UBOOL Tick(FLOAT DeltaTime, enum ELevelTick TickType);

	void AddAttacker(class ABaseAIPawn* Attacker);
};

// ----------------------------------------------------------------------- //
// Properties interface
// ----------------------------------------------------------------------- //

// ----------------------------------------------------------------------- //
// Weapon handling
// ----------------------------------------------------------------------- //

// ----------------------------------------------------------------------- //
// Pawn overrides
// ----------------------------------------------------------------------- //

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
`if(`notdefined(__TW_BASEAI_LEAN_))
	AbortSOUsage();
`endif

	class'BaseAISubsystem'.static.DecreaseTeamSize(GetTeamNum());
	if(MyBaseAI != None && MyBaseAI.Enemy != None)
	{
		BaseAIPawn(MyBaseAI.Enemy).RemoveAttacker(self);
	}

	return Super.Died(Killer,damageType,HitLocation);
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);
	MyBaseAI = BaseAIController(C);

	// BaseAIPawn subclasses actually do get possessed by players!
	if ( MyBaseAI != None )
	{
		LastTeamNum = MyBaseAI.GetTeamNum();
	}
}

function UnPossessed()
{
	MyBaseAI = None;

	super.UnPossessed();
`if(`notdefined(__TW_BASEAI_LEAN_))
	if (AnimationProxy != None)
	{
		AnimationProxy.UnPossessed();
	}
`endif
}

simulated function NotifyTeamChanged()
{
	Super.NotifyTeamChanged();

	LastTeamNum = GetTeamNum();
}

// ----------------------------------------------------------------------- //
// Readabilities (Chatter too)
// ----------------------------------------------------------------------- //

// ----------------------------------------------------------------------- //
// Target selection/limitation
// ----------------------------------------------------------------------- //
/** 
* @param AIType specifies what type of attackers is of interest, -1 means all
* @return number of Pawns of given type (or all if AIType == -1) attacking this controller
*/
native final function int GetAttackerCount(optional int AIType = -1) const;

native final function RemoveAttacker(BaseAIPawn Attacker);

// ----------------------------------------------------------------------- //
// level progress stuff
// ----------------------------------------------------------------------- //

// ----------------------------------------------------------------------- //
// movement
// ----------------------------------------------------------------------- //

// ----------------------------------------------------------------------- //
// debug
// ----------------------------------------------------------------------- //
final native function DrawCrumbs(HUD HUD) const;

defaultproperties
{
`if(`notdefined(__TW_BASEAI_LEAN_))
	AISelectionModifier=1.0
	AimAccuracy=Accuracy_Normal
	bUseAnimationProxy=true
	MovementProps=(bStartMovementShooting=true, bStartMovementShootingOnRepath=false, bEndMovementShooting=true, bCanCombatWalk=true)
	bHasAISelectionModifierPerTeam=false
`endif

	bCanBeAdheredTo=TRUE
	bCanBeFrictionedTo=TRUE
}
