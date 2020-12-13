/**
 * Holds the base configuration settings
 *
 * NOTE: This class will normally be code generated, but the tool doesn't exist yet
 */
class KFOnlineGameSearch extends OnlineGameSearch
	native;

var public transient enum ESortOrder
{
	SORTORDER_None,
	SORTORDER_ACENDING,
	SORTORDER_DECENDING,

} SortOrder;

var public transient enum ESortType
{
	SORTTYPE_None,
	SORTTYPE_Name,//alphabetic
	SORTTYPE_Mode,//alphabetic
	SORTTYPE_Difficulty,//numeric 
	SORTTYPE_Map,//alphabetic
	SORTTYPE_PlayerCount,//numeric
	SORTTYPE_WaveCount,//numeric
	SORTTYPE_Ping,//numeric
} SortType;

var transient int LastResultsSize;

//Make fake results so we can test the server browser
native final function MakeFakeServerResults();
native final function SortResults(optional ESortType NewSortType = SORTTYPE_None, optional ESortOrder NewSortOrder = SORTORDER_None);

function bool SortIfChanged()
{
	if (Results.length != LastResultsSize)
	{
		LastResultsSize = Results.length;
		SortResults();
		return true;
	}
	return false;
}

defaultproperties
{
	GameSettingsClass=class'KFGame.KFOnlineGameSettings'
	SortOrder=SORTORDER_ACENDING
	SortType=SORTTYPE_Ping
	bIsLanQuery=false
	MaxSearchResults=25
	LastResultsSize=0
}