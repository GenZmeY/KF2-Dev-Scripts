class KFProj_Missile_Patriarch_Versus extends KFProj_Missile_Patriarch;

DefaultProperties
{
	//defaults
	FlockRadius=5.f
	FlockMaxForce=200.f
	FlockCurlForce=1200.f
	WobbleForce=90.f

	Damage=230

	// explosion
	Begin Object Name=ExploTemplate0
		Damage=70
		DamageRadius=650
		DamageFalloffExponent=2.f
	End Object
}