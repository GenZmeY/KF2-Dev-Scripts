//=============================================================================
// KFOnlineStatsRead
//=============================================================================
// The KF 2 game stats class that holds and modifies the read stats data
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Joshua Rowan 3/4/2014
//=============================================================================

class KFOnlineStatsRead extends OnlineStatsRead
	native;

`include(KFOnlineStats.uci)

var	KFOnlineStatsWrite		LinkedWriteObject;

var	UniqueNetID OwningUniqueID;
/** Sets when Steam's UserStatsReceived callback triggers. */
var EOnlineEnumerationReadState UserStatsReceivedState;

/** Debugging */
var 		bool 	bLogStatsRead;

function OnStatsInitialized(bool bWasSuccessful)
{
	if( !bWasSuccessful)
	{
		`warn("##########################################################################");
		`warn("KFOnlineStatsRead: Unable to get Steam statistics.  Stats will not be set!");
		`warn("##########################################################################");
	}
	else
	{
		OnReadComplete();
	}
}

native function NativeOnReadComplete();

function OnInventoryReadComplete_Steamworks()
{
	class'GameEngine'.static.GetOnlineSubsystem().ClearOnInventoryReadCompleteDelegate(OnInventoryReadComplete_Steamworks);
	LinkedWriteObject.CheckPerkPSGRewards(None);
}

function OnInventoryReadComplete_Playfab(bool bWasSuccessful)
{
	class'GameEngine'.static.GetPlayfabInterface().ClearInventoryReadCompleteDelegate(OnInventoryReadComplete_Playfab);
	if (bWasSuccessful)
	{
		LinkedWriteObject.CheckPerkPSGRewards(None);
	}
}

event OnReadComplete()
{
	NativeOnReadComplete();
	`log("KFOnlineStatsRead: OnReadComplete called, Rows[0].Columns.Length=" $ Rows[0].Columns.Length @ `showvar(self), bLogStatsRead, 'DevOnline');

	// Grant perk prestige rewards for all perks at their current prestige level, just in case a
	// reward was missed due to network/infrastructure issues. We need to wait for the user's
	// stats AND inventory to be loaded, though, so set a callback for the inventory if necessary.
	//@SABER_EGS IsEosBuild() case added
	if (class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild())
	{
		if (class'GameEngine'.static.GetOnlineSubsystem().CurrentInventory.Length == 0)
		{
			class'GameEngine'.static.GetPlayfabInterface().AddInventoryReadCompleteDelegate(OnInventoryReadComplete_Playfab);
		}
		else
		{
			LinkedWriteObject.CheckPerkPSGRewards(None);
		}
	}
	else
	{
		if (!class'GameEngine'.static.GetOnlineSubsystem().bInventoryReady)
		{
			class'GameEngine'.static.GetOnlineSubsystem().AddOnInventoryReadCompleteDelegate(OnInventoryReadComplete_Steamworks);
		}
		else
		{
			LinkedWriteObject.CheckPerkPSGRewards(None);
		}
	}
}


