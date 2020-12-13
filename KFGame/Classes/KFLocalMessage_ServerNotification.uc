class KFLocalMessage_ServerNotification extends KFLocalMessage;

enum EServerMessageType
{
	SMT_None,
	// usables messaging (should always be lowest "priority")
	SMT_TeamsPendingBalance,
};

var localized string			TeamPendingBalanceMessage;


static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch ( Switch )
	{
		case SMT_TeamsPendingBalance:
			return default.TeamPendingBalanceMessage;
			break;

		default: return "";
	}
}