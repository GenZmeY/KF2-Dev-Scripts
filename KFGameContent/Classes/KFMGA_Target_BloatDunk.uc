//=============================================================================
// KFMGA_Target_BloatDunk
//=============================================================================
// Extension of target to handle specifics for bloat dunk, particularly for
//      modification of lights to show which one is active.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMGA_Target_BloatDunk extends KFMGA_Target;

/** Point lights used to visualize on/off state of the target */
var() PointLightComponent OnLight;
var() PointLightComponent OffLight;

/** Additional static mesh component to swap to when in the on state */
var() StaticMeshComponent OnMesh;

function ValidHit(Controller EventInstigator, Actor HitActor)
{
    super.ValidHit(EventInstigator, HitActor);

    if (NumHits <= 0)
    {
        SetHidden(true);
    }    
}

simulated event Reset()
{
    super.Reset();
    SetHidden(false);
    SetInactive();
}

simulated event SetActive()
{
    bActiveTarget = true;
    
    //Green things on
    OnLight.SetEnabled(true);
    OnMesh.SetHidden(false);

    //Red things off
    OffLight.SetEnabled(false);
    Mesh.SetHidden(true);
}

simulated event SetInactive()
{
    bActiveTarget = false;
    if (IsAlive())
    {
        //Green things off
        OnLight.SetEnabled(false);
        OnMesh.SetHidden(true);

        //Red things on
        OffLight.SetEnabled(true);
        Mesh.SetHidden(false);
    }
    else
    {
        //Everything off
        OnLight.SetEnabled(false);
        OnMesh.SetHidden(true);

        OffLight.SetEnabled(false);
        Mesh.SetHidden(true);
    }
}

defaultproperties
{
    Begin Object Class=PointLightComponent Name=PointLight0
		bCastPerObjectShadows=false
    End Object
    Components.Add(PointLight0)
    OnLight = PointLight0

    Begin Object Class=PointLightComponent Name=PointLight1
		bCastPerObjectShadows=false
    End Object
    Components.Add(PointLight1)
    OffLight = PointLight1

    Begin Object class=StaticMeshComponent Name=Mesh1
    End Object
    OnMesh = Mesh1
    Components.Add(Mesh1)
}