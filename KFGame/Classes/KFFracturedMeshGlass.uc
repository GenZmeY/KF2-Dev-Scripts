//=============================================================================
// KFFracturedMeshGlass
//=============================================================================
// A custom FracturedMeshActor used for fragile, translucent glass
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFFracturedMeshGlass extends KFFracturedMeshActor
	placeable
	native(Effect);

/** Amount of damage taken before before bump destroys (aka Fragile) */
var deprecated int DestroyOnBumpThreshold;

/** If true, AI bump will completely destroy the glass regardless of other settings */
var() bool bInstiKillOnAIBump;

/** Cached MICs that are generated for material params */
var transient MaterialInstanceConstant 	MIC;
var transient bool						bTickMaterialParam;

cpptext
{
	// For material light params
	virtual void TickSpecial(FLOAT DeltaSeconds);
	virtual UBOOL InStasis();

	// For TRACE_LineOfSight
	virtual UBOOL ShouldTrace( UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags );

	/** Converts legacy KFFracturedMeshActors to KFFracturedMeshGlass */
	virtual void EditorReplacedActor (AActor* OldActor);

	virtual UBOOL IgnoreBlockingBy( const AActor *Other ) const;
};

/*
 * Set network role based on type setting
 */
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	// initialize Light MIC
	if ( MaterialLightParams.LightActor != None )
	{
		MIC = FracturedStaticMeshComponent.CreateAndSetMaterialInstanceConstant(MaterialLightParams.MatID);
		bTickMaterialParam = true;
	}	
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// we need tick for light material params
	if ( bTickMaterialParam && bTickIsDisabled )
	{
		SetTickIsDisabled(false);
	}
}

/** TakeDamage will hide/spawn chunks when they get shot. */
simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

/** Check bDestroyOnBumpIfWeakened, requires bWorldGeometry==false */
event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	local Pawn OtherPawn;

	if ( !bHasBeenDestroyed )
	{
		if ( bHasLostChunk )
		{
			BreakOffAllFragments(Other.Velocity);
		}
		else if ( bInstiKillOnAIBump )
		{
			OtherPawn = Pawn(other);
			if ( OtherPawn != None && !OtherPawn.IsHumanControlled() )
			{
				BreakOffAllFragments(Other.Velocity);
			}
		}
	}
}

/** Ignore StopsProjectile for non-bullets (e.g. Greandes, Rockets) when cracked */
simulated function bool StopsProjectile(Projectile P)
{
	local KFProjectile KFProj;
	local bool bShatter;

	if( P.bBounce )
	{
		KFProj = KFProjectile( P );
		if( KFProj != none )
		{
			switch( KFProj.GlassShatterType )
			{
			case FMGS_ShatterNone:
				bShatter = false;
				break;

			case FMGS_ShatterDamaged:
				bShatter = bHasLostChunk;
				break;

			case FMGS_ShatterAll:
				bShatter = true;
				break;
			};
		}
	}

	if( bShatter )
	{
		// on the server break off the rest of the glass
		if ( Role == ROLE_Authority && !bHasBeenDestroyed )
		{
			BreakOffAllFragments(Normal(P.Velocity) * 200);
		}
		return false;
	}
	else if( ReplicationMode == RT_Clientside )
	{
		// not entirely safe to bounce off of clientside-only meshes
		// maybe shatter?
	}

	return Super.StopsProjectile(P);
}

/** Disable falloff to amp up destruction effects */
simulated function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor				DamageCauser,
	optional float      DamageFalloffExponent=1.f,
	optional bool		bAdjustRadiusDamage=true
)
{
	Super.TakeRadiusDamage(InstigatedBy, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, true, DamageCauser, DamageFalloffExponent, bAdjustRadiusDamage);
}

defaultproperties
{
	bWorldGeometry=false // for bump
	TotalHealth=300
	bDestroyFragmentsOnImpact=true
	bInstiKillOnAIBump=true

	VulnerableDamageType(0)=class'KFDT_Sonic'
}
