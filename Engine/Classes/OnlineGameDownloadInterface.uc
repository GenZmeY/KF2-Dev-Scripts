// A game-downloading interface
interface OnlineGameDownloadInterface dependson(OnlineSubsystem);

enum EDownloadSpeed
{
	EDLS_Pause,
	EDLS_Slow,
	EDLS_Fast,
};

function bool IsGameComplete();

function bool IsChunkComplete( const int InChunkIndex, const bool bRequireFastAccess );
function bool AreChunksComplete( const array<int> ChunkIndices, const bool bRequireFastAccess );

function bool DoesGameNeedRefresh();
function RefreshGame();

function float GetChunkETA( const int InChunkIndex );
function float GetChunksETA( const array<int> ChunkIndices );

function float GetChunkProgress( const int InChunkIndex );
function float GetChunksProgress( const array<int> ChunkIndices );
function float GetOverallProgress();

function array<int> GetTodoList();

function SetChunksHighPriority( const array<int> ChunkIndices );
function SetDownloadSpeed( const EDownloadSpeed InSpeed );

delegate OnChunkComplete( const int ChunkIndex );
function AddOnChunkCompleteDelegate( delegate<OnChunkComplete> InDelegate );
function ClearOnChunkCompleteDelegate( delegate<OnChunkComplete> InDelegate );
