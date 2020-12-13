class KFGFxMoviePlayer_NaughtyList extends GFxMoviePlayer;

var KFGFxNaughtyList NaughtyListMenu;
var KFGameReplicationInfo KFGRI;

const MAX_NAMES = 12;
var array<string> FillerNames;

event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local bool bHandled;

	bHandled = true;

	switch (WidgetName)
	{
		case 'NaughtyList':
			if(NaughtyListMenu == none)
			{
				NaughtyListMenu = KFGFxNaughtyList(Widget);
				NaughtyListMenu.Initialize();
				Refresh();
			}
			break;
		default:
			bHandled = false;
	}

	return bHandled;
}


simulated function Refresh()
{
	local GFxObject DataObject;
	local GFxObject DataProvider;
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local int i;

	if (KFGRI == none)
	{
		return;
	}
	DataProvider = CreateArray();
	//get the player list
	KFGRI.GetKFPRIArray(KFPRIArray);//pass by reference

	for (i = 0; i < MAX_NAMES; i++)
	{
		DataObject = CreateObject("Object");
		if (KFPRIArray.length > i)
		{
			DataObject.SetString("label", KFPRIArray[i].PlayerName);
		}
		else
		{
			DataObject.SetString("label", FillerNames[i]);
		}
		//DataObject.SetBool("bDead", KFPRIArray[i].PlayerHealth <= 0);
		DataProvider.SetElementObject(i, DataObject);
	}
	
	
	NaughtyListMenu.SetObject("Data", DataProvider);
}


DefaultProperties
{
	//defaults
	RenderTextureMode=RTM_AlphaComposite
	RenderTexture=TextureRenderTarget2D'UI_World_NaughtyList.NaughtyList_RT'
	MovieInfo=SwfMovie'UI_World_NaughtyList.NaughtyListWorld_SWF'	
	bCaptureInput=false
	bAutoPlay=true

	WidgetBindings.Add((WidgetName="NaughtyList",WidgetClass=class'KFGFxNaughtyList'))

	FillerNames(0)="Mia"
	FillerNames(1)="Adam"
	FillerNames(2)="Tyler"
	FillerNames(3)="Jon"
	FillerNames(4)="Dave"
	FillerNames(5)="Other Dave"
	FillerNames(6)="Zane"
	FillerNames(7)="Joe"
	FillerNames(8)="Bill"
	FillerNames(9)="Alan"
	FillerNames(10)="Andrew"
	FillerNames(11)="Chris"

}