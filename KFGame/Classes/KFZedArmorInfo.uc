//=============================================================================
// KFZedArmorInfo
//=============================================================================
// Handles armor info that can be attached to any Zed.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFZedArmorInfo extends Object
	within KFPawn_Monster
	config(Game)
	abstract;

struct ArmorZoneInfo
{
	var name ArmorZoneName;				// Name of the armor zone
	var array<name> AffectedHitZones;	// Hit zones that map to this armor zone
	var bool bAffectedByFrontDamage;	// Whether frontal attacks affect this armor zone
	var bool bAffectedByBackDamage;		// Whether attacks from behind affect this armor zone
	var name SocketName;				// Name of the socket explosion FX play from
	var int ArmorHealth;				// Amount of health the armor absorbs before it blows off
	var int ObliterateDmgThreshold;		// Amount of single-shot damage that will obliterate the armor and negate its protection
	var transient int ArmorHealthMax;
	var ParticleSystem ExplosionTemplate;
	var AkEvent ExplosionSFXTemplate;
	var array<name> BonesToHideOnExplode;
	var array<name> BonesToShowOnExplode;
	var Texture2D ZoneIcon;

	structdefaultproperties
	{
		bAffectedByFrontDamage=true
		bAffectedByBackDamage=true
		ObliterateDmgThreshold=MaxInt
	}
};

var array<ArmorZoneInfo> ArmorZones;
var float ArmorScale;

/** These damage types cause this zed to receive increased damage */
var  array<DamageModifierInfo> ArmorDamageTypeModifiers;

var transient float LastTakeDamageTime;

function byte GetArmorZonePctByte(int ZoneIdx)
{
	return FloatToByte(float(ArmorZones[ZoneIdx].ArmorHealth) / float(ArmorZones[ZoneIdx].ArmorHealthMax));
}

function InitArmor()
{
	local KFGameInfo KFGI;
	local float HealthMod;
	local float HeadHealthMod;
	local int i, j;

	KFGI = KFGameInfo(WorldInfo.Game);
	if (KFGI != None)
	{
		HealthMod = 1.f;
		HeadHealthMod = 1.f;
		KFGI.DifficultyInfo.GetAIHealthModifier(Outer, KFGI.GetModifiedGameDifficulty(), KFGI.GetLivingPlayerCount(), HealthMod, HeadHealthMod);

		for (i = 0; i < ArmorZones.Length; ++i)
		{
			ArmorZones[i].ArmorHealth *= HealthMod;
			ArmorZones[i].ArmorHealthMax = ArmorZones[i].ArmorHealth;
			RepArmorPct[i] = GetArmorZonePctByte(i);
		}
	}

	for (i = 0; i < ArmorZones.Length; ++i)
	{
		for (j = 0; j < ArmorZones[i].BonesToShowOnExplode.length; ++j)
		{
			Mesh.HideBoneByName(ArmorZones[i].BonesToShowOnExplode[j], PBO_Disable);
		}
	}

	UpdateArmorUI();
}

function ExplodeArmor(int ArmorZoneIdx)
{
	if (bool(ArmorZoneStatus & (1 << ArmorZoneIdx)))
	{
		ArmorZones[ArmorZoneIdx].ArmorHealth = 0;
		RepArmorPct[ArmorZoneIdx] = 0;
		ArmorZoneStatus = ArmorZoneStatus ^ (1 << ArmorZoneIdx);
		UpdateArmorPiece(ArmorZoneIdx);
	}
}

simulated function UpdateArmorPieces()
{
	local int i, UpdatedZones;

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		UpdatedZones = ArmorZoneStatus ^ PreviousArmorZoneStatus;
		for (i = 0; i < ArmorZones.Length; ++i)
		{
			if (bool(UpdatedZones & (1 << i)))
			{
				UpdateArmorPiece(i);
			}
		}

		UpdateArmorUI();
	}

	PreviousArmorZoneStatus = ArmorZoneStatus;
}

