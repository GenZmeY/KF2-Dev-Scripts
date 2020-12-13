class KFGFxWidget_MenuBarVersus extends KFGFxWidget_MenuBar;

static function bool CanUseGearButton( PlayerController PC, KFGfxMoviePlayer_Manager GfxManager )
{
	return PC.PlayerReplicationInfo.GetTeamNum() != 255 && super.CanUseGearButton( PC, GfxManager );
}