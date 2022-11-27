//=============================================================================
// KFUnlockManager
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFUnlockManager extends Object
	abstract
    native
    dependson(KFCharacterInfo_Human);

enum ESharedContentUnlock
{
	SCU_None,
	SCU_Zweihander,
	SCU_ChainBat,
	SCU_ChiappaRhino,
	SCU_IonThruster,
	SCU_MosinNagant,
	SCU_G18RiotShield,
	SCU_CompoundBow,
	SCU_G18C,
	SCU_Blunderbuss,
	SCU_Minigun,
	SCU_MineReconstructor,
	SCU_FrostFang,
	SCU_GravityImploder,
	SCU_FAMAS,
	SCU_Thermite,
	SCU_BladedPistol,
	SCU_ParasiteImplanter,
	SCU_Doshinegun,
	SCU_AutoTurret,
	SCU_ShrinkRayGun,
	SCU_Scythe,
	SCU_G36C,
	SCU_HVStormCannon,
	SCU_ZedMKIII
};


enum EPlatformRestriction
{
	PR_All,
	PR_XboxOne,
	PR_PC,
	PR_PS4,
	PR_Console,
};


struct native SharedContent
{
	var name Name;
	var string IconPath;
	var int ID;
};

/** contains ids (app or microtrans) to unlock this content */
var array<SharedContent> SharedContentList;

/** contains owned title information (will be empty on PC) */
var array<OnlineCrossTitleContent> CrossTitleContent;

/** Cache a copy of the online subsystem (save to class default)*/
var OnlineSubsystem MyOnlineSubsystem;

/** Unlock cosmetics in dev build */
var const bool bDebugUnlocks;

cpptext
{
	/** Checks if a Steam AppID is owned by the logged-in player */
	UBOOL GetAppIDAvailable(INT ID);

	/** Check if a Steam inventory item is owned by the logged-in player */
	UBOOL GetInventoryIDAvailable(INT ID);

	/** TRUE if this PRI is valid for shared content unlock */
	UBOOL CanShareContent(APlayerReplicationInfo* PRI);
	/** return TRUE if the UnlockId bit is set for a given set of flags */
	UBOOL CheckSharedUnlock(int UnlockFlags, int UnlockId);

	/** Steam Id of the Killing Floor 2 group */
	static const FUniqueNetId KF2Group;
}

/****************************************************************************************
* Shared Weapon Unlocks
*****************************************************************************************/

/**
 * Called once per PRI to set up shared weapon content
 * Network: Local Player
 */
static native function 		InitSharedUnlocksFor(KFPlayerReplicationInfo PRI, optional const out array<OnlineCrossTitleContent> InCrossTitleContent);

/**
 * returns TRUE if any player on this server has this unlock
 * Network: All
 */
static native function bool IsSharedContentUnlocked(int UnlockId);

/**
*Returns TRUE if a player has event weapon skin
*/
static native function bool GetObjectiveItemGranted(int UnlockId);

/**
 * returns a list of all available (aka connected ) players with a given unlock
 * Network: All
 */
static native function 		GetSharedContentPlayerList(int UnlockId, out array<PlayerReplicationInfo> out_PRIArray);



/****************************************************************************************
* Platform Restrictions
*****************************************************************************************/

/**
 * returns TRUE if the content is restricted for the current platform
 * Network: All
 */
static native function bool IsPlatformRestricted( EPlatformRestriction PlatformRestrictionType );


/****************************************************************************************
* Character Unlocks
*****************************************************************************************/

/** Returns whether a unique numeric ID is unlocked. Zero is always unlocked. */
static native private function bool GetIDAvailable(INT ID);

static function bool GetWeaponSkinAvailable(INT ID)
{
	return GetIDAvailable(ID);
}

static event bool GetEmoteAvailable( INT ID )
{
	return GetIDAvailable( ID );
}

static final event bool GetHeadShotEffectAvailable(INT ID)
{
	return GetIDAvailable(ID);
}

//@HSL_BEGIN - JRO - 5/12/2016 - Need a native accessor method. Can't make GetAvailable an event due to the KFUnlockableAsset being a non-native interface
static event bool GetAvailableCharacterArchetype(KFCharacterInfo_Human archetype)
{
	return GetAvailable(archetype);
}
//@HSL_END

/** Returns whether a UObject asset is unlocked and available for use */
static function bool GetAvailable(KFUnlockableAsset Asset)
{
	//@HSL_BEGIN - JRO - 5/12/2016 - Disable non-starter characters while installing
	if ( !class'GameEngine'.static.IsGameFullyInstalled() &&
		String(Asset.Name) != "CHR_MrFoster_archetype")
	{
		return false;
	}
	//@HSL_END
	return GetIDAvailable(Asset.GetAssetId());
}

/** Returns whether a character skin variant is unlocked and available for use */
static function bool GetAvailableSkin(const out SkinVariant Asset)
{
	return GetIDAvailable(Asset.UnlockAssetID);
}