simulated function UpdateArmorPiece(int PieceIdx)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;
	local KFCharacterInfo_Monster MonsterArch;
	local int i;

	Mesh.GetSocketWorldLocationAndRotation(
		default.ArmorZones[PieceIdx].SocketName, SocketLocation, SocketRotation);
	PlaySoundBase(default.ArmorZones[PieceIdx].ExplosionSFXTemplate, true, true, true,
		SocketLocation, true, SocketRotation);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		MonsterArch = GetCharacterMonsterInfo();
		if (MonsterArch.ExtraVFX.length > PieceIdx)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(
				MonsterArch.ExtraVFX[PieceIdx].VFX, SocketLocation, SocketRotation);
		}
	}

	for (i = 0; i < ArmorZones[PieceIdx].BonesToHideOnExplode.Length; ++i)
	{
		BonesToHidePostAsyncWork.AddItem(ArmorZones[PieceIdx].BonesToHideOnExplode[i]);
	}

	for (i = 0; i < ArmorZones[PieceIdx].BonesToShowOnExplode.Length; ++i)
	{
		BonesToShowPostAsyncWork.AddItem(ArmorZones[PieceIdx].BonesToShowOnExplode[i]);
	}

	if (BonesToHidePostAsyncWork.Length > 0 || BonesToShowPostAsyncWork.Length > 0)
	{
		Outer.SetTickGroup(TG_PostAsyncWork);
	}
}

simulated function UpdateArmorUI()
{
	local SCompressedArmorInfo CompressedArmorInfoList[3];
	local int i;
	local KFPlayerController KFPC;

	if (!IsABoss())
	{
		return;
	}

	KFPC = KFPlayerController(GetALocalPlayerController());

	if (KFPC == none)
	{
		return;
	}

	for (i = 0; i < ArmorZones.length; i++)
	{
		CompressedArmorInfoList[i].Percentage = ByteToFloat(RepArmorPct[i]);
		CompressedArmorInfoList[i].IconTexture = default.ArmorZones[i].ZoneIcon;
	}

	if (KFPC.MyGFxHUD != none && KFPC.MyGFxHUD.bossHealthBar != none)
	{
		KFPC.MyGFxHUD.bossHealthBar.UpdateArmorUI(CompressedArmorInfoList);
	}
}

function SetShieldScale(float InScale)
{
	local int i;

	ArmorScale = InScale;
	for (i = 0; i < ArmorZones.Length; ++i)
	{
		ArmorZones[i].ArmorHealth *= InScale;
		ArmorZones[i].ArmorHealthMax = ArmorZones[i].ArmorHealth;
		RepArmorPct[i] = GetArmorZonePctByte(i);
	}
}

function int GetArmorZoneIndex(name BoneName, vector DamagerSource)
{
	local int HitZoneIdx, i;
	local bool bFrontDamage, bBackDamage;

	bFrontDamage = (DamagerSource - Location) dot Vector(Rotation) > 0;
	bBackDamage = !bFrontDamage;

	HitZoneIdx = HitZones.Find('ZoneName', BoneName);
	if (HitZoneIdx >= 0)
	{
		for (i = 0; i < ArmorZones.Length; ++i)
		{
			if (ArmorZones[i].AffectedHitZones.Find(HitZones[HitZoneIdx].ZoneName) != INDEX_NONE)
			{
				if ((ArmorZones[i].bAffectedByFrontDamage && bFrontDamage) ||
					(ArmorZones[i].bAffectedByBackDamage && bBackDamage))
				{
					return i;
				}
			}
		}
	}

	return INDEX_NONE;
}

function TakeArmorZoneDamage(int ZoneIdx, int InDamage, out int OutDamage)
{
	InDamage = Min(ArmorZones[ZoneIdx].ArmorHealth, InDamage);
	ArmorZones[ZoneIdx].ArmorHealth -= InDamage;
	OutDamage = Max(0, OutDamage - InDamage);
	RepArmorPct[ZoneIdx] = GetArmorZonePctByte(ZoneIdx);

	if (ArmorZones[ZoneIdx].ArmorHealth <= 0)
	{
		ZedExplodeArmor(ZoneIdx, ArmorZones[ZoneIdx].ArmorZoneName);
	}

	UpdateArmorUI();

	LastTakeDamageTime = WorldInfo.TimeSeconds;
}

