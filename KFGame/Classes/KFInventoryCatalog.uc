// This class is to keep track and look up the id-item matches so we can pass them to a matinee. 

class KFInventoryCatalog extends Object;

enum ECrateSeries
{
	ECrate_ZedKiller,
	ECrate_StoriesOfWar,
	ECrate_CyberBone,
	ECrate_HorzineIssue,
	ECrate_DragonFire,
	ECrate_StreetPunks,
	ECrate_FirstEncounter,
	ECrate_Predator,
	ECrate_TacticalHorzine,
	ECrate_EmergencyIssue,
	ECrate_Swat,
	ECrate_Exhibit,
	ECrate_EliteMedic,
	ECrate_Victorian,
    ECrate_WeaponCollector_S1,
	ECrate_MaceShield,
	ECrate_TacticalHorzineMKII,
	ECrate_Deepstrike,
	ECrate_HighVoltage,
	ECrate_Flare,
	ECrate_Junkyard,
	ECrate_Vietnam,
	ECrate_Emote_S1,
	ECrate_Emote_S2,
	ECrate_Emote_S3,
	ECrate_BlueFire,
	ECrate_Vault,
	ECrate_Vault_Test,
	ECrate_Neon,
	ECrate_NeonMKII,
	ECrate_NeonMKIII,
	ECrate_NeonMKIV,
	ECrate_NeonMKV,
	ECrate_Dragonwave,
	ECrate_BeyondHorizon,
	ECrate_Jaeger,
	ECrate_HorzineSupply_SDAR,
	ECrate_HorzineSupply_SLOCO,
	ECrate_HorzineSupply_SCyberSamurai,
	ECrate_HorzineSupply_SDeity,
	ECrate_Steampunk,
	ECrate_HorzineSupply_SProjectH,
	ECrate_HorzineSupply_SBoneyard,
	ECrate_PSNHorzineSupply_CS1,
	ECrate_PSNHorzineSupply_CS2,
	ECrate_PSNHorzineSupply_CS3,
	ECrate_PSNHorzineSupply_CS5,
	ECrate_PSNHorzineSupply_CS6,
	ECrate_PSNHorzineSupply_CS7,
	ECrate_PSNHorzineSupply_CS8,
	ECrate_PSNHorzineSupply_CS9,
	ECrate_PSNHorzineSupply_CS10,
	ECrate_PSNHorzineSupply_CS11,
	ECrate_PSNHorzineSupply_CS15,
	ECrate_PSNHorzineSupply_WS1,
	ECrate_PSNHorzineSupply_WS2,
	ECrate_PSNHorzineSupply_WS3,
	ECrate_PSNHorzineSupply_WS4,
	ECrate_PSNHorzineSupply_WS5,
	ECrate_PSNHorzineSupply_WS6,
	ECrate_PSNHorzineSupply_WS7,
	ECrate_PSNHorzineSupply_WS8,
	ECrate_PSNHorzineSupply_WS9,
	ECrate_PSNHorzineSupply_WS10,
	ECrate_PSNHorzineSupply_WS11,
	ECrate_PSNHorzineSupply_WS12,
	ECrate_PSNHorzineSupply_WS13,
	ECrate_PSNHorzineSupply_WS14,
	ECrate_PSNHorzineSupply_WS15,
	ECrate_PSNHorzineSupply_WS16,
	ECrate_PSNHorzineSupply_WS17,
	ECrate_PSNHorzineSupply_E1,
	ECrate_PSNHorzineSupply_E2,
	ECrate_PSNHorzineSupply_E3,
	ECrate_HorzineSupply_S1,
	ECrate_HorzineSupply_S2,
	ECrate_HorzineSupply_S3,
	ECrate_HorzineSupply_S4,
	ECrate_HorzineSupply_S5,
	ECrate_HorzineSupply_S6,
	ECrate_HorzineSupply_S7,
	ECrate_HorzineSupply_S8,
	ECrate_HorzineSupply_S9,
	ECrate_HorzineSupply_S10,
	ECrate_HorzineSupply_S11,
	ECrate_HorzineSupply_S12,
	ECrate_HorzineSupply_S13,
	ECrate_HorzineSupply_S14,
	ECrate_HorzineSupply_S15,
	ECrate_HorzineSupply_S16,

	};

enum EItemDisplayContainerType
{
	IDT_None,
	IDT_Crate,
	IDT_USB,
};

struct ItemCatalogEntry
{
	var int ContainerID;
	var int KeyID;
	var name ItemSeriesName;
	var EItemDisplayContainerType ContainerType;
};

var() array<ItemCatalogEntry> ItemKeyArray;

static function EItemDisplayContainerType GetItemDisplayContainerType(int ItemID)
{
	local int i;

	for (i = 0; i < default.ItemKeyArray.length; i++)
	{
		if(default.ItemKeyArray[i].ContainerID == ItemID || default.ItemKeyArray[i].KeyID == ItemID)
		{
			return default.ItemKeyArray[i].ContainerType;
		}
	}

	return IDT_None;
}

