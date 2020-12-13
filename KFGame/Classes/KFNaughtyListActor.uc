class KFNaughtyListActor extends Actor
	placeable;

var KFGFxMoviePlayer_NaughtyList MyMoviePlayer;
var class<KFGFxMoviePlayer_NaughtyList> MyNaughtyListClass;
var KFGameReplicationInfo KFGRI;
var float UpdateInterval;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Init();
}

simulated function Init()
{
	if (Role == ROLE_Authority && WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}
	MyMoviePlayer = new() MyNaughtyListClass;
	MyMoviePlayer.SetTimingMode(TM_Real);
	if( MyMoviePlayer.MovieInfo != None )
	{
		if( MyMoviePlayer.bAutoPlay )
		{
			MyMoviePlayer.Start();
			MyMoviePlayer.Advance(0.f);
		}
	}
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	MyMoviePlayer.KFGRI = KFGRI;
	SetTimer(UpdateInterval, true, nameof(Update));
	Update();
}

simulated function Update()
{
	if (Role == ROLE_Authority && WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}
	MyMoviePlayer.Refresh();
}


DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
        Sprite=Texture2D'EditorResources.S_Trigger'
        HiddenGame=true
        AlwaysLoadOnClient=False
        AlwaysLoadOnServer=False
        SpriteCategoryName="Triggers"
    End Object
    Components.Add(Sprite)

	//defaults
	MyNaughtyListClass=class'KFGame.KFGFxMoviePlayer_NaughtyList'
	UpdateInterval=5.0f

	bGameRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bCollideActors=false
}