//=============================================================================
// KFCharacterInfo_Monster
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 3/19/2014
//=============================================================================

class KFCharacterInfo_Monster extends KFCharacterInfoBase
	hidecategories(Object)
	native(Pawn);

struct native ZedColorMod
{
    var() LinearColor MainColor;
    var() LinearColor PatternColor;
    var() LinearColor TrimColor;
};

/** Character mesh to use */
var(ThirdPerson) SkeletalMesh CharacterMesh<DisplayName=Body Mesh>;

/** Material overrides to use */
var(ThirdPerson) array<MaterialInterface> Skins;

/** Material overrides to use for zeds that cloak */
var(ThirdPerson) array<MaterialInterface> CloakedSkins;

/** Material overrides to use for zeds that cloak */
var(ThirdPerson) array<MaterialInterface> SpottedSkins;

/** Player-controlled material overrides to use */
var(ThirdPerson) array<MaterialInterface> PlayerControlledSkins;

/** Aggressively optimized mesh for the server with minimal bones */
var(Server) SkeletalMesh ServerMesh;

/** Additional material IDs that require MICs for gameplay material params */
var(Effects) array<int> ExtraMICIndices;

/** List of meshes to attach to the main body using the Parent Anim Component system */
var(ThirdPerson) array<SkeletalMesh> PACMeshList;

/** List of possible randomized colors to apply to zed */
var(ThirdPerson) array<ZedColorMod> RandomizedColors;

struct native StaticAttachments
{
    var() StaticMesh StaticAttachment;
	var() name AttachSocketName;
    var() name AttachBoneName;
    var() Rotator RelativeRotation;
};
/** List of static mesh attachments that will be paired to specific bones */
var(ThirdPerson) array<StaticAttachments> StaticAttachList;

/************************************************************************/
/*  Audio                                                   */
/************************************************************************/

struct native DoorSoundFx
{
	var() AkEvent Metal;
	var() AkEvent Wood;
};

var(Effects) DoorSoundFx		DoorHitSound;

/************************************************************************/
/*  Gore Info														    */
/************************************************************************/

/** Settings for special melee dismeberment such as being able to split a character in half */
struct native MeleeSpecialDismembermentInfo
{
	var() bool bAllowHorizontalSplit;
	var() name SpineBoneName<EditCondition=bAllowHorizontalSplit>;
	var() bool bAllowVerticalSplit;
	var() name LeftShoulderBoneName<EditCondition=bAllowVerticalSplit>;
	var() name RightShoulderBoneName<EditCondition=bAllowVerticalSplit>;
};

/** This is the blood splatter effect to use on the walls when this pawn is shot @see LeaveABloodSplatterDecal **/
var MaterialInstance BloodSplatterDecalMaterial;

/** Temp option in order to transition from GoreLOD to GoreMesh */
//var(Gore) bool bUseGoreMesh;

/** Gore mesh with alternate bone weights */
var(Gore) SkeletalMesh GoreMesh;

/** Materials to override on the gore mesh */
var(Gore) array<MaterialInterface> GoreSkins;

/** Player-controlled materials to override on the gore mesh */
var(Gore) array<MaterialInterface> PlayerControlledGoreSkins;

/** The LOD to use as the gore mesh */
//var(Gore) int GoreMeshLOD;

/** Gore settings for bones that can be dismembered.
	ALL HITZONE BONES MUST BE INCLUDED EVEN IF THEY CANNOT BE DISMEMBERED  */
var(Gore) editinline array<KFGoreJointInfo> GoreJointSettings;
/** Gore chunk attachment settings for the mesh */
var(Gore) editinline array<KFGoreChunkAttachmentInfo> GoreChunkAttachments;
/** Giblets to spawn on obliteration*/
var(Gore) editinline array<KFGibletInfo> GibletSettings;

/** Use for special melee dismeberment settings such as being able to split a character in half */
var(Gore) MeleeSpecialDismembermentInfo SpecialMeleeDismemberment;

/** Additional particle effect to be spawned for an explosion (if any)*/
var(Gore) ParticleSystem ExplosionEffectTemplate<DisplayName=Gib Explosion Template>;

/** Particle effect to be spawned on obliteration */
var(Gore) ParticleSystem ObliterationEffectTemplate<DisplayName=Obliteration Effect Template>;

/** Particle effect to be spawned when knocked down, stunned, etc */
var(Effects) ParticleSystem DazedEffectTemplate<DisplayName=Stunned/Knocked Down Effect Template>;

/** Use to scale the number of gibs when the character explodes. Values greater than 1
	scale up, and values smaller than 0 scale down. Must be greater than 0. This is for
	actual grenade (or other explosive) based explosions. It has no effect on explosions
	triggered by Explosion Joints */
var(Gore) float ExplosionGibScale<DisplayName=Num Gibs Scale|UIMin=0|ClampMin=0|UIMax=10.0|ClampMax=10.0> ;

