//=============================================================================
// KFGameInfo_WeeklySurvival
//=============================================================================
// Weekly variant of KFPC for handling per-player functionality related to
//      different weekly survival modes.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Dan Weiss
//=============================================================================

class KFPlayerController_WeeklySurvival extends KFPlayerController
    native(Controller)
    dependson(EphemeralMatchStats);

/** If the game mode is using permanent zed time, our handling of some functionality is a bit different */
var bool bUsingPermanentZedTime;

/** One of our changes is a radius/height check for relevant actors that would normally kick us out of zed time */
var float ZedTimeRadius;
var float ZedTimeBossRadius;
var float ZedTimeHeight;

/** How often to check for coming out of partial zed time if bUsingPermanentZedTime is on */
var float ZedRecheckTime;

cpptext
{
    virtual UBOOL TestZedTimeVisibility(APawn* P, UNetConnection* Connection, UBOOL bLocalPlayerTest) override;
}

replication
{
    if (bNetDirty)
        bUsingPermanentZedTime, ZedTimeRadius, ZedTimeBossRadius, ZedTimeHeight;
}

function EnterZedTime()
{
    local bool bNewResult;
    local KFPawn KFP;
    local KFPerk MyPerk;

    //Some hax around rechecking zed time if we're in permanent mode.  Do the recheck on IsAffectedByZedTime
    //      and only call client function if the result is different than before.
    if (bUsingPermanentZedTime)
    {
        SetTimer(ZedRecheckTime, false, 'RecheckZedTime');

        KFP = KFPawn(Pawn);
        if (KFP != none)
        {
            bNewResult = IsAffectedByZedTime();
            //== because Pawn is !PC result
            if (KFP.bUnaffectedByZedTime == bNewResult)
            {
                MyPerk = GetPerk();
                if ( MyPerk != none )
                {
                    MyPerk.NotifyZedTimeStarted();
                }

                KFP.bUnaffectedByZedTime = !bNewResult;

                if ( KFP.bUnaffectedByZedTime )
                {
                    StartPartialZedTimeSightCounter();
                }

                // Call the client
                ClientEnterZedTime(KFP.bUnaffectedByZedTime);
            }
        }
    }
    else
    {
        super.EnterZedTime();
    }
}

function RecheckZedTime()
{
    EnterZedTime();
}