//=============================================================================
// KFUIDataStore_GameResource
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 11/25/2013
//=============================================================================

class KFUIDataStore_GameResource extends UIDataStore_GameResource
	native(UIPrivate);

/** Returns the KFMapSummary using the mapname as the key */
static function KFMapSummary GetMapSummaryFromMapName( string MapName )
{
	local KFUIDataStore_GameResource GameResourceDS;
	local array<UIResourceDataProvider> MapProviders;
	local int ProviderIndex;

	GameResourceDS = KFUIDataStore_GameResource(class'UIRoot'.static.StaticResolveDataStore(class'KFUIDataStore_GameResource'.default.Tag));

	if ( GameResourceDS != None )
	{
		if ( GameResourceDS.GetResourceProviders('Maps', MapProviders) )
		{
			ProviderIndex = GameResourceDS.FindProviderIndexByMapName( MapName, MapProviders );
			if ( ProviderIndex != INDEX_NONE && ProviderIndex >= 0 && ProviderIndex < MapProviders.length )
			{
				return KFMapSummary(MapProviders[ProviderIndex]);
			}
		}
	}

	return None;
}

static function int FindProviderIndexByMapName( string MapName, out array<UIResourceDataProvider> out_MapProviders)
{
	local int i;
	for ( i = 0; i < out_MapProviders.length; i++ )
	{
		if ( Caps(KFMapSummary(out_MapProviders[i]).MapName) == Caps(MapName) )
		{
			return i;
		}
	}
	return -1;
}


/** Returns the mapname at a specific provider index */
static function string GetMapNameUsingProviderIndex( int ProviderIndex )
{
	local UIDataStore_GameResource GameResourceDS;
	local array<UIResourceDataProvider> MapProviders;
	local KFMapSummary MapData;

	GameResourceDS = UIDataStore_GameResource(class'UIRoot'.static.StaticResolveDataStore(class'KFUIDataStore_GameResource'.default.Tag));
	if ( GameResourceDS != None )
	{
		// Grab the map providers
		if ( GameResourceDS.GetResourceProviders('Maps', MapProviders) )
		{
			if ( MapProviders.length > 0 &&
				 ProviderIndex >= 0 &&
				 ProviderIndex < MapProviders.length )
			{
				MapData = KFMapSummary(MapProviders[ProviderIndex]);
				return MapData.MapName;
			}
		}
	}

	return "";
}

/** Inits all of the data providers from their per object config sections */
native private function InitializeProvidersInternal();

/** Inits all of the data providers from their per object config sections */
//native final function int FindProviderIndexByMapName( string MapName, out array<UIResourceDataProvider> out_MapProviders) const;

/** static method to initialize the providers */
static function InitializeProviders()
{
	local KFUIDataStore_GameResource GameResourceDS;

	GameResourceDS = KFUIDataStore_GameResource(class'UIRoot'.static.StaticResolveDataStore(class'KFUIDataStore_GameResource'.default.Tag));
	if (GameResourceDS != None)
	{
		GameResourceDS.InitializeProvidersInternal();
	}
}
