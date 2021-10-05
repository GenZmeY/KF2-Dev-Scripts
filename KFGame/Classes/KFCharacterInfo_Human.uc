//=============================================================================
// KFCharacterInfo_Human
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 3/19/2014
//=============================================================================

class KFCharacterInfo_Human extends KFCharacterInfoBase
	native(Pawn)
	implements(KFUnlockableAsset)
	hidecategories(Object);

`include(KFGame\KFGameAnalytics.uci);
`include(KFGame\KFMatchStats.uci);

/************************************************************************/
/*  Identification													    */
/************************************************************************/

var() const int UnlockAssetID;

/** Whether these are female characters */
var() bool bIsFemale;

/************************************************************************/
/*  3P Mesh Info							                            */
/************************************************************************/

/** The material ID for the skin in the mesh */
var(ThirdPerson) int HeadMaterialID;
var(ThirdPerson) int BodyMaterialID;

enum ECosmeticType
{
	ECosmeticType_Head,
	ECosmeticType_Body,
	ECosmeticType_Attachment,
	ECosmeticType_Arms
};

struct native SkinVariant
{
	var() const int UnlockAssetID;
	/** The path to this skins package and texture */
	var() Texture UITexture;
	/** The material this outfit can use */
 	var MaterialInstance Skin;
	var() string SkinName;
	/** The first person material of this outfit */
	var MaterialInstance Skin1p;
	var() string Skin1pName;
};

struct native OutfitVariants
{
	//var() const int UnlockAssetID;
	/** The path to this skins package and texture */
	var() Texture UITexture;
	/** Hard reference to the mesh, async load. */
	var edithide transient SkeletalMesh Mesh;
	/** Outfit mesh name. Must be of form PackageName.MeshName */
	var() string MeshName;
	/** Reference to the different skin variants for a particular outfit mesh */
	var() array<SkinVariant> SkinVariations;
};

/** List of booleans that will effect which items can be attached with the current attachment */
struct native AttachmentOverrideList
{
	var() bool bHat;
	var() bool bFace;
	var() bool bEyes;
	var() bool bJaw;
	var() bool bArmband;
	var() bool bBackpack;

	/** List of cosmetic indices that this attachment will detach, if they are currently attached to a player */
	var array<byte> SpecialOverrideIds;
};

struct native AttachmentVariants
{
	var() KFCharacterAttachment AttachmentItem;

	var() const int UnlockAssetID;
	/** The path to this skins package and texture */
	var Texture UITexture;
	/** If set enables the material mask parameter on the assigned head variant */
	var() bool bMaskHeadMesh;
	/** Hard reference to the mesh, async load. */
	var edithide transient StaticMesh MeshStatic;
	/** Hard reference to the mesh, async load. */
	var edithide transient SkeletalMesh MeshSkeletal;
	/** Attachment mesh name. Must be of form PackageName.MeshName */
	var() string MeshName;
	/** Name of the socket that it attaches to. The socket MUST exist in the body mesh for static mesh
		attachments to work. SocketName is also used to resolve conflicts - when more than one attachment
		tries to attach to the same socket, it will replace the previously existing attachment. It will keep
		both if there is no conflict. NOTE: Skeletal meshes do not require sockets for attachment, but the socket name
		can still be used for conflit resolution. */
	var name SocketName;
	/** Hard reference to the mesh, async load. */
	var edithide transient StaticMesh MeshStatic1p;
	/** Hard reference to the mesh, async load. */
	var edithide transient SkeletalMesh MeshSkeletal1p;
	/** Mesh name for 1p attachmentt */
	var() string MeshName1p;
	/** Name of the socket that the 1p mesh attaches to. If bIsSkeletalAttachment is true, then the mesh will attach
	    to the ParentAnimComponent. */
	var() name SocketName1p;
	/** Translation relative to given socket (for additional control) */
	var() vector RelativeTranslation;
	/** Rotation relative to given socket (for additional control) */
	var() rotator RelativeRotation;
	/** Scale relative to given socket (for additional control) */
	var() vector RelativeScale;
	/** Distance at which the attachment will be hidden (distance culled). If 0, it is never culled */
	var float MaxDrawDistance;
	/** Material ID used for skin variations for this attachment (default is 0) */
	var int SkinMaterialID;
	/** Reference to the different skin variants for a particular attachment mesh */
	var array<SkinVariant> SkinVariations;
	/** List of sockets that this attachment will detach, if they are currently attached to a player */
	var AttachmentOverrideList OverrideList;

	/** List of cosmetic indices that this attachment will detach, if they are currently attached to a player */
	var array<byte> SpecialOverrideIds;

	var() array<KFCharacterAttachment> SpecialOverrideAttachments;

	structdefaultproperties
	{
		RelativeScale=(X=1.f,Y=1.f,Z=1.f)
	}
};

/**
	Whether to enable Character Customization. If TRUE, it uses the settings below
	to assemble the character, otherwise it uses the CharacterMesh
*/

/** The package key for async loading purposes. Console only. */
var(ThirdPerson) string CosmeticsPackageKey;
/** The outfit variants for a character. Used for Character Customization */
var(ThirdPerson) const array<OutfitVariants> BodyVariants;
/** The head variants for a character. Used for Character Customization */
var(ThirdPerson) const array<OutfitVariants> HeadVariants;
/** Various cosmetic variants for a character. Used for Character Customization */
var(ThirdPerson) const array<AttachmentVariants> CosmeticVariants;

/************************************************************************/
/*  1P Character Info                                                   */
/************************************************************************/

struct native FirstPersonArmVariants
{
	/** Arms mesh. */
	var edithide transient SkeletalMesh Mesh;
	/** Mesh name. Must be of form PackageName.MeshName */
	var() string MeshName;
	/**	Reference to the different skin variants for a particular arms mesh */
 	var edithide init array<MaterialInstance> SkinVariants;
	var() array<string> SkinVariantsName;
};

/** The outfit variants for a character. Used for Character Customization */
var(FirstPerson) array<FirstPersonArmVariants> CharacterArmVariants;

/** Package to load to find the arm mesh for this char. */
var(FirstPerson) string	ArmMeshPackageName;

