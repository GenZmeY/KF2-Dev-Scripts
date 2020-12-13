//=============================================================================
// KFWeldableComponent
//=============================================================================
// Actor that encapsulates the management and replication of welding info.
// Enables any object to be weldable (used along with KFWeldableTrigger).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFWeldableComponent extends Actor
	native;

/** Amount of damage a welded door can take */
var int MaxWeldIntegrity;
/** Current integrity of a welded door */
var repnotify transient int WeldIntegrity;

/** Percent of repair complete from 0-255 */
var repnotify byte RepairProgress;

/** Amount of "explosive" weld needed */
var int DemoWeldRequired;
/** Current amount of "explosive" weld */
var transient int DemoWeld;

/** True if the door has health less than 0 and is off its hinges */
var transient bool bIsDestroyed;

var bool bWeldable, bUnweldable, bRepairable;

delegate Delegate_AdjustWeldAmount(out int Amount);
delegate Delegate_OnWeldIntegrityChanged(optional int Amount, optional KFPawn Welder);
delegate Delegate_OnRepairProgressChanged(optional float Amount, optional KFPawn Welder);

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		WeldIntegrity, DemoWeld, RepairProgress, bIsDestroyed;
}

cpptext
{
	UBOOL IsOverlapping(AActor *Other, FCheckResult* Hit = NULL, UPrimitiveComponent* OtherPrimitiveComponent = NULL, UPrimitiveComponent* MyPrimitiveComponent = NULL);
};

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(WeldIntegrity))
	{
		if (Delegate_OnWeldIntegrityChanged != none)
		{
			Delegate_OnWeldIntegrityChanged(0, None);
		}
	}
	else if (VarName == nameof(RepairProgress))
	{
		if (Delegate_OnRepairProgressChanged != none)
		{
			Delegate_OnRepairProgressChanged(0, None);
		}
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

function Weld(int Amount, optional KFPawn Welder)
{
	local int OriginalAmount;
	local KFPerk WelderPerk;
	local bool bCanExplosiveWelded;

	if (Welder != none && Amount > 0)
	{
		WelderPerk = KFPlayerController(Welder.Controller).GetPerk();
		if (WelderPerk != none && WelderPerk.CanExplosiveWeld())
		{
			bCanExplosiveWelded = true;
		}
	}

	if ((Amount > 0 && !CanBeWelded() && !bCanExplosiveWelded) || (Amount < 0 && !CanBeUnwelded()))
	{
		return;
	}

	OriginalAmount = Amount;

	if (Delegate_AdjustWeldAmount != none)
	{
		Delegate_AdjustWeldAmount(Amount);
	}

	UpdateWeldIntegrity(Amount);

	if (Welder != none && Amount > 0)
	{
		if (bCanExplosiveWelded)
		{
			UpdateDemoWeld(Amount);
		}
	}

	if (Delegate_OnWeldIntegrityChanged != none)
	{
		Delegate_OnWeldIntegrityChanged(OriginalAmount, Welder);
	}
}

function UpdateWeldIntegrity(int Amount)
{
	SetWeldIntegrity(WeldIntegrity + Amount);
}

function SetWeldIntegrity(int Amount)
{
	WeldIntegrity = Clamp(Amount, 0, MaxWeldIntegrity);
	bForceNetUpdate = true;
}

function SetRepairProgress(int Amount)
{
	RepairProgress = Clamp(Amount, 0, 255);
	bForceNetUpdate = true;
}

function UpdateDemoWeld(int Amount)
{
	SetDemoWeld(DemoWeld + Amount);
}

function SetDemoWeld(int Amount)
{
	DemoWeld = Clamp(Amount, 0, DemoWeldRequired);
	bForceNetUpdate = true;
}

function SetDestroyed(bool bDestroyed)
{
	bIsDestroyed = bDestroyed;
}

/** Increase the weld integrity - Network: Server only */
function Repair(float Amount, optional KFPawn Welder)
{
	local byte ByteAmount;

	if (!CanBeRepaired())
	{
		return;
	}

	ByteAmount = FloatToByte(Amount);
	if (RepairProgress + ByteAmount >= 255)
	{
		RepairProgress = 255;
	}
	else
	{
		RepairProgress += ByteAmount;
	}

	bForceNetUpdate = true;

	if (Delegate_OnRepairProgressChanged != none)
	{
		Delegate_OnRepairProgressChanged(Amount, Welder);
	}
}

simulated function bool CanBeWelded()
{
	return bWeldable && WeldIntegrity < MaxWeldIntegrity;
}

simulated function bool CanBeUnwelded()
{
	return bUnweldable && WeldIntegrity > 0;
}

simulated function bool CanBeRepaired()
{
	return bRepairable;
}

simulated function bool CanBeDemoWelded()
{
	return DemoWeldRequired > 0 && DemoWeld < DemoWeldRequired;
}

simulated function float GetWeldPct()
{
	return (float(WeldIntegrity) / float(MaxWeldIntegrity)) * 100.f;
}

simulated function SetCollisionCylinderSize(float Radius, float Height)
{
	CylinderComponent(CollisionComponent).SetCylinderSize(Radius, Height);
}

simulated function float GetCollisionCylinderRadius()
{
	return CylinderComponent(CollisionComponent).CollisionRadius;
}

simulated function float GetCollisionCylinderHeight()
{
	return CylinderComponent(CollisionComponent).CollisionHeight;
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true

	Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollideActors=true
		CollisionRadius=+00100.000000
		CollisionHeight=+00200.000000
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bHidden=true
	bCollideActors=true
	bProjTarget=false
	bStatic=false
	bNoDelete=false
}