class KFActor_DoshPile extends StaticMeshActor;

var float DoshPileMax;
var ParticleSystemComponent	ExplodeOutEffect;
var(Projectile) ParticleSystem ExplodeOutTemplate;

var ParticleSystemComponent	ExplodeInEffect;
var(Projectile) ParticleSystem ExplodeInTemplate;

var float LastPercent;

var int MaterialSlot;
var float ExplodeDelay;
var bool bDelayActive;
var bool bCreatedMic;

var int PileIndexID;

function SetValue(Float Percentfilled)
{
	// Only the main, central pile needs animate (i.e. create a MIC).
	// If this is not the main pile, simple toggle hidden; creating a MIC causes visual problems.
	if (PileIndexID != 0)
	{
		SetHidden(PercentFilled < 1.0);
		return;
	}

	if(!bDelayActive)
	{
		if (!bCreatedMic)
		{
			StaticMeshComponent.CreateAndSetMaterialInstanceConstant(MaterialSlot);
			bCreatedMic = true;
		}

		MaterialInstanceConstant(StaticMeshComponent.GetMaterial(MaterialSlot)).SetScalarParameterValue('Perc', Percentfilled);
		LastPercent = Percentfilled;
	}
	
}

simulated function Destroyed()
{
	if (ExplodeOutEffect != None)
    {
        DetachComponent(ExplodeOutEffect);
        WorldInfo.MyEmitterPool.OnParticleSystemFinished(ExplodeOutEffect);
        ExplodeOutEffect = None;
    }

    if (ExplodeInEffect != None)
    {
        DetachComponent(ExplodeInEffect);
        WorldInfo.MyEmitterPool.OnParticleSystemFinished(ExplodeInEffect);
        ExplodeInEffect = None;
    }
}

function ExplodeIn()
{
	bDelayActive = false;
	SetValue(1);
}

function ExplodeOut()
{
	bDelayActive = false;
	SetValue(0);
}

simulated function OnExplodeParticleSystemFinished(ParticleSystemComponent PSC)
{
	if (PSC == ExplodeInEffect && ExplodeInEffect != none)
	{
		ExplodeInEffect = none;
	}
	else if (PSC == ExplodeOutEffect && ExplodeInEffect != none)
	{
		ExplodeOutEffect = none;
	}

	DetachComponent(PSC);
	WorldInfo.MyEmitterPool.OnParticleSystemFinished(PSC);
}

function SpawnCompleteParticleEffects(optional bool bExplodIn = true)
{
	if (bDelayActive)
	{
		return;
	}
	bDelayActive = true;

	if(bExplodIn)
	{
		ExplodeInEffect = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ExplodeInTemplate);
		if (ExplodeInEffect != none)
		{
			ExplodeInEffect.OnSystemFinished = OnExplodeParticleSystemFinished;
			ExplodeInEffect.SetAbsolute(false, false, false);
			ExplodeInEffect.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
			ExplodeInEffect.bUpdateComponentInTick = true;
			AttachComponent(ExplodeInEffect);
		}
		else
		{
			`log("Explode in effect failed to spawn. Is this setup correctly?");
		}
		
		SetTimer(ExplodeDelay, false, nameof(ExplodeIn));
	}
	else
	{
		ExplodeOutEffect = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ExplodeOutTemplate);
		if (ExplodeOutEffect != none)
		{
			ExplodeOutEffect.OnSystemFinished = OnExplodeParticleSystemFinished;
			ExplodeOutEffect.SetAbsolute(false, false, false);
			ExplodeOutEffect.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
			ExplodeOutEffect.bUpdateComponentInTick = true;
			AttachComponent(ExplodeOutEffect);
		}
		else
		{
			`log("Explode out effect not spawned.  Is this setup correctly?");
		}
		
		SetTimer(ExplodeDelay, false, nameof(ExplodeOut));
	}

	PlayDoshPileExplodeSound();
}


function PlayDoshPileExplodeSound()
{
	local KFPlayerController KFPC;

	foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
	{
		if(KFPC.MyGfxManager != none)
		{
			KFPC.MyGfxManager.PlaySoundFromTheme( class'KFGFxMenu_DoshVault'.default.PileDisappearEventName, class'KFGFxMenu_DoshVault'.default.DoshVaultSoundThemeName);
		}
	}
}

function SpawnFillingParticleEffects()
{
	//NO FILL PARTICLE YET
}

DefaultProperties
{
	ExplodeInTemplate=ParticleSystem'FX_Environmental_EMIT_THREE.FX_Dosh_Vault_Appear_01'

	ExplodeOutTemplate=ParticleSystem'FX_Environmental_EMIT_THREE.FX_Dosh_Vault_Disappear_01'

    bStatic=false
    bNoDelete=false

    DoshPileMax=1000000.0

    MaterialSlot=1

    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'econ_dosh_mesh.Econ_Dosh_Pallet_SM'
    End Object

    ExplodeDelay=1.0f
	bCreatedMic=false

	LastPercent=INDEX_NONE
}