/** Name of mesh within ArmMeshPackageName to use for arms. */
var(FirstPerson) SkeletalMesh	ArmMesh;

/** Package that contains team-skin materials for first-person arms. */
var(FirstPerson) string			ArmSkinPackageName;

/************************************************************************/
/*  Favorite Weapons (for dialog)                                       */
/************************************************************************/

// make sure this matches NUM_FAVE_WEAPS in KFDialogManager
const NUM_FAVE_WEAPS = 8;
var(FaveWeapons) editconst name FavoriteWeaponClassNames[NUM_FAVE_WEAPS];
var(FaveWeapons) editoronly class<KFWeaponDefinition> FavoriteWeaponClassDefs[NUM_FAVE_WEAPS]<AllowAbstract>;

/************************************************************************/
/*  Emote AnimSets                             					        */
/************************************************************************/
var Animset EmoteAnimset;

/************************************************************************/
/*  Wild West London Weekly											    */
/************************************************************************/
var transient LinearColor WWLHatMonoChromeValue;
var transient LinearColor WWLHatColorValue;

/************************************************************************/
/*  Native Functions												    */
/************************************************************************/

cpptext
{
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	// set FavoriteWeaponClassNames from FavoriteWeaponClassDefs
	void SetFavoriteWeaponClassNames();

	virtual void AddReferencedObjects(TArray<UObject*>& ObjectArray);
}

/************************************************************************/
/*  Script Functions												    */
/************************************************************************/

/** Implements KFUnlockableAsset */
function int GetAssetId()
{
	return UnlockAssetID;
}

function string GetMesh(const out AttachmentVariants Variant)
{
	if (Len(Variant.MeshName) > 0)
	{
		return Variant.MeshName;
	}
	else
	{
		return Variant.AttachmentItem.MeshName;
	}
}

function string GetMeshByIndex(int index)
{
	return GetMesh(CosmeticVariants[index]);
}

function string Get1pMesh(const out AttachmentVariants Variant)
{
	if (Len(Variant.MeshName1p) > 0)
	{
		return Variant.MeshName1p;
	}
	else
	{
		return Variant.AttachmentItem.MeshName1p;
	}
}

function string Get1pMeshByIndex(int index)
{
	return Get1pMesh(CosmeticVariants[index]);
}

/** Return the 1P arm skeletal mesh representation for the class */
function SkeletalMesh GetFirstPersonArms()
{
	if (ArmMesh == None)
	{
		`warn("Unable to load first person arms");
	}

	return ArmMesh;
}

/** Return the texture portrait stored for this character */
/*function Texture GetCharPortrait(int TeamNum)
{
	return (TeamNum < DefaultTeamHeadPortrait.length) ? DefaultTeamHeadPortrait[TeamNum] : DefaultHeadPortrait;
}*/

function int GetFavoriteWeaponIndexOf( Weapon W )
{
	local int i;

    for( i = 0; i < NUM_FAVE_WEAPS; ++i )
    {
       if( W.Class.Name == FavoriteWeaponClassNames[i] )
       {
           return i;
       }
    }

    return -1;
}

/** Sets misc. properties from the character info */
simulated function SetCharacterFromArch( KFPawn KFP, optional KFPlayerReplicationInfo KFPRI )
{
   	super.SetCharacterFromArch( KFP, KFPRI );

	if ( KFPRI == none )
	{
        `Warn("Does not have a KFPRI" @ Self);
	 	return;
	}

   	// a little hacky, relies on presumption that enum vals 0-3 are male, 4-8 are female
	if ( bIsFemale )
	{
		KFPRI.TTSSpeaker = ETTSSpeaker(Rand(4));
	}
	else
	{
		KFPRI.TTSSpeaker = ETTSSpeaker(Rand(5) + 4);
	}
}

/** Sets the pawns character mesh from it's CharacterInfo, and updates instance of player in map if there is one. */
simulated function SetCharacterMeshFromArch( KFPawn KFP, optional KFPlayerReplicationInfo KFPRI )
{
	local int AttachmentIdx, CosmeticMeshIdx;
	local bool bMaskHeadMesh;
	//local int NumberOfCosmetics, NumberOfCosmeticsPostRemoval;

   	super.SetCharacterMeshFromArch( KFP, KFPRI );

   	if ( KFPRI == none )
	{
        `Warn("Does not have a KFPRI" @ Self);
	 	return;
	}

	// Body mesh & skin. Index of 255 implies use index 0 (default).
    SetBodyMeshAndSkin(
    	KFPRI.RepCustomizationInfo.BodyMeshIndex,
    	KFPRI.RepCustomizationInfo.BodySkinIndex,
    	KFP, KFPRI);

    // Head mesh & skin. Index of 255 implies use index 0 (default).
	SetHeadMeshAndSkin(
		KFPRI.RepCustomizationInfo.HeadMeshIndex,
		KFPRI.RepCustomizationInfo.HeadSkinIndex,
		KFP, KFPRI);

	// First person arms mesh and skin are based on body mesh & skin.
	// Index of 255 implies use index 0 (default).
	SetArmsMeshAndSkin(
    	KFPRI.RepCustomizationInfo.BodyMeshIndex,
    	KFPRI.RepCustomizationInfo.BodySkinIndex,
    	KFP, KFPRI);

	// skip dedicated for purely cosmetic stuff
	if ( KFP.WorldInfo.NetMode != NM_DedicatedServer )
	{
		// Must clear all attachments before trying to attach new ones,
		// otherwise we might accidentally remove things we're not supposed to
		for( AttachmentIdx=0; AttachmentIdx < `MAX_COSMETIC_ATTACHMENTS; AttachmentIdx++ )
		{
			// Clear any previous attachments from other characters
			DetachAttachment(AttachmentIdx, KFP);
		}

		// Cosmetic attachment mesh & skin. Index of 255 implies don't use any attachments (default)
		for( AttachmentIdx=0; AttachmentIdx < `MAX_COSMETIC_ATTACHMENTS; AttachmentIdx++ )
		{
			CosmeticMeshIdx = KFPRI.RepCustomizationInfo.AttachmentMeshIndices[AttachmentIdx];
			if ( CosmeticMeshIdx != `CLEARED_ATTACHMENT_INDEX && CosmeticMeshIdx != INDEX_NONE)
			{
					//NumberOfCosmetics++;
					bMaskHeadMesh = bMaskHeadMesh || CosmeticVariants[CosmeticMeshIdx].bMaskHeadMesh;
					
					// Attach all saved attachments to the character
					SetAttachmentMeshAndSkin(
						CosmeticMeshIdx,
						KFPRI.RepCustomizationInfo.AttachmentSkinIndices[AttachmentIdx],
						KFP, KFPRI);
			}
		}

		// Check again for all cosmetic in case one of them was removed, this will fix problems with masked heads
		/*for( AttachmentIdx=0; AttachmentIdx < `MAX_COSMETIC_ATTACHMENTS; AttachmentIdx++ )
		{
			CosmeticMeshIdx = KFPRI.RepCustomizationInfo.AttachmentMeshIndices[AttachmentIdx];
			if ( CosmeticMeshIdx != `CLEARED_ATTACHMENT_INDEX && CosmeticMeshIdx != INDEX_NONE)
			{
					NumberOfCosmeticsPostRemoval++;
			}
		}*/

		// If the number of cosmetics changed, made a new set of the mesh/cosmetics recursively and return
		/*if(NumberOfCosmeticsPostRemoval != NumberOfCosmetics)
		{
			SetCharacterMeshFromArch( KFP, KFPRI );
			return;
		}*/

		InitCharacterMICs(KFP, bMaskHeadMesh);
	}
}

