//=============================================================================
// KFDT_Piercing_HRG_CranialPopper 
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_HRG_CranialPopper extends KFDT_Piercing
    abstract
    hidedropdown;

//Visual class to attach to the victim when impact occurs
var class<Actor> TubeAttachClass;

var class<KFDamageType> PoisonDamageType;

static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
//    if( super.CanDismemberHitZone( InHitZoneName ) )
//    {
//        return true;
//    }

    switch ( InHitZoneName )
    {
    case 'head':
        return true;
    }

    return false;
}

/**
* Allows the damage type to customize exactly which hit zones it can dismember while the zed is alive
*/
static simulated function bool CanDismemberHitZoneWhileAlive(name InHitZoneName)
{
    switch ( InHitZoneName )
    {
    case 'head':
        return true;
    }

    return false;
}

static function PlayImpactHitEffects(KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator)
{
    local Actor TubeAttachment;
    local Vector StickLocation;
    local Rotator StickRotation;
    local name BoneName;
    local WorldInfo WI;
    local KFPawn RetracePawn;
    local Vector RetraceLocation;
    local Vector RetraceNormal;
    local TraceHitInfo HitInfo;

    WI = class'WorldInfo'.static.GetWorldInfo();
    if (P != none && HitZoneIndex > 0 && HitZoneIndex < P.HitZones.Length && WI != none && WI.NetMode != NM_DedicatedServer)
    {
        //Don't play additional FX here if we aren't attaching a new tube, let its built in blood spray handle things
        //super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);

        //Retrace to get valid hit normal
        foreach WI.TraceActors(class'KFPawn', RetracePawn, RetraceLocation, RetraceNormal, HitLocation + HitDirection * 50, HitLocation - HitDirection * 50, vect(0, 0, 0), HitInfo, 1) //TRACEFLAG_Bullet
        {
            if (P == RetracePawn)
            {
                HitLocation = RetraceLocation;
                HitDirection = -RetraceNormal;
                break;
            }
        }

        TubeAttachment = P.Spawn(default.TubeAttachClass, P, , HitLocation, Rotator(HitDirection));
        if (TubeAttachment != none)
        {
            BoneName = P.HitZones[HitZoneIndex].BoneName;
            P.Mesh.TransformToBoneSpace(BoneName, TubeAttachment.Location, TubeAttachment.Rotation, StickLocation, StickRotation);
            TubeAttachment.SetBase(P, , P.Mesh, BoneName);
            TubeAttachment.SetRelativeLocation(StickLocation);
            TubeAttachment.SetRelativeRotation(StickRotation);
        }
    }
}

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{
    // potential for two DoTs if DoT_Type is set
    if (default.PoisonDamageType.default.DoT_Type != DOT_None)
    {
        Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, default.PoisonDamageType);
    }
}

defaultproperties
{
    KDamageImpulse=3000
    KDeathUpKick=800
    KDeathVel=500

    StumblePower=30
    GunHitPower=0

    BigHeadPower=100

    PoisonDamageType=class'KFDT_Poison_HRG_CranialPopper'

    WeaponDef=class'KFWeapDef_HRG_CranialPopper'
    ModifierPerkList(0)=class'KFPerk_Sharpshooter'

    TubeAttachClass=class'KFWeapActor_CranialPopper_Tube'
}