static function name GetItemSeries(int ItemID)
{
	local int i;

	for (i = 0; i < default.ItemKeyArray.length; i++)
	{
		if(default.ItemKeyArray[i].ContainerID == ItemID || default.ItemKeyArray[i].KeyID == ItemID)
		{
			return default.ItemKeyArray[i].ItemSeriesName;
		}
	}

	return '';
}

DefaultProperties
{
	//defaults
	ItemKeyArray[ECrate_ZedKiller]=(ContainerID=3174, KeyID=3178, ItemSeriesName=zedkiller, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_StoriesOfWar]=(ContainerID=3180, KeyID=3179, ItemSeriesName=sow, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_CyberBone]=(ContainerID=3181, KeyID=3182, ItemSeriesName=cyberbone, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_HorzineIssue]=(ContainerID=3274, KeyID=3275, ItemSeriesName=horzineissue, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_DragonFire]=(ContainerID=3280, KeyID=3281, ItemSeriesName=dragonfire, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_StreetPunks]=(ContainerID=3596, KeyID=3597, ItemSeriesName=streetpunks, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_FirstEncounter]=(ContainerID=3896, KeyID=3895, ItemSeriesName=firstencounter, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_Predator]=(ContainerID=3592, KeyID=3593, ItemSeriesName=predator, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_TacticalHorzine]=(ContainerID=3590, KeyID=3591, ItemSeriesName=tacticalhorzine, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_EmergencyIssue]=(ContainerID=3594, KeyID=3595, ItemSeriesName=emergencyissue, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_Swat]=(ContainerID=4134, KeyID=4135, ItemSeriesName=swat, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_Exhibit]=(ContainerID=4115, KeyID=4114, ItemSeriesName=exhibit, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_EliteMedic]=(ContainerID=4145, KeyID=4144, ItemSeriesName=elitemedic, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_Victorian]=(ContainerID=4214, KeyID=4215, ItemSeriesName=victorian, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_WeaponCollector_S1]=(ContainerID=5987, KeyID=5988, ItemSeriesName=WeaponCollector_S1, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_HorzineSupply_S1]=(ContainerID=3284, KeyID=3282, ItemSeriesName=horzine1, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S2]=(ContainerID=3285, KeyID=3283, ItemSeriesName=horzine2, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S3]=(ContainerID=3598, KeyID=3599, ItemSeriesName=horzine3, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S4]=(ContainerID=3600, KeyID=3601, ItemSeriesName=horzine4, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S5]=(ContainerID=3882, KeyID=3880, ItemSeriesName=horzine5, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S6]=(ContainerID=3883, KeyID=3881, ItemSeriesName=horzine6, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S7]=(ContainerID=4107, KeyID=4105, ItemSeriesName=horzine7, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S8]=(ContainerID=4108, KeyID=4106, ItemSeriesName=horzine8, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S9]=(ContainerID=4207, KeyID=4208, ItemSeriesName=horzine9, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_HorzineSupply_SDAR]=(ContainerID=5873, KeyID=5874, ItemSeriesName=horzineDAR, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_HorzineSupply_SLOCO]=(ContainerID=6445, KeyID=6446, ItemSeriesName=horzineLOCO, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_HorzineSupply_SCyberSamurai]=(ContainerID=6616, KeyID=6617, ItemSeriesName=horzineCyberSamurai, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_HorzineSupply_SDeity]=(ContainerID=7120, KeyID=7126, ItemSeriesName=horzineDeity, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_HorzineSupply_SProjectH]=(ContainerID=7391, KeyID=7398, ItemSeriesName=horzineProjectH, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_HorzineSupply_SBoneyard]=(ContainerID=7621, KeyID=7620, ItemSeriesName=horzineBoneyard, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS1]=(ContainerID=4304, KeyID=4303, ItemSeriesName=psncrate_cs1, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS2]=(ContainerID=4305, KeyID=4303, ItemSeriesName=psncrate_cs2, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS3]=(ContainerID=5371, KeyID=4303, ItemSeriesName=psncrate_cs3, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS5]=(ContainerID=5900, KeyID=4303, ItemSeriesName=psncrate_cs5, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS6]=(ContainerID=5989, KeyID=4303, ItemSeriesName=psncrate_cs6, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS7]=(ContainerID=6457, KeyID=4303, ItemSeriesName=psncrate_cs7, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS8]=(ContainerID=6658, KeyID=4303, ItemSeriesName=psncrate_cs8, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS9]=(ContainerID=7127, KeyID=4303, ItemSeriesName=psncrate_cs9, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS10]=(ContainerID=7400, KeyID=4303, ItemSeriesName=psncrate_cs10, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS11]=(ContainerID=7627, KeyID=4303, ItemSeriesName=psncrate_cs11, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS1]=(ContainerID=4307, KeyID=4303, ItemSeriesName=psncrate_ws1, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS2]=(ContainerID=4306, KeyID=4303, ItemSeriesName=psncrate_ws2, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS3]=(ContainerID=4569, KeyID=4303, ItemSeriesName=psncrate_ws3, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS4]=(ContainerID=4790, KeyID=4303, ItemSeriesName=psncrate_ws4, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS5]=(ContainerID=5369, KeyID=4303, ItemSeriesName=psncrate_ws5, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS6]=(ContainerID=5901, KeyID=4303, ItemSeriesName=psncrate_ws6, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS7]=(ContainerID=5991, KeyID=4303, ItemSeriesName=psncrate_ws7, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS8]=(ContainerID=6201, KeyID=4303, ItemSeriesName=psncrate_ws8, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS9]=(ContainerID=6202, KeyID=4303, ItemSeriesName=psncrate_ws9, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS10]=(ContainerID=6218, KeyID=4303, ItemSeriesName=psncrate_ws10, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS11]=(ContainerID=6433, KeyID=4303, ItemSeriesName=psncrate_ws11, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS12]=(ContainerID=6667, KeyID=4303, ItemSeriesName=psncrate_ws12, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS13]=(ContainerID=7117, KeyID=4303, ItemSeriesName=psncrate_ws13, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS14]=(ContainerID=7119, KeyID=4303, ItemSeriesName=psncrate_ws14, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS15]=(ContainerID=7424, KeyID=4303, ItemSeriesName=psncrate_ws15, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS16]=(ContainerID=7628, KeyID=4303, ItemSeriesName=psncrate_ws16, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_WS17]=(ContainerID=7953, KeyID=4303, ItemSeriesName=psncrate_ws17, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_E1]=(ContainerID=5646, KeyID=4303, ItemSeriesName=emote1, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_E2]=(ContainerID=5647, KeyID=4303, ItemSeriesName=emote2, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_E3]=(ContainerID=7929, KeyID=4303, ItemSeriesName=emote3, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S10]=(ContainerID=4499, KeyID=4501, ItemSeriesName=horzine10, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S11]=(ContainerID=4500, KeyID=4502, ItemSeriesName=horzine11, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_TacticalHorzineMKII]=(ContainerID=4514, KeyID=4513, ItemSeriesName=tacticalhorzineII, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_MaceShield]=(ContainerID=4561, KeyID=4562, ItemSeriesName=maceshield, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_HorzineSupply_S12]=(ContainerID=4604, KeyID=4603, ItemSeriesName=horzine12, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_Deepstrike]=(ContainerID=4593, KeyID=4594, ItemSeriesName=deepstrike, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_HorzineSupply_S13]=(ContainerID=4776, KeyID=4775, ItemSeriesName=horzine13, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_HighVoltage]=(ContainerID=4786, KeyID=4785, ItemSeriesName=highvoltage, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_Flare]=(ContainerID=4802, KeyID=4801, ItemSeriesName=flare, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_HorzineSupply_S14]=(ContainerID=5010, KeyID=5011, ItemSeriesName=horzine14, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_Vietnam]=(ContainerID=4979, KeyID=4980, ItemSeriesName=vietnam, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_Junkyard]=(ContainerID=4993, KeyID=4994, ItemSeriesName=junkyard, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_Emote_S1]=(ContainerID=4541, KeyID=4540, ItemSeriesName=emote1, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_Emote_S2]=(ContainerID=5143, KeyID=5142, ItemSeriesName=emote2, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_Emote_S3]=(ContainerID=7927, KeyID=7928, ItemSeriesName=emote3, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S16]=(ContainerID=5240, KeyID=5241, ItemSeriesName=horzine16, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_Neon]=(ContainerID=5194, KeyID=5195, ItemSeriesName=neon, ContainerType=IDT_USB)
	ItemKeyArray[ECrate_Vault]=(ContainerID=5313, KeyID=-1, ItemSeriesName=vaultcrate, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_HorzineSupply_S15]=(ContainerID=5233, KeyID=5234, ItemSeriesName=horzine15, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_PSNHorzineSupply_CS15]=(ContainerID=5642, KeyID=4303, ItemSeriesName=horzine15, ContainerType=IDT_Crate)
	ItemKeyArray[ECrate_Vault_Test]=(ContainerID=5613, KeyID=-1, ItemSeriesName=vaultcrate_test, ContainerType=IDT_Crate)
	ItemKeyArray[Ecrate_NeonMKII]=(ContainerID=6198, KeyID=6197, ItemSeriesName=NeonMKII, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_NeonMKIII]=(ContainerID=6430, KeyID=6431, ItemSeriesName=NeonMKIII, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_BlueFire]=(ContainerID=6200, KeyID=6199, ItemSeriesName=Bluefire, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_NeonMKIV]=(ContainerID=6665, KeyID=6666, ItemSeriesName=NeonMKIV, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_NeonMKV]=(ContainerID=7107, KeyID=7108, ItemSeriesName=NeonMKV, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_Dragonwave]=(ContainerID=7114, KeyID=7115, ItemSeriesName=Dragonwave, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_Steampunk]=(ContainerID=7407, KeyID=7408, ItemSeriesName=Steampunk, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_BeyondHorizon]=(ContainerID=7622, KeyID=7623, ItemSeriesName=BeyondHorizon, ContainerType=IDT_USB)
	ItemKeyArray[Ecrate_Jaeger]=(ContainerID=7951, KeyID=7952, ItemSeriesName=Jaeger, ContainerType=IDT_USB)
} 