function AdjustBoneDamage(out int InDamage, name BoneName, Vector DamagerSource, class<DamageType> DamageType)
{
	local int ArmorZoneIdx, ModDmgMax, ModDmgRem, ObliterateDamage;
	local float Modifier;

	// modify damage done and apply to armor
	Modifier = GetArmorDamageTypeModifier(DamageType);
	ModDmgMax = InDamage * Modifier;
	ModDmgRem = ModDmgMax;

	ArmorZoneIdx = GetArmorZoneIndex(BoneName, DamagerSource);
	if (ArmorZoneIdx != INDEX_NONE && ArmorZones[ArmorZoneIdx].ArmorHealth > 0)
	{
		if (ModDmgMax >= ArmorZones[ArmorZoneIdx].ObliterateDmgThreshold)
		{
			// obliterate armor and leave InDamage unmodified
			ObliterateDamage = ArmorZones[ArmorZoneIdx].ArmorHealth;
			TakeArmorZoneDamage(ArmorZoneIdx, ObliterateDamage, ObliterateDamage);
		}
		else
		{
			TakeArmorZoneDamage(ArmorZoneIdx, ModDmgRem, ModDmgRem);
		}
	}

	// unmodify any damage remaining and return it (apply it to zed)
	InDamage = float(ModDmgRem) / Modifier;
}

function AdjustNonBoneDamage(out int InDamage, class<DamageType> DamageType)
{
	local int i, NumValidZones, ModDmgMax, ModDmgRem, PrevModDmgRem, ModDmgToDo;
	local float Modifier;

	// modify damage done and apply to armor
	Modifier = GetArmorDamageTypeModifier(DamageType);
	ModDmgMax = InDamage * Modifier;
	ModDmgRem = ModDmgMax;

	do
	{
		PrevModDmgRem = ModDmgRem;
		NumValidZones = 0;
		for (i = 0; i < ArmorZones.Length; ++i)
		{
			if (ArmorZones[i].ArmorHealth > 0)
			{
				NumValidZones++;
			}
		}

		if (NumValidZones > 0)
		{
			ModDmgToDo = Max(1, ModDmgRem / NumValidZones);
			for (i = 0; i < ArmorZones.Length && ModDmgRem > 0; ++i)
			{
				if (ArmorZones[i].ArmorHealth > 0)
				{
					TakeArmorZoneDamage(i, ModDmgToDo, ModDmgRem);
				}
			}
		}
	} until (ModDmgRem == 0 || PrevModDmgRem == ModDmgRem);

	// unmodify any damage remaining and return it (apply it to zed)
	InDamage = float(ModDmgRem) / Modifier;
}

/** Returns damage multiplier for an incoming damage type @todo: c++?*/
function float GetArmorDamageTypeModifier(class<DamageType> DT)
{
	local int i;
	local int DifficultyIdx;
	local float DamageModifier;

	// reverse iteration so that most specific damage type can be last on the array
	for (i = ArmorDamageTypeModifiers.Length - 1; i >= 0; --i)
	{
		if ( ClassIsChildOf(DT, ArmorDamageTypeModifiers[i].DamageType) )
		{
			if (WorldInfo.Game != None && ArmorDamageTypeModifiers[i].DamageScale.Length > 1)
			{
				DifficultyIdx = Min(WorldInfo.Game.GetModifiedGameDifficulty(), ArmorDamageTypeModifiers[i].DamageScale.Length);
				DamageModifier = ArmorDamageTypeModifiers[i].DamageScale[DifficultyIdx];
			}
			else
			{
				DamageModifier = ArmorDamageTypeModifiers[i].DamageScale[0];
			}

			if (DamageModifier < 1.f)
			{
				DamageModifier = FMax(Lerp(1.f, DamageModifier, GameResistancePct),  0.f);
			}
			
			if(DT.default.ArmorDamageModifier != 1)
			{
				DamageModifier *= DT.default.ArmorDamageModifier;
			}
			
			return DamageModifier;
		}
	}
	
	if(DT.default.ArmorDamageModifier != 1)
	{
		return DT.default.ArmorDamageModifier;
	}
	return 1.f;
}

function ExplodeAllArmor()
{
	local int i, outDamage;

	for (i = 0; i < ArmorZones.Length; ++i)
	{
		TakeArmorZoneDamage(i, ArmorZones[i].ArmorHealth, outDamage);
	}
}
