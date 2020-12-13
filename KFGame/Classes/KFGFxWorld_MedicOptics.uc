//=============================================================================
// KFGFxWorld_MedicOptics
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 8/20/2014
//=============================================================================

class KFGFxWorld_MedicOptics extends GFxMoviePlayer;

var byte		CurrentAmmoCount;
var byte		CurrentCharge;
var GFxObject 	OpticsContainer;
var float 		MinPercentPerShot;

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	switch(WidgetName)
	{
		case ('medicOpticsContainer'):
			if ( OpticsContainer == none )
			{
				OpticsContainer = Widget;
				InitValues();
		    }
       	break;
    }
    
	return true;
}

function InitValues()
{
	SetShotPercentCost( MinPercentPerShot );
}

/** Update the optics ammo reading */
simulated function SetPrimaryAmmo(byte NewAmmoCount)
{
	if (OpticsContainer != none)
	{
		OpticsContainer.SetInt("ammoValue", NewAmmoCount);
	}
}

function SetShotPercentCost(float CostPercent)
{
	MinPercentPerShot = CostPercent;
	if (OpticsContainer != none)
	{
		OpticsContainer.SetInt("costPercentPerShot", CostPercent);
	}	
}

/** Update the optics healing meter */
function SetHealerCharge(byte NewCharge)
{
	if (OpticsContainer != none)
	{
		OpticsContainer.SetInt("chargeMeter", NewCharge);
	}
}

/** Remove the lock on targeting */
function ClearLockOn()
{
	if (OpticsContainer != none)
	{
		OpticsContainer.ActionScriptVoid("clearLock");		
	}
}

/** Start the lock on optics animation */
function StartLockOn()
{
	if (OpticsContainer != none)
	{
		OpticsContainer.ActionScriptVoid("startLockOn");	
	}
}

/** Play the locked optics animation */
function LockedOn()
{
	if (OpticsContainer != none)
	{
		OpticsContainer.ActionScriptVoid("lockedOn");		
	}
}

defaultproperties
{
	RenderTexture=TextureRenderTarget2D'WEP_1P_Optics_TEX.Wep_1stP_Optics_R2T'
	MovieInfo=SwfMovie'UI_World.MedicOpticsWorld_SWF'
	bAutoPlay=false
}
