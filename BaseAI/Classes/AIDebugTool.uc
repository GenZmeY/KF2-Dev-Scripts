//=============================================================================
// AIDebugTool
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AIDebugTool extends Object
	dependson(BaseAIController)
	config(AI)
    native(Debug);

var transient float GameFrameTime;

var int BTPersonalLogSize;
var array<string> BTPersonalLog;

var BaseAIController DebugTarget;
var int EntryToDisplay;

var transient init array<name> Filters;
var array<name> ColorCategories;

var array<Actor> UnreachableActors;

enum ELogDrawingMode
{
	AIDH_DrawAll,
	AIDH_EntryDetails,
	AIDH_BlackBoard,
	AIDH_Preconditions,
	AIDH_SquadEnemy,
	AIDH_Animation,
	AIDH_Weapon
};
var int DrawingFlags;

struct String_Mirror
{
	var string Value;
};

struct native AIDebugLogLine
{
	var native String_Mirror Line{FString};
	var native Name LineCategory;
	//@todo Add additional data, like position, hit info, etc

	structcpptext
	{
	FAIDebugLogLine(const TCHAR* PtrLine, FName inCategory = NAME_None)
	{
		Line = PtrLine;
		LineCategory = inCategory;
	}

	FAIDebugLogLine(const FString& LineIn, FName inCategory = NAME_None)
	{
		Line = LineIn;
		LineCategory = inCategory;
	}
	}
};

struct native AIDebugLogEntry
{
	var float TimeStamp;
	var vector WorldPosition;
	var vector EnemyPosition;
	var vector Facing;
	var native String_Mirror BTStatus{FString};
	var native array<String_Mirror> BlackBoardEntries{FString};
	var native array<String_Mirror> BehaviorTrace{FString};
	var native array<String_Mirror> Preconditions{FString};
	var native array<String_Mirror> CommandStack{FString};
	var native array<String_Mirror> SquadEnemyList{FString};
	var native array<String_Mirror> LocalEnemyList{FString};
	var native array<String_Mirror> InnerState{FString};
	var native array<String_Mirror> AnimationProxy{FString};
	var native array<vector> Route;
	var native init array<SpaceLineInfo> DebugLines;
	var native array<String_Mirror> WeaponInfo{FString};
	var array<AIDebugLogLine> Lines;

	structcpptext
	{
	FAIDebugLogEntry() 
	{
		appMemzero(this, sizeof(FAIDebugLogEntry));
    }
	}
};

struct native AIDebugActorsLog
{
	var int Tail;
	var array<AIDebugLogEntry> Entries;
	var int NotEmptyElements;

	/** this variable is used for pooling. DO NOT CHANGE! */
    var private const int nIndex;

	structcpptext
	{

	enum { LogSize = 500 };

	FAIDebugActorsLog(UBOOL bInit = TRUE)
    {
		appMemzero(this, sizeof(FAIDebugLogEntry));
		if(bInit)
		{
			Init();
		}
    }

	FORCEINLINE void Init()
	{
		Entries.Reserve(LogSize);
		Entries.AddZeroed(LogSize);
	}

	FORCEINLINE void Reset()
	{
		Entries.Empty(LogSize);
		Entries.AddZeroed(LogSize);
		NotEmptyElements = 0;
	}

	/** Pooling interface Get*/
	FORCEINLINE INT GetIndex() const
	{
	   return nIndex;
	}
	/** Pooling interface Set*/
	FORCEINLINE void SetIndex(INT index)
	{
	   nIndex = index;
	}

	void SaveToFile(FArchive* File);
	void LoadFile(FArchive* File, UBOOL bLoadOldLogs = FALSE);
	
	}
};

struct native ETQDebugEntry
{
	var float TimeStamp;
	var native init array<String_Mirror> ExecutedQueries{FString};
};
var transient ETQDebugEntry CurrentETQLog;
var init array<ETQDebugEntry> ETQLogHistory;

var bool bLoadOldLogs;

var transient Actor LoggingContext;

var native const Map_Mirror	Logs{TMap<const AActor*, FAIDebugActorsLog*>};

/**
 * Draws stored log for given Actor. If Actor == None than contents of loaded 
 * ailogex file are displayed
 */
final native function DrawLog(Canvas Canvas, Actor Actor);
final native function bool LoadLogFile(string FileName, optional bool bAppendMapName = true);
final native function FlushLogs(optional string DirName, optional BaseAIController AI);

final native function SetDebugTarget(BaseAIController NewDebugTarget);

final native noexport function Log(Actor Actor, string LogText, optional Name LogCategory);
final native noexport function LogSpaceLine(Actor Actor, vector Start, vector End, EDebugLineType Type, optional string Comment, optional Name Category);

final native function SetContext(Actor Actor);

/**
 * To get previous entries send a negative number as a parameter
 */
final native function DisplayNextEntry(optional int Count = 1, optional int Direction = 1);

final native function ToggleLogDrawingMode(ELogDrawingMode Mode);

final native function SetHistoryFilter(Name Filter, bool bVal);
final native function ClearHistoryFilter();

final native function ColorHistory(Name Filter);
final native function ClearHistoryColor();

final native function LogUnreachableActor(Actor inActor);
final native function FlushUnreachableActors();

final native function AddETQLog(string QueryName, string TestName, Actor Querier);
final native function FlushETQHistory();

final native function AddBTLogEntry(string Entry);

final native function Vector GetActorEntryLocation(optional Actor inActor, optional int Index=-1);

final native function DumpNativeCallStack(Actor Actor, optional Name LogCategory = 'CallStack');

cpptext
{
	void Init();
	void Tick(FLOAT DeltaTime);
	void CleanUp(UBOOL bShutDown);
	
	void FlushAILog(class AActor* Actor, UBOOL bRemoveLog = FALSE);

	enum EAILogElement
	{
		AILE_PrevChannel,
		AILE_Command,
		AILE_Timestamp,
		AILE_BlackBoard,
		AILE_BehaviorStack,
		AILE_Preconditions,
		AILE_CommandStack,
		AILE_SquadEnemies,
		AILE_LocalEnemies,
		AILE_Route,
		AILE_InnerState,
		AILE_WeaponInfo
	};

	void Log(const class AActor* Actor,const FString& LogText,FName LogCategory=NAME_None);
	void LogSpaceLine(const class AActor* Actor,const FVector& Start,const FVector& End,BYTE Type,const FString& Comment=TEXT(""),FName Category=NAME_None);
	void ContextLog(const FString& LogText,FName LogCategory=NAME_None);
	void ContextLogSpaceLine(const FVector& Start,const FVector& End,BYTE Type,const FString& Comment=TEXT(""),FName Category=NAME_None);

protected:
	void ChannelEntryHeader(const class AActor* Actor, FAIDebugLogEntry* ptrEntry);
	UBOOL HasAnyLines(struct FAIDebugActorsLog* Log, INT EntryIdx, TArray<FName>& inFilters) const;
	FAIDebugLogEntry* GetLogEntry(const class AActor* Actor);

private:
	static TDataBank<FAIDebugActorsLog> sm_Logs;
};

defaultproperties
{
	BTPersonalLogSize=23
	bLoadOldLogs=false
}
