//=============================================================================
// PlugInOwnerInterface
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
interface PlugInOwnerInterface;

function BaseAiPlugInHistory GetAiPlugInHistory();

//function float GetCurrentTime();
function float GetTimeSince( float Time2Test );