`if(`notdefined(ShippingPC))
function DumpStats( UniqueNetId ForPlayer )
{
	local int i;
	local string CurrentStringStat;
	local UniqueNetId ZeroId;

	`log("Reading stats for"@class'OnlineSubsystem'.static.UniqueNetIdToString( ForPlayer, false ));

	if( Rows.Length > 0 )
	{
		// This is kind of a hack. If the player ID was never set on the stats, ensure we don't send one so it won't break GetStatValueForPlayerAsString
		if( Rows[0].PlayerId == ZeroId )
		{
			ForPlayer = ZeroId;
		}

		for( i = 0; i < ColumnMappings.Length; i++ )
		{
			if( GetStatValueForPlayerAsString( ForPlayer, ColumnMappings[i].Id, CurrentStringStat) )
			{
				`log("Listing stat"@ColumnMappings[i].Name@"with value"@CurrentStringStat);
			}
			else
			{
				`log("Failed to get stat for Id"@ColumnMappings[i].Id);
			}
		}
	}
	else
	{
		`log("No stats available to dump");
	}
}
`endif

defaultproperties
{
	bLogStatsRead=false
	
	ViewId=VIEWID_KFGameStats

	ColumnIds.Add(STATID_Cmdo_Progress)
	ColumnIds.Add(STATID_Cmdo_Build)
	ColumnIds.Add(STATID_Bsrk_Progress)
	ColumnIds.Add(STATID_Bsrk_Build)
	ColumnIds.Add(STATID_Sup_Progress)
	ColumnIds.Add(STATID_Sup_Build)
	ColumnIds.Add(STATID_Fire_Progress)
	ColumnIds.Add(STATID_Fire_Build)
	ColumnIds.Add(STATID_Medic_Progress)
	ColumnIds.Add(STATID_Medic_Build)
	ColumnIds.Add(STATID_Shrp_Progress)
	ColumnIds.Add(STATID_Shrp_Build)
	ColumnIds.Add(STATID_Demo_Progress)
	ColumnIds.Add(STATID_Demo_Build)
	ColumnIds.Add(STATID_Surv_Progress)
	ColumnIds.Add(STATID_Surv_Build)
	ColumnIds.Add(STATID_Guns_Progress)
	ColumnIds.Add(STATID_Guns_Build)
	ColumnIds.Add(STATID_SWAT_Progress)
	ColumnIds.Add(STATID_SWAT_Build)
	ColumnIds.Add(STATID_Kills)
	ColumnIds.Add(STATID_StalkerKills)
	ColumnIds.Add(STATID_Sup_WeldPoints)
	ColumnIds.Add(STATID_Medic_HealPoints)
	ColumnIds.Add(STATID_CrawlerKills)
	ColumnIds.Add(STATID_FleshpoundKills)
    ColumnIds.Add(STATID_SpecialEventProgress)
    ColumnIds.Add(STATID_WeeklyEventProgress)
    ColumnIds.Add(STATID_DailyEventInfo)
    ColumnIds.Add(STATID_DailyEventIDs)
    ColumnIds.Add(STATID_DailyEventStats1)
    ColumnIds.Add(STATID_DailyEventStats2)
	ColumnIds.Add(STATID_SpecialEventKills_DEPRECATED);
	ColumnIds.Add(STATID_SeasonalEventStats1);
	ColumnIds.Add(STATID_SeasonalEventStats2);
	ColumnIds.Add(STATID_SeasonalEventStats3);
	ColumnIds.Add(STATID_SeasonalEventStats4);
	ColumnIds.Add(STATID_SeasonalEventStats5);
	ColumnIds.Add(STATID_PersonalBest_KnifeKills)
	ColumnIds.Add(STATID_PersonalBest_PistolKills)
	ColumnIds.Add(STATID_PersonalBest_HeadShots)
	ColumnIds.Add(STATID_PersonalBest_Healing)
	ColumnIds.Add(STATID_PersonalBest_Kills)
	ColumnIds.Add(STATID_PersonalBest_Assists)
	ColumnIds.Add(STATID_PersonalBest_LargeZedKill)
	ColumnIds.Add(STATID_PersonalBest_Dosh)
	ColumnIds.Add(STATID_MatchWins)
    ColumnIds.Add(STATID_DoshVaultTotal)
    ColumnIds.Add(STATID_LastViewedDoshVaultTotal)
	ColumnIds.Add(STATID_DoshVaultProgress)
	ColumnIds.Add(STATID_DoshVaultRecovered)

	ColumnMappings.Add((Id=STATID_Cmdo_Progress, Name="CmdoProgress"))
	ColumnMappings.Add((Id=STATID_Cmdo_Build, Name="CmdoBuild"))
	ColumnMappings.Add((Id=STATID_Bsrk_Progress, Name = "BsrkProgress"))
	ColumnMappings.Add((Id=STATID_Bsrk_Build, Name = "BsrkBuild"))
	ColumnMappings.Add((Id=STATID_Sup_Progress, Name = "SupProgress"))
	ColumnMappings.Add((Id=STATID_Sup_Build, Name = "SupBuild"))
	ColumnMappings.Add((Id=STATID_Fire_Progress, Name = "FireProgress"))
	ColumnMappings.Add((Id=STATID_Fire_Build, Name = "FireBuild"))
	ColumnMappings.Add((Id=STATID_Medic_Progress, Name = "MedicProgress"))
	ColumnMappings.Add((Id=STATID_Medic_Build, Name = "MedicBuild"))
	ColumnMappings.Add((Id=STATID_Shrp_Progress, Name = "ShrpProgress"))
	ColumnMappings.Add((Id=STATID_Shrp_Build, Name = "ShrpBuild"))
	ColumnMappings.Add((Id=STATID_Demo_Progress, Name = "DemoProgress"))
	ColumnMappings.Add((Id=STATID_Demo_Build, Name = "DemoBuild"))
	ColumnMappings.Add((Id=STATID_Surv_Progress, Name = "SurvProgress"))
	ColumnMappings.Add((Id=STATID_Surv_Build, Name = "SurvBuild"))
	ColumnMappings.Add((Id=STATID_Guns_Progress, Name = "GunsProgress"))
	ColumnMappings.Add((Id=STATID_Guns_Build, Name = "GunsBuild"))
	ColumnMappings.Add((Id=STATID_SWAT_Progress, Name = "SWATProgress"))
	ColumnMappings.Add((Id=STATID_SWAT_Build, Name = "SWATBuild"))
	ColumnMappings.Add((Id=STATID_Kills, Name = "Kills"))
	ColumnMappings.Add((Id=STATID_StalkerKills, Name = "StalkerKills"))
	ColumnMappings.Add((Id=STATID_Sup_WeldPoints, Name = "SupWeldPoints"))
	ColumnMappings.Add((Id=STATID_Medic_HealPoints, Name = "MedicHealPoints"))
	ColumnMappings.Add((Id=STATID_CrawlerKills, Name = "CrawlerKills"))
	ColumnMappings.Add((Id=STATID_FleshpoundKills, Name = "FleshpoundKills"))
    ColumnMappings.Add((Id=STATID_SpecialEventProgress, Name = "SpecialEventProgress"))
    ColumnMappings.Add((Id=STATID_WeeklyEventProgress, Name = "WeeklyEventProgress"))
    ColumnMappings.Add((Id=STATID_DailyEventInfo, Name="DailyEventProgress"))
    ColumnMappings.Add((Id=STATID_DailyEventIDs, Name="DailyEventIDs"))
    ColumnMappings.Add((Id=STATID_DailyEventStats1, Name="DailyEventStats1"))
    ColumnMappings.Add((Id=STATID_DailyEventStats2, Name="DailyEventStats2"))
	ColumnMappings.Add((Id=STATID_SpecialEventKills_DEPRECATED, Name="SpecialEventKills"))
	ColumnMappings.Add((Id=STATID_SeasonalEventStats1, Name="SeasonalEventStats1"))
	ColumnMappings.Add((Id=STATID_SeasonalEventStats2, Name="SeasonalEventStats2"))
	ColumnMappings.Add((Id=STATID_SeasonalEventStats3, Name="SeasonalEventStats3"))
	ColumnMappings.Add((Id=STATID_SeasonalEventStats4, Name="SeasonalEventStats4"))
	ColumnMappings.Add((Id=STATID_SeasonalEventStats5, Name="SeasonalEventStats5"))
	ColumnMappings.Add((Id=STATID_PersonalBest_KnifeKills, Name = "PersonalBestKnifeKills"))
	ColumnMappings.Add((Id=STATID_PersonalBest_PistolKills, Name = "PersonalBestPistolKills"))
	ColumnMappings.Add((Id=STATID_PersonalBest_HeadShots, Name = "PersonalBestHeadshots"))
	ColumnMappings.Add((Id=STATID_PersonalBest_Healing, Name = "PersonalBestHealing"))
	ColumnMappings.Add((Id=STATID_PersonalBest_Kills, Name = "PersonalBestKills"))
	ColumnMappings.Add((Id=STATID_PersonalBest_Assists, Name = "PersonalBestAssists"))
	ColumnMappings.Add((Id=STATID_PersonalBest_LargeZedKill, Name = "PersonalBestLargeZedKills"))
	ColumnMappings.Add((Id=STATID_PersonalBest_Dosh, Name = "PersonalBestDosh"))
	ColumnMappings.Add((Id=STATID_MatchWins, Name = "MatchWins"))
    ColumnMappings.Add((Id=STATID_DoshVaultTotal, Name="DoshVaultTotal"))
    ColumnMappings.Add((Id=STATID_LastViewedDoshVaultTotal, Name="LastViewedDoshVaultTotal"))
	ColumnMappings.Add((Id=STATID_DoshVaultProgress, Name="DoshVaultProgress"))
	ColumnMappings.Add((Id=STATID_DoshVaultRecovered, Name="DoshVaultRecovered"))
}