/** Returns whether a character outfit variant is unlocked and available for use */
static function bool GetAvailableOutfit(const out OutfitVariants Asset)
{
	local int i;

	for( i = 0; i < Asset.SkinVariations.Length; ++i)
	{
		// unlock if it has at least one available skin
		if ( GetIDAvailable(Asset.SkinVariations[i].UnlockAssetId) )
		{
			return TRUE;
		}
	}

	return false;
}

/** Returns whether a character accessory or head variant is unlocked and available for use */
static function bool GetAvailableAttachment(const out AttachmentVariants Asset)
{
	local int i;

	for( i = 0; i < Asset.AttachmentItem.SkinVariations.Length; ++i)
	{
		// unlock if it has at least one available skin
		if ( GetIDAvailable(Asset.AttachmentItem.SkinVariations[i].UnlockAssetId) )
		{
			return TRUE;
		}
	}

	return false;
}

/** Checks to see that all cosmetic items for this character are owned */
static private event bool CheckCustomizationOwnership(KFPlayerReplicationInfo PRI)
{
	local KFCharacterInfo_Human CharArch;
	local OutfitVariants Outfit;
	local SkinVariant Skin;
	local AttachmentVariants Attachment;
	local int i;
	local KFGameReplicationInfo KFGRI;

	CharArch = PRI.CharacterArchetypes[PRI.RepCustomizationInfo.CharacterIndex];

	if ( CharArch != None )
	{
		// body
		Outfit = CharArch.BodyVariants[PRI.RepCustomizationInfo.BodyMeshIndex];
		Skin = Outfit.SkinVariations[PRI.RepCustomizationInfo.BodySkinIndex];
 		/*if( !GetIDAvailable(Outfit.UnlockAssetID) )
 		{
 			ClearCharacterCustomization(PRI);
 			return FALSE;
 		}
 		else*/ if( !GetIDAvailable(Skin.UnlockAssetID)  )
 		{
 			ClearCharacterCustomization(PRI);
 			return FALSE;
 		}

 		// head
 		Outfit = CharArch.HeadVariants[PRI.RepCustomizationInfo.HeadMeshIndex];

		Skin = Outfit.SkinVariations[PRI.RepCustomizationInfo.HeadSkinIndex];
 		/*if( !GetIDAvailable(Outfit.UnlockAssetID) )
 		{
 			ClearCharacterCustomization(PRI);
 			return FALSE;
 		}
 		else*/ if( !GetIDAvailable(Skin.UnlockAssetID) )
 		{
 			ClearCharacterCustomization(PRI);
 			return FALSE;
 		}


		KFGRI = KFGameReplicationInfo(PRI.WorldInfo.GRI);
 		// accessory
		for( i=0; i < `MAX_COSMETIC_ATTACHMENTS; i++ )
		{
			if (i == 2 && KFGRI != none && KFGRI.bIsWeeklyMode && KFGRI.CurrentWeeklyIndex == 12)
			{
				continue;
			}

			if (PRI.RepCustomizationInfo.AttachmentSkinIndices[i] == INDEX_NONE)
			{
				continue;
			}

			Attachment = CharArch.CosmeticVariants[PRI.RepCustomizationInfo.AttachmentMeshIndices[i]];
			if (Attachment.AttachmentItem == None)
			{
				return FALSE;
			}

			Skin = Attachment.AttachmentItem.SkinVariations[PRI.RepCustomizationInfo.AttachmentSkinIndices[i]];

			if( !GetIDAvailable(Skin.UnlockAssetID) )
			{
 				ClearCharacterCustomization(PRI);
 				return FALSE;
			}
		}
	}

	return TRUE;
}

static native private function ClearCharacterCustomization(KFPlayerReplicationInfo PRI);

/****************************************************************************************
* Debugging
*****************************************************************************************/

static native function TestSteamAPI(PlayerReplicationInfo PRI, byte CallFlags);

defaultproperties
{
	SharedContentList(SCU_Zweihander)={(
		Name=KFWeap_Edged_Zweihander,
		IconPath="WEP_UI_Zweihander_TEX.UI_WeaponSelect_Zweihander",
		ID=219640)}
	SharedContentList(SCU_ChainBat)={(
		Name=KFWeap_Blunt_ChainBat,
		IconPath="Wep_UI_ChainBat_TEX.UI_WeaponSelect_RRChainbat",
		ID=300380)}
	SharedContentList(SCU_ChiappaRhino)={(
		Name=KFWeap_Pistol_ChiappaRhino,
		IconPath="Wep_UI_ChiappaRhino_TEX.UI_WeaponSelect_ChiappaRhinos",
		ID=7704)}
	SharedContentList(SCU_IonThruster)={(
		Name=KFWeap_Edged_IonThruster,
		IconPath="WEP_UI_Ion_Sword_TEX.UI_WeaponSelect_IonSword",
		ID=7715)}
	SharedContentList(SCU_MosinNagant)={(
		Name=KFWeap_Rifle_MosinNagant,
		IconPath="wep_ui_mosin_tex.UI_WeaponSelect_MosinNagant",
		ID=7856)}
	SharedContentList(SCU_G18RiotShield)={(
		Name=KFWeap_SMG_G18,
		IconPath="WEP_UI_RiotShield_TEX.UI_WeaponSelect_RiotShield",
		ID=7850)}
	SharedContentList(SCU_CompoundBow)={(
		Name=KFWeap_Bow_CompoundBow,
		IconPath="WEP_UI_CompoundBow_TEX.UI_WeaponSelect_Compound_Bow",
		ID=8169)}
	SharedContentList(SCU_G18C)={(
		Name=KFWeap_Pistol_G18C,
		IconPath="wep_ui_g18c_tex.UI_WeaponSelect_G18C",
		ID=8293)}
	SharedContentList(SCU_Blunderbuss)={(
		Name=KFWeap_Pistol_Blunderbuss,
		IconPath="WEP_UI_Blunderbuss_TEX.UI_WeaponSelect_BlunderBluss",
		ID=8299)}
	SharedContentList(SCU_Minigun)={(
		Name=KFWeap_Minigun,
		IconPath="WEP_UI_Minigun_TEX.UI_WeaponSelect_Minigun",
		ID=8478)}
	SharedContentList(SCU_MineReconstructor)={(
		Name=KFWeap_Mine_Reconstructor,
		IconPath="WEP_UI_Mine_Reconstructor_TEX.UI_WeaponSelect_HMTechMineReconstructor",
		ID=8472)}
	SharedContentList(SCU_FrostFang)={(
		Name=KFWeap_Rifle_FrostShotgunAxe,
		IconPath="WEP_UI_Frost_Shotgun_Axe_TEX.UI_WeaponSelect_FrostGun",
		ID=8609)}
	SharedContentList(SCU_GravityImploder)={(
		Name=KFWeap_GravityImploder,
		IconPath="WEP_UI_Gravity_Imploder_TEX.UI_WeaponSelect_Gravity_Imploder",
		ID=8778)}
	SharedContentList(SCU_FAMAS)={(
		Name=KFWeap_AssaultRifle_FAMAS,
		IconPath="WEP_UI_Famas_TEX.UI_WeaponSelect_Famas",
		ID=8934)}
	SharedContentList(SCU_Thermite)={(
		Name=KFWeap_RocketLauncher_ThermiteBore,
		IconPath="WEP_UI_Thermite_TEX.UI_WeaponSelect_Thermite",
		ID=8940)}
	SharedContentList(SCU_BladedPistol)={(
		Name=KFWeap_Pistol_Bladed,
		IconPath="WEP_UI_BladedPistol_TEX.UI_WeaponSelect_BladedPistol",
		ID=9126)}
	SharedContentList(SCU_ParasiteImplanter)={(
		Name=KFWeap_Rifle_ParasiteImplanter,
		IconPath="WEP_UI_ParasiteImplanter_TEX.UI_WeaponSelect_ParasiteImplanter",
		ID=9132)}
	SharedContentList(SCU_Doshinegun)={(
		Name=KFWeap_AssaultRifle_Doshinegun,
		IconPath="WEP_UI_Doshinegun_TEX.UI_Weapon_Select_Doshinegun",
		ID=9275)}
	SharedContentList(SCU_AutoTurret)={(
		Name=KFWeap_AutoTurret,
		IconPath="WEP_UI_AutoTurret_TEX.UI_WeaponSelect_AutoTurret",
		ID=9284)}
	SharedContentList(SCU_ShrinkRayGun)={(
		Name=KFWeap_ShrinkRayGun,
		IconPath="WEP_UI_ShrinkRay_Gun_TEX.UI_Weapon_Select_Shrink_Ray_Gun",
		ID=9290)}
	SharedContentList(SCU_Scythe)={(
		Name=KFWeap_Edged_Scythe,
		IconPath="WEP_UI_Scythe_TEX.UI_WeaponSelect_Scythe",
		ID=9478)}
	SharedContentList(SCU_G36C)={(
		Name=KFWeap_AssaultRifle_G36C,
		IconPath="WEP_UI_G36C_TEX.UI_WeaponSelect_G36C",
		ID=9484)}
	SharedContentList(SCU_HVStormCannon)={(
		Name=KFWeap_HVStormCannon,
		IconPath="wep_ui_hvstormcannon_tex.UI_WeaponSelect_HVStormCannon",
		ID=9569)}
	SharedContentList(SCU_ZedMKIII)={(
		Name=KFWeap_ZedMKIII,
		IconPath="wep_ui_zedmkiii_tex.UI_WeaponSelect_ZEDMKIII",
		ID=9575)}
}
