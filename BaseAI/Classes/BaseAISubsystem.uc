//=============================================================================
// AnimationProxy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class BaseAISubsystem extends AISubsystem
	config(Engine)
	native
	inherits(FCallbackEventDevice,FTickableObject);

var AIDebugTool AIDebug;

var const array<BaseAISquad> Squads;

var const array<INT> TeamSizes;

// ----------------------------------------------------------------------- //
// @deprecated with __TW_BASEAI_LEAN_
// ----------------------------------------------------------------------- //
`if(`notdefined(__TW_BASEAI_LEAN_))
var ETQSystem ETQSys;
var BTManager BTMgr;
var MessageSystem MsgSys;
var NavigationSystem NavSys;
var DigitalActingManager DAM;
var SightSystem SightSys;

var const SmartObjectReplicationActor SmartObjectReplication;
var const array<SOHubComponent> SmartObjects;
var const array<SOHubComponent> InitPendingSmartObjects;
var const array<CoverLink> SpawnedCovers;
var const array<AIAvoidanceComponent> AvoidanceComponents;

native static final noexport function ETQSystem GetETQSystem();
native static final noexport function BTManager GetBTManager();
native static final noexport function MessageSystem GetMessageSystem();
native static final noexport function NavigationSystem GetNavigationSystem();
native static final noexport function DigitalActingManager GetDAM();
native static final noexport function SightSystem GetSightSystem();

native static final noexport function RegisterSmartObject(SOHubComponent SO);
native static final noexport function UnRegisterSmartObject(SOHubComponent SO);

native static final noexport function RegisterSpawnedCover(CoverLink Cover);
native static final noexport function UnRegisterSpawnedCover(CoverLink Cover);

native static final noexport function RegisterAvoidanceComponent(AIAvoidanceComponent AvoidanceComponent);
native static final noexport function UnRegisterAvoidanceComponent(AIAvoidanceComponent AvoidanceComponent);
`endif

// ----------------------------------------------------------------------- //
// END __TW_BASEAI_LEAN_
// ----------------------------------------------------------------------- //

native static final noexport function BaseAISubsystem GetInstance();
native static final noexport function AIDebugTool GetAIDebugTool();

native static final noexport function RegisterSquad(BaseAISquad Squad);
native static final noexport function UnRegisterSquad(BaseAISquad Squad);

native static final noexport function IncreaseTeamSize(BYTE TeamId);
native static final noexport function DecreaseTeamSize(BYTE TeamId);
native static final noexport function int GetTeamSize(byte TeamId);
native static final noexport function int GetEnemyTeamsSize(byte TeamId);

//NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn, class<DamageType> damageType)
native static final function NotifyKilled(Controller Killer, Controller KilledController, Pawn KilledPawn, class<DamageType> damageType);

cpptext
{
	virtual void Init(UBOOL bEngineStart = FALSE);
	virtual void Tick(FLOAT DeltaSeconds);
	virtual void CleanUp(UBOOL bShutDown = FALSE);
	virtual void PrepareMapChange();
	virtual void OnLevelStreamedOut(ULevel* Level);
	
	static UAIDebugTool* GetAIDebugTool(void);

	static void RegisterSquad(class ABaseAISquad* Squad);
	static void UnRegisterSquad(class ABaseAISquad* Squad);
	static TArray<ABaseAISquad*>* GetSquads();

	static void ObjectDestroyed(UObject* Object);

	static void IncreaseTeamSize(BYTE TeamId);
	static void DecreaseTeamSize(BYTE TeamId);

	static void OnPawnDestroyed(class ABaseAIPawn* Pawn);
	void OnCheckPointLoad();

private:
	void DecreaseTeamSizeInternal(BYTE TeamId);
public:
	static int GetTeamSize(BYTE TeamId);
	static int GetEnemyTeamsSize(BYTE TeamId, BYTE TeamIdLimit = 255);

	//-- editor related methods --//
	void OnPIEEnd();
	void OnPIEMapSwitch();
	
	virtual void Send(ECallbackEventType InType);
	virtual void Send(ECallbackEventType InType, DWORD Flags);

	virtual UBOOL IsTickable() const { return TRUE; }
};

defaultproperties
{
	bImplementsNavMeshGeneration=true
}