/** Create all the MICs we'll need for material params later */
private function InitCharacterMICs(KFPawn P, optional bool bMaskHead)
{
	local int i;
	
	if( P.WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	P.CharacterMICs.Remove(0, P.CharacterMICs.Length);

	// body MIC
	if ( P.Mesh != None )
	{
		P.CharacterMICs[0] = P.Mesh.CreateAndSetMaterialInstanceConstant(BodyMaterialID);
	}

	// head MIC
	if( P.ThirdPersonHeadMeshComponent != None )
	{
		P.CharacterMICs[1] = P.ThirdPersonHeadMeshComponent.CreateAndSetMaterialInstanceConstant(HeadMaterialID);

		if ( bMaskHead )
		{
			// initial mask for new head MIC (also see ResetHeadMaskParam())
			P.CharacterMICs[1].SetScalarParameterValue('Scalar_Mask', 1.f);
		}
	}

	// attachment MIC
	for( i=0; i < `MAX_COSMETIC_ATTACHMENTS; i++ )
	{
		if( P.ThirdPersonAttachments[i] != none )
		{
			P.CharacterMICs.AddItem(P.ThirdPersonAttachments[i].CreateAndSetMaterialInstanceConstant(0));
		}

		if (P.FirstPersonAttachments[i] != none)
		{
			P.CharacterMICs.AddItem(P.FirstPersonAttachments[i].CreateAndSetMaterialInstanceConstant(0));
		}
	}
}

private function SetBodyMeshAndSkin(
	byte CurrentBodyMeshIndex,
	byte CurrentBodySkinIndex,
	KFPawn KFP,
	KFPlayerReplicationInfo KFPRI)
{
	local string CharBodyMeshName;
	local SkeletalMesh CharBodyMesh;

    //Always use default body on servers
    if (KFP.WorldInfo.NetMode == NM_DedicatedServer)
    {
        CurrentBodyMeshIndex = 0;
        CurrentBodySkinIndex = 0;
    }

	// Character Mesh
	if( BodyVariants.length > 0 )
	{
		// Assign a skin to the body mesh as a material override
		CurrentBodyMeshIndex = (CurrentBodyMeshIndex < BodyVariants.length) ? CurrentBodyMeshIndex : 0;

		if (KFPRI.StartLoadCosmeticContent(self, ECOSMETICTYPE_Body, CurrentBodyMeshIndex))
		{
			return;
		}

		// Retrieve the name of the meshes to be used from the archetype
		CharBodyMeshName = BodyVariants[CurrentBodyMeshIndex].MeshName;

		// Load the meshes
		CharBodyMesh = SkeletalMesh(DynamicLoadObject(CharBodyMeshName, class'SkeletalMesh'));

		// Assign the body mesh to the pawn
		if ( CharBodyMesh != KFP.Mesh.SkeletalMesh )
		{
			KFP.Mesh.SetSkeletalMesh(CharBodyMesh);
			KFP.OnCharacterMeshChanged();
		}

		if (KFP.WorldInfo.NetMode != NM_DedicatedServer)
		{
			SetBodySkinMaterial(BodyVariants[CurrentBodyMeshIndex], CurrentBodySkinIndex, KFP);
		}
	}
	else
	{
		`warn("Character does not have a valid mesh");
	}
}

protected simulated function SetBodySkinMaterial(OutfitVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP)
{
	local int i;
	if (KFP.WorldInfo.NetMode != NM_DedicatedServer)
	{
		if( CurrentVariant.SkinVariations.length > 0 )
		{
			// Assign a skin to the body mesh as a material override
			NewSkinIndex = (NewSkinIndex < CurrentVariant.SkinVariations.length) ? NewSkinIndex : 0;
			KFP.Mesh.SetMaterial(BodyMaterialID, CurrentVariant.SkinVariations[NewSkinIndex].Skin);
		}
		else
		{
			// Use material specified in the mesh asset
			for( i=0; i<KFP.Mesh.GetNumElements(); i++ )
			{
				KFP.Mesh.SetMaterial(i, none);
			}
		}
	}
}

protected simulated function SetHeadSkinMaterial(OutfitVariants CurrentVariant, byte NewSkinIndex, KFPawn KFP)
{
	local int i;
	if (KFP.WorldInfo.NetMode != NM_DedicatedServer)
	{
		if( CurrentVariant.SkinVariations.length > 0 )
		{
			// Assign a skin to the body mesh as a material override
			NewSkinIndex = (NewSkinIndex < CurrentVariant.SkinVariations.length) ? NewSkinIndex : 0;
			KFP.ThirdPersonHeadMeshComponent.SetMaterial(HeadMaterialID, CurrentVariant.SkinVariations[NewSkinIndex].Skin);
		}
		else
		{
			// Use material specified in the mesh asset
			for( i=0; i<KFP.ThirdPersonHeadMeshComponent.GetNumElements(); i++ )
			{
				KFP.ThirdPersonHeadMeshComponent.SetMaterial(i, none);
			}
		}
	}
}

private function SetHeadMeshAndSkin(
	byte CurrentHeadMeshIndex,
	byte CurrentHeadSkinIndex,
	KFPawn KFP,
	KFPlayerReplicationInfo KFPRI)
{
	local string CharHeadMeshName;
	local SkeletalMesh CharHeadMesh;

	if ( HeadVariants.length > 0 )
	{
		CurrentHeadMeshIndex = (CurrentHeadMeshIndex < HeadVariants.length) ? CurrentHeadMeshIndex : 0;

		if (KFPRI.StartLoadCosmeticContent(self, ECOSMETICTYPE_Head, CurrentHeadMeshIndex))
		{
			return;
		}

		CharHeadMeshName = HeadVariants[CurrentHeadMeshIndex].MeshName;
		CharHeadMesh = SkeletalMesh(DynamicLoadObject(CharHeadMeshName, class'SkeletalMesh'));

		// Parent the third person head mesh to the body mesh
		KFP.ThirdPersonHeadMeshComponent.SetSkeletalMesh(CharHeadMesh);
		KFP.ThirdPersonHeadMeshComponent.SetScale(DefaultMeshScale);

		KFP.ThirdPersonHeadMeshComponent.SetParentAnimComponent(KFP.Mesh);
		KFP.ThirdPersonHeadMeshComponent.SetShadowParent(KFP.Mesh);
		KFP.ThirdPersonHeadMeshComponent.SetLODParent(KFP.Mesh);

		KFP.AttachComponent(KFP.ThirdPersonHeadMeshComponent);

		if (KFP.WorldInfo.NetMode != NM_DedicatedServer)
		{
			SetHeadSkinMaterial(HeadVariants[CurrentHeadMeshIndex], CurrentHeadSkinIndex, KFP);
		}
	}
}

/**
 * Check to see if the attachment is supported for this mesh. Go through all the sockets of the mesh
 * and check if the socket for the attachment is present. If not, that attachment is not supported.
 * Network: Local Player Only
 */
function bool IsAttachmentAvailable(const out AttachmentVariants Attachment, Pawn PreviewPawn)
{
	if ( !class'KFUnlockManager'.static.GetAvailableAttachment(Attachment) )
	{
		//`log("Attachment" @ Attachment.MeshName @ "is not purchased.");
		return FALSE;
	}
	else if ( Attachment.AttachmentItem.SocketName != ''
		&& PreviewPawn.Mesh.GetSocketByName(Attachment.AttachmentItem.SocketName) == None )
	{
		`log("Attachment" @ Attachment.MeshName @ "is missing a required socket.");
		return FALSE;
	}

	return TRUE;
}

// Assigning the Arms Mesh default properties to the 1p cosmetic.
native function SetFirstPersonCosmeticAttachment(SkeletalMeshComponent SkeletalComponent);

protected simulated function SetAttachmentMesh(int CurrentAttachmentMeshIndex, int AttachmentSlotIndex, string CharAttachmentMeshName, name CharAttachmentSocketName, SkeletalMeshComponent PawnMesh, KFPawn KFP, bool bIsFirstPerson = false)
{
	local StaticMeshComponent StaticAttachment;
	local SkeletalMeshComponent SkeletalAttachment;
	local bool bIsSkeletalAttachment;
	local StaticMesh CharAttachmentStaticMesh;
	local SkeletalMesh CharacterAttachmentSkelMesh;
	local float MaxDrawDistance;
	local SkeletalMeshSocket AttachmentSocket;
	local vector AttachmentLocationRelativeToSocket, AttachmentScaleRelativeToSocket;
	local rotator AttachmentRotationRelativeToSocket;

	MaxDrawDistance = CosmeticVariants[CurrentAttachmentMeshIndex].AttachmentItem.MaxDrawDistance;
	AttachmentLocationRelativeToSocket = CosmeticVariants[CurrentAttachmentMeshIndex].RelativeTranslation;
	AttachmentRotationRelativeToSocket = CosmeticVariants[CurrentAttachmentMeshIndex].RelativeRotation;
	AttachmentScaleRelativeToSocket = CosmeticVariants[CurrentAttachmentMeshIndex].RelativeScale;
	bIsSkeletalAttachment = CosmeticVariants[CurrentAttachmentMeshIndex].AttachmentItem.bIsSkeletalAttachment;

	//`log("AttachmentLocationRelativeToSocket: x="$AttachmentLocationRelativeToSocket.x@"y="$AttachmentLocationRelativeToSocket.y@"z="$AttachmentLocationRelativeToSocket.z);
	// If it is a skeletal attachment, parent anim it to the body mesh
	if (bIsSkeletalAttachment)
	{
		if (bIsFirstPerson && (SkeletalMeshComponent(KFP.FirstPersonAttachments[AttachmentSlotIndex]) != none))
		{
			SkeletalAttachment = SkeletalMeshComponent(KFP.FirstPersonAttachments[AttachmentSlotIndex]);
		}
		else if (!bIsFirstPerson && (SkeletalMeshComponent(KFP.ThirdPersonAttachments[AttachmentSlotIndex]) != none))
		{
			SkeletalAttachment = SkeletalMeshComponent(KFP.ThirdPersonAttachments[AttachmentSlotIndex]);
		}
		else
		{
			SkeletalAttachment = new(KFP) class'KFSkeletalMeshComponent';
			if (bIsFirstPerson)
			{
				SetFirstPersonCosmeticAttachment(SkeletalAttachment);
			}
			SkeletalAttachment.SetActorCollision(false, false);

			if(bIsFirstPerson)
			{
				KFP.FirstPersonAttachments[AttachmentSlotIndex] = SkeletalAttachment;
			}
			else
			{
				KFP.ThirdPersonAttachments[AttachmentSlotIndex] = SkeletalAttachment;
			}
		}

		// Load and assign skeletal mesh
		CharacterAttachmentSkelMesh = SkeletalMesh(DynamicLoadObject(CharAttachmentMeshName, class'SkeletalMesh'));
		SkeletalAttachment.SetSkeletalMesh(CharacterAttachmentSkelMesh);

		// Parent animation and LOD transitions to body mesh
		SkeletalAttachment.SetParentAnimComponent(PawnMesh);
		SkeletalAttachment.SetLODParent(PawnMesh);
		SkeletalAttachment.SetScale(DefaultMeshScale);
		SkeletalAttachment.SetCullDistance(MaxDrawDistance);
		SkeletalAttachment.SetShadowParent(PawnMesh);
		SkeletalAttachment.SetLightingChannels(KFP.PawnLightingChannel);

		KFP.AttachComponent(SkeletalAttachment);
	}
	// Otherwise (if static), attach to a socket on the body mesh
	else
	{
		if (!bIsFirstPerson && (StaticMeshComponent(KFP.ThirdPersonAttachments[AttachmentSlotIndex]) != none))
		{
			StaticAttachment = StaticMeshComponent(KFP.ThirdPersonAttachments[AttachmentSlotIndex]);
		}
		else if (bIsFirstPerson && (StaticMeshComponent(KFP.FirstPersonAttachments[AttachmentSlotIndex]) != none))
		{
			StaticAttachment = StaticMeshComponent(KFP.FirstPersonAttachments[AttachmentSlotIndex]);
		}
		else
		{
			StaticAttachment = new(KFP) class'StaticMeshComponent';
			StaticAttachment.SetActorCollision(false, false);

			if(bIsFirstPerson)
			{
				KFP.FirstPersonAttachments[AttachmentSlotIndex] = StaticAttachment;
			}
			else
			{
				KFP.ThirdPersonAttachments[AttachmentSlotIndex] = StaticAttachment;
			}
		}

		// Load and assign static mesh
		CharAttachmentStaticMesh = StaticMesh(DynamicLoadObject(CharAttachmentMeshName, class'StaticMesh'));
		StaticAttachment.SetStaticMesh(CharAttachmentStaticMesh);

		// Set properties
		StaticAttachment.SetScale(DefaultMeshScale);
		StaticAttachment.SetCullDistance(MaxDrawDistance);
		StaticAttachment.SetShadowParent(KFP.Mesh);
		StaticAttachment.SetLightingChannels(KFP.PawnLightingChannel);

		// For static meshes, attach to given socket
		AttachmentSocket = PawnMesh.GetSocketByName(CharAttachmentSocketName);
		PawnMesh.AttachComponent(
			StaticAttachment,
			AttachmentSocket.BoneName,
			AttachmentSocket.RelativeLocation + AttachmentLocationRelativeToSocket,
			AttachmentSocket.RelativeRotation + AttachmentRotationRelativeToSocket,
			AttachmentSocket.RelativeScale * AttachmentScaleRelativeToSocket);
	}

	if(bIsFirstPerson)
	{
		KFP.FirstPersonAttachmentSocketNames[AttachmentSlotIndex] = CharAttachmentSocketName;
	}
	else
	{
		KFP.ThirdPersonAttachmentSocketNames[AttachmentSlotIndex] = CharAttachmentSocketName;
	}
}

protected simulated function SetAttachmentSkinMaterial(
	int PawnAttachmentIndex,
	const out AttachmentVariants CurrentVariant,
	byte NewSkinIndex,
	KFPawn KFP,
	optional bool bIsFirstPerson)
{
	local int i;
	if (KFP.WorldInfo.NetMode != NM_DedicatedServer)
	{
		if( CurrentVariant.AttachmentItem.SkinVariations.length > 0 )
		{
			// Assign a skin to the attachment mesh as a material override
			if ( NewSkinIndex < CurrentVariant.AttachmentItem.SkinVariations.length )
			{
				if (bIsFirstPerson)
				{
					if (KFP.FirstPersonAttachments[PawnAttachmentIndex] != none)
					{
						KFP.FirstPersonAttachments[PawnAttachmentIndex].SetMaterial(
							CurrentVariant.AttachmentItem.SkinMaterialID,
							CurrentVariant.AttachmentItem.SkinVariations[NewSkinIndex].Skin1p);
					}
				}
				else
				{
					KFP.ThirdPersonAttachments[PawnAttachmentIndex].SetMaterial(
						CurrentVariant.AttachmentItem.SkinMaterialID,
						CurrentVariant.AttachmentItem.SkinVariations[NewSkinIndex].Skin);
				}
			}
			else
			{
				`log("Out of bounds skin index for" @ CurrentVariant.MeshName);
				RemoveAttachmentMeshAndSkin(PawnAttachmentIndex, KFP);
			}
		}
		else
		{
			if (bIsFirstPerson)
			{
				if (KFP.FirstPersonAttachments[PawnAttachmentIndex] != none)
				{
					for (i = 0; i < KFP.FirstPersonAttachments[PawnAttachmentIndex].GetNumElements(); i++)
					{
						KFP.FirstPersonAttachments[PawnAttachmentIndex].SetMaterial(i, none);
					}
				}
			}
			else
			{
				// Use material specified in the mesh asset
				for( i=0; i < KFP.ThirdPersonAttachments[PawnAttachmentIndex].GetNumElements(); i++ )
				{
					KFP.ThirdPersonAttachments[PawnAttachmentIndex].SetMaterial(i, none);
				}
			}
		}
	}
}

protected simulated function SetWeeklyCowboyAttachmentSkinMaterial(
	int PawnAttachmentIndex,
	const out AttachmentVariants CurrentVariant,
	byte NewSkinIndex,
	KFPawn KFP,
	optional bool bIsFirstPerson)
{
	local MaterialInstanceConstant MIC;
	
	if (KFP.WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bIsFirstPerson)
		{
			if (KFP.FirstPersonAttachments[PawnAttachmentIndex] != none)
			{
				KFP.FirstPersonAttachments[PawnAttachmentIndex].SetMaterial(
					CurrentVariant.AttachmentItem.SkinMaterialID,
					CurrentVariant.AttachmentItem.SkinVariations[0].Skin1p);

				MIC = MaterialInstanceConstant(KFP.FirstPersonAttachments[PawnAttachmentIndex].GetMaterial(0));
			}
		}
		else
		{
			KFP.ThirdPersonAttachments[PawnAttachmentIndex].SetMaterial(
				CurrentVariant.AttachmentItem.SkinMaterialID,
				CurrentVariant.AttachmentItem.SkinVariations[0].Skin);
			MIC = MaterialInstanceConstant(KFP.ThirdPersonAttachments[PawnAttachmentIndex].GetMaterial(0));
		}

		if (MIC != none)
		{
			MIC.SetVectorParameterValue('color_monochrome', WWLHatMonoChromeValue);
			MIC.SetVectorParameterValue('Black_White_switcher', WWLHatColorValue);
		}
	}
}

/** Called on owning client to change a cosmetic attachment or on other clients via replication */
private function SetAttachmentMeshAndSkin(
	int CurrentAttachmentMeshIndex,
	int CurrentAttachmentSkinIndex,
	KFPawn KFP,
	KFPlayerReplicationInfo KFPRI)
{
	local string CharAttachmentMeshName;
	local name CharAttachmentSocketName;
	local int AttachmentSlotIndex;
	local KFGameReplicationInfo KFGRI;

	if (KFP.WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}

	// Clear any previously attachments for the same slot
	//DetachConflictingAttachments(CurrentAttachmentMeshIndex, KFP, KFPRI);
	// Get a slot where this attachment could fit
	AttachmentSlotIndex = GetAttachmentSlotIndex(CurrentAttachmentMeshIndex, KFP, KFPRI);
	if (AttachmentSlotIndex == INDEX_NONE)
	{
		return;
	}

	// Since cosmetic attachments are optional, do not choose index 0 if none is
	// specified unlike the the head and body meshes
	if ( CosmeticVariants.length > 0 &&
		 CurrentAttachmentMeshIndex < CosmeticVariants.length )
	{
		if (KFPRI.StartLoadCosmeticContent(self, ECOSMETICTYPE_Attachment, CurrentAttachmentMeshIndex))
		{
			return;
		}

		// Attach 1p attachment, if applicable
		CharAttachmentMeshName = Get1pMeshByIndex(CurrentAttachmentMeshIndex);
		if (CharAttachmentMeshName != "")
		{
			CharAttachmentSocketName = CosmeticVariants[CurrentAttachmentMeshIndex].AttachmentItem.SocketName1p;

			// If previously attached and we could have changed outfits (e.g. local player UI) then re-validate
			// required skeletal mesh socket.  Must be after body mesh DLO, but before AttachComponent.
			if ( KFP.IsLocallyControlled() )
			{
				if ( CharAttachmentSocketName != '' && KFP.Mesh.GetSocketByName(CharAttachmentSocketName) == None )
				{
					RemoveAttachmentMeshAndSkin(AttachmentSlotIndex, KFP, KFPRI);
					return;
				}
			}

			SetAttachmentMesh(CurrentAttachmentMeshIndex, AttachmentSlotIndex, CharAttachmentMeshName,
				CharAttachmentSocketName, KFP.ArmsMesh, KFP, true);

			KFGRI = KFGameReplicationInfo(KFP.WorldInfo.GRI);
			if (AttachmentSlotIndex == 2 && KFP != none && KFGRI.bIsWeeklyMode && (class'KFGameEngine'.static.GetWeeklyEventIndexMod() == 12))
			{
				SetWeeklyCowboyAttachmentSkinMaterial(
					AttachmentSlotIndex,
					CosmeticVariants[CurrentAttachmentMeshIndex],
					CurrentAttachmentSkinIndex,
					KFP,
					true);
			}
			else
			{
				SetAttachmentSkinMaterial(
					AttachmentSlotIndex,
					CosmeticVariants[CurrentAttachmentMeshIndex],
					CurrentAttachmentSkinIndex,
					KFP,
					true);
			}
		}
		else
		{
			KFP.FirstPersonAttachments[AttachmentSlotIndex] = none;
			KFP.FirstPersonAttachmentSocketNames[AttachmentSlotIndex] = '';
		}

		// Attach 3p attachment, if applicable
		CharAttachmentMeshName = GetMeshByIndex(CurrentAttachmentMeshIndex);
		if (CharAttachmentMeshName != "")
		{
			CharAttachmentSocketName = CosmeticVariants[CurrentAttachmentMeshIndex].AttachmentItem.SocketName;

			// If previously attached and we could have changed outfits (e.g. local player UI) then re-validate
			// required skeletal mesh socket.  Must be after body mesh DLO, but before AttachComponent.
			if ( KFP.IsLocallyControlled() )
			{
				if ( CharAttachmentSocketName != '' && KFP.Mesh.GetSocketByName(CharAttachmentSocketName) == None )
				{
					RemoveAttachmentMeshAndSkin(AttachmentSlotIndex, KFP, KFPRI);
					return;
				}
			}

			SetAttachmentMesh(CurrentAttachmentMeshIndex, AttachmentSlotIndex, CharAttachmentMeshName,
				CharAttachmentSocketName, KFP.Mesh, KFP, false);

			KFGRI = KFGameReplicationInfo(KFP.WorldInfo.GRI);
			if (AttachmentSlotIndex == 2 && KFP != none && KFGRI.bIsWeeklyMode && (class'KFGameEngine'.static.GetWeeklyEventIndexMod() == 12))
			{
				SetWeeklyCowboyAttachmentSkinMaterial(
					AttachmentSlotIndex,
					CosmeticVariants[CurrentAttachmentMeshIndex],
					CurrentAttachmentSkinIndex,
					KFP,
					false);
			}
			else
			{
				SetAttachmentSkinMaterial(
					AttachmentSlotIndex,
					CosmeticVariants[CurrentAttachmentMeshIndex],
					CurrentAttachmentSkinIndex,
					KFP,
					false);
			}
		}
	}

	// Treat `CLEARED_ATTACHMENT_INDEX as special value (for client detachment)
	if( CurrentAttachmentMeshIndex == `CLEARED_ATTACHMENT_INDEX )
	{
		RemoveAttachmentMeshAndSkin(AttachmentSlotIndex, KFP, KFPRI);
	}
}

/**
 * Removes any attachments that exist in the same socket or have overriding cases
 * Network: Local Player
 */
function DetachConflictingAttachments(int NewAttachmentMeshIndex, KFPawn KFP, optional KFPlayerReplicationInfo KFPRI, optional out array<int> out_RemovedAttachments )
{
	local name NewAttachmentSocketName;
	local int i, CurrentAttachmentIdx;

	if ( CosmeticVariants.length > 0 &&
		 NewAttachmentMeshIndex < CosmeticVariants.length && NewAttachmentMeshIndex != INDEX_NONE)
	{
		// The socket that this attachment requires
		NewAttachmentSocketName = CosmeticVariants[NewAttachmentMeshIndex].AttachmentItem.SocketName;

		for( i=0; i < `MAX_COSMETIC_ATTACHMENTS; i++ )
		{
			CurrentAttachmentIdx = KFPRI.RepCustomizationInfo.AttachmentMeshIndices[i];
			if ( CurrentAttachmentIdx == `CLEARED_ATTACHMENT_INDEX )
				continue;

			// Remove the object if it is taking up our desired slot
			if( KFP.ThirdPersonAttachmentSocketNames[i] != '' &&
				KFP.ThirdPersonAttachmentSocketNames[i] == NewAttachmentSocketName )
			{
				RemoveAttachmentMeshAndSkin(i, KFP, KFPRI);
				out_RemovedAttachments.AddItem(i);
				continue;
			}

			// Remove the object if it cannot exist at the same time as another equipped item
			if( GetOverrideCase(CurrentAttachmentIdx, NewAttachmentMeshIndex) )
			{
				RemoveAttachmentMeshAndSkin(i, KFP, KFPRI);
				out_RemovedAttachments.AddItem(i);
				continue;
			}

			// Check inverse override
			if( GetOverrideCase(NewAttachmentMeshIndex, CurrentAttachmentIdx) )
			{
				RemoveAttachmentMeshAndSkin(i, KFP, KFPRI);
				out_RemovedAttachments.AddItem(i);
				continue;
			}
		}
	}
}

/**
 * Removes any attachments that exist in the same socket or have overriding cases
 * Network: Local Player
 */
function bool GetOverrideCase(int AttachmentIndex1, int AttachmentIndex2)
{
	local KFCharacterAttachment Attachment1;

	if (AttachmentIndex1 == INDEX_NONE || AttachmentIndex2 == INDEX_NONE)
	{
		return false;
	}

	//dont try to access out of bound elements
	if (AttachmentIndex1 >= CosmeticVariants.Length || AttachmentIndex2 >= CosmeticVariants.Length)
		return FALSE;

	Attachment1 = CosmeticVariants[AttachmentIndex1].AttachmentItem;

	if (CosmeticVariants[AttachmentIndex2].SpecialOverrideAttachments.length > 0)
	{
		if (CosmeticVariants[AttachmentIndex2].SpecialOverrideAttachments.Find(Attachment1) != INDEX_NONE)
		{
			return TRUE;
		}
	}
	else
	{
		if (CosmeticVariants[AttachmentIndex2].AttachmentItem.DefaultSpecialOverrideAttachments.Find(Attachment1) != INDEX_NONE)
		{
			return TRUE;
		}
	}
	switch (CosmeticVariants[AttachmentIndex1].AttachmentItem.SocketName)
	{
	case 'Hat_Attach':
		return CosmeticVariants[AttachmentIndex2].AttachmentItem.OverrideList.bHat;
	case 'Face_Attach':
		return CosmeticVariants[AttachmentIndex2].AttachmentItem.OverrideList.bFace;
	case 'Eyes_Attach':
		return CosmeticVariants[AttachmentIndex2].AttachmentItem.OverrideList.bEyes;
	case 'Jaw_Attach':
		return CosmeticVariants[AttachmentIndex2].AttachmentItem.OverrideList.bJaw;
	case 'Armband_Attach':
		return CosmeticVariants[AttachmentIndex2].AttachmentItem.OverrideList.bArmband;
	case 'Backpack_Attach':
		return CosmeticVariants[AttachmentIndex2].AttachmentItem.OverrideList.bBackpack;
	}

	return false;
}

/** Called on owning client to get the most appropriate slot for a cosmetic attachment.
	@returns -1 if no available slot otherwise returns the next available. If there is
	a socket conflict with an existing attachment, it returns the index of the existing
	attachment (to be replaced)
 */
function int GetAttachmentSlotIndex(
	int CurrentAttachmentMeshIndex,
	KFPawn KFP,
	KFPlayerReplicationInfo KFPRI)
{
	local int AttachmentIdx;

	if (KFPRI == none)
	{
		`warn("GetAttachmentSlotIndex - NO KFPRI");
		return INDEX_NONE;
	}

	// Return the next available attachment index or the index that matches this mesh
	for( AttachmentIdx=0; AttachmentIdx < `MAX_COSMETIC_ATTACHMENTS; AttachmentIdx++ )
	{
		if (KFPRI.RepCustomizationInfo.AttachmentMeshIndices[AttachmentIdx] == CurrentAttachmentMeshIndex)
		{
			return AttachmentIdx;
		}
	}
	return INDEX_NONE;
}

/** Called on owning client directly to remove a cosmetic attachment, or by
	SetAttachmentMeshAndSkin() on a replicated client when attachment index is `CLEARED_ATTACHMENT_INDEX
 */
simulated function RemoveAttachmentMeshAndSkin(
	int PawnAttachmentIndex,
	KFPawn KFP,
	optional KFPlayerReplicationInfo KFPRI)
{
	// Detach the attachment
	DetachAttachment(PawnAttachmentIndex, KFP);

	// Notify clients
	if( KFPRI != none )
	{
		KFPRI.ClearCharacterAttachment(PawnAttachmentIndex);
    }
}

/** Remove the attachment from the mesh */
function DetachAttachment(int PawnAttachmentIndex, KFPawn KFP)
{
	// Detach the attachment
	if( KFP.ThirdPersonAttachments[PawnAttachmentIndex] != none )
	{
        // We have a different attachment path if it is a skeletal mesh component
		if( SkeletalMeshComponent(KFP.ThirdPersonAttachments[PawnAttachmentIndex]) != none )
		{
			KFP.DetachComponent(KFP.ThirdPersonAttachments[PawnAttachmentIndex]);
			if (KFP.FirstPersonAttachments[PawnAttachmentIndex] != none)
			{
				KFP.DetachComponent(KFP.FirstPersonAttachments[PawnAttachmentIndex]);
			}
		}
		else
		{
			KFP.mesh.DetachComponent(KFP.ThirdPersonAttachments[PawnAttachmentIndex]);
			if (KFP.FirstPersonAttachments[PawnAttachmentIndex] != none)
			{
				KFP.ArmsMesh.DetachComponent(KFP.FirstPersonAttachments[PawnAttachmentIndex]);
			}
		}
	}

	// Update the pawn's attachment metadata
	KFP.ThirdPersonAttachmentSocketNames[PawnAttachmentIndex] = '';
	KFP.FirstPersonAttachmentSocketNames[PawnAttachmentIndex] = '';
}

/** Assign an arm mesh and material to this pawn */
simulated function SetFirstPersonArmsFromArch( KFPawn KFP, optional KFPlayerReplicationInfo KFPRI )
{
	local int CosmeticMeshIdx, AttachmentIdx;

	if ( KFPRI == none )
	{
        `Warn("Does not have a KFPRI" @ Self);
	 	return;
	}

	// First person arms mesh and skin are based on body mesh & skin.
	// Index of 255 implies use index 0 (default).
    SetArmsMeshAndSkin(
    	KFPRI.RepCustomizationInfo.BodyMeshIndex,
    	KFPRI.RepCustomizationInfo.BodySkinIndex,
    	KFP,
		KFPRI);

	// Cosmetic attachment first person mesh & skin. Index of 255 implies don't use any attachments (default)
	// Don't have to worry about clearing out attachments since that was handled in 3rd person cosmetics.
	for (AttachmentIdx = 0; AttachmentIdx < `MAX_COSMETIC_ATTACHMENTS; AttachmentIdx++)
	{
		CosmeticMeshIdx = KFPRI.RepCustomizationInfo.AttachmentMeshIndices[AttachmentIdx];
		if (CosmeticMeshIdx != `CLEARED_ATTACHMENT_INDEX && CosmeticMeshIdx != INDEX_NONE)
		{
			`log("Attach 1p mesh" @ CosmeticMeshIdx);

			// Attach all saved attachments to the character
			SetAttachmentMeshAndSkin(
				CosmeticMeshIdx,
				KFPRI.RepCustomizationInfo.AttachmentSkinIndices[AttachmentIdx],
				KFP, KFPRI);
		}
	}
}

simulated function SetArmsMeshAndSkin(
	byte ArmsMeshIndex,
	byte ArmsSkinIndex,
	KFPawn KFP,
	KFPlayerReplicationInfo KFPRI)
{
	local byte CurrentArmMeshIndex, CurrentArmSkinIndex;
	local string CharArmMeshName;
	local SkeletalMesh CharArmMesh;

	if (KFP.WorldInfo.NetMode != NM_DedicatedServer && KFP.IsHumanControlled() && KFP.IsLocallyControlled())
	{
		// Character mesh
		if( CharacterArmVariants.length > 0 )
		{
			CurrentArmMeshIndex = (ArmsMeshIndex < CharacterArmVariants.length) ? ArmsMeshIndex : 0;
			if (KFPRI.StartLoadCosmeticContent(self, ECOSMETICTYPE_Arms, CurrentArmMeshIndex))
			{
				return;
			}

			// Retrieve the name of the meshes to be used from the archetype
			CharArmMeshName = CharacterArmVariants[CurrentArmMeshIndex].MeshName;

			// Load the meshes
			CharArmMesh = SkeletalMesh(DynamicLoadObject(CharArmMeshName, class'SkeletalMesh'));

			// Assign the arms mesh to the pawn
			KFP.ArmsMesh.SetSkeletalMesh(CharArmMesh);

			if( CharacterArmVariants[CurrentArmMeshIndex].SkinVariants.length > 0 )
			{
				// Assign a skin to the arms mesh as a material override
				CurrentArmSkinIndex = (ArmsSkinIndex < CharacterArmVariants[CurrentArmMeshIndex].SkinVariants.length) ? ArmsSkinIndex : 0;
				KFP.ArmsMesh.SetMaterial(0, CharacterArmVariants[CurrentArmMeshIndex].SkinVariants[CurrentArmSkinIndex]);
			}
			else
			{
				// Use material specified in the asset
				KFP.ArmsMesh.SetMaterial(0, none);
			}
		}
		else if( ArmMesh != none )
		{
			// Clear character customization settings
			KFP.ArmsMesh.SetMaterial(0, none);

	        // Assign the arms mesh to the pawn
	        KFP.ArmsMesh.SetSkeletalMesh(ArmMesh);
		}
		else
		{
			`warn("Character does not have a valid arms mesh");
		}
	}
}

static function int GetWeaponAnimSetIdx()
{
	return default.EmoteAnimset != none ? default.AnimSets.length + 1 : default.AnimSets.length;
}

simulated function SetCharacterAnimFromArch( KFPawn Pawn )
{
	super.SetCharacterAnimFromArch( Pawn );

	if( EmoteAnimset != none )
	{
		Pawn.Mesh.Animsets.AddItem(EmoteAnimset);
	}
}

defaultproperties
{
	SoundGroupArch=KFPawnSoundGroup'FX_Pawn_Sounds_ARCH.HumanPawnSounds'
	EmoteAnimset=AnimSet'ECON_emote.ECON_Emotes'
	WWLHatMonoChromeValue=(R=1.0f,G=0.0f,B=0.0f)
	WWLHatColorValue=(R=0.0f,G=0.0f,B=0.0f)
}