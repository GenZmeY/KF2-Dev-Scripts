//=============================================================================
// KFLocalMessage_Game
//=============================================================================
// Message class for general gam play messages
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFLocalMessage_Game extends KFLocalMessage;

enum EGameMessageType
{
	GMT_GaveAmmoTo,
	GMT_GaveArmorTo,
	GMT_GaveAmmoAndArmorTo,
	GMT_ReceivedAmmoFrom,
	GMT_ReceivedArmorFrom,
	GMT_ReceivedAmmoAndArmorFrom,
	GMT_HealedBy,
	GMT_HealedPlayer,
	GMT_HealedSelf,
	GMT_Equipped,
	GMT_PickedupArmor,
	GMT_FullArmor,
	GMT_Ammo,
	GMT_PickedupWeaponAmmo,
	GMT_AmmoIsFull,
	GMT_AmmoAndArmorAreFull,
	GMT_AlreadyCarryingWeapon,
	GMT_PickedupItem,
	GMT_TooMuchWeight,
	GMT_PendingPerkChangesSet,
    GMT_PendingPerkChangesApplied,
    GMT_FailedDropInventory,
    GMT_ReceivedGrenadesFrom,
	GMT_GaveGrenadesTo,

    GMT_FoundCollectible,
    GMT_FoundAllCollectibles,
    GMT_UserSharingContent,

	GMT_PowerUpHellishRageActivated,

	KMT_Killed,
	KMT_Suicide

};

var localized string 			ReceivedAmmoFromMessage;
var localized string 			GaveAmmoToMessage;
var localized string 			HealedByMessage;
var localized string			HealedMessage;
var localized string			PickedupArmorMessage;
var localized string			FullArmorMessage;
var localized string			PickupAmmoMessage;
var localized string 			AmmoFullMessage;
var localized string			AlreadyCarryingWeaponMessage;
var localized string			PickupWeaponAmmoMessage;
var localized string			PickupMessage;
var localized string			TooMuchWeightMessage;
var localized string 			ReceivedGrenadesFromMessage;
var localized string 			GaveGrenadesToMessage;
var localized string 			YourselfString;

var localized string			FailedDropInventoryMessage;
var localized string 			PendingPerkChangesSet;
var localized string 			PendingPerkChangesApplied;

var localized string			KilledMessage;
var localized string			SuicideMessage;

var localized string 			KillzedBy_PatriarchString;
var localized string 			KillzedBy_HansString;
var localized string 			KillzedBy_MatriarchString;
var localized string 			KillzedBy_ZedCrawlerString;
var localized string 			KillzedBy_ZedBloatString;
var localized string 			KillzedBy_ZedFleshpoundString;
var localized string 			KillzedBy_ZedGorefastString;
var localized string 			KillzedBy_ZedHuskString;
var localized string 			KillzedBy_ZedScrakeString;
var localized string 			KillzedBy_ZedSirenString;
var localized string 			KillzedBy_ZedStalkerString;
var localized string 			KillzedBy_ZedClot_CystString;
var localized string 			KillzedBy_ZedClot_AlphaString;
var localized string 			KillzedBy_ZedClot_SlasherString;
var localized string 			KillzedBy_ZedDAR_EMPString;
var localized string 			KillzedBy_ZedDAR_LaserString;
var localized string 			KillzedBy_ZedDAR_RocketString;

var localized string 			FoundAMapCollectibleMessage;
var localized string			FoundAllMapCollectiblesMessage;
var localized string 			MapCollectibleName;
var localized string 			SharingContentString;
var localized string 			PowerUpHellishRageActivatedMessage;

var localized string 			HeadShotAddedString;
var localized string 			HeadShotMaxString;
var localized string 			HeadShotResetString;

// Returns a hex color code for the supplied message type
static function string GetHexColor(int Switch)
{
    switch ( Switch )
	{
		case GMT_GaveAmmoTo:
		case GMT_GaveArmorTo:
		case GMT_GaveAmmoAndArmorTo:
		case GMT_ReceivedAmmoAndArmorFrom:
		case GMT_ReceivedAmmoFrom:
		case GMT_ReceivedArmorFrom:
		case GMT_HealedBy:
        case GMT_HealedPlayer:
        case GMT_HealedSelf:
        case GMT_PickedupArmor:
        case GMT_FullArmor:
        case GMT_Ammo:
        case GMT_AmmoIsFull:
        case GMT_AmmoAndArmorAreFull:
        case GMT_PickedupWeaponAmmo:
        case GMT_AlreadyCarryingWeapon:
        case GMT_PickedupItem:
        case GMT_PendingPerkChangesSet:
		case GMT_PendingPerkChangesApplied:
		case GMT_ReceivedGrenadesFrom:
		case GMT_GaveGrenadesTo:
		case GMT_PowerUpHellishRageActivated:
             return default.GameColor;
	}

	return "00FF00";
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string TempString;

	switch ( Switch )
	{
		case GMT_GaveAmmoTo:
		case GMT_GaveArmorTo:
		case GMT_GaveAmmoAndArmorTo:
			return default.GaveAmmoToMessage @RelatedPRI_1.PlayerName;
		case GMT_ReceivedAmmoFrom:
		case GMT_ReceivedArmorFrom:
		case GMT_ReceivedAmmoAndArmorFrom:
			return default.ReceivedAmmoFromMessage @RelatedPRI_1.PlayerName;
		case GMT_HealedBy:
			return default.HealedByMessage @RelatedPRI_1.PlayerName;
		case GMT_PendingPerkChangesSet:
			return default.PendingPerkChangesSet;
		case GMT_PendingPerkChangesApplied:
			return default.PendingPerkChangesApplied;
		case GMT_HealedPlayer:
			return default.HealedMessage@ RelatedPRI_1.PlayerName;
		case GMT_HealedSelf:
			return default.HealedMessage@ default.YourselfString;
		case GMT_PickedupArmor:
			return default.PickedupArmorMessage;
		case GMT_FullArmor:
			return default.FullArmorMessage;
		case GMT_Ammo:
			return default.PickupAmmoMessage;
		case GMT_AmmoIsFull:
		case GMT_AmmoAndArmorAreFull:
			return default.AmmoFullMessage;
		case GMT_PickedupWeaponAmmo:
			TempString = Repl(default.PickupWeaponAmmoMessage, "%x%", class<Inventory>( OptionalObject ).default.ItemName, true);
			return TempString;
		case GMT_AlreadyCarryingWeapon:
			return default.AlreadyCarryingWeaponMessage;
		case GMT_PickedupItem:
			return default.PickupMessage@ Inventory( OptionalObject).ItemName;
		case GMT_TooMuchWeight:
			return default.TooMuchWeightMessage;
		case GMT_FailedDropInventory:
			return default.FailedDropInventoryMessage;
		case GMT_GaveGrenadesTo:
			return default.GaveGrenadesToMessage @RelatedPRI_1.PlayerName;
		case GMT_ReceivedGrenadesFrom:
			return default.ReceivedGrenadesFromMessage @RelatedPRI_1.PlayerName;
		case GMT_FoundCollectible:
			return default.FoundAMapCollectibleMessage;
		case GMT_FoundAllCollectibles:
			return default.FoundAllMapCollectiblesMessage;
		case GMT_UserSharingContent:
            return RelatedPRI_1.PlayerName @Default.SharingContentString;
		case GMT_PowerUpHellishRageActivated:
            return default.PowerUpHellishRageActivatedMessage;
		case KMT_Killed:
			return	RelatedPRI_2.PlayerName$GetKilledByZedMessage( OptionalObject );
		case KMT_Suicide:
			return	RelatedPRI_2.PlayerName@ default.SuicideMessage;
		default:
			return "";
	}
}

