//=============================================================================
// KFExplosion_ParasiteSeed
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_ParasiteSeed extends KFExplosion_MedicGrenade;

var transient bool FirstExplosion;

/**
  * Deal damage or heal players
  */
protected simulated function AffectsPawn(Pawn Victim, float DamageScale)
{
	local KFPawn_Human HumanVictim;
	local KFPawn_Monster MonsterVictim;
	local KFProj_MedicGrenade OwnerProjectile;
	local bool bCanRepairArmor;
	local Box BBox;	
	local vector	BBoxCenter;
	local Actor		HitActor;
	local bool		bDamageBlocked;

	if( Victim != none && Victim.IsAliveAndWell() )
	{
		MonsterVictim = KFPawn_Monster(Victim);
		if( MonsterVictim != none )
		{
			if(!FirstExplosion || bWasFadedOut|| bDeleteMe || bPendingDelete )
			{
				return;
			}

			Victim.GetComponentsBoundingBox(BBox);
			BBoxCenter = (BBox.Min + BBox.Max) * 0.5f;
			HitActor = TraceExplosive(BBoxCenter, Location + vect(0, 0, 20));
			bDamageBlocked = (HitActor != None && HitActor != Victim);
			if(bDamageBlocked && HitActor.IsA('KFDoorActor'))
			{
				bDamageBlocked = false;
			}
			if( !bDamageBlocked )
			{	
				Victim.TakeRadiusDamage(InstigatorController, ExplosionTemplate.Damage * DamageScale, ExplosionTemplate.DamageRadius,
				ExplosionTemplate.MyDamageType, ExplosionTemplate.MomentumTransferScale, Location, bDoFullDamage,
				(Owner != None) ? Owner : self, ExplosionTemplate.DamageFalloffExponent);
			}
		}
		else 
		{
			HumanVictim = KFPawn_Human(Victim);
			if( HumanVictim != none && HumanVictim.GetExposureTo(Location) > 0 )
			{
				OwnerProjectile = KFProj_MedicGrenade(Owner);
				if( OwnerProjectile != none )
				{
					bCanRepairArmor = OwnerProjectile.HealedPawns.Find( HumanVictim ) == INDEX_NONE;
				}
				
				HumanVictim.HealDamage(HealingAmount, InstigatorController, HealingDamageType, bCanRepairArmor);

				if( bCanRepairArmor )
				{
					OwnerProjectile.HealedPawns.AddItem( HumanVictim );
				}
			}
		}
	}
}

simulated function DelayedExplosionDamage()
{
	FirstExplosion=false;
	super.DelayedExplosionDamage();
}

DefaultProperties
{
	FirstExplosion = true;

	HealingDamageType=class'KFDT_Healing_ParasiteSeed'
	HealingAmount=5 //10
	Interval=0.5 //1
	MaxTime=5.0 //5.5

	bExplodeMoreThanOnce=false
	bDoFullDamage=false //true
	bSkipLineCheckForPawns=true

	LoopingParticleEffect=ParticleSystem'WEP_3P_Medic_Grenade_EMIT.FX_Medic_Grenade_Explosion'
	LoopStartEvent=AkEvent'WW_WEP_Medic_GrenadeLauncher.Play_WEP_Medic_GrenadeLauncher_Grenade_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_Medic_GrenadeLauncher.Stop_WEP_Medic_GrenadeLauncher_Grenade_Smoke_Loop'
}
