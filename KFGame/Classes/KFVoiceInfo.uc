//=============================================================================
// KFVoiceInfo
//=============================================================================
// Base class for all Voices in the game
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFVoiceInfo extends Object
	abstract;

var Array<SoundNodeWave> AckSounds;
var Array<SoundNodeWave> FriendlyFireSounds;
var Array<SoundNodeWave> GotYourBackSounds;
var Array<SoundNodeWave> NeedOurFlagSounds;
var Array<SoundNodeWave> SniperSounds;
var Array<SoundNodeWave> InPositionSounds;
var Array<SoundNodeWave> HaveFlagSounds;
var Array<SoundNodeWave> AreaSecureSounds;

var SoundNodeWave IncomingSound;
var SoundNodeWave EnemyFlagCarrierSound;
var SoundNodeWave EnemyFlagCarrierHereSound;
var SoundNodeWave EnemyFlagCarrierHighSound;
var SoundNodeWave EnemyFlagCarrierLowSound;
var SoundNodeWave MidfieldSound;
var SoundNodeWave GotOurFlagSound;

/** Offset into actor specific location speech array */
var int LocationSpeechOffset;

/** Index offsets for message groups */
const ACKINDEXSTART = 600;
const FRIENDLYFIREINDEXSTART = 700;
const GOTYOURBACKINDEXSTART = 800;
const NEEDOURFLAGINDEXSTART = 900;
const SNIPERINDEXINDEXSTART = 1000;
const LOCATIONUPDATEINDEXSTART = 1100;
const INPOSITIONINDEXSTART = 1200;
const ENEMYSTATUSINDEXSTART = 1300;
const KILLEDVEHICLEINDEXSTART = 1400;
const ENEMYFLAGCARRIERINDEXSTART = 1500;
const HOLDINGFLAGINDEXSTART = 1600;
const AREASECUREINDEXSTART = 1700;
const GOTOURFLAGINDEXSTART = 1900;
const NODECONSTRUCTEDINDEXSTART = 2000;

static function int GetAckMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( default.AckSounds.Length == 0)
	{
		return -1;
	}
	return ACKINDEXSTART + Rand(default.AckSounds.Length);
}

static function int GetFriendlyFireMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( (default.FriendlyFireSounds.Length == 0) || (Recipient == None) || (KFPlayerController(Recipient.Owner) == None) )
	{
		return -1;
	}
	//KFPlayerController(Recipient.Owner).LastFriendlyFireTime = Sender.WorldInfo.TimeSeconds;

	return FRIENDLYFIREINDEXSTART + Rand(default.FriendlyFireSounds.Length);
}

static function int GetGotYourBackMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( default.GotYourBackSounds.Length == 0)
	{
		return -1;
	}
	return GOTYOURBACKINDEXSTART + Rand(default.GotYourBackSounds.Length);
}

static function int GetNeedOurFlagMessageIndex(Controller Sender, PlayerReplicationInfo Recipient, Name Messagetype)
{
	if ( default.NeedOurFlagSounds.Length == 0)
	{
		return -1;
	}
	return NEEDOURFLAGINDEXSTART + Rand(default.NeedOurFlagSounds.Length);
}

defaultproperties
{
}