/** Use to scale the impulse applied to gibs when the character explodes. Values greater than 1
	scale up, and values smaller than 0 scale down. Must be greater than 0. This affects both
	grenade based explosions and explosions triggered by Explosion Joints */
var(Gore) float ExplosionImpulseScale<DisplayName=Gib Impulse Scale|UIMin=0|ClampMin=0|UIMax=20.0|ClampMax=20.0> ;

/************************************************************************/
/*  Wild West London Weekly											    */
/************************************************************************/
var string ZEDCowboyHatMeshPath;

var transient LinearColor WWLHatMonoChromeValue;
var transient LinearColor WWLHatColorValue;

/************************************************************************/
/*  Tiny Skulls Weekly											        */
/************************************************************************/

var float TinySkullPitchAudio;

/************************************************************************/
/*  Script Functions												    */
/************************************************************************/

/** Sets the pawns character mesh from it's CharacterInfo, and updates instance of player in map if there is one. */
simulated function SetCharacterMeshFromArch( KFPawn KFP, optional KFPlayerReplicationInfo KFPRI )
{
	local int i;
	local int MaterialIndex;
    local SkeletalMeshComponent PACAttachment;
    local StaticMeshComponent StaticAttachment;
    local LinearColor AppliedColor;
	local array<MaterialInstanceConstant> ExtraMICs;
	local MaterialInstanceConstant ExtraMIC;
	local StaticAttachments NewAttachment;
	local KFGameReplicationInfo KFGRI;
	local MaterialInstanceConstant NewMIC;

	super.SetCharacterMeshFromArch( KFP, KFPRI );

    //Set randomized color indices if valid
    if (RandomizedColors.Length > 0 && KFPawn_Monster(KFP) != none)
    {
        KFPawn_Monster(KFP).RandomColorIdx = Rand(RandomizedColors.Length);
    }

	if( CharacterMesh != none )
	{
		KFGRI = KFGameReplicationInfo(KFP.WorldInfo.GRI);

		// Clear character customization settings
		KFP.DetachComponent(KFP.ThirdPersonHeadMeshComponent);
		for( i=0; i < `MAX_COSMETIC_ATTACHMENTS; i++ )
		{
			KFP.DetachComponent(KFP.ThirdPersonAttachments[i]);
			if (KFP.FirstPersonAttachments[i] != none)
			{
				KFP.DetachComponent(KFP.FirstPersonAttachments[i]);
			}
		}

        // Assign the body mesh to the pawn
		if ( KFP.WorldInfo.NetMode == NM_DedicatedServer && ServerMesh != None )
		{
			KFP.Mesh.SetSkeletalMesh(ServerMesh);
		}
		else
		{
			KFP.Mesh.SetSkeletalMesh(CharacterMesh);
		}
		KFP.Mesh.SetScale(DefaultMeshScale);

		if (KFP != none && KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 15)
		{
        	KFP.PitchAudio(TinySkullPitchAudio);
		}
		else
		{
			KFP.PitchAudio(DefaultMeshScale);
		}


		// Use material specified in the mesh asset
		// @note: need to add this if we allow character swap post-spawn (e.g. customization)
		//for( i=0; i<KFP.Mesh.GetNumElements(); i++ )
		//{
		//	KFP.Mesh.SetMaterial(i, none);
		//}

		if ( KFP.UsePlayerControlledZedSkin() )
		{
			for( i=0; i < PlayerControlledSkins.Length; i++ )
			{
				KFP.Mesh.SetMaterial(i, PlayerControlledSkins[i]);
			}
		}
		else if( Skins.Length > 0 )
		{
			for( i = 0; i < Skins.Length; ++i )
			{
				KFP.Mesh.SetMaterial( i, Skins[i] );
			}
		}

        //Use the third person attachments list to cache these, so again we can't
        //  go beyond that size, similar to the player attachments system
        for (i = 0; i < PACMeshList.Length && i < `MAX_COSMETIC_ATTACHMENTS; ++i)
        {
            PACAttachment = new(KFP) class'SkeletalMeshComponent';
            if (PACAttachment != none)
            {
                KFP.ThirdPersonAttachments[i] = PACAttachment;
                PACAttachment.SetActorCollision(false, false);
                PACAttachment.SetSkeletalMesh(PACMeshList[i]);
                PACAttachment.SetParentAnimComponent(KFP.Mesh);
                PACAttachment.SetLODParent(KFP.Mesh);
                PACAttachment.SetShadowParent(KFP.Mesh);
                PACAttachment.SetLightingChannels(KFP.PawnLightingChannel);
				ExtraMICs.AddItem(PACAttachment.CreateAndSetMaterialInstanceConstant(0));
                KFP.AttachComponent(PACAttachment);
            }
        }

        for (i = 0; i < StaticAttachList.Length; ++i)
        {
            StaticAttachment = new (KFP) class'StaticMeshComponent';
            if (StaticAttachment != none)
            {
                KFPawn_Monster(KFP).StaticAttachList.AddItem(StaticAttachment);
                StaticAttachment.SetActorCollision(false, false);
                StaticAttachment.SetStaticMesh(StaticAttachList[i].StaticAttachment);
                StaticAttachment.SetShadowParent(KFP.Mesh);
                StaticAttachment.SetLightingChannels(KFP.PawnLightingChannel);
				ExtraMICs.AddItem(StaticAttachment.CreateAndSetMaterialInstanceConstant(0));
                KFP.AttachComponent(StaticAttachment);
				if (StaticAttachList[i].AttachSocketName != `NAME_NONE)
				{
					KFP.Mesh.AttachComponentToSocket(
						StaticAttachment, StaticAttachList[i].AttachSocketName);
				}
				else
				{
					KFP.Mesh.AttachComponent(StaticAttachment, StaticAttachList[i].AttachBoneName,,
						StaticAttachList[i].RelativeRotation);
				}
            }
        }

		if (KFP != none && KFGRI.bIsWeeklyMode && (class'KFGameEngine'.static.GetWeeklyEventIndexMod() == 12))
		{
			NewAttachment.StaticAttachment =  StaticMesh(DynamicLoadObject(ZEDCowboyHatMeshPath, class'StaticMesh'));
			NewAttachment.AttachSocketName = KFPawn_Monster(KFP).ZEDCowboyHatAttachName;

			StaticAttachment = new (KFP) class'StaticMeshComponent';
            if (StaticAttachment != none)
            {
                KFPawn_Monster(KFP).StaticAttachList.AddItem(StaticAttachment);
                StaticAttachment.SetActorCollision(false, false);
                StaticAttachment.SetStaticMesh(NewAttachment.StaticAttachment);
                StaticAttachment.SetShadowParent(KFP.Mesh);
                StaticAttachment.SetLightingChannels(KFP.PawnLightingChannel);
				NewMIC = StaticAttachment.CreateAndSetMaterialInstanceConstant(0);
				NewMIC.SetVectorParameterValue('color_monochrome', WWLHatMonoChromeValue);
				NewMIC.SetVectorParameterValue('Black_White_switcher', WWLHatColorValue);
				ExtraMICs.AddItem(NewMIC);
                KFP.AttachComponent(StaticAttachment);
				KFP.Mesh.AttachComponentToSocket(StaticAttachment, NewAttachment.AttachSocketName);
            }
		}
	}

	// Initialize MICs
	if( KFP.WorldInfo.NetMode != NM_DedicatedServer && KFP.Mesh != None )
	{
		KFP.CharacterMICs.Length = 0;
		KFP.CharacterMICs[0] = KFP.Mesh.CreateAndSetMaterialInstanceConstant(0);

		foreach ExtraMICIndices(MaterialIndex)
		{
			KFP.CharacterMICs.AddItem(KFP.Mesh.CreateAndSetMaterialInstanceConstant(MaterialIndex));
		}

		foreach ExtraMICs(ExtraMIC)
		{
			KFP.CharacterMICs.AddItem(ExtraMIC);
		}
	}

    //Initialize randomized color parameters now that all MICs are setup
    if (KFP.WorldInfo.NetMode != NM_DedicatedServer && KFPawn_Monster(KFP) != none)
    {
        for (i = 0; i < KFP.CharacterMICs.Length; ++i)
        {
            if (KFPawn_Monster(KFP).RandomColorIdx >= 0)
            {
                AppliedColor = RandomizedColors[KFPawn_Monster(KFP).RandomColorIdx].MainColor;
                KFP.CharacterMICs[i].SetVectorParameterValue('vector_MainColor', AppliedColor);
                AppliedColor = RandomizedColors[KFPawn_Monster(KFP).RandomColorIdx].PatternColor;
                KFP.CharacterMICs[i].SetVectorParameterValue('vector_PatternColor', AppliedColor);
                AppliedColor = RandomizedColors[KFPawn_Monster(KFP).RandomColorIdx].TrimColor;
                KFP.CharacterMICs[i].SetVectorParameterValue('vector_TrimColor', AppliedColor);
            }
        }
    }
}

defaultproperties
{
	//GoreMeshLOD=-1
	ExplosionGibScale=1.f
	ExplosionImpulseScale=1.f

	WWLHatMonoChromeValue=(R=1.0f,G=0.0f,B=0.0f)
	WWLHatColorValue=(R=1.0f,G=0.0f,B=0.0f)

	ZEDCowboyHatMeshPath = "CHR_CosmeticSet01_MESH.cowboyhat.CHR_CowboyHat_Alberts_Cosmetic"
	TinySkullPitchAudio = 0.5f;
}
