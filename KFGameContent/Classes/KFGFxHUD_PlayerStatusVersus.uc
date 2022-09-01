class KFGFxHUD_PlayerStatusVersus extends KFGFxHUD_PlayerStatus;

var class<Pawn> LastPawnClass;

function TickHud(float DeltaTime)
{
    UpdateHealth();
    UpdateCharacterName();
}

function UpdateCharacterName()
{
    local KFPawn MyKFPawn;
    if(MyPC.Pawn != none && LastPawnClass != MyPC.Pawn.Class )
    {
        MyKFPawn = KFPawn(MyPC.Pawn);
        if(MyKFPawn != none)
        {
            LastPawnClass = MyPC.Pawn.Class;
            SetString("characterName", MyKFPawn.GetLocalizedName());
        }
    }
}

// Overridden to not need human pawns
function UpdateHealth()
{
    if( MyPC == none || MyPC.Pawn == none )
    {
        LastHealth = 0;
        SetInt("playerHealth" , LastHealth);
	}
	else if( LastHealth != MyPC.Pawn.Health )
	{
        SetInt("playerHealth" , ( float(MyPC.Pawn.Health) / float(MyPC.Pawn.HealthMax) ) * 100 );
        LastHealth = MyPC.Pawn.Health;
	}
    SetVisible(LastHealth > 0);
}


function UpdateXP(int XPDelta, int XPPercent, bool bLevelUp, Class<KFPerk> PerkClass)
{
    
}

function UpdateArmor()
{
    
}


function UpdatePerk()
{
   
}


function UpdateHealer(Optional bool bForce)
{
   
}


function ShowActiveIndicators( array<ActiveSkill> ActiveSkills )
{
    
}

function ClearBuffIcons()
{

}


defaultproperties
{
    LastPerkLevel=-1
}