static function string GetKilledByZedMessage( Object KillerObject )
{	
	local class<Pawn> PawnClass;
	local class<KFDamageType> KFDT;

	PawnClass = class<Pawn>(KillerObject);

	if( PawnClass != none && PawnClass.default.ControllerClass != none)
	{
		switch ( PawnClass.default.ControllerClass.Name )
		{
			case 'KFAIController_ZedPatriarch':
				return default.KillzedBy_PatriarchString;
			case 'KFAIController_Hans':
				return default.KillzedBy_HansString;
			case 'KFAIController_ZedMatriarch':
				return default.KillzedBy_MatriarchString;
			case 'KFAIController_ZedCrawler':
			case 'KFAIController_ZedCrawlerKing':
				return default.KillzedBy_ZedCrawlerString;
			case 'KFAIController_ZedBloat':
				return default.KillzedBy_ZedBloatString;
			case 'KFAIController_ZedFleshpound':
				return default.KillzedBy_ZedFleshpoundString;
			case 'KFAIController_ZedGorefast':
			case 'KFAIController_ZedGorefastDualBlade':
				return default.KillzedBy_ZedGorefastString;
			case 'KFAIController_ZedHusk':
				return default.KillzedBy_ZedHuskString;
			case 'KFAIController_ZedScrake':
				return default.KillzedBy_ZedScrakeString;
			case 'KFAIController_ZedSiren':
				return default.KillzedBy_ZedSirenString;
			case 'KFAIController_ZedStalker':
				return default.KillzedBy_ZedStalkerString;
			case 'KFAIController_ZedClot_Cyst':
				return default.KillzedBy_ZedClot_CystString;
			case 'KFAIController_ZedClot_Alpha':
			case 'KFAIController_ZedClot_AlphaKing':
				return default.KillzedBy_ZedClot_AlphaString;
			case 'KFAIController_ZedClot_Slasher':
				return default.KillzedBy_ZedClot_SlasherString;
			case 'KFAIController_ZedDAR_EMP':
				return default.KillzedBy_ZedDAR_EMPString;
			case 'KFAIController_ZedDAR_Laser':
				return default.KillzedBy_ZedDAR_LaserString;
			case 'KFAIController_ZedDAR_Rocket':
				return default.KillzedBy_ZedDAR_RocketString;
		}
	}
	else
	{
		// Killer controller no longer exists for some reason, try to get death message by damagetype
		KFDT = class<KFDamageType>( KillerObject );
		if( KFDT != none )
		{
			switch( KFDT.Name )
			{
				// Crawler damagetypes
				case 'KFDT_Explosive_CrawlerSuicide':
				case 'KFDT_Toxic_PlayerCrawlerSuicide':
					return default.KillzedBy_ZedCrawlerString;

				// Bloat damagetypes
				case 'KFDT_BloatPuke':
				case 'KFDT_Toxic_BloatPukeMine':
				case 'KFDT_Toxic_BloatKingPukeMine':
					return default.KillzedBy_ZedBloatString;

				// Husk damagetypes
				case 'KFDT_Fire_HuskFireball':
				case 'KFDT_Fire_HuskFlamethrower':
				case 'KFDT_Explosive_HuskSuicide':
					return default.KillzedBy_ZedHuskString;
			}
		}
	}

	return default.KilledMessage;
} 

static function float GetPos( int Switch, HUD myHUD )
{
	switch ( Switch )
	{
		case KMT_Killed:
		case KMT_Suicide:
			return 0.1;
	}

    return 0.8;
}


DefaultProperties
{
	Lifetime=5
	bIsConsoleMessage=false
 	bIsUnique=true
 	bIsSpecial=true
 	bBeep=true

	FontSize=20
	DrawColor=(R=255,G=0,B=0,A=255)
}

