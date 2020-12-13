class KFGFxPostRoundContainer_Team extends GfxObject
dependson(KFTeamInfo_Human);

var localized string TitleString;
var localized string WavesCompleteString;
var localized string BossDeadString;
var localized string DeathsString;
var localized string DamageString;
var localized string TotalString;
var localized string YourTeamString;
var localized string OpponentsString;

var int TeamValue;
var int TeamID;

function Initialize()
{
	LocalizeText();
	CreateResultsForTeam();
}

function CreateResultsForTeam()
{
	local GfxObject DataObject;
	local KFGameReplicationInfo KFGRI;
	local sTeamScoreData TeamScoreDataPacket;

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	TeamScoreDataPacket = KFTeamInfo_Human(KFGRI.Teams[TeamID]).TeamScoreDataPacket;

	DataObject = CreateObject("Object");

	if( TeamScoreDataPacket.WaveBonus != INDEX_NONE )
	{
		DataObject.SetInt("waveNum", 		TeamScoreDataPacket.WaveBonus);
		DataObject.SetInt("bossDeadNum", 	TeamScoreDataPacket.BossDamageDone == class'KFGameInfo'.static.GetBossKillScore() ? class'KFGameInfo'.static.GetBossKillScore() : 0);
		DataObject.SetInt("deathNum", 		TeamScoreDataPacket.Deaths * class'KFGameInfo'.default.POINTS_PENALTY_FOR_DEATH);
		DataObject.SetInt("damagNum", 		KFGRI.bMatchVictory ? TeamScoreDataPacket.BossDamageTaken : 0);
		DataObject.SetInt("totalNum", 		TeamScoreDataPacket.RoundScore);	
		DataObject.SetBool("bHasData", 		true);	
	}	
	else
	{
		DataObject.SetBool("bHasData", 		false);	
	}

	SetObject("data", DataObject);	
}


function LocalizeText()
{
	local GfxObject TextObject;
	local string TeamNameString;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	TextObject = CreateObject("Object");

	TeamNameString = TitleString@TeamValue;
	
	if(KFGRI.GetCurrentRoundNumber() == 1)
	{
		if(KFGRI.Teams[TeamID].TeamIndex != GetPC().PlayerReplicationInfo.GetTeamNum())
		{
			TeamNameString = TeamNameString$YourTeamString;
		}
		else
		{
			TeamNameString = TeamNameString$OpponentsString;
		}
	}
	else if(KFGRI.GetCurrentRoundNumber() == 2)
	{
		if(KFGRI.Teams[TeamID].TeamIndex == GetPC().PlayerReplicationInfo.GetTeamNum())
		{
			TeamNameString = TeamNameString$YourTeamString;
		}
		else
		{
			TeamNameString = TeamNameString$OpponentsString;
		}
	}	

	TextObject.SetString("title", 		TeamNameString );
	TextObject.SetString("wavesComp", 	WavesCompleteString);
	TextObject.SetString("bossDead", 	BossDeadString);
	TextObject.SetString("deaths", 		DeathsString);
	TextObject.SetString("damage", 		DamageString);
	TextObject.SetString("total", 		TotalString);

	SetObject("localizedText", TextObject);		
}

DefaultProperties
{

}