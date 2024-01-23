//=============================================================================
// KFProj_Bullet_Frost_Shotgun_Axe
//=============================================================================
// Bullet class for the Frost_Shotgun_Axe
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_Frost_Shotgun_Axe extends KFProj_Bullet_Pellet
	hidedropdown;

var AkEvent oFrozenSound;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local KFPawn p;
	p = KFPawn(Other);
	super.ProcessTouch(Other, HitLocation, HitNormal);
	if(p != none)
	{
		if(KFPawn_Monster(p).IsDoingSpecialMove(SM_Frozen))
		{
			p.PlayAkEvent(oFrozenSound);
		}
	}
}

defaultproperties
{
	MaxSpeed=7000 //24000.0
	Speed=7000 //24000.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'WEP_Frost_Shotgun_Axe_EMIT.FX_FrostFang_Tracer_01'
	ProjFlightTemplateZedTime=ParticleSystem'WEP_Frost_Shotgun_Axe_EMIT.FX_FrostFang_Tracer_Zedtime_01'
	ImpactEffects=KFImpactEffectInfo'WEP_Frost_Shotgun_Axe_ARCH.WEP_FrostFang_Projectile_Impact'
	oFrozenSound=AkEvent'WW_WEP_FrostFang.Play_FrostFang_Frozen_Impact'
	AssociatedPerkClass=class'KFPerk_Support'
}

