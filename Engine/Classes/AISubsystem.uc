/**
 * Copyright 2008 PCF, All Rights Reserved.
 * This class is here because Engine needs to hold a pointer to an instance of it.
 */
 class AISubsystem extends Subsystem
	abstract
	native;

var bool bImplementsNavMeshGeneration;

cpptext
{
	virtual void Init(UBOOL bEngineStart = FALSE) PURE_VIRTUAL(UAISubsystem::Init,);
	virtual void CleanUp(UBOOL bShutDown = FALSE) PURE_VIRTUAL(UAISubsystem::CleanUp,);

	/** to be called on new level loading */
	virtual void Reset() PURE_VIRTUAL(UAISubsystem::Reset,);

	virtual void PrepareMapChange() PURE_VIRTUAL(UAISubsystem::PrepareMapChange,);
	/** GC started, after all CALLBACK_PreGarbageCollection */
	virtual void OnLevelStreamedOut(ULevel* Level) PURE_VIRTUAL(UAISubsystem::OnLevelStreamedOut,);

	/** interface for triggering nav mesh generation */
	virtual UBOOL GenerateNavMesh() { return FALSE; }

	virtual void OnPIEStart() PURE_VIRTUAL(UAISubsystem::OnPIEStart,);
	virtual void OnPIEFinished() PURE_VIRTUAL(UAISubsystem::OnPIEFinished,);

	virtual void ToggleNavBy(AActor* Referencer, UBOOL bEnable, BYTE NavFlag=0) PURE_VIRTUAL(UAISubsystem::ToggleNavBy,);
	virtual void ToggleNavBy(UComponent* Referencer, UBOOL bEnable, BYTE NavFlag=0) PURE_VIRTUAL(UAISubsystem::ToggleNavBy,);
	virtual void ToggleNavBy(ACoverLink* Referencer, INT SlotIdx, UBOOL bEnable, BYTE NavFlag=0) PURE_VIRTUAL(UAISubsystem::ToggleNavBy,);

	virtual void UpdateActionAreas() PURE_VIRTUAL(UAISubsystem::UpdateActionAreas,);
}

final native static noexport function ToggleNavByActor(Actor Referencer, bool bEnable);
final native static noexport function ToggleNavByComponent(Component Referencer, bool bEnable);
final native static noexport function ToggleNavByCover(CoverLink Referencer, int SlotIdx, bool bEnable);

`if(`__TW_)
/** Used to access the difficulty values from KFGame for BaseAI */
event float GetDifficultyValue(int Index)
{
	return -1;
}
`endif

defaultproperties
{
	bImplementsNavMeshGeneration=false
}
