interface OnlinePartyInterface dependson(OnlineSubsystem);

function GetPartyMembers( out array<PartyMember> OutPartyMembers );
function UniqueNetId GetLeaderMemberId();
function UniqueNetId GetMyMemberId();

function bool InviteToPartyByUserNames( array<string> UserNames, string InviteMessage );

function bool CreateParty( bool bPrivate );
function bool LeaveParty();

// Messages
function bool SendMessage( string Message );
delegate OnNotifyMessageReceived( string Message, UniqueNetId Sender );
function AddNotifyMessageReceivedDelegate( delegate<OnNotifyMessageReceived> InDelegate );
function ClearNotifyMessageReceivedDelegate( delegate<OnNotifyMessageReceived> InDelegate );

// Notify that member(s) have updated
delegate OnNotifyPartyMembersUpdated( array<PartyMember> UpdatedMembers );
function AddNotifyPartyMembersUpdatedDelegate( delegate<OnNotifyPartyMembersUpdated> InDelegate );
function ClearNotifyPartyMembersUpdatedDelegate( delegate<OnNotifyPartyMembersUpdated> InDelegate );

// Notify that there is a new leader
delegate OnNotifyLeaderChanged( UniqueNetId NewLeader );
function AddNotifyLeaderChangedDelegate( delegate<OnNotifyLeaderChanged> InDelegate );
function ClearNotifyLeaderChangedDelegate( delegate<OnNotifyLeaderChanged> InDelegate );

`if(`__TW_)
// Notify that there is a new party status
delegate OnNotifyStatusUpdated(EPartyNotificationStatus PartyStatus);
function AddNotifyStatusUpdatedDelegate( delegate<OnNotifyStatusUpdated> InDelegate );
function ClearNotifyStatusUpdatedDelegate( delegate<OnNotifyStatusUpdated> InDelegate );
`endif