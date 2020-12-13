//=============================================================================
// KFWeapAttach_Railgun
//=============================================================================
// Custom weapon attachment for the third person Railgun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KFWeapAttach_Railgun extends KFWeaponAttachment;

/*********************************************************************************************
 * @name Ambient sound
 ********************************************************************************************* */
/** Pilot light sound play event */
var AkEvent                         AmbientSoundPlayEvent;

/** Pilot light sound stop event */
var AkEvent	                        AmbientSoundStopEvent;

/**
 * Starts playing looping ambient sound
 */
simulated function StartAmbientSound()
{
	if( Instigator != none && !Instigator.IsFirstPerson() )
	{
		if ( AmbientSoundPlayEvent != None )
		{
        	Instigator.PlaySoundBase(AmbientSoundPlayEvent, true, true, true,, true);
		}
    }
}

/**
 * Stops playing looping ambient sound
 */
simulated function StopAmbientSound()
{
	if ( AmbientSoundStopEvent != None )
	{
    	Instigator.PlaySoundBase(AmbientSoundStopEvent, true, true, true,, true);
    }
}

/** Attach weapon to owner's skeletal mesh */
simulated function AttachTo(KFPawn P)
{
    Super.AttachTo(P);

    StartAmbientSound();
}

/** Detach weapon from owner's skeletal mesh */
simulated function DetachFrom(KFPawn P)
{
    StopAmbientSound();

    Super.DetachFrom(P);
}

simulated function Destroyed()
{
	StopAmbientSound();

	super.Destroyed();
}

/** Spawn tracer effects for this weapon */
simulated function SpawnTracer(vector EffectLocation, vector HitLocation)
{
	local ParticleSystemComponent E;
	local vector Dir;
	local float DistSQ;
	local float TracerDuration;
	local KFTracerInfo TracerInfo;

	if ( Instigator == None || Instigator.FiringMode >= TracerInfos.Length )
	{
		return;
	}

	TracerInfo = TracerInfos[Instigator.FiringMode];
    if( ((`NotInZedTime(self) && TracerInfo.bDoTracerDuringNormalTime)
        || (`IsInZedTime(self) && TracerInfo.bDoTracerDuringZedTime))
        && TracerInfo.TracerTemplate != none )
    {
        Dir = HitLocation - EffectLocation;
		DistSQ = VSizeSq(Dir);
    	if ( DistSQ > TracerInfo.MinTracerEffectDistanceSquared )
    	{
    		// Lifetime scales based on the distance from the impact point. Subtract a frame so it doesn't clip.
			TracerDuration = fMin( (Sqrt(DistSQ) - 100.f) / TracerInfo.TracerVelocity, 1.f );
			if( TracerDuration > 0.f )
			{
	    		E = WorldInfo.MyEmitterPool.SpawnEmitter( TracerInfo.TracerTemplate, EffectLocation, rotator(Dir) );
	 			E.SetFloatParameter( 'Tracer_Lifetime', TracerDuration );
	 			// Add the railgun tracer shot end parameter
                E.SetVectorParameter( 'Shotend', HitLocation );
	 		}
    	}
	}
}

defaultproperties
{
	AmbientSoundPlayEvent=AkEvent'WW_WEP_SA_Railgun.Play_Railgun_Loop'
	AmbientSoundStopEvent=AkEvent'WW_WEP_SA_Railgun.Stop_Railgun_Loop'
}


