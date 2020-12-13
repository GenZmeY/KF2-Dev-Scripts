//=============================================================================
// SprayActor_Heal
//=============================================================================
// Base class for spray actor that heals teammates
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class SprayActor_Heal extends SprayActor_Flame
    hidecategories(Object, Movement, Display, Attachment, Collision, Physics, Advanced, Debug, Mobile)
	placeable;

var(SprayHeal) int DirectHitHealingAmount;
var(SprayHeal) int SplashHitHealingAmount;
var(SprayHeal) float  HealInterval;

var class<DamageType> HealingDamageType;
var array<DamagedActorInfo> RecentlyHealedActors;

function bool CheckRecentlyHealed(Actor ActorToCheck)
{
	local int i;
	local bool bFoundHitActor, bHealedRecently;

	for (i = RecentlyHealedActors.Length - 1; i >= 0; i--)
	{
		if ((WorldInfo.TimeSeconds - RecentlyHealedActors[i].HitTime) > 1.f)
		{
			RecentlyHealedActors.Remove(i, 1);
			continue;
		}

		if (!bFoundHitActor && RecentlyHealedActors[i].HitActor == ActorToCheck)
		{
			bFoundHitActor = true;

			// Only damage at a specified rate, so return if it's too soon
			if ((WorldInfo.TimeSeconds - RecentlyHealedActors[i].HitTime) < HealInterval)
			{
				bHealedRecently = true;
			}
		}
	}

	return bHealedRecently;
}
event SprayMeshHit(Actor TouchActor)
{
	local DamagedActorInfo NewActorInfo;

	if (Role == ROLE_Authority)
	{
		if (Instigator != None && TouchActor != None && Instigator != TouchActor && Instigator.GetTeamNum() == TouchActor.GetTeamNum())
		{
			if (!CheckRecentlyHealed(TouchActor))
			{
				NewActorInfo.HitActor = TouchActor;
				NewActorInfo.HitTime = WorldInfo.TimeSeconds;

				// Store any actors that get damage
				RecentlyHealedActors.AddItem(NewActorInfo);

				TouchActor.HealDamage(DirectHitHealingAmount, Instigator.Controller, HealingDamageType);
				return;
			}
		}
	}

	super.SprayMeshHit(TouchActor);
}

event SplashHit(Actor SplashTouchActor)
{
	local DamagedActorInfo NewActorInfo;

	if (Role == ROLE_Authority)
	{
		if (Instigator != None && SplashTouchActor != None && Instigator != SplashTouchActor && Instigator.GetTeamNum() == SplashTouchActor.GetTeamNum())
		{
			if (!CheckRecentlyHealed(SplashTouchActor))
			{
				NewActorInfo.HitActor = SplashTouchActor;
				NewActorInfo.HitTime = WorldInfo.TimeSeconds;

				// Store any actors that get damage
				RecentlyHealedActors.AddItem(NewActorInfo);

				SplashTouchActor.HealDamage(SplashHitHealingAmount, Instigator.Controller, HealingDamageType);
				return;
			}
		}
	}

	super.SplashHit(SplashTouchActor);
}

defaultProperties
{
	bCollideWithTeammates=true
	DirectHitHealingAmount=2
	SplashHitHealingAmount=1
	HealInterval=0.1f
	MyDamageType=class'KFDT_Toxic_MedicGrenade'
	HealingDamageType=class'KFDT_Healing_MedicGrenade'
}
