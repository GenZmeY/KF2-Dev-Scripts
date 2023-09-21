// KFWeapAttach_LMG_MG3
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_LMG_MG3 extends KFWeaponAttachment;

var transient byte CachedNumAltBullets;
var transient float CachedAltFireOffset;

event PreBeginPlay()
{
 	super.PreBeginPlay();

    CachedNumAltBullets = class'KFWeap_LMG_MG3'.default.NumAltBullets;
    CachedAltFireOffset = (class'KFWeap_LMG_MG3'.default.SpreadWidthDegrees * DegToRad) / (CachedNumAltBullets - 1);
}

/** Plays fire animation on weapon mesh */
simulated function PlayWeaponFireAnim()
{
	local float Duration;
    local float NewAnimRate;

    // Increase Anim Rate so loop firing shows the ammo belt moving.
    NewAnimRate = 2.0f;

	if ( Instigator.bIsWalking )
	{
		Duration = WeapMesh.GetAnimLength( WeaponIronFireAnim );
		WeapMesh.PlayAnim( WeaponIronFireAnim, Duration / NewAnimRate,, true );
	}
	else
	{
		Duration = WeapMesh.GetAnimLength( WeaponFireAnim );
		WeapMesh.PlayAnim( WeaponFireAnim, Duration / NewAnimRate,, true );
	}
}

/** Spawn tracer effects for this weapon */
simulated function SpawnTracer(vector EffectLocation, vector HitLocation)
{
    local vector OriginalDir;
    local vector UpVector, RightVector;
	local KFTracerInfo TracerInfo;
    local Quat R;
    local byte i;

	if ( Instigator == None || Instigator.FiringMode >= TracerInfos.Length )
	{
		return;
	}

    if (Instigator.FiringMode != 1 || Instigator.Controller != None)
    {
        Super.SpawnTracer(EffectLocation, HitLocation);
        return;
    }

	TracerInfo = TracerInfos[Instigator.FiringMode];
    if( ((`NotInZedTime(self) && TracerInfo.bDoTracerDuringNormalTime)
        || (`IsInZedTime(self) && TracerInfo.bDoTracerDuringZedTime))
        && TracerInfo.TracerTemplate != none )
    {
        // At least one matches the 1P
        OriginalDir = HitLocation - EffectLocation;
        SpawnTracerVFX(TracerInfo, OriginalDir, EffectLocation);
        
        RightVector = vector(Rotation) cross vect(0,0,1);
        UpVector = RightVector cross vector(Rotation);
    
        for (i = 0; i < (CachedNumAltBullets - 1) / 2; ++i)
        {
            R = QuatFromAxisAndAngle(UpVector, CachedAltFireOffset * (i+1));
            SpawnTracerVFX(TracerInfo, QuatRotateVector(R, OriginalDir), EffectLocation);

            R = QuatFromAxisAndAngle(UpVector, -CachedAltFireOffset * (i+1));
            SpawnTracerVFX(TracerInfo, QuatRotateVector(R, OriginalDir), EffectLocation);
        }
	}
}

simulated function SpawnTracerVFX(KFTracerInfo TracerInfo, vector Direction, vector EffectLocation)
{
    local ParticleSystemComponent E;
	local float DistSQ;
	local float TracerDuration;

    DistSQ = VSizeSq(Direction);
    if ( DistSQ > TracerInfo.MinTracerEffectDistanceSquared )
    {
        // Lifetime scales based on the distance from the impact point. Subtract a frame so it doesn't clip.
        TracerDuration = fMin( (Sqrt(DistSQ) - 100.f) / TracerInfo.TracerVelocity, 1.f );
        if( TracerDuration > 0.f )
        {
            E = WorldInfo.MyEmitterPool.SpawnEmitter( TracerInfo.TracerTemplate, EffectLocation, rotator(Direction) );
            E.SetVectorParameter( 'Tracer_Velocity', TracerInfo.VelocityVector );
            E.SetFloatParameter( 'Tracer_Lifetime', TracerDuration );
        }
    }
}

defaultproperties
{
    CachedNumAltBullets=0
    CachedAltFireOffset=0
}
