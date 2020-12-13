
class KFOnlineLobbyDingo extends TWOnlineLobby within OnlineSubsystemDingo
    config( Engine )
    native;

var OnlineSubsystem OnlineSubsystem;

function bool Initialize()
{
    OnlineSubsystem.GameInterface.AddCreateOnlineGameCompleteDelegate( OnCreateOnlineGameComplete );
    OnlineSubsystem.GameInterface.AddMultiplayerSessionChangeDelegate( OnMultiplayerSessionChange );
    return true;
}

event EmitUIMessage( string Message )
{
    class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().ClientMessage( Message );
}

event EmitJoinMessage( string Message )
{
    class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController().JoinPlayfabServer( true, Message );
}

function native bool LobbyJoinGame( optional string ServerIP );

function native bool LobbyJoinServer( string ServerIP );

function native SetServerPassword( string password );

function native string GetLobbyURLString();

function native bool IsInLobby();

function native bool IsLobbyOwner();

function native bool GetLobbyAdmin( UniqueNetId LobbyId, out UniqueNetId AdminId );

function native UniqueNetId GetMyId();

function native string GetFriendNickname( UniqueNetId FriendId, optional bool IncludeSelf = true );

function native SetLobbyData( string Key, string Value );

function native string GetLobbyData( int LobbyIndex, string Key );

function native bool SetVisibility( int VisibilityIndex );

function native ShowLobbyInviteInterface( string InviteMessage );

function native bool SendInviteToUsers( array<string> MembersToInvite, string InviteMessage );

function native bool LobbyMessage( string Message );

function native bool GetCurrentLobby( out ActiveLobbyInfo LobbyInfo );

function native int GetCurrentPartySize();

function native UniqueNetId GetCurrentLobbyId();

function native bool GetLobbyFromCommandline( out UniqueNetId LobbyId, optional bool bMarkAsJoined = True );

function native LobbyInvite( UniqueNetId LobbyId, UniqueNetId FriendId, bool bAccepted );

function native bool MakeLobby( int MaxPlayers, ELobbyVisibility Type );

function native bool QuitLobby();

function native OnMultiplayerSessionChange( Name SessionName, SessionUpdateInfo SessionChanges );

function native OnCreateOnlineGameComplete( name SessionName, bool bWasSuccessful );