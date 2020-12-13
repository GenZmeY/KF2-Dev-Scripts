class KFWeap_Minigun_Patriarch_Versus extends KFWeap_Minigun_Patriarch;

/** Cached reference to pawn */
var KFPawn_ZedPatriarch_Versus MyPatPawn;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if( Instigator != none )
	{
		MyPatPawn = KFPawn_ZedPatriarch_Versus(Instigator);
	}
}

simulated function bool ShouldWeaponIgnoreStartFire() { return true; }

DefaultProperties
{
	Spread(DEFAULT_FIREMODE)=0.022
	InstantHitDamage(DEFAULT_FIREMODE)=10.0
	PlayerIronSightFOV=60
}