//=============================================================================
// KFWeapon
//=============================================================================
// The base KF 2 weapon class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - John "Ramm-Jaeger" Gibson 9/27/2012
//=============================================================================
class KFWeapon extends Weapon
	abstract
	native
	nativereplication
	hidecategories(Advanced,Collision,Mobile,Movement,Object,Physics,Attachment,Debug)
	dependson(KFPlayerReplicationInfo, KFMeleeHelperWeapon);

`include(KFGame\KFGameAnalytics.uci);

// variables used to rotate cylinder
struct native CylinderRotationInfo
{
	// how many degrees to rotate the cylinder by each shot
	var float Inc;
	// rotation starting point
	var transient float PrevDegrees;
	// rotation goal
	var transient float NextDegrees;
	// how quickly to rotate
	var float Time;
	// timer to keep track of rotation time
	var transient float Timer;
	// the skelcontrol that controls the cylinder (cached)
	var transient SkelControlSingleBone Control;

	// tracks cylinder state (before fire, after fire but before rotating, rotating)
	var transient int State;
};

/** mesh for overlay - Each weapon will need to add its own overlay mesh in its default props */
var protected MeshComponent OverlayMesh;

/** Cached reference to KFSkeletalMeshComponent(Mesh) */
var KFSkeletalMeshComponent MySkelMesh;

/************************************************************************************
* @name	Content
***********************************************************************************/
var const string PackageKey;
var const string FirstPersonMeshName;
var const array<string> FirstPersonAnimSetNames;
var const string FirstPersonAnimTree;
var const string PickupMeshName;
var const string AttachmentArchetypeName;
var const string MuzzleFlashTemplateName;

var bool AttachOnContentLoad;
var bool SetOnContentLoad;
var transient bool WeaponContentLoaded;
var int WeaponPackagesPendingLoad;

/************************************************************************************
 * @name	Firing / Timing / States
 ***********************************************************************************/
/** Fire mode 0 is the default weapon firing. */
const DEFAULT_FIREMODE			= 0;
/** Fire mode 1 is the alternate weapon firing. */
const ALTFIRE_FIREMODE			= 1;
/** arbitrary firemode for reloading */
const RELOAD_FIREMODE			= 2;
/** Firing mode used when doing a melee attack */
const BASH_FIREMODE				= 3;
/** Firing mode used when doing a melee attack */
const GRENADE_FIREMODE			= 4;
/** A firemode that is manually set (>= PendingFire.Length) for weapons with special firing states */
const CUSTOM_FIREMODE			= 6;

/** Invalid firemode */
const FIREMODE_NONE				= 255;

var array<Texture2D>		FireModeIconPaths;

/** For weapons that have an automatic or burst fire mode, this stores the
  * single fire mode for use by the sound system when in zed time. If set
  * to 255 then the standard looping fire sound will still be played in
  * zed time */
var byte SingleFireSoundIndex;

/** Alt-fire mode is selected, all default fires will be converted */
var bool bUseAltFireMode;
/** Flag to make sure we stop the correct FireMode when using alt-fire toggle */
var transient bool bStopAltFireOnNextRelease;

/** Holds the min. amount of refire time that has to pass before you can switch */
var float MinFiringPutDownPct;

/** How much penetration power does this fire mode have */
var(Weapon) Array<float>		PenetrationPower;
/** How scale the penetration power this fire mode loses based on the percentage of penetration power left*/
var(Weapon) Array<InterpCurveFloat>	PenetrationDamageReductionCurve;
/** How much penetration power is remaining for this shot */
var transient float			PenetrationPowerRemaining;

/** If > 0, reduce the effect of zed time dilation on this weapon */
var const transient float ZedTimeResistance;

/** How long after we toss a grenade before a zed can grab us.
  * Prevents us from blowing ourselves up on grenades that we
  * were in the middle of tossing when we got grabbed */
var(Weapon) float   GrenadeTossWeakZedGrabCooldown;

/** Time after we are grabbed by a zed to prevent nade throwing so we don't blow ourselvs up */
var(Weapon) float   ZedGrabGrenadeTossCooldown;

/** Set when calling StartFire(DEFAULT_FIREMODE) from a gamepad press */
var bool bGamepadFireEntry;

/** Number of shots to fire per burst. */
var(Weapon)	byte BurstAmount;

/************************************************************************************
 * @name	Aim Assist
 ***********************************************************************************/

/** Target friction enabled? */
var() bool bTargetFrictionEnabled;

/** Max distance allow for friction */
var() float TargetFrictionDistanceMax;

/** Target adhesion enabled? */
var() bool bTargetAdhesionEnabled;

/** Max distance to allow adhesion to still kick in */
var() float TargetAdhesionDistanceMax;

/** Adhesion scalar curve based on distance */
var() InterpCurveFloat TargetAdhesionOffsetScaleCurve;
/** Adhesion scalar curve based on angle offset to center of zed cylinder */
var() InterpCurveFloat TargetAdhesionDistanceScaleCurve;

/** Friction scalar curve based on distance */
var() InterpCurveFloat TargetFrictionOffsetScaleCurve;
/** Friction scalar curve based on angle offset to center of zed cylinder */
var() InterpCurveFloat TargetFrictionDistanceScaleCurve;

/** Aim correction - headshot offset */
var() const float AimCorrectionSize;

/************************************************************************************
 * @name	Player controller vars
 ***********************************************************************************/

/** Current KFPlayerController controlling this weapon */
var KFPlayerController KFPlayer;

/** Adjusts the equipping player's movement speeds*/
/** Modifying existing speed */
var float MovementSpeedMod;
/** Overrides other speed modifiers, hard set at that value*/
var float OverrideGroundSpeed;
var float OverrideSprintSpeed;

/************************************************************************************
 * @name	Weapon positioning: Iron sights, hipped, etc
 ***********************************************************************************/

/** The weapon is using the sights to aim*/
var				bool	bUsingSights;
/** This weapon has sights to aim*/
var(IronSight)	bool	bHasIronSights;
/** This weapon maintain iron sights on jump*/
var             bool    bKeepIronSightsOnJump;

/** The weapon wants to go to ironsights when the bring up happens (because someone was already in ironsights when they switched)*/
var         	bool	bIronSightOnBringUp;

/** Hide the weapon for screenshots, etc */
var bool bForceHidden;

/** special offset when using hidden weapons, as we need to still place the weapon for e.g. attached beams */
var vector HiddenWeaponsOffset;

/** The default FOV to use for this weapon when not in ironsights */
var(Camera)	float		MeshFOV;
/** The fov to use for this weapon when in ironsights */
var(Camera)	float		MeshIronSightFOV;
/** The fov to use for the player when in ironsights */
var(Camera)	float		PlayerIronSightFOV;
/** The fov to use while in the weapon sprinting state */
var(Camera)	float		PlayerSprintFOV;

/** The position of the weapon when in standard ironsights position */
var(Positioning)	vector		IronSightPosition;
/** We are transitioning to zoomed in. When set to true native code will attempt to interpolate to the zoomed in ironsight position */
var				bool		bZoomingIn;
/** We are transitioning to zoomed out. When set to true native code will attempt to interpolate to the zoomed out ironsight position */
var				bool		bZoomingOut;
/** Time remaining on the active transition to/from iron sights */
var				float		ZoomTime;
/** How long the transition to iron sights should take */
var(IronSight)	float		ZoomInTime;
/** How long the transition from iron sights should take */
var(IronSight)	float		ZoomOutTime;
/** Amount to rotate to when zooming in to give the feeling of an animation playing */
var(IronSight)	rotator		ZoomInRotation;
/** Doing a "quick down" zoom */
var(IronSight)	bool        bDoingQuickDownZoom;
/** Amount to rotate to when doing a quick weapon put down */
var(IronSight)	rotator		QuickWeaponDownRotation;
/** How long the transition to quick weapon down should take */
var(IronSight)	float		QuickWeaponDownTime;
/** How long the transition from quick weapon down should take */
var(IronSight)	float		QuickWeaponDownFinishTime;
/** Don't use the ZoomInRotation for this zoom */
var(IronSight)	bool		bSkipZoomInRotation;
/** Set by the native code when zooming in/out. This is the interpolated rotation over time of the value set in ZoomInRotation */
var				rotator		ZoomRotInterp;
/** When we start zooming what player view location is the first person weapon in. Used by the native code to calculate where to start zooming from */
var				vector		ZoomStartOffset;
/** We were zooming in and it was interrupted. Used by the native code to handle smooth interpolations between zoomed positions */
var				bool		bZoomInInterrupted;
/** We were zooming out and it was interrupted. Used by the native code to handle smooth interpolations between zoomed positions */
var				bool		bZoomOutInterrupted;
/** How much time we have to finish a partial zoom out. Used by the native code to handle smooth interpolations between zoomed positions */
var				float		ZoomPartialTime;
/** When we start zooming what rotation offset is the weapon. Used by the native code to handle smooth interpolations between zoomed positions */
var				rotator		ZoomRotStartOffset;
/** When we start zooming what WeaponFOV did we start with */
var             float       ZoomWeaponFOVStart;
/** The last time we zoomed out. */
var				float		LastZoomOutTime;
/** How long to take to zoom out when we're doing a fast zoom out (i.e. when an action like reloading interupts ironsights) */
var(IronSight)	float		FastZoomOutTime;
/** The weapon is doing a fast zoom out without animating, and won't get ZoomStart/End Notifies */
var             bool        bFastZoomOut;
/** The Target player view location for the first person weapon for this zoom */
var				vector		ZoomTargetOffset;
/** The weapon has a scope and should use the scope offset for zoomed in mode */
var 			bool		bHasScopePosition;
/** The position of the weapon when looking through the scope */
var(Positioning)	vector		ScopePosition;
/** Currently zoomed into the scope position */
var             bool        bUsingScopePosition;

var(DepthOfField) bool DOF_bOverrideEnvironmentDOF;
var(DepthOfField) float DOF_SharpRadius;
var(DepthOfField) float DOF_FocalRadius;
var(DepthOfField) float DOF_MinBlurSize;
var(DepthOfField) float DOF_MaxNearBlurSize;
var(DepthOfField) float DOF_MaxFarBlurSize;
var(DepthOfField) float DOF_ExpFalloff;
var(DepthOfField) float DOF_MaxFocalDistance;

var(DepthOfField) float DOF_BlendInSpeed;
var(DepthOfField) float DOF_BlendOutSpeed;

var(DepthOfField) float DOF_FG_SharpRadius;
var(DepthOfField) float DOF_FG_FocalRadius;
var(DepthOfField) float DOF_FG_MinBlurSize;
var(DepthOfField) float DOF_FG_MaxNearBlurSize;
var(DepthOfField) float DOF_FG_ExpFalloff;

/** Holds an offest for spawning grenades. */
var(Positioning)			vector	GrenadeFireOffset;

/** The weapon is using the sights to aim*/
var(Positioning)    bool	bWeaponNeedsServerPosition;

/** If true, weapon position should follow camera anims played on the weapon AnimSeq */
var(Positioning)	bool	bFollowAnimSeqCamera;

/** If TRUE, will use system to warn AI when a player has been aiming at them for too long */
var(IronSight) protected const bool bWarnAIWhenAiming;

/** The maximum distance at which to warn AI, squared */
var(IronSight) protected const float MaxAIWarningDistSQ;

/** The maximum distance from the danger point that AI should be warned */
var(IronSight) protected const float MaxAIWarningDistFromPointSQ;

/** How long the weapon needs to be relatively settled before warning AI. X=MinDuration, Y=MaxDuration */
var(IronSight) protected const vector2d AimWarningDelay;

/** How long to wait after a warning before checking if AI should be warned again */
var(IronSight) protected const float AimWarningCooldown;

/** Last aim rotation between settled checks */
var transient private rotator LastAimRotation;

/** Last time we warned AI */
var transient private float LastAimWarningTime;

/** How much accumulated time the weapon has been settled for */
var transient private float CurrentAimSettledTime;

/*********************************************************************************************
 * @name	Inventory Grouping/etc.
********************************************************************************************* */

enum EInventoryGroup
{
	IG_Primary,
	IG_Secondary,
	IG_Melee,
	IG_Equipment,
	IG_None
};

/** Determines which group a weapon falls into in weapon select */
var(Inventory) EInventoryGroup	InventoryGroup;

/** Inventory (In blocks) cost */
var(Inventory) byte	InventorySize;

/** Used to place this weapon in the inventory */
var(Inventory) float GroupPriority;
///** The UI image for this weapon */
var(Inventory) Texture2D WeaponSelectTexture;
/** The path that locates the image for this weapon */
var(Inventory) Texture2D SecondaryAmmoTexture;
/** The path that locates the image for this weapon */
var(Inventory) bool bCanRefillSecondaryAmmo;
/** Flag to know if the weapon uses grenades as secondary ammo to change the HUD display when not loaded or empty */
var(Inventory) bool bUseGrenadeAsSecondaryAmmo;

/** used when aborting a weapon switch (state WeaponAbortEquip) */
var float EquipAbortTime;

/** True if we were given this weapon at spawn */
var bool bGivenAtStart;

/** class of the dual variant of this weapon, if applicable */
var class<KFWeap_DualBase> DualClass;

/*********************************************************************************************
 * @name	Ammo / Reload
********************************************************************************************* */

/** If set execute PerformReload on client only and synchronize at end of state */
`define USE_RELOAD_SYNC		1

const PRIMARY_AMMO		= 0;
const SECONDARY_AMMO	= 1;

// ---------------------------------------------
// Magazine - Primary and Secondary/alt

/** Ammo from current magazine */
var				int	AmmoCount[2];
/** Size of the weapon magazine, i.e. how many rounds it can hold */
var(Inventory)	int	MagazineCapacity[2];
/** How much ammo does it take to fire this firemode? */
var(Inventory) protected Array<byte> AmmoCost;
/** Is this a no magazine/clip weapon e.g. the hunting shotgun? */
var(Inventory)	bool 	bNoMagazine;

// ---------------------------------------------
/// Spare ammo - Primary Only... for now

/** Spare ammo, contained in extra magazines (outside of what's currently in the weapon) */
var repnotify	int		SpareAmmoCount[2];
/** Maximum amount of amount that can be carried for this gun, not counting what is in the magazine. Total amount this weapon can carry is SpareAmmoCapacity + MagazineCapacity */
var(Inventory)	int		SpareAmmoCapacity[2];
/** Number of additional magazines to start with. Starting ammo total is (InitialSpareMags * MagazineCapacity) + MagazineCapacity */
var	int		InitialSpareMags[2];

/** What percentage of a full single magazine capacity to give when resupplying this weapon from an ammo pickup */
var(Inventory)	float   AmmoPickupScale[2];

/** */
var(Inventory) bool bUsesSecondaryAmmoAltHUD;

enum EReloadStatus
{
	RS_None,
	RS_OpeningBolt,
	RS_Reloading,
	RS_ClosingBolt,
	RS_Complete
};

var EReloadStatus		ReloadStatus;
var(Inventory) bool		bCanBeReloaded;
var(Inventory) bool		bReloadFromMagazine;

/** Number of rounds left to reload during the reload state */
var int ReloadAmountLeft;
/** Number of rounds to reload during the reload state */
var int InitialReloadAmount;

/**
*	Initial Spare ammo when starting a reload. Used to keep track of how much ammo should be loaded into the gun
*	This is so, in case ammo changes when reloading, there are not desync problems.
*/
var int InitialReloadSpareAmmo;

/** If set, this weapon can always reload */
var const bool bInfiniteSpareAmmo;

/** If set, this weapon won't consume any ammo */
var bool bInfiniteAmmo;

/** If FALSE, AmmoCount is server authoritative and should not be modified on the client */
var const bool bAllowClientAmmoTracking;

/** Last time 'AbortReload' was called */
var transient float LastReloadAbortTime;

/** How long to wait after firing to force reload */
var() float	ForceReloadTimeOnEmpty;

// In support of dynamic weapon skins
var transient int ShotsHit;

/*********************************************************************************************
 * @name  Fire Effects
 ******************************************************************************************* */

/** Camera anim to play when firing (for camera shakes) */
var array<CameraAnim> FireCameraAnim;

var(Camera) float   ShakeScaleSighted;      // How much to scale the FireCameraAnim when in ironsights
var(Camera) float   ShakeScaleStandard;     // How much to scale the FireCameraAnim by default (Hipped/Shouldered)

/** Controller rumble to play when firing. */
var ForceFeedbackWaveform WeaponFireWaveForm;

var	bool	bPlayingLoopingFireSnd;
var bool	bPlayingLoopingFireAnim;

/*********************************************************************************************
 * @name	Animations (const names reduce instanced data)
********************************************************************************************* */

/** Cached anim nodes */
var KFAnimSeq_Tween				WeaponAnimSeqNode;
var AnimNodeAdditiveBlending	IdleBobBlendNode;
var AnimNodeBlendPerBone		EmptyMagBlendNode;

// Loop settings per firemode
var(Animations)	array<bool>	bLoopingFireAnim;
var(Sounds)	array<bool>	bLoopingFireSnd;

/** How much tweening to use on fire animations */
var(Animations) float   FireTweenTime;
/** Use the animation sequence length to get equip times */
var(Animations) bool	bUseAnimLenEquipTime;

/** If set, this weapon has unique shoot anims for the last round */
var(Animations) bool	bHasFireLastAnims;

// Standard
/** Animations to play when the weapon is fired */
var(Animations) const editconst name    	FireAnim;
/** Animation to play when the weapon is fired and bLoopingFireAnim is true */
var(Animations) const editconst	name		FireLoopAnim;
/** Animation to play when the last shot if fired */
var(Animations) const editconst	name		FireLastAnim;
/** Animation to play when the weapon is Put Down */
var(Animations) const editconst name		PutDownAnim;
/** Animation to play when the weapon is Equipped */
var(Animations) const editconst name		EquipAnim;
/** Animation to play when the weapon is idle */
var(Animations) const editconst array<name> IdleAnims;

// Special idle anims
var(Animations)					bool		bUseAdditiveMoveAnim;
var(Animations) const editconst array<name>	IdleFidgetAnims;
var transient					float	 	LastIdleFidgetAnimTime;

// Iron Sights
/** Animation to play when the weapon is fired */
var(Animations) const editconst	array<name>	FireSightedAnims;
/** Animation to play when the weapon is fired and bLoopingFireAnim is true */
var(Animations) const editconst	name		FireLoopSightedAnim;
/** Animation to play when the last shot if fired */
var(Animations) const editconst	name		FireLastSightedAnim;
/** Animation to play when idling */
var(Animations) editconst	  array<name>	IdleSightedAnims;

// High RPM Firing
/** Animation to play at the end of a looping fire anim */
var(Animations) const editconst	name		FireLoopStartAnim;
/** Animation to play at the end of a looping fire anim */
var(Animations) const editconst	name		FireLoopStartSightedAnim;
/** Animation to play at the end of a looping fire anim */
var(Animations) const editconst	name		FireLoopEndAnim;
/** Animation to play at the end of a looping fire anim */
var(Animations) const editconst	name		FireLoopEndSightedAnim;
/** Shoot animation to play when ending looping fire on last shot */
var(Animations) const editconst	name		FireLoopEndLastAnim;
/** Shoot animation to play when ending looping fire on last shot  when aiming*/
var(Animations) const editconst	name		FireLoopEndLastSightedAnim;

// Scoped Firing
/** Animation to play when the weapon is fired */
var(Animations) const editconst	name	FireScopedAnim;
/** Animation to play when the weapon is fired and bLoopingFireAnim is true */
var(Animations) const editconst	name	FireLoopScopedAnim;
/** Animation to play when the last shot if fired */
var(Animations) const editconst	name	FireLastScopedAnim;

/** Default melee attack animation names */
var array<name> MeleeAttackAnims;

// Reloading (const to reduce instanced data)
const ReloadEmptyMagAnim = 'Reload_Empty';
const ReloadNonEmptyMagAnim = 'Reload_Half';
const ReloadEmptyMagEliteAnim = 'Reload_Empty_Elite';
const ReloadNonEmptyMagEliteAnim = 'Reload_Half_Elite';

const ReloadOpenAnim = 'Reload_Open';
const ReloadSingleAnim = 'Reload_Insert';
const ReloadOpenInsertAnim = 'Reload_Open_Shell';
const ReloadCloseAnim = 'Reload_Close';
const ReloadOpenEliteAnim = 'Reload_Open_Elite';
const ReloadSingleEliteAnim = 'Reload_Insert_Elite';
const ReloadOpenInsertEliteAnim = 'Reload_Open_Shell_Elite';
const ReloadCloseEliteAnim = 'Reload_Close_Elite';

// Grenades
/** Animation to play when a grenade is thrown */
const GrenadeThrowAnim = 'Nade_Throw';

// Sprinting
const SprintStartAnim = 'Sprint_In';
const SprintLoopAnim = 'Sprint_Loop';
const SprintEndAnim = 'Sprint_Out';

// Shoot animation to play when reload is interrupted when bReloadFromMagazine = false
const FireOneHandAnim = 'Shoot_OneHand';
const FireOneHandLastAnim = 'Shoot_OneHand_Last';

/** Camera anim played when sprinting */
var(Camera)		CameraAnim		SprintCameraAnim;
var	transient	CameraAnimInst	SprintCameraAnimInst;
var transient   float			SprintAnimRate;

// SkelControls
var bool bEnableTiltSkelControl;

/** Set from unlock notify to enable test for an aborted reload */
var transient bool bCheckBoltLockPostReload;

/** array of bones to lock when out of ammo */
var array<name> BonesToLockOnEmpty;

/** Handle impact effects on impact manager */
var bool bForceHandleImpacts;

/*********************************************************************************************
 * @name	Sounds
********************************************************************************************* */

var(Sounds) bool bSuppressSounds;

struct native WeaponFireSndInfo
{
	var() AkEvent		DefaultCue;
	var() AkEvent		FirstPersonCue;
};

/** Sound to play when the weapon is fired */
var(Sounds)	array<WeaponFireSndInfo>	WeaponFireSnd;
/** sound to play when the weapon stops fired. Used for high ROF weapons that have a looping fire sound */
var(Sounds)	array<WeaponFireSndInfo>	WeaponFireLoopEndSnd;

/** sound to play when the weapon is dry fired */
var(Sounds)	array<AkBaseSoundObject>  WeaponDryFireSnd;
/** If set to true, attempting to reload will switch to best available weapon */
var() bool  bPendingAutoSwitchOnDryFire;

/*********************************************************************************************
 * @name	First person weapon view positioning and rendering
********************************************************************************************* */

const BloodParamName			= 'Scalar_Blood_Contrast';
const MinBloodParamValue		= 0.20f;

/** How much to damp view bob */
var(Motion) float	BobDamping;

/** How much to damp jump and land bob */
var(Motion) float	JumpDamping;

/** Offset from view center */
var(Positioning) vector	PlayerViewOffset;

/** If true, will be un-hidden on the next setPosition call. */
var bool bPendingShow;

/** Used to display effects such as blood splatter and muzzle glow */
var array<MaterialInstanceConstant>	WeaponMICs;

/** Number of materials in mesh used for blood maps */
var int NumBloodMapMaterials;

/** Defines how bloody the weapon looks */
var float							BloodParamValue;

/** ItemID for currently/last equipped weapon skin. TODO: Cloud save */
var const config int SkinItemId;

/*********************************************************************************************
 * @name	Weapon Lag System
********************************************************************************************* */

/** The weapon lag value to use to offset the weapon in first person. Calculated by ProcessWeaponLag in the native code*/
var             vector  WeaponLag;

// Basic Weapon Lag Variables
/** Horizontal Offset, in units from the weapon's resting position */
var				float	LagHorizontal;
/** Vertical Offset, in units from the weapon's resting position */
var				float	LagVertical;
var				float	LagVelocityHorizontal;
var				float	LagVelocityVertical;

// Weapon Lag calculations for when the pawn's accelleration changes, or the pawn turns. Affects spring LagTensionHorizontal and dampening.
var(Motion)		float	LagTensionHorizontal;
var(Motion)		float	LagVerticalTension;

// Weapon LagResistanceHorizontal/Vertical represents how much the gun does not want to move at all, affects dampening.
var(Motion)		float	LagResistanceHorizontal;
var(Motion)		float	LagResistanceVertical;

// Limitations and Conversions
/** the maximum offset/lag that the weapon should lag when moving around */
var(Motion)		float	LagLimit;
/** A constant that converts yaw velocity to linear velocity to be used in calculating weapon-lag */
var(Motion)		float 	LagYawCoefficient;

// Weapon Lag State Properties
// Dynamic Lag tension modifiers. Effectively, these Strength values
// are multiplied into the tension based on the pawn's state.
var(Motion)		float	LagStrengthIronSights;
var(Motion)		float	LagStrengthCrouch;
var(Motion)		float	LagStrengthWalk;
var(Motion)		float	LagStrengthJog;
var(Motion)		float	LagStrengthSprint;

// Strafe Lag - special lag for moving left and right
/** The horizontal offset from center when the pawn Strafes left/right. */
var				float 	StrafeLag;
var				float 	StrafeLagVelocity;
/** The maximum horizontal offset from center */
var(Motion)		float 	StrafeLagLimit;
/** Rate at which momentum changes should affect Strafe lagging */
var(Motion)		float 	StrafeLagRate;
/** Rate at which weapon should return to normal after straffing.*/
var(Motion)		float 	StrafeLagReturnRate;

/** How quickly the weapon is Yawing */
var int AimYawSpeed;
/** How quickly the weapon is Pitching */
var int AimPitchSpeed;

/*********************************************************************************************
 * @name	Attachments
********************************************************************************************* */

/** The class of the third person attachment to spawn */
var(Attachments) KFWeaponAttachment 	AttachmentArchetype;

/** Object within weapon that manages melee attacks */
var(Weapon) instanced KFMeleeHelperWeapon MeleeAttackHelper;

/** A muzzle flash instance */
var					   KFMuzzleFlash MuzzleFlash;
/** A reference to the muzzle flash template */
var(Attachments) const KFMuzzleFlash MuzzleFlashTemplate;

/** How long ejected shells should stay in the foreground until changing to world depth */
var(Attachments) const float EjectedShellForegroundDuration;

/** DEPRECATED */
var deprecated bool bHasFlashlight;

/** A laser sight instance */
var	transient		   KFLaserSightAttachment LaserSight;
/** A reference to the laser sight template */
var(Attachments) const KFLaserSightAttachment LaserSightTemplate;
/** Whether the weapon supports laser sights or not */
var(Attachments)		bool			   bHasLaserSight;

/*********************************************************************************************
 * @name	Projectiles
********************************************************************************************* */

/** The max Dot Angle to allow for adjusting projectiles so they hit where the crosshair is aiming. This prevent wierd issues where you are firing on something really close, and the projectile spawning code makes the projectile's velocity (AimDir) go off in some really odd direction */
const MaxAimAdjust_Angle = 0.1f;	// Radians
const MaxAimAdjust_Cos = 0.995f;	// Cos(MaxAimAdjust)

/** Used only by shotgun classes. Needed here to function with both the Medic shotgun and regular shotguns, since they extend different base classes */
var float LastPelletFireTime;

/** Number of pellets to fire, if greater than 1 then it uses shotgun-like functionality */
var(Weapon) array<byte>	NumPellets;

/*********************************************************************************************
 * @name	Firing
********************************************************************************************* */

/** Amount to scale spread when moving and shooting. Set this to something greater than 1.0 if you want to have added spread while moving. KF1 did not have this */
var(Weapon)	float	MovingSpreadMod;
/** Amount to scale spread when using ironsights */
var(Weapon)	float	IronSightsSpreadMod;
/** Amount to scale spread when Crouched */
var(Weapon)	float	CrouchSpreadMod;

/*********************************************************************************************
 * @name	Recoil
 *
 * @note - recoil rotation is calculated randomly using the below values. The recoil pitch will be a random
 * amount between min and max Recoil Pitch. The recoil yaw will be a min and max value between min and max Recoil Yaw.
 * The weapon will recoil at for RecoilRate amount of seconds, and then when firing has ceased will blend back to zero at
 * the recoil rate multiplied by the RecoilBlendOutRatio. The weapon itself will move around independent of the camera
 * movement withing the RecoilMax limits. Suppression recoil is on top of standard recoil. It moves the player's
 * view around when bullets are whizzing by for example.
********************************************************************************************* */

/** max vertical units a weapon muzzle will climb from recoil */
var(Recoil)	int		maxRecoilPitch;
/** min vertical units a weapon muzzle will climb from recoil */
var(Recoil)	int 	minRecoilPitch;
/** max horizontal units a weapon muzzle will move from recoil */
var(Recoil)	int		maxRecoilYaw;
/** min horizontal units a weapon muzzle will move from recoil */
var(Recoil)	int		minRecoilYaw;
/** Time in seconds each recoil should take to be applied. Must be less than the fire rate or the full recoil wont be applied */
var(Recoil)	float	RecoilRate;
/** What percentage of the RecoilSpeed it will take to blend recoil out */
var(Recoil)	float	RecoilBlendOutRatio;
/** What percentage of recoil to apply to the view rotation when firing */
var(Recoil)	float	RecoilViewRotationScale;
/** Scales how much effect the players rotation input (from mouse/gamepad) has on reducing the total recoil (the first person weapon model's recoil) */
var(Recoil) float   RecoilCompensationScale;
/** At what percentage the weapon is recoiled torwards the Max or Min Pitch limit to start blending to full view rotation recoil */
var(Recoil)	float	FullRecoilPitchPct;
/** At what percentage the weapon is recoiled torwards the Max or Min Yaw limit to start blending to full view rotation recoil */
var(Recoil) float   FullRecoilYawPct;

// Normal Hipped Recoil
/** Maximum yaw rotation of the weapon from recoil before the player's view moves */
var(Recoil)	int		RecoilMaxYawLimit;
/** Minimum yaw rotation of the weapon from recoil before the player's view moves */
var(Recoil)	int		RecoilMinYawLimit;
/** Maximum pitch rotation of the weapon from recoil before the player's view moves */
var(Recoil)	int		RecoilMaxPitchLimit;
/** Minimum pitch rotation of the weapon from recoil before the player's view moves */
var(Recoil)	int		RecoilMinPitchLimit;

// Iron Sight Recoil
/** Maximum yaw rotation of the weapon from recoil before the player's view moves when using Iron sights */
var(Recoil)	int		RecoilISMaxYawLimit;
/** Minimum yaw rotation of the weapon from recoil before the player's view moves when using Iron sights */
var(Recoil)	int		RecoilISMinYawLimit;
/** Maximum pitch rotation of the weapon from recoil before the player's view moves when using Iron sights */
var(Recoil)	int		RecoilISMaxPitchLimit;
/** Minimum pitch rotation of the weapon from recoil before the player's view moves when using Iron sights */
var(Recoil)	int		RecoilISMinPitchLimit;

// Internal recoil vars used by the native code
/** Stores recoil when a weapon is fired */
var			rotator	RecoilRotator;
/** Stores the total recoil for this group of weapon firing */
var			rotator	TotalRecoilRotator;
/** How much time left to process this recoil */
var			float	RecoilTimeLeft;
/** The amount of time it will take to process this recoil */
var			float	RecoilSpeed;
/** Stores the calculated yaw blend out rate */
var			int		RecoilYawBlendOutRate;
/** Stores the calculated pitch blend out rate */
var			int		RecoilPitchBlendOutRate;

/** Used to track how close the recoil is to the edge of the buffer */
var float RecoilPitchPercentage;
/** Used to track how close the recoil is to the edge of the buffer */
var float RecoilYawPercentage;

// Internal recoil vars used by the native code
/** Stores recoil when suppression is recieved */
var			rotator	SuppressRecoilRotator;
/** Remaining time to process suppression recoil */
var			float	SuppressRecoilTimeLeft;

/** The amount of time it will take to process this suppression recoil */
var(Recoil)	float	SuppressRecoilSpeed;
/** The percentage of the suppression recoil to apply to the player's view */
var(Recoil)	float	SuppressRecoilViewRotationScale;

// Note on Recoil modifiers: Total recoil modifier will be the weapon posture modifier multiplied by the player stance modifier.
// Default recoil is based on a standing player in ironsights position (not moving), or bipod deployed position for weapons
// with bipods

/** Recoil modifier for when the player is holding the weapon in the hipped position */
var(Recoil)       float           HippedRecoilModifier;
/** Recoil modifier for when the player is jogging and shooting */
var(Recoil)       float           JoggingRecoilModifier;
/** Recoil modifier for when the player is walking and shooting */
var(Recoil)       float           WalkingRecoilModifier;
/** Recoil modifier for falling player stance */
var(Recoil)       float           FallingRecoilModifier;
/** Recoil modifier for crouched */
var(Recoil)       float           StanceCrouchedRecoilModifier;
/** Stores the last calculated recoil modifier */
var               float           LastRecoilModifier;

/** Used to compensate for weapons that have an ironsight mesh FOV that is different
 * Than the player's world FOV. When these mismatch, it causes the recoil
 * rotation to mismatch as well. Use this value to get them back in sync.
 *
 */
var(Recoil) float IronSightMeshFOVCompensationScale;

/*********************************************************************************************
 * @name	Clientside hit detection
 ********************************************************************************************* */

/** Compressed ImpactInfo more suitable for server function replication */
struct native ImpactRepInfo
{
	var	Actor		HitActor;
	var	vector		HitLocation;
	var	vector		RayDir;

	// BoneName --- Used by KFPawns for hit zone detection.  Each zone name must be
	// added to MAX_NETWORKED_HARDCODED_NAME otherwise it will be replicated as a string.
	var	name		HitInfo_BoneName;

	// HitComp --- Used for KActorFromStatic, but since the engine does not
	// replicate we only lose remote KActors playing on the listen server.
};

/*********************************************************************************************
 * @name	Perks
 ********************************************************************************************* */
/** Is this perk backup weapon? */
var 				bool 						bIsBackupWeapon;
var(Weapon) protected array< Class<KFPerk> >	AssociatedPerkClasses;
/*********************************************************************************************
 * @name	Debug
 ********************************************************************************************* */

// `log conditions.  More efficient than using log tags, because the msg is not evaluated.
var config bool bLogAnimation;
var config bool	bLogStates;
/** If set, this weapon will pause with the PlayersOnly command */
var bool bPauseWithPlayersOnly;

/** If set, this weapon will pause with the PlayersOnly command */
var bool bDebugRecoilPosition;

/** temp ammo logging */
var config bool	bLogAmmo;

/** Log weapon upgrade system. */
var const bool bLogWeaponUpgrade;

/*********************************************************************************************
 * @name Weapon Upgrade System
 *********************************************************************************************/

enum EWeaponUpgradeStat
{
	// general stats
	EWUS_Weight,
	EWUS_Heal,
	EWUS_HealFullRecharge,
	EWUS_BlockDmgMitigation, // TODO
	EWUS_ParryDmgMitigation, // TODO

	// firemode stats (0 = default/primary, 1 = altfire/secondary, 2 = bash/tertiary)
	EWUS_Damage0,
	EWUS_Damage1,
	EWUS_Damage2,
	EWUS_MagCapacity0,
	EWUS_MagCapacity1,
	EWUS_MagCapacity2,
	EWUS_SpareCapacity0,
	EWUS_SpareCapacity1,
	EWUS_SpareCapacity2,
	EWUS_Spread0,
	EWUS_Spread1,
	EWUS_Spread2,
	EWUS_Penetration0,
	EWUS_Penetration1,
	EWUS_Penetration2,
	EWUS_ExploRadius0,
	EWUS_ExploRadius1,
	EWUS_ExploRadius2,
	EWUS_ReloadRate0,
	EWUS_ReloadRate1,
	EWUS_ReloadRate2,
	EWUS_Recoil0,
	EWUS_Recoil1,
	EWUS_Recoil2,
	EWUS_MeleeSpeed0,
	EWUS_MeleeSpeed1,
	EWUS_MeleeSpeed2,
	EWUS_AfflictEMP0,
	EWUS_AfflictEMP1,
	EWUS_AfflictEMP2,
	EWUS_AfflictFire0,
	EWUS_AfflictFire1,
	EWUS_AfflictFire2,
	EWUS_AfflictMelee0,
	EWUS_AfflictMelee1,
	EWUS_AfflictMelee2,
	EWUS_AfflictGun0,
	EWUS_AfflictGun1,
	EWUS_AfflictGun2,
	EWUS_AfflictStumble0,
	EWUS_AfflictStumble1,
	EWUS_AfflictStumble2,
	EWUS_AfflictStun0,
	EWUS_AfflictStun1,
	EWUS_AfflictStun2,
	EWUS_AfflictPoison0,
	EWUS_AfflictPoison1,
	EWUS_AfflictPoison2,
	EWUS_AfflictSnare0,
	EWUS_AfflictSnare1,
	EWUS_AfflictSnare2,
	EWUS_AfflictKnockdown0,
	EWUS_AfflictKnockdown1,
	EWUS_AfflictKnockdown2,
	EWUS_AfflictFreeze0,
	EWUS_AfflictFreeze1,
	EWUS_AfflictFreeze2,
	EWUS_AfflictMicrowave0,
	EWUS_AfflictMicrowave1,
	EWUS_AfflictMicrowave2,
	EWUS_AfflictBleed0,
	EWUS_AfflictBleed1,
	EWUS_AfflictBleed2,

	// custom (for modders)
	EWUS_Custom1,
	EWUS_Custom2,
	EWUS_Custom3,
	EWUS_Custom4,
	EWUS_Custom5,
};

struct native WeaponUpgradeStatInc
{
	var EWeaponUpgradeStat Stat;
	var float Scale;
	var int Add;

	structdefaultproperties
	{
		Scale=1.f
		Add=0
	}
};

struct native WeaponUpgradeInfo
{
	var array<WeaponUpgradeStatInc> Stats;
};

var array<WeaponUpgradeInfo> WeaponUpgrades;
var int CurrentWeaponUpgradeIndex;

// Actual firemodes (0-5) need to be mapped to upgrade firemodes (0, 1, and 2) since they don't line up
// and are different between guns and melee weapons
var int UpgradeFireModes[7];

var bool bStorePreviouslyEquipped;

/*********************************************************************************************
 * @name	Components
********************************************************************************************* */

var class<KFMedicWeaponComponent> MedicCompClass;
var KFMedicWeaponComponent MedicComp;
var repnotify Actor MedicCompRepActor;

var class<KFTargetingWeaponComponent> TargetingCompClass;
var KFTargetingWeaponComponent TargetingComp;
var repnotify Actor TargetingCompRepActor;

cpptext
{
	// Actor
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	virtual void TickSpecial(FLOAT DeltaSeconds);
	virtual UBOOL PlayerControlled();
	virtual void PreBeginPlay();

	// Called from TickSpecial
	void TickIronSightsZoom(FLOAT DeltaSeconds);
	void UpdateTimeDilation();

	// Called from PC.ProcessViewRotation
	void ProcessRecoil(class APlayerController* PC, FLOAT DeltaTime, FRotator& DeltaRot);
	void ProcessWeaponLag(class AKFPawn* KFP, FLOAT DeltaTime, FRotator& DeltaRot);
	void ProcessSway(class APlayerController* PC, float DeltaTime);

    /* Returns the size of the object/ resource for display to artists/ LDs in the Editor.*/
	int GetResourceSize();
    /* Manually grabs the important resources inside KFWeapon and returns their total size.*/
	int GetWeaponResourceSize( TArray<class UObject*>& InMemoryArray, UBOOL bUniqueItemsOnly );

	virtual void RefreshSkinItemId();
}

replication
{
	if (bNetDirty && (bNetInitial || !bAllowClientAmmoTracking) )
		AmmoCount;
	if (bNetDirty)
		SpareAmmoCount, MagazineCapacity, SpareAmmoCapacity, bGivenAtStart,CurrentWeaponUpgradeIndex;

	if (bNetDirty)
		MedicCompRepActor, TargetingCompRepActor;
}

/*********************************************************************************************
 * @name	Native helper functions
********************************************************************************************* */

/** Util that makes sure the overlay component is last in the AllComponents/Components array. */
native function EnsureWeaponOverlayComponentLast();
/** Wether the player can purchase ammo for the weapon. Will be true for most of the weapons */
native function bool CanBuyAmmo();

/**
 * Handles view rotation and weapon rotation changes for the weapon. Called in script by
 * the KFPlayerController holding this weapon. Currently handles free-aim and recoil.
 *
 * @param		PC				PlayerController whose pawn is holding this weapon
 * @param		DeltaTime		Amount of time that has passed since the last update
 * @param		DeltaRot		The view rotational delta the PC is attempting to perform
 */
native function WeaponProcessViewRotation(PlayerController PC, float DeltaTime, out Rotator DeltaRot);

/** Queries the pawn and returns our current Perk */
native function KFPerk GetPerk() const;

/** 0: Normal zed time, 1: Ignore zed time */
native function SetZedTimeResist(float ResistPct);
/** Zero out current zed time resitances */
native function ClearZedTimeResist();
/** Allow weapons with abnormal state transitions to always use zed time resist*/
simulated function bool HasAlwaysOnZedTimeResist(){return false;}
/** Get beam hit detection between points*/
native function array<Actor> BeamLineCheck(vector BeamEnd, vector BeamStart, vector BeamExtent, out array<vector> OutHitLocations);

/*********************************************************************************************
 * @name	Constructors, Destructors, and Loading
********************************************************************************************* */

simulated event ReplicatedEvent(name VarName)
{
	switch (VarName)
	{
	case nameof(MedicCompRepActor):
		MedicComp = KFMedicWeaponComponent(MedicCompRepActor);
		if (MedicComp != none)
		{
			MedicComp.Init(self, AmmoCost[ALTFIRE_FIREMODE]);
		}
		break;

	case nameof(TargetingCompRepActor):
		TargetingComp = KFTargetingWeaponComponent(TargetingCompRepActor);
		if (TargetingComp != none)
		{
			TargetingComp.Init(self);
		}
		break;

	default:
		super.ReplicatedEvent(VarName);
	};
}

/**
 * Called immediately before gameplay begins.
 */
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	MySkelMesh = KFSkeletalMeshComponent(Mesh);
	if ( MySkelMesh == None )
	{
		`warn("A Invalid KFSkeletalMeshComponent(Mesh) cast!!!");
	}

	// Cache AnimNodeSeq (no AnimTree version)
 	WeaponAnimSeqNode = KFAnimSeq_Tween( GetWeaponAnimNodeSeq() );

	InitializeAmmo();
	InitializeEquipTime();

	// Set up the recoil blend out parameters
	if( RecoilRate > 0 && RecoilBlendOutRatio > 0 )
	{
		RecoilYawBlendOutRate = maxRecoilYaw/RecoilRate * RecoilBlendOutRatio;
		RecoilPitchBlendOutRate = maxRecoilPitch/RecoilRate * RecoilBlendOutRatio;
	}

	if (Role == ROLE_Authority)
	{
		if (MedicCompClass != none)
		{
			MedicComp = Spawn(MedicCompClass, Owner);
			MedicComp.Init(self, AmmoCost[ALTFIRE_FIREMODE]);
			MedicCompRepActor = MedicComp;
		}

		if (TargetingCompClass != none)
		{
			TargetingComp = Spawn(TargetingCompClass, Owner);
			TargetingComp.Init(self);
			TargetingCompRepActor = TargetingComp;
		}
	}
}

function SetShownInInventory(bool bValue);

/** Cache Anim Nodes from the tree
* 	@note: skipped on server because AttachComponent/AttachWeaponTo is not called
*/
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	WeaponAnimSeqNode = KFAnimSeq_Tween(SkelComp.FindAnimNode('WeaponSeq'));
	// If we're not using a NodeName, try default anim node
	if ( WeaponAnimSeqNode == None )
	{
		WeaponAnimSeqNode = KFAnimSeq_Tween( GetWeaponAnimNodeSeq() );
	}

	IdleBobBlendNode = AnimNodeAdditiveBlending(SkelComp.FindAnimNode('IdleBobAdditiveBlend'));
	ToggleAdditiveBobAnim(false, 0.f);

	EmptyMagBlendNode = AnimNodeBlendPerBone(SkelComp.FindAnimNode('EmptyMagBlend'));
	if( EmptyMagBlendNode != none && BonesToLockOnEmpty.Length > 0 )
	{
		BuildEmptyMagNodeWeightList( EmptyMagBlendNode, BonesToLockOnEmpty );
	}

	if (bHasLaserSight)
	{
		AttachLaserSight();
	}
}

/** Rebuilds weight list for "empty mag" bolt lock node after updating its target bones */
native function BuildEmptyMagNodeWeightList( AnimNodeBlendPerBone EmptyNode, const out array<name> BonesToLock );

/** Setup the time it takes before the equip anim can be interrupted */
simulated event InitializeEquipTime()
{
	EquipTime = EquipTime>0 ? EquipTime : 0.01;
	PutDownTime = PutDownTime>0 ? PutDownTime : 0.01;

	if ( bUseAnimLenEquipTime && WeaponContentLoaded )
	{
		EquipTime = MySkelMesh.GetAnimInterruptTime(EquipAnim);
		PutDownTime = MySkelMesh.GetAnimLength(PutDownAnim);
	}
}

/**
 * Initialize the FOV settings for this weapon, adjusting for aspect ratio
 * @param SizeX the X resolution of the screen
 * @param SizeY the Y resolution of the screen
 * @param DefaultPlayerFOV the default player FOV of the player holding this weapon
 * @param DefaultPlayerFOV the PlayerController of the player holding this weapon
 */
simulated function InitFOV(float SizeX, float SizeY, float DefaultPlayerFOV)
{
	local float DummyParam;

	MeshFOV = class'KFPlayerController'.static.CalcFOVForAspectRatio(default.MeshFOV, SizeX, SizeY, DummyParam);
	MeshIronSightFOV = class'KFPlayerController'.static.CalcFOVForAspectRatio(default.MeshIronSightFOV, SizeX, SizeY, DummyParam);
	PlayerIronSightFOV = class'KFPlayerController'.static.CalcFOVForAspectRatio(default.PlayerIronSightFOV, SizeX, SizeY, DummyParam);
	PlayerSprintFOV = class'KFPlayerController'.static.CalcFOVForAspectRatio(default.PlayerSprintFOV, SizeX, SizeY, DummyParam);

	if( DefaultPlayerFOV > PlayerSprintFOV )
	{
		PlayerSprintFOV = DefaultPlayerFOV;
	}

	if( bUsingSights )
	{
		SetFOV(MeshIronSightFOV);
	}
	else
	{
		SetFOV(MeshFOV);
	}

    `log("PlayerIronSightFOV = "$PlayerIronSightFOV$" default POV = "$default.PlayerIronSightFOV, bLogAnimation);
    `log("SprintFOV = "$PlayerSprintFOV$" default POV = "$default.PlayerSprintFOV, bLogAnimation);
}

/*********************************************************************************************
 * @name	Inventory & Weapon Switching
 *********************************************************************************************/

/** Weapon skins */
native reliable client private function ClientSetFirstPersonSkin(int ItemId);
native function SetWeaponSkinPostLoad();
native reliable server private event ServerUpdateWeaponSkin(int ItemId);
native private function ClearSkinItemId();

simulated function Timer_UpdateWeaponSkin()
{
	local int i, AmmoType;
	local float MagazinePct, ShotsFiredPct, ShotsHitPct;

	if (WeaponMICs.Length > 0)
    {
		AmmoType = GetAmmoType(CurrentFireMode);
		if (AmmoType == 0)
		{
			MagazinePct = 1.f - (float(AmmoCount[AmmoType]) / float(MagazineCapacity[AmmoType]));
			ShotsFiredPct = float(MagazineCapacity[AmmoType] - AmmoCount[AmmoType]) / float(MagazineCapacity[AmmoType]);
			ShotsHitPct = float(ShotsHit) / float(MagazineCapacity[AmmoType]);

			for (i = 0; i < WeaponMICs.Length; ++i)
			{
				if (WeaponMICs[i] != none)
				{
					WeaponMICs[i].SetScalarParameterValue('AmmoCount', MagazinePct);
					WeaponMICs[i].SetScalarParameterValue('ShotsFired', ShotsFiredPct);
					WeaponMICs[i].SetScalarParameterValue('ShotsHit', ShotsHitPct);
				}
			}
		}
    }
}

//StartLoad will trigger an async package load.  The registered callback will then
//		call LoadWeaponContent on this weapon when the package is ready.
//
//TriggerAsync will be called statically and simply cache packages to root.  Useful
//		for remote clients to preload content when a user picks up a weapon without
//		having to do the full setting stack.
simulated native static function TriggerAsyncContentLoad(class<KFWeapon> WeaponClass);
native protected function StartLoadWeaponContent();
native private function LoadWeaponContent();
native private function CacheWeaponContent();
native private function UnloadWeaponContent();

/**
 * This Inventory Item has just been given to this Pawn
 * (server only)
 */
function GivenTo( Pawn thisPawn, optional bool bDoNotActivate )
{
	Super.GivenTo(thisPawn, bDoNotActivate);

	// need to reset skin and wait for ServerUpdateWeaponSkin
	if ( !Instigator.IsLocallyControlled() )
	{
		ClearSkinItemId();
	}

	if (Role == ROLE_Authority && !WeaponContentLoaded)
	{
		StartLoadWeaponContent();
	}

	KFInventoryManager(InvManager).AddCurrentCarryBlocks( GetModifiedWeightValue() );
	KFPawn(Instigator).NotifyInventoryWeightChanged();

	if (MedicComp != none)
	{
		MedicComp.OnWeaponGivenTo(thisPawn);
	}
}

reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
{
	if (Role != ROLE_Authority && !WeaponContentLoaded)
	{
		StartLoadWeaponContent();
	}
	super.ClientGivenTo(NewOwner, bDoNotActivate);
}

/**
 * A notification call when this weapon is removed from the Inventory of a pawn
 * @see Inventory::ItemRemovedFromInvManager
 */
function ItemRemovedFromInvManager()
{
	local KFInventoryManager KFIM;

	Super.ItemRemovedFromInvManager();

	KFIM = KFInventoryManager(InvManager);
	if (KFIM == none)
	{
		return;
	}

	`log(self @ "-" @ GetFuncName() @ "- CurrentCarryBlocks:" @ KFIM.CurrentCarryBlocks @ "ModifiedWeightValue:" @ GetModifiedWeightValue(), KFIM.bLogInventory);
	KFIM.AddCurrentCarryBlocks( -GetModifiedWeightValue());
	KFPawn(Instigator).NotifyInventoryWeightChanged();

	if (MedicComp != none)
	{
		MedicComp.OnWeaponRemovedFromInvManager();
		MedicComp.Destroy();
		MedicComp = none;
	}

	if (TargetingComp != none)
	{
		TargetingComp.Destroy();
		TargetingComp = none;
	}
}

reliable client function ClientWeaponSet(bool bOptionalSet, optional bool bDoNotActivate)
{
	if (WeaponContentLoaded)
	{
		SetWeapon();
	}
	SetOnContentLoad = true;

	Super.ClientWeaponSet(bOptionalSet, bDoNotActivate);

	if (MedicComp != none)
	{
		MedicComp.OnClientWeaponSet();
	}
}

simulated event SetWeapon()
{
	local PlayerController PC;
	local int i;

	// This is the first time we have a valid Instigator (see PendingClientWeaponSet)
	if (Instigator != None && InvManager != None
		&& WorldInfo.NetMode != NM_DedicatedServer)
	{
		PC = PlayerController(Instigator.Controller);
		if (PC != none && PC.myHUD != none)
		{
			InitFOV(PC.myHUD.SizeX, PC.myHUD.SizeY, PC.DefaultFOV);
		}

		// One-time skin initialization on local player
		if (SkinItemId > 0)
		{
			ClientSetFirstPersonSkin(SkinItemId);
		}

		// Weapon MICs for blood maps
		for (i = 0; i < NumBloodMapMaterials; ++i)
		{
			WeaponMICs.AddItem(Mesh.CreateAndSetMaterialInstanceConstant(i));
		}
	}
}

simulated event TriggerAttachment()
{
	Activate();
}

 /**
 * Attach Weapon Mesh, Weapon MuzzleFlash and Muzzle Flash Dynamic Light to a SkeletalMesh
 *
 * @param	who is the pawn to attach to
 */
simulated function AttachWeaponTo( SkeletalMeshComponent MeshCpnt, optional Name SocketName )
{
	local KFPawn KFP;
	local int i;

	//Weapon not ready for attach - delay until ready
	if (!WeaponContentLoaded)
	{
		return;
	}

	KFP = KFPawn(Instigator);
	if( KFP != none && KFP.ArmsMesh != none )
	{
		KFP.ArmsMesh.SetParentAnimComponent(MySkelMesh);
		KFP.ArmsMesh.SetFOV(MySkelMesh.FOV);
		for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
		{
			if (KFP.FirstPersonAttachments[i] != none)
			{
				if (SkeletalMeshComponent(KFP.FirstPersonAttachments[i]) != none)
				{
					SkeletalMeshComponent(KFP.FirstPersonAttachments[i]).SetParentAnimComponent(MySkelMesh);
					SkeletalMeshComponent(KFP.FirstPersonAttachments[i]).SetLODParent(MySkelMesh);
				}

				if (KFSkeletalMeshComponent(KFP.FirstPersonAttachments[i]) != none)
				{
					KFSkeletalMeshComponent(KFP.FirstPersonAttachments[i]).SetFOV(MySkelMesh.FOV);
				}
			}
		}
	}

	// Attach 1st Person Muzzle Flashes, etc,
	if ( Instigator.IsFirstPerson() )
	{
		// Toggle preshadows before attaching component (depending on graphics settings)
		if( KFP.AllowFirstPersonPreshadows() )
		{
			Mesh.bAllowPerObjectShadows = true;
		}
		else
		{
			Mesh.bAllowPerObjectShadows = false;
		}

		AttachComponent(Mesh);
		EnsureWeaponOverlayComponentLast();
		SetHidden(True);
		bPendingShow = TRUE;

		// Set the weapon to use the Instigator pawn's lighting channel
		if( KFP != none )
		{
			SetMeshLightingChannels(KFP.PawnLightingChannel);
			if( KFP.ArmsMesh != none )
			{
				Mesh.SetShadowParent(KFP.ArmsMesh);
				// Reattach our arms mesh at the same time as our weapon to avoid them ticking and popping on screen early
				AttachComponent(KFP.ArmsMesh);

				// Reattach the arms cosmetics to the weapon.
				for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
				{
					if (KFP.FirstPersonAttachments[i] != none)
					{
						AttachComponent(KFP.FirstPersonAttachments[i]);
					}
				}
			}
		}
	}
	// Attach the weapon on the server too, otherwise the hipped free-aim stuff won't work (recoil) and attaching flamethrower stuff messes up
	else if ( bWeaponNeedsServerPosition && (WorldInfo.NetMode == NM_DedicatedServer || (WorldInfo.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled())) )
	{
		AttachComponent(Mesh);
		EnsureWeaponOverlayComponentLast();
		SetHidden(True);
		bPendingShow = TRUE;
	}
	else
	{
		SetHidden(True);
		if (KFP != None)
		{
			KFP.ArmsMesh.SetHidden(true);
			for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
			{
				if (KFP.FirstPersonAttachments[i] != none)
				{
					KFP.FirstPersonAttachments[i].SetHidden(true);
				}
			}
		}
	}

	// Assign/spawn the 3rd Person Attachment
	if (KFP != None)
	{
		AttachThirdPersonWeapon(KFP);
	}

	if (MedicComp != none)
	{
		MedicComp.OnWeaponAttachedTo();
	}

	if (TargetingComp != none)
	{
		TargetingComp.OnWeaponAttachedTo();
	}

	if (WorldInfo.NetMode != NM_DedicatedServer && SkinItemId > 0 && class'KFWeaponSkinList'.static.SkinNeedsCodeUpdates(SkinItemId))
	{
		Timer_UpdateWeaponSkin();
		SetTimer(0.5f, true, nameof(Timer_UpdateWeaponSkin));
	}
}

/** Assign a new 3rd person weapon attachment  */
function AttachThirdPersonWeapon(KFPawn P)
{
	// Create weapon attachment (server only)
	if ( Role == ROLE_Authority )
	{
		P.WeaponAttachmentTemplate = AttachmentArchetype;
		P.WeaponClassForAttachmentTemplate = class;

		// Assign replicated 3rd person skin (local & server)
		if (P.IsHumanControlled())
		{
			ServerUpdateWeaponSkin(SkinItemId);
		}

		if ( WorldInfo.NetMode != NM_DedicatedServer )
		{
			P.WeaponAttachmentChanged();
		}
	}
}

simulated function KFWeaponAttachment GetWeaponAttachmentTemplate()
{
	if (AttachmentArchetype == none)
	{
		TriggerAsyncContentLoad(Class);
	}

	return AttachmentArchetype;
}

/**
 * Detach weapon from skeletal mesh
 *
 * @param	SkeletalMeshComponent weapon is attached to.
 */
simulated function DetachWeapon()
{
	local KFPawn KFP;
	local int i;

	DetachComponent( Mesh );
	if (OverlayMesh != None)
	{
		DetachComponent(OverlayMesh);
	}

	KFP = KFPawn(Instigator);
	if (Role == ROLE_Authority && KFP != None)
	{
		if ( KFP.WeaponAttachmentTemplate == AttachmentArchetype )
		{
			KFP.WeaponAttachmentTemplate = None;
			KFP.WeaponClassForAttachmentTemplate = none;
			if ( WorldInfo.NetMode != NM_DedicatedServer )
			{
				KFP.WeaponAttachmentChanged();
			}
		}
	}

	if( KFP != none && KFP.ArmsMesh != none )
	{
		// Detach our arms mesh at the same time as our weapon to avoid them ticking and popping on screen early
		DetachComponent(KFP.ArmsMesh);
		for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
		{
			if (KFP.FirstPersonAttachments[i] != none)
			{
				DetachComponent(KFP.FirstPersonAttachments[i]);
			}
		}
	}

	SetBase(None);
	SetHidden(True);
	DetachMuzzleFlash();

	if (MedicComp != none)
	{
		MedicComp.OnWeaponDetached();
	}

	if (TargetingComp != none)
	{
		TargetingComp.OnWeaponDetached();
	}

	if (IsTimerActive(nameof(Timer_UpdateWeaponSkin)))
	{
		ClearTimer(nameof(Timer_UpdateWeaponSkin));
	}
}

/**
 * Remove/Detach the muzzle flash components
 */
simulated function DetachMuzzleFlash()
{
	if (MySkelMesh != none && MuzzleFlash != None)
	{
		MuzzleFlash.DetachMuzzleFlash(MySkelMesh);
		MuzzleFlash = None;
	}
}

simulated function AttachLaserSight()
{
	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
        return;
	}

	if ( MySkelMesh != none && LaserSight == None && bHasLaserSight && LaserSight == none )
	{
		LaserSight = new(self) Class'KFLaserSightAttachment' (LaserSightTemplate);
		LaserSight.AttachLaserSight(MySkelMesh, true);
	}
}

function RemoveGun()
{
	if (Instigator != none && Instigator.InvManager != none)
	{
		Instigator.InvManager.RemoveFromInventory(Self);
	}

	Instigator = None;
	GotoState('');

	AIController = None;

	Destroy();
}

/**
 * Drop this item out in to the world
 */
function DropFrom(vector StartLocation, vector StartVelocity)
{
	local DroppedPickup P;

	// Offset spawn closer to eye location
	StartLocation.Z += Instigator.BaseEyeHeight / 2;

	// for some reason, Inventory::DropFrom removes weapon from inventory whether it was able to spawn the pickup or not.
	// we only want the weapon removed from inventory if pickup was successfully spawned, so instead of calling the supers,
	// do all the super functionality here.

	if( !CanThrow() )
	{
		return;
	}

	if( DroppedPickupClass == None || DroppedPickupMesh == None )
	{
		Destroy();
		return;
	}

	// the last bool param is to prevent collision from preventing spawns
	P = Spawn(DroppedPickupClass,,, StartLocation,,,true);
	if( P == None )
	{
		// if we can't spawn the pickup (likely for collision reasons),
		// just return without removing from inventory or destroying, which removes from inventory
		PlayerController(Instigator.Controller).ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_FailedDropInventory );
		return;
	}

	if( Instigator != None && Instigator.InvManager != None )
	{
		Instigator.InvManager.RemoveFromInventory(Self);

		if( Instigator.IsAliveAndWell() && !Instigator.InvManager.bPendingDelete )
		{
			`DialogManager.PlayDropWeaponDialog( KFPawn(Instigator) );
		}
	}

	SetupDroppedPickup( P, StartVelocity );

	Instigator = None;
	GotoState('');

	AIController = None;
}

simulated function bool CanThrow()
{
	// still throw the weapon on death even if it doesn't have its content loaded
	return super.CanThrow() &&
		(WeaponContentLoaded || (Instigator != none && (Instigator.bPlayedDeath || Instigator.Health <= 0)));
}

/** Sets up pickup. Allows subclasses to make adjustments (most notably dualbase) */
function SetupDroppedPickup( out DroppedPickup P, vector StartVelocity )
{
	P.SetPhysics(PHYS_Falling);
	P.Inventory	= self;
	P.InventoryClass = class;
	P.Velocity = StartVelocity;
	P.Instigator = Instigator;
	P.SetPickupMesh(DroppedPickupMesh);
	P.SetPickupParticles(DroppedPickupParticles);
}

/** Allows pickup to update weapon properties */
function SetOriginalValuesFromPickup( KFWeapon PickedUpWeapon )
{
	local byte i;
	local KFWeapon KFWInv;

	if(PickedUpWeapon.CurrentWeaponUpgradeIndex > INDEX_NONE)
	{
		SetWeaponUpgradeLevel(PickedUpWeapon.CurrentWeaponUpgradeIndex);
		KFInventoryManager(InvManager).AddCurrentCarryBlocks(GetUpgradeStatAdd(EWUS_Weight, CurrentWeaponUpgradeIndex));
		KFPawn(Instigator).NotifyInventoryWeightChanged();
	}

	for (i = 0; i < 2; i++)
	{
		AmmoCount[i] = PickedUpWeapon.AmmoCount[i];
	}

	SpareAmmoCount[0] = PickedUpWeapon.SpareAmmoCount[0];

	// Duals are created when a dropped single is picked up. If this weapon is a single and we already have the dual version,
	// that means we just created the dual from the single. So, since the dual we just created has default ammo, subtract
	// whatever is missing from the single from the dual.
	if( DualClass != none )
	{
		foreach KFInventoryManager(InvManager).InventoryActors( class'KFWeapon', KFWInv )
		{
			if( KFWInv.Class == DualClass )
			{
				KFWInv.AmmoCount[0] -= default.MagazineCapacity[0] - AmmoCount[0];
				KFWInv.AmmoCount[1] -= default.MagazineCapacity[1] - AmmoCount[1];

				KFWInv.SpareAmmoCount[0] -= (default.InitialSpareMags[0] * default.MagazineCapacity[0]) - SpareAmmoCount[0];
				KFWInv.SpareAmmoCount[0] = Min( KFWInv.SpareAmmoCount[0], KFWInv.SpareAmmoCapacity[0] );

				KFWInv.ClientForceAmmoUpdate(KFWInv.AmmoCount[0],KFWInv.SpareAmmoCount[0]);
				KFWInv.ClientForceSecondaryAmmoUpdate(KFWInv.AmmoCount[1]);

				KFWInv.bGivenAtStart = PickedUpWeapon.bGivenAtStart;

				return;
			}
		}
	}

	ClientForceAmmoUpdate( AmmoCount[0],SpareAmmoCount[0] );
	ClientForceSecondaryAmmoUpdate( AmmoCount[1] );

	bGivenAtStart = PickedUpWeapon.bGivenAtStart;
}

/**
 * When you pickup a weapon, the inventory system has a chance to restrict the pickup.
 */
function bool DenyPickupQuery(class<Inventory> ItemClass, Actor Pickup)
{
	local bool bDenyPickUp;
	local KFPlayerController KFPC;
	local class<KFWeapon> KFWeapClass;

	if (ItemClass == class)
	{
		KFWeapClass = class<KFWeapon>(ItemClass);
		// don't do this ammo check if the player is trying to pick up the second dual weapon
		if (KFWeapClass == none || KFWeapClass.default.DualClass == none || KFWeapClass.default.DualClass != default.DualClass)
		{
			// Unless ammo is full, allow the pickup to handle giving ammo
			// @note: projectile pickups can only refill primary ammo
			if (CanRefillSecondaryAmmo() && !Pickup.IsA('Projectile'))
			{
				bDenyPickUp = ((SpareAmmoCount[0] + AmmoCount[0]) >= GetMaxAmmoAmount(0) && AmmoCount[1] >= MagazineCapacity[1]);
			}
			else
			{
				if (KFProj_RicochetStickBullet(Pickup) == none || KFProj_RicochetStickBullet(Pickup).bPickupCanBeDenied)
				{
					bDenyPickUp = ((SpareAmmoCount[0] + AmmoCount[0]) >= GetMaxAmmoAmount(0));
				}
				else
				{
					bDenyPickUp = false;
				}
			}
		}

		if (bDenyPickUp)
		{
			KFPC = KFPlayerController(Instigator.Controller);
			//show non critical message for deny pickup
			if (KFPC != None)
			{
				KFPC.ReceiveLocalizedMessage(class'KFLocalMessage_Game', (MagazineCapacity[0] == 0) ? GMT_AlreadyCarryingWeapon : GMT_AmmoIsFull);
			}
		}
	}

	return bDenyPickUp;
}

function NotifyPickedUp()
{
	ClientNotifyPickedUp();
}

reliable client function ClientNotifyPickedUp()
{
	local KFPlayerController KFPC;
	local KFGFxMenu_Trader TraderMenu;

	// tell the trader we picked up a new weapon so it can update its display
	KFPC = KFPlayerController(Instigator.Controller);
	if( KFPC != none )
	{
		if( KFPC.MyGFxManager != none )
		{
			TraderMenu = KFGFxMenu_Trader(KFPC.MyGFxManager.CurrentMenu);
			if( TraderMenu != none )
			{
				TraderMenu.GiveExternalWeapon( self );
			}
		}
	}
}

/** Treat as non-standard equipment item for */
simulated function bool DenyPerkResupply()
{
	if (default.InventoryGroup >= IG_Equipment)
	{
		if (Class.Name == 'KFWeap_Thrown_C4')
		{
			return false;
		}

		if (Class.Name == 'KFWeap_AutoTurret')
		{
			return false;
		}

		return true;
	}

	return false;
}

simulated static function bool IsMeleeWeapon()
{
	return default.bMeleeWeapon;
}

/**
 * Returns a weight reflecting the desire to use the
 * given weapon, used for AI and player best weapon
 * selection.
 *
 * @return	weapon rating (range -1.f to 1.f)
 *
 * Overridden to use new GroupPriority
 */
simulated function float GetWeaponRating()
{
	if (!Instigator.IsHumanControlled() || !HasAnyAmmo())
	{
		return super.GetWeaponRating();
	}

	return GroupPriority;
}

/*********************************************************************************************
 * @name	Tick/Update
 *********************************************************************************************/

simulated event Tick( float DeltaTime )
{
	if( LaserSight != None )
	{
		LaserSight.Update(DeltaTime, self);
	}
}

/*********************************************************************************************
 * @name	Iron Sights / Zoom
 *********************************************************************************************/

/**
 * Adjust the FOV for the first person weapon and arms.
 */
simulated event SetFOV( float NewFOV )
{
	local KFPawn KFP;
	local int i;

	if ( MySkelMesh != none)
	{
		MySkelMesh.SetFOV(NewFOV);
	}

	if( MuzzleFlash != none )
	{
		MuzzleFlash.SetFOV(NewFOV);
	}

	// if the first person arms are attached to this gun update those too
	KFP = KFPawn(Instigator);
	if( KFP != none && KFP.ArmsMesh.ParentAnimComponent == MySkelMesh )
	{
		if( KFP.ArmsMesh != none )
		{
			KFP.ArmsMesh.SetFOV(NewFOV);
			for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
			{
				if (KFP.FirstPersonAttachments[i] != none)
				{
					if (KFSkeletalMeshComponent(KFP.FirstPersonAttachments[i]) != none)
					{
						KFSkeletalMeshComponent(KFP.FirstPersonAttachments[i]).SetFOV(NewFOV);
					}
				}
			}
		}
	}

	// Set the FOV of the Laser Sight
    if( bHasLaserSight && LaserSight != none )
	{
	   LaserSight.SetMeshFOV( NewFOV );
	}
}

/**
 * Toggle iron sights aiming
 */
simulated function SetIronSights(bool bNewIronSights)
{
	if ( bUsingSights == bNewIronSights )
	{
		return;
	}

	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	if( bUsingSights )
	{
		PerformZoom(false);
	}
	else if( AllowIronSights() )
	{
		PerformZoom(true);
	}
}

/**
 * Return true if the weapon can transition to iron sights. Overriden in
 * states where we want to prevent ironsight transitions
 */
simulated function bool AllowIronSights()
{
	if( !bHasIronSights )
	{
		return false;
	}

	return true;
}

/**
 * Return true if the weapon is currently using iron sight. Overriden in
 * states where we want to change how the iron input works
 */
simulated function bool IsUsingSights()
{
	return bUsingSights;
}

/**
 * Enables or disables depth of field as part of the iron sights effect
 */
simulated function EnableIronSightsDoF(bool bEnableDoF)
{
	local KFPlayerController PC;

	// Toggle depth of field
	if(Instigator != none)
	{
		PC = KFPlayerController(Instigator.Controller);
		if(PC != none)
		{
			PC.EnableIronSights(bEnableDoF);
			PC.EnableDepthOfField(bEnableDoF);
		}
	}
}

/**
 * Enables or disables player zoom as part of the iron sights effect
 */
simulated function EnablePlayerZoom(bool bEnableZoom)
{
	local KFPlayerController PC;

	// Toggle depth of field
	if(Instigator != none)
	{
		PC = KFPlayerController(Instigator.Controller);
		if(PC != none)
		{
			if(bEnableZoom)
			{
				PC.StartAutoTargeting();
                PC.HandleTransitionFOV(PlayerIronSightFOV, ZoomTime);
			}
			else
			{
				PC.HandleTransitionFOV(PC.DefaultFOV, ZoomTime);
			}
		}
	}
}

/**
 * Handles the logic of which zoom functions to call based on if
 * we are a client or a server
 *
 * @param bZoomStatus which direction we are zooming
 * @param bAnimateTransition whether or not to blend/animate the ironsight transition
 */
simulated function PerformZoom(bool bZoomStatus, optional bool bAnimateTransition = true)
{
	if( bZoomStatus )
	{
		if( Instigator.Physics == PHYS_Falling )
			return;

		ZoomIn(bAnimateTransition, default.ZoomInTime);

		if( bUsingSights && Role < ROLE_Authority )
		{
			ServerZoomIn(bAnimateTransition);
		}
	}
	else
	{
		ZoomOut(bAnimateTransition, default.ZoomOutTime);

		if( !bUsingSights && Role < ROLE_Authority )
		{
			ServerZoomOut(bAnimateTransition);
		}
	}
}

/**
 * Handles all the functionality for zooming in including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 * @param ZoomTimeToGo how much zoom time is left
 */
simulated function ZoomIn(bool bAnimateTransition, float ZoomTimeToGo)
{
	if( bAnimateTransition )
	{
		ZoomInTime=ZoomTimeToGo;

		// If the zoom out was interrupted, set the parameters for the native code to interpolate the zoom from the proper position
		if( bZoomingOut )
		{
			bZoomingOut=false;
			// Flag so the native code knows the zoom was interupted
			bZoomOutInterrupted=true;
			// Set the zoom time relative to how far along we were when zooming out
			ZoomTime=ZoomInTime - ZoomTime;
			// Let the native code know where/when the zoom was interrupted
			ZoomPartialTime=ZoomTime;
			ZoomStartOffset=PlayerViewOffset;
			ZoomRotStartOffset=ZoomRotInterp;
		}
		else
		{
			ZoomTime=ZoomInTime;
			ZoomStartOffset=PlayerViewOffset;
		}

		// Choose which zoom target to use. If we have a weapon with special sights customize here.
		if( bHasScopePosition && bUsingScopePosition )
		{
			ZoomTargetOffset=ScopePosition;
		}
		else
		{
			ZoomTargetOffset=IronSightPosition;
		}

		if( MySkelMesh != none )
		{
			ZoomWeaponFOVStart=MySkelMesh.FOV;
		}
		else
		{
			ZoomWeaponFOVStart=MeshFOV;
		}

		bZoomingIn=true;
	}

	if( Instigator != none && Instigator.IsLocallyControlled() )
	{
        EnablePlayerZoom(true);
		EnableIronSightsDoF(true);

		`DialogManager.PlayIronsightsDialog( KFPawn(Instigator) );
	}

	// Start timer to check if AI should be warned
	if( bWarnAIWhenAiming && Instigator != none && WorldInfo.NetMode != NM_Client )
	{
		LastAimWarningTime = 0.f;
		CurrentAimSettledTime = 0.f;
		LastAimRotation = GetAdjustedAim( Instigator.GetWeaponStartTraceLocation() );
		SetTimer( 0.1f, true, nameOf(Timer_CheckForAIWarning) );
	}

	bUsingSights = true;
}

/**
 * Handles calling the zoom in function on the server
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
reliable server private function ServerZoomIn(bool bAnimateTransition)
{
	ZoomIn(bAnimateTransition, default.ZoomInTime);
}

/**
 * Handles all the functionality for zooming out including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 * @param ZoomTimeToGo how much zoom time is left
 */
simulated function ZoomOut(bool bAnimateTransition, float ZoomTimeToGo)
{
	if( bAnimateTransition )
	{
		ZoomOutTime=ZoomTimeToGo;

		// If the zoom in was interrupted, set the parameters for the native code to interpolate the zoom from the proper position
		if( bZoomingIn )
		{
			bZoomingIn=false;
			// Flag so the native code knows the zoom was interupted
			bZoomInInterrupted=true;
			// Set the zoom time relative to how far along we were when zooming in
			ZoomTime=ZoomOutTime - ZoomTime;
			// Let the native code know where/when the zoom was interrupted
			ZoomPartialTime=ZoomTime;
			ZoomStartOffset=PlayerViewOffset;
			ZoomRotStartOffset=ZoomRotInterp;
		}
		else
		{
			ZoomTime=ZoomOutTime;
			ZoomStartOffset=PlayerViewOffset;
		}
		bZoomingOut=true;
	}
	else
	{
		// do a fast zoomout with no notifies
		bFastZoomOut = true;

		// If the zoom in was interrupted, set the parameters for the native code to interpolate the zoom from the proper position
		if( bZoomingIn )
		{
			bZoomingIn=false;
			// Flag so the native code knows the zoom was interupted
			bZoomInInterrupted=true;
			// Set the zoom time relative to how far along we were when zooming in
			ZoomTime=default.ZoomOutTime - ZoomTime;
			// Let the native code know where/when the zoom was interrupted
			ZoomPartialTime=ZoomTime;
			ZoomStartOffset=PlayerViewOffset;
			ZoomRotStartOffset=ZoomRotInterp;
		}
		else
		{
			ZoomTime=FastZoomOutTime;
			ZoomStartOffset=PlayerViewOffset;
		}
		bZoomingOut=true;

		LastZoomOutTime=WorldInfo.TimeSeconds+ZoomTime;
	}

	// Choose which zoom target to use. If we have a weapon with special sights customize here.
	ZoomTargetOffset=default.PlayerViewOffset;

	if( MySkelMesh != none )
	{
		ZoomWeaponFOVStart=MySkelMesh.FOV;
	}
	else
	{
		ZoomWeaponFOVStart=MeshIronSightFOV;
	}

	if( Instigator != none && Instigator.IsLocallyControlled() )
	{
		EnableIronSightsDoF(false);
		EnablePlayerZoom(false);

		`DialogManager.StopBreathingDialog( KFPawn(Instigator) );
	}

	// Stop timer to check if AI should be warned
	if( bWarnAIWhenAiming && WorldInfo.NetMode != NM_Client )
	{
		ClearTimer( nameOf(Timer_CheckForAIWarning) );
	}

	bUsingSights = false;
}

/**
 * Handles calling the zoom out function on the server
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
reliable server private function ServerZoomOut(bool bAnimateTransition)
{
	ZoomOut(bAnimateTransition, default.ZoomOutTime);
}

/**
 * Called by the native code when the interpolation of the first person weapon to the zoomed position finishes
 */
simulated event OnZoomInFinished()
{
	// Manually trigger anim end event for idles (zooming is a procedural anim)
	OnAnimEnd(none,0.f,0.f);
}

/**
 * Called by the native code when the interpolation of the first person weapon from the zoomed position finishes
 */
simulated event OnZoomOutFinished()
{
	// Manually trigger anim end event for idles (zooming is a procedural anim)
	OnAnimEnd(none,0.f,0.f);
}

/** Returns TRUE if this weapon is currently warning AI when aiming */
function bool IsWarningAI()
{
	return bWarnAIWhenAiming && bUsingSights;
}

/** Runs on a loop when zoomed to determine if AI should be warned */
function Timer_CheckForAIWarning()
{
	local vector Direction, DangerPoint;
	local vector TraceStart, Projection;
	local rotator NewAimRotation;
	local Pawn P;
	local KFPawn_Monster HitMonster;

	TraceStart = Instigator.GetWeaponStartTraceLocation();
	NewAimRotation = Instigator.GetBaseAimRotation();
	if( RSize(Normalize(LastAimRotation - NewAimRotation)) < 400.f )
	{
		CurrentAimSettledTime += 0.1f;
	}

	// Warn AI if the weapon is off cooldown
	if( CurrentAimSettledTime >= RandRange(AimWarningDelay.X, AimWarningDelay.Y)
		&& `TimeSince(LastAimWarningTime) > AimWarningCooldown )
	{
        // Grab our destination test location (trace offset + trace range)
        Direction = vector( NewAimRotation );

	    // Trace along a line from Location to TestLocation, warning zeds on its path
	    foreach WorldInfo.AllPawns( class'Pawn', P )
	    {
	        if( P.GetTeamNum() != Instigator.GetTeamNum() && !P.IsHumanControlled() && P.IsAliveAndWell() )
	        {
	            // Determine if AI is within range as well as within our field of view
	            Projection = P.Location - TraceStart;
	            if( VSizeSQ(Projection) < MaxAIWarningDistSQ )
	            {
	                PointDistToLine( P.Location, Direction, TraceStart, DangerPoint );

		            if( VSizeSQ(DangerPoint - P.Location) < MaxAIWarningDistFromPointSQ )
		            {
		                // Tell the AI to evade away from the DangerPoint
		                HitMonster = KFPawn_Monster( P );
		                if( HitMonster != none && HitMonster.MyKFAIC != None )
		                {
		                    HitMonster.MyKFAIC.ReceiveLocationalWarning( DangerPoint, TraceStart, self );
		                }
		            }
		        }
	        }
	    }

        // Reset settled time and start cooldown
        LastAimWarningTime = WorldInfo.TimeSeconds;
        CurrentAimSettledTime = 0.f;
	}

	LastAimRotation = NewAimRotation;
}

/*********************************************************************************************
 * @name	Instigator / movement
 ********************************************************************************************* */


/** If TRUE, Instigator/Owner moves at walking speed when this weapon is equipped */
simulated function bool ShouldOwnerWalk()
{
	return bUsingSights;
}

/** If TRUE, the owner of this weapon is susceptible to grapple attacks */
function bool IsGrappleBlocked(Pawn InstigatedBy)
{
	return FALSE;
}

simulated function SetWeaponSprint(bool bNewSprintStatus)
{
	if ( bNewSprintStatus )
	{
		if ( bUsingSights )
		{
			SetIronSights( false );
		}

		if ( CurrentFireMode < GetPendingFireLength() && PendingFire(CurrentFireMode) )
		{
			StopFire(CurrentFireMode);
		}

		GotoWeaponSprinting();
	}
}

simulated function StopPawnSprint(bool bClearPlayerInput)
{
	local KFPawn KFP;
	local PlayerController PC;
	local KFPlayerInput Input;

	KFP = KFPawn(Instigator);
	if ( KFP != None )
	{
		KFP.SetSprinting(false);

		if ( KFP.IsLocallyControlled() )
		{
			PC = PlayerController(Instigator.Controller);
			if ( PC != none )
			{
				if( bClearPlayerInput )
				{
					PC.bRun = 0;
				}

				// always stop ExtendedSprint
				Input = KFPlayerInput(PC.PlayerInput);
				if ( Input != None && Input.bExtendedSprinting )
				{
					PC.bRun = 0;
					Input.bExtendedSprinting = false;
				}
			}
		}
	}
}

simulated function bool AllowSprinting()
{
	return true;
}

simulated function GotoWeaponSprinting();

/** Called by Pawn AdjustDamage */
function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser);

/** Called by Pawn PlayTakeHitEffects */
simulated function PlayTakeHitEffects(vector HitLocation, Actor DamageCauser);

/*********************************************************************************************
 * @name	Animation
 ********************************************************************************************* */

/**
 * Play the same animation on both the weapon and the arms
 */
simulated function PlayAnimation(name Sequence, optional float fDesiredDuration, optional bool bLoop, optional float BlendInTime=0.1, optional float BlendOutTime=0.0)
{
	if ( Sequence == '' || Instigator == None || WeaponAnimSeqNode == none )
	{
		return;
	}

	`log("PlayAnimation Sequence="@Sequence@"Length="@fDesiredDuration@"bLoop="@bLoop, bLogAnimation);

	// Adjust tween node settings before setting the new animation
	if ( Instigator.IsFirstPerson() )
	{
        // Do the blends in the same length of real world time so that things don't
        // end up blending over really long periods of real time and looking wierd - Ramm
        BlendInTime *= WorldInfo.TimeDilation * CustomTimeDilation;

		WeaponAnimSeqNode.SetTweenTime(BlendInTime);
	}

	// Play animation on weapon and arms
	PlayWeaponAnimation(Sequence, fDesiredDuration, bLoop);

	// Go ahead and set up the OnAnimEnd callback in this global, and let the states handle it,
	// otherwise the Active state cuts off any animation that was trying to finish.
	if ( !bLoop )
	{
		if( fDesiredDuration > 0 )
		{
			SetTimer(fDesiredDuration - BlendOutTime,false,nameof(OnAnimEnd));
		}
		else
		{
			SetTimer((MySkelMesh.GetAnimLength(Sequence) * DefaultAnimSpeed) - BlendOutTime,false,nameof(OnAnimEnd));
		}
	}
	else
	{
		ClearTimer(nameof(OnAnimEnd));
	}
}

/** Overriden to use WeaponAnimSeqNode */
simulated function PlayWeaponAnimation(name Sequence, float fDesiredDuration, optional bool bLoop, optional SkeletalMeshComponent SkelMesh)
{
	local float DesiredRate;

	if ( Mesh != none && Instigator != none && WorldInfo.NetMode != NM_DedicatedServer )
	{
		if ( WeaponAnimSeqNode != None )
		{
			if (WeaponAnimSeqNode.AnimSeq == None || WeaponAnimSeqNode.AnimSeq.SequenceName != Sequence)
			{
				WeaponAnimSeqNode.SetAnim(Sequence);
			}

			if(fDesiredDuration > 0.0 && WeaponAnimSeqNode.AnimSeq.RateScale > 0.0)
			{
				DesiredRate = WeaponAnimSeqNode.AnimSeq.SequenceLength / (fDesiredDuration * WeaponAnimSeqNode.AnimSeq.RateScale);
				WeaponAnimSeqNode.PlayAnim(bLoop, DesiredRate);
			}
			else
			{
				WeaponAnimSeqNode.PlayAnim(bLoop, DefaultAnimSpeed);
			}
		}
	}
}

/** Overridden to look for cached WeaponAnimNodeSequence */
simulated function AnimNodeSequence GetWeaponAnimNodeSeq()
{
	if ( WeaponAnimSeqNode != None )
	{
		return WeaponAnimSeqNode;
	}

	return Super.GetWeaponAnimNodeSeq();
}

/**
 * returns true if this weapon is currently playing any animations
 * TODO: Should probably add checking the hands in here as well, to make sure
 * they don't get out of sync
 */
simulated function bool WeaponIsAnimating()
{
	// Check we have access to mesh and animations
	if( MySkelMesh == none || GetWeaponAnimNodeSeq() == none )
	{
		return false;
	}

	return WeaponAnimSeqNode.bPlaying;
}

/** @see PlayerController:ClientPlayCameraAnim */
simulated function CameraAnimInst PlayCameraAnim( CameraAnim AnimToPlay, optional float Scale=1.f, optional float Rate=1.f,
						optional float BlendInTime, optional float BlendOutTime, optional bool bLoop,
						optional bool bRandomStartTime, optional ECameraAnimPlaySpace Space=CAPS_CameraLocal, optional rotator CustomPlaySpace )
{
	local PlayerController PC;
	local CameraAnimInst AnimInst;

	PC = PlayerController(Instigator.Controller);
	if (PC.PlayerCamera != None)
	{
		AnimInst = PC.PlayerCamera.PlayCameraAnim(AnimToPlay, Rate, Scale, BlendInTime, BlendOutTime, bLoop, bRandomStartTime);
		if (AnimInst != None && Space != CAPS_CameraLocal)
		{
			AnimInst.SetPlaySpace(Space, CustomPlaySpace);
		}
	}

	return AnimInst;
}

/** Return true if this weapon should play the fire last animation for this shoot animation */
simulated function bool ShouldPlayFireLast(byte FireModeNum)
{
	if ( bHasFireLastAnims )
	{
		if( (!bAllowClientAmmoTracking && Role < ROLE_Authority && AmmoCount[GetAmmoType(FireModeNum)] <= 1)
			|| ((bAllowClientAmmoTracking || Role == ROLE_Authority) && AmmoCount[GetAmmoType(FireModeNum)] == 0) )
		{
			return true;
		}
	}

    return false;
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	local bool bPlayFireLast;

    bPlayFireLast = ShouldPlayFireLast(FireModeNum);

	if (MedicComp != none && FireModeNum == ALTFIRE_FIREMODE)
	{
		return MedicComp.GetWeaponFireAnim();
	}

	// scoped-sight anims
	if( bUsingScopePosition )
	{
		if( bPlayFireLast && FireLastScopedAnim != '' )
        {
            return FireLastScopedAnim;
        }
        else
        {
            return FireScopedAnim;
        }
	}
	// ironsights animations
	else if ( bUsingSights )
	{
		if( bPlayFireLast && FireLastSightedAnim != '' )
        {
            return FireLastSightedAnim;
        }
        else
        {
            return FireSightedAnims[Rand(FireSightedAnims.Length)];
        }
	}
	else
	{
		if( !bReloadFromMagazine && LastReloadAbortTime == WorldInfo.TimeSeconds )
		{
			return bPlayFireLast ? FireOneHandLastAnim : FireOneHandAnim;
		}

		return (bPlayFireLast && FireLastAnim != '') ? FireLastAnim : FireAnim;
	}
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLoopingFireAnim(byte FireModeNum)
{
	// scoped-sight anims
	if( bUsingScopePosition )
	{
		return FireLoopScopedAnim;
	}
	// ironsights animations
	else if ( bUsingSights )
	{
		return FireLoopSightedAnim;
	}

	return FireLoopAnim;
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLoopStartFireAnim(byte FireModeNum)
{
	if ( bUsingSights )
	{
		return FireLoopStartSightedAnim;
	}

	return FireLoopStartAnim;
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetLoopEndFireAnim(byte FireModeNum)
{
	local bool bPlayFireLast;

    bPlayFireLast = ShouldPlayFireLast(FireModeNum);

	if ( bUsingSights )
	{
    	if( bPlayFireLast && FireLoopEndLastSightedAnim != '' )
        {
            return FireLoopEndLastSightedAnim;
        }
        else
        {
            return FireLoopEndSightedAnim;
        }
	}
	else
	{
    	if( bPlayFireLast && FireLoopEndLastAnim != '' )
        {
            return FireLoopEndLastAnim;
        }
        else
        {
            return FireLoopEndAnim;
        }
	}
}

/** Get name of the animation to play for PlayFireEffects */
simulated function name GetMeleeAnimName(EPawnOctant AtkDir, EMeleeAttackType AtkType)
{
	local int idx;

	if( MeleeAttackAnims.Length > 0 )
	{
		// These are randomely selected, so anim lengths should match!
		idx = Rand(MeleeAttackAnims.Length);
		return MeleeAttackAnims[idx];
	}
}

simulated function AnimNodeSequence GetArmAnimNodeSeq()
{
	local KFPawn P;

	P = KFPawn(Instigator);
	if (P != None && P.ArmsMesh != None)
	{
		return AnimNodeSequence(P.ArmsMesh.Animations);
	}

	return None;
}

/** Locks the bolt bone in place to the open position (Called by animnotify) */
simulated function ANIMNOTIFY_LockBolt()
{
	// only do this if we're out of ammo
	if ( bAllowClientAmmoTracking )
	{
		if ( AmmoCount[0] == 0 )
		{
			EmptyMagBlendNode.SetBlendTarget(1, 0);
		}
	}
	else
	{
		// 'approximately' out of ammo
		if( (Role < ROLE_Authority && AmmoCount[0] <= 1)
			|| (Role == ROLE_Authority && AmmoCount[0] == 0) )
		{
			EmptyMagBlendNode.SetBlendTarget(1, 0);
		}
	}
}

/** Unlocks the bolt bone (Called by animnotify) */
simulated function ANIMNOTIFY_UnLockBolt()
{
	bCheckBoltLockPostReload = true;
	EmptyMagBlendNode.SetBlendTarget(0, 0);
}

/** Turn on/off additive blend node used for movement */
simulated function ToggleAdditiveBobAnim(bool bOn, optional float BlendTime=0.1f)
{
	if ( IdleBobBlendNode != None )
	{
		IdleBobBlendNode.SetBlendTarget((bOn && bUseAdditiveMoveAnim) ? 1.f : 0.f, BlendTime);
	}
}

/** Check AmmoCount and update anim tree nodes if needed */
simulated function UpdateOutOfAmmoEffects(float BlendTime)
{
	if ( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	if( EmptyMagBlendNode != None )
	{
		// For now just update the lock to fix edge case with newly picked up weapon until
		// AnimNotify system is completely removed.  Only supported for client-side ammo
		if ( AmmoCount[0] == 0 )
		{
			EmptyMagBlendNode.SetBlendTarget(1, 0);
		}
	}
}

/*********************************************************************************************
 * @name	1st person positioning
********************************************************************************************* */

native final function bool GetAnimSeqCameraPosition(out vector OutPos, out rotator OutRot);

/**
 * This function aligns the gun model in the world
 */
simulated event SetPosition(KFPawn Holder)
{
	local vector DrawOffset, ViewOffset,  FinalLocation;
	local rotator NewRotation, FinalRotation, SpecRotation;
	local PlayerController PC;
	local KFPlayerController KFPC;
	local vector SpecViewLoc;
	local Rotator DebugRotationOffset;
	local rotator UsedBufferRotation;
	local vector CamLoc;
	local rotator CamRot;
	local int i;
	local KFPawn KFP;

	if ( !Holder.IsFirstPerson() && !bWeaponNeedsServerPosition )
		return;

	// Hide the weapon if hidden
	if ( bForceHidden )
	{
		Mesh.SetHidden(True);
		Holder.ArmsMesh.SetHidden(true);
		KFP = KFPawn(Instigator);
		if(KFP != none)
		{
			for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
			{
				if (KFP.FirstPersonAttachments[i] != none)
				{
					KFP.FirstPersonAttachments[i].SetHidden(true);
				}
			}
		}
		NewRotation = Holder.GetViewRotation();
		SetLocation(Instigator.GetPawnViewLocation() + (HiddenWeaponsOffset >> NewRotation));
		SetRotation(NewRotation);
		SetBase(Instigator);
		return;
	}

	if(bPendingShow)
	{
		SetHidden(False);
		bPendingShow = FALSE;
	}

	Mesh.SetHidden(False);

	// Find the local player controller
	PC = GetALocalPlayerController();

	// Adjust for the current hand
	ViewOffset = PlayerViewOffset;

	// TODO: Ramm - look at this offset value and see if we like it
	if (class'Engine'.static.IsRealDStereoEnabled())
	{
		ViewOffset.X -= 30;
	}

	// Calculate the draw offset for Recorded Demo Specator
	if ( Holder.Controller == None && KFDemoRecSpectator(PC) != None)
	{
		PC.GetPlayerViewPoint(SpecViewLoc, SpecRotation);
		DrawOffset = ViewOffset >> SpecRotation;
		DrawOffset += Holder.WeaponBob(BobDamping, JumpDamping);
		FinalLocation = SpecViewLoc + DrawOffset;
		SetLocation(FinalLocation);
		SetBase(Holder);

		SetRotation(SpecRotation);
		return;
	}

	// Calculate weapon rotation
	NewRotation = (Holder.Controller == None) ? Holder.GetBaseAimRotation() : Holder.Controller.Rotation;

	// Add in any rotation from the zoom in rotation interpolation
	NewRotation += ZoomRotInterp;

	// Rotation local space offsets
	// Add in the free-aim rotation
	KFPC = KFPlayerController( Holder.Controller );
	if ( KFPC != None )
	{
		if( bDebugRecoilPosition )
		{
			DebugRotationOffset.Pitch = RecoilISMaxPitchLimit;
			KFPC.WeaponBufferRotation = DebugRotationOffset;
		}

		// Scale the rendered Buffer rotation by the FOV compensation scale
		if( KFPC.WeaponBufferRotation.Pitch < 32768 )
		{
            UsedBufferRotation.Pitch = KFPC.WeaponBufferRotation.Pitch/IronSightMeshFOVCompensationScale;
        }
        else
        {
            UsedBufferRotation.Pitch = 65535 - ((65535 - KFPC.WeaponBufferRotation.Pitch)/IronSightMeshFOVCompensationScale);
        }

        if( KFPC.WeaponBufferRotation.Yaw < 32768 )
        {
            UsedBufferRotation.Yaw = KFPC.WeaponBufferRotation.Yaw/IronSightMeshFOVCompensationScale;
        }
        else
        {
            UsedBufferRotation.Yaw = 65535 - ((65535 - KFPC.WeaponBufferRotation.Yaw) / IronSightMeshFOVCompensationScale);
        }

		NewRotation += UsedBufferRotation;
	}

	// Add in offset from camera animation
	if ( bFollowAnimSeqCamera && GetAnimSeqCameraPosition(CamLoc, CamRot) )
	{
		ViewOffset += CamLoc;
		NewRotation += CamRot;
	}

	FinalRotation = NewRotation;

	// Calculate the draw offset
	DrawOffset.Z += Holder.GetEyeHeight();
	DrawOffset += Holder.WeaponBob(BobDamping, JumpDamping);
	DrawOffset += (WeaponLag + ViewOffset) >> FinalRotation;

	// Adjust it in the world
	FinalLocation = Holder.Location + DrawOffset;

	SetLocation(FinalLocation);
	SetRotation(FinalRotation);
	SetBase(Holder);
}

/**
 * This function is called from the pawn when the visibility of the weapon changes
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	local KFPawn KFP;
	local SkeletalMeshComponent SkelMesh;
	local PrimitiveComponent Primitive;
	local int i;

	if (Mesh != None)
	{
		if (bIsVisible && !Mesh.bAttached)
		{
			AttachComponent(Mesh);
			EnsureWeaponOverlayComponentLast();
			// if the mesh isn't attached, we skipped playing the idle anim so play it now
			PlayIdleAnim();
		}
		SetHidden(!bIsVisible);
		SkelMesh = SkeletalMeshComponent(Mesh);
		if (SkelMesh != None)
		{
			foreach SkelMesh.AttachedComponents(class'PrimitiveComponent', Primitive)
			{
				Primitive.SetHidden(!bIsVisible);
			}
		}
	}

	KFP = KFPawn(Instigator);
	if (KFP != None && KFP.ArmsMesh != None)
	{
		if( bIsVisible )
		{
			AttachComponent(KFP.ArmsMesh);
		}
		else
		{
			DetachComponent(KFP.ArmsMesh);
		}
		KFP.ArmsMesh.SetHidden(!bIsVisible);

		for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
		{
			if (KFP.FirstPersonAttachments[i] != none)
			{
				if (bIsVisible)
				{
					AttachComponent(KFP.FirstPersonAttachments[i]);
				}
				else
				{
					DetachComponent(KFP.FirstPersonAttachments[i]);
				}
				KFP.FirstPersonAttachments[i].SetHidden(!bIsVisible);
			}
		}
	}

	if ( OverlayMesh != none )
	{
		OverlayMesh.SetHidden(!bIsVisible);
	}
}

/*********************************************************************************************
 * @name	Effects
********************************************************************************************* */

/**
 * PlayFireEffects Is the root function that handles all of the effects associated with
 * a weapon.  This function creates the 1st person effects.  It should only be called
 * on a locally controlled player.
 */
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	local name WeaponFireAnimName;
	local KFPerk CurrentPerk;
	local float TempTweenTime, AdjustedAnimLength;

	// If we have stopped the looping fire sound to play single fire sounds for zed time
	// start the looping sound back up again when the time is back above zed time speed
	if( FireModeNum < bLoopingFireSnd.Length && bLoopingFireSnd[FireModeNum] && !bPlayingLoopingFireSnd )
    {
        StartLoopingFireSound(FireModeNum);
    }

	PlayFiringSound(CurrentFireMode);

	if( Instigator != none )
	{
		// Tell our pawn about any changes in animation speed
		UpdateWeaponAttachmentAnimRate( GetThirdPersonAnimRate() );

		if( Instigator.IsLocallyControlled() )
		{
			if( Instigator.IsFirstPerson() )
			{
				if ( !bPlayingLoopingFireAnim )
				{
					WeaponFireAnimName = GetWeaponFireAnim(FireModeNum);

					if ( WeaponFireAnimName != '' )
					{
						AdjustedAnimLength = MySkelMesh.GetAnimLength(WeaponFireAnimName);
						TempTweenTime = FireTweenTime;

						CurrentPerk = GetPerk();
						if( CurrentPerk != none )
						{
							CurrentPerk.ModifyRateOfFire( AdjustedAnimLength, self );

							// We need to unlock the slide if we fire from zero ammo while uber ammo is active
							if( EmptyMagBlendNode != none
								&& BonesToLockOnEmpty.Length > 0
								&& AmmoCount[GetAmmoType(FireModeNum)] == 0
								&& CurrentPerk.GetIsUberAmmoActive(self) )
							{
								EmptyMagBlendNode.SetBlendTarget( 0, 0 );
								TempTweenTime = 0.f;
							}
						}

						PlayAnimation(WeaponFireAnimName, AdjustedAnimLength,, TempTweenTime);
					}
				}

				// Start muzzle flash effect
				CauseMuzzleFlash(FireModeNum);
			}

			HandleRecoil();
			ShakeView();

			if (AmmoCount[0] == 0 && ForceReloadTimeOnEmpty > 0)
			{
				SetTimer(ForceReloadTimeOnEmpty, false, nameof(ForceReload));
			}
		}
	}
}

simulated function StopFireEffects(byte FireModeNum)
{
	if (MuzzleFlash != None)
	{
        MuzzleFlash.StopMuzzleFlash();
	}
}

/**
 * Starts playing looping FireAnim and FireSnd
 */
simulated function StartLoopingFireEffects(byte FireModeNum, optional bool bForceAnim)
{
	local name WeaponFireAnimName;

	if ( bForceAnim || (FireModeNum < bLoopingFireAnim.Length && bLoopingFireAnim[FireModeNum]) )
	{
		// If available, try to play loop start anim
		WeaponFireAnimName = GetLoopStartFireAnim(FireModeNum);
		if ( WeaponFireAnimName != '' )
		{
			PlayAnimation(WeaponFireAnimName, MySkelMesh.GetAnimLength(WeaponFireAnimName), FALSE, FireTweenTime, 0.f);
		}
		// Otherwise go straight to the looping animation
		else
		{
			WeaponFireAnimName = GetLoopingFireAnim(FireModeNum);
			PlayAnimation(WeaponFireAnimName, MySkelMesh.GetAnimLength(WeaponFireAnimName), TRUE, FireTweenTime);
		}

		bPlayingLoopingFireAnim = true;
	}

	StartLoopingFireSound(FireModeNum);
}

/**
 * Stops playing looping FireAnim and FireSnd
 */
simulated function StopLoopingFireEffects(byte FireModeNum)
{
	local name LoopEndFireAnim;

	if ( bPlayingLoopingFireAnim )
	{
		LoopEndFireAnim = GetLoopEndFireAnim(FireModeNum);
		if ( LoopEndFireAnim != '' )
		{
			PlayAnimation(LoopEndFireAnim, MySkelMesh.GetAnimLength(LoopEndFireAnim));
		}
		else
		{
			ClearTimer(nameof(OnAnimEnd));	// needed for loopstart anim to return to idle
		}
		bPlayingLoopingFireAnim = false;
	}

	StopLoopingFireSound( FireModeNum );
}

/** True if we want to override the looping fire sounds with fire sounds from another firemode */
simulated function bool ShouldForceSingleFireSound()
{
	// If this weapon has a single-shot firemode, disable looping fire sounds during zedtime
	if ( `IsInZedTime(self) && SingleFireSoundIndex != 255 )
	{
		return true;
	}

	return false;
}

/**
 * Starts playing looping FireSnd only (used for switching sounds in Zedtime)
 */
simulated function StartLoopingFireSound(byte FireModeNum)
{
	if ( FireModeNum < bLoopingFireSnd.Length && bLoopingFireSnd[FireModeNum] && !ShouldForceSingleFireSound() )
	{
		bPlayingLoopingFireSnd = true;
		KFPawn(Instigator).SetWeaponAmbientSound(WeaponFireSnd[FireModeNum].DefaultCue, WeaponFireSnd[FireModeNum].FirstPersonCue);
	}
}

/**
 * Stops playing looping FireSnd only (used for switching sounds in Zedtime)
 */
simulated function StopLoopingFireSound(byte FireModeNum)
{
	if ( bPlayingLoopingFireSnd )
	{
		KFPawn(Instigator).SetWeaponAmbientSound(None);
		if ( FireModeNum < WeaponFireLoopEndSnd.Length )
		{
			WeaponPlayFireSound(WeaponFireLoopEndSnd[FireModeNum].DefaultCue, WeaponFireLoopEndSnd[FireModeNum].FirstPersonCue);
		}

		bPlayingLoopingFireSnd = false;
	}
}

/**
 * Tells the weapon to play a firing sound (uses CurrentFireMode)
 */
simulated function PlayFiringSound( byte FireModeNum )
{
    local byte UsedFireModeNum;

	MakeNoise(1.0,'PlayerFiring'); // AI

	if (MedicComp != none && FireModeNum == ALTFIRE_FIREMODE)
	{
		MedicComp.PlayFiringSound();
	}
	else
	if ( !bPlayingLoopingFireSnd )
	{
		UsedFireModeNum = FireModeNum;

		// Use the single fire sound if we're in zed time and want to play single fire sounds
		if( FireModeNum < bLoopingFireSnd.Length && bLoopingFireSnd[FireModeNum] && ShouldForceSingleFireSound() )
        {
            UsedFireModeNum = SingleFireSoundIndex;
        }

        if ( UsedFireModeNum < WeaponFireSnd.Length )
		{
			WeaponPlayFireSound(WeaponFireSnd[UsedFireModeNum].DefaultCue, WeaponFireSnd[UsedFireModeNum].FirstPersonCue);
		}
	}
}

/**
 * This function selects whether we should play a first person or third person sound
 */
simulated function WeaponPlayFireSound(AkBaseSoundObject DefaultSound, AkBaseSoundObject FirstPersonSound)
{
    // ReplicateSound needs an "out" vector
    local vector SoundLocation;

	if( Instigator != None && !bSuppressSounds  )
	{
		// With our WWise integration, SoundLocation can't be same as Instigator location (or whatever
        // object calls PlaySoundBase/ReplicateSound) otherwise it gets set to 0 in native in
        // APlayerController::HearSound and attaches the sound to the instigator and the sound will
        // follow the the actor around. For now sing the eye location to solve this issue.
        SoundLocation = Instigator.GetPawnViewLocation();

		if ( FirstPersonSound != None && Instigator.IsLocallyControlled() && Instigator.IsFirstPerson() )
		{
            Instigator.PlaySoundBase( FirstPersonSound, true, false, false );

            // Play first person, but replicate third person
			if ( WorldInfo.NetMode == NM_ListenServer )
			{
                KFPawn(Instigator).ReplicateSound(DefaultSound, false, false, false, SoundLocation);
			}
		}
		else if ( DefaultSound != None )
		{
            Instigator.PlaySoundBase( DefaultSound, false, true, false, SoundLocation );
		}
	}
}

/**
 * This function handles playing sounds for weapons.  How it plays the sound depends on the following:
 *
 * If we are a listen server, then this sound is played and replicated as normal
 * If we are a remote client, but locally controlled (ie: we are on the client) we play the sound and don't replicate it
 * If we are a dedicated server, play the sound and replicate it to everyone BUT the owner (he will play it locally).
 *
 *
 * @param	Sound	- The Source to play
 */
simulated function WeaponPlaySound(AkBaseSoundObject Sound, optional float NoiseLoudness)
{
	// if we are a listen server, just play the sound.  It will play locally
	// and be replicated to all other clients.
	if( Sound != None && Instigator != None && !bSuppressSounds  )
	{
	    Instigator.PlaySoundBase(Sound, false, true);
	}
}

/**
 * Causes the muzzle flash to turn on and setup a time to
 * turn it back off again.
 */
simulated function CauseMuzzleFlash(byte FireModeNum)
{
	if (MuzzleFlash == None)
	{
		AttachMuzzleFlash();
	}

	if (MuzzleFlash != None )
	{
		MuzzleFlash.CauseMuzzleFlash(FireModeNum);
		if ( MuzzleFlash.bAutoActivateShellEject )
		{
			MuzzleFlash.CauseShellEject();
			SetShellEjectsToForeground();
		}
	}
}

/** notify to spawn a shell eject from the muzzle flash component */
simulated function ANIMNOTIFY_ShellEject()
{
	if (MuzzleFlash == None)
	{
		AttachMuzzleFlash();
	}

	if (MuzzleFlash != None )
	{
		MuzzleFlash.CauseShellEject();
		SetShellEjectsToForeground();
	}
}

/**
 * Called on a client, this function Attaches the WeaponAttachment
 * to the Mesh.
 */
simulated function AttachMuzzleFlash()
{
	if ( MySkelMesh != none )
	{
		if (MuzzleFlashTemplate != None)
		{
			MuzzleFlash = new(self) Class'KFMuzzleFlash'(MuzzleFlashTemplate);
			MuzzleFlash.AttachMuzzleFlash(MySkelMesh);
		}
	}
}

/** Sets the shell ejector to the foreground depth */
simulated function SetShellEjectsToForeground()
{
	// Put shells in the foreground at first
	if( MuzzleFlash != none && MuzzleFlash.ShellEjectPSC != none && EjectedShellForegroundDuration > 0.f )
	{
		MuzzleFlash.ShellEjectPSC.SetDepthPriorityGroup( SDPG_Foreground );
		MuzzleFlash.ShellEjectPSC.bDepthTestEnabled = true;

		SetTimer( EjectedShellForegroundDuration, false, nameOf(Timer_RestoreShellEjectDepth) );
	}
}

/** Sets the shell ejection PSC back to world depth */
simulated function Timer_RestoreShellEjectDepth()
{
	if( MuzzleFlash != none && MuzzleFlash.ShellEjectPSC != none )
	{
		MuzzleFlash.ShellEjectPSC.SetDepthPriorityGroup( SDPG_World );
		MuzzleFlash.ShellEjectPSC.bDepthTestEnabled = false;
	}
}

/** plays view shake on the owning client only */
simulated function ShakeView()
{
	local PlayerController PC;
	local float ShakeViewScale;

	PC = PlayerController(Instigator.Controller);
	if( PC == None || LocalPlayer(PC.Player) == None )
	{
		return;
	}

	if (MedicComp != none)
	{
		MedicComp.AdjustShakeView(CurrentFireMode);
	}

	// Play camera shake/anim
	if (CurrentFireMode < FireCameraAnim.length && FireCameraAnim[CurrentFireMode] != None)
	{
		ShakeViewScale = ShakeScaleStandard;
		if( bUsingSights )
		{
			ShakeViewScale *= ShakeScaleSighted;
		}

		// Use a CameraAnim for now, but consider CameraShake with bRandomAnimSegment
		PC.ClientPlayCameraAnim(FireCameraAnim[CurrentFireMode], ShakeViewScale, 1.f, 0.0f, 0.1f);
	}

	// Play controller vibration
	PC.ClientPlayForceFeedbackWaveform( WeaponFireWaveForm );
}

/** Increment bloody material parameter */
simulated function AddBlood(float MinAmount, float MaxAmount)
{
	local float NewBlood;
	local int i;

	if ( WorldInfo.NetMode != NM_DedicatedServer && WeaponMICs.Length > 0 )
	{
		NewBlood = RandRange(MinAmount, MaxAmount);
		BloodParamValue = FMax(BloodParamValue + NewBlood, MinBloodParamValue);

		for( i = 0; i < WeaponMICs.Length; ++i )
		{
			if( WeaponMICs[i] != none )
			{
				WeaponMICs[i].SetScalarParameterValue( BloodParamName, BloodParamValue );
			}
		}
	}
}

/*********************************************************************************************
 * @name	Firing / Projectile
********************************************************************************************* */

/**
 * @see Weapon::StartFire
 */
simulated function StartFire(byte FireModeNum)
{
	if (MedicComp != none)
	{
		if (!MedicComp.ShouldStartFire(FireModeNum))
		{
			return;
		}
	}

	// Attempt auto-reload
	if( FireModeNum == DEFAULT_FIREMODE || FireModeNum == ALTFIRE_FIREMODE )
	{
		if ( ShouldAutoReload(FireModeNum) )
		{
			FireModeNum = RELOAD_FIREMODE;
		}
	}

	// Convert to altfire if we have alt fire mode active
	if (FireModeNum == DEFAULT_FIREMODE)
	{
		bStopAltFireOnNextRelease = false;
		if (bUseAltFireMode && !bGamepadFireEntry)
		{
			FireModeNum = ALTFIRE_FIREMODE;
			bStopAltFireOnNextRelease = true;
		}
	}

	if ( FireModeNum == RELOAD_FIREMODE )
	{
		// Skip Super/ ServerStartFire and let server wait for ServerSendToReload to force state synchronization
		BeginFire(FireModeNum);
		return;
	}

	Super.StartFire(FireModeNum);
}

/**
 * BeginFire is the point at which the server and client sync up their code path.  It's job is to set
 * the weapon in to the firing state.
 * Network: LocalPlayer and Server
 */
simulated function BeginFire( Byte FireModeNum )
{
	local KFPerk_Gunslinger GunslingerPerk;
	super.BeginFire( FireModeNum );

	if( Role == Role_Authority )
	{
		GunslingerPerk = KFPerk_Gunslinger(GetPerk());
		if( GunslingerPerk != none && !IsMeleeWeapon() && !GunslingerPerk.IsWeaponOnPerk( self,, GunslingerPerk.class ) )
		{
			GunslingerPerk.ResetHeadShotCombo();
		}
	}
}

/**
 * @see Weapon::StopFire
 */
simulated function StopFire(byte FireModeNum)
{
	// Convert to altfire if we have alt fire mode active
	if ( FireModeNum == DEFAULT_FIREMODE && bStopAltFireOnNextRelease )
	{
		bStopAltFireOnNextRelease = false;
		FireModeNum = ALTFIRE_FIREMODE;
	}

	Super.StopFire(FireModeNum);
}

/**
 * Toggle between DEFAULT and ALTFIRE
 */
simulated function AltFireMode()
{
	// LocalPlayer Only
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	// Needs a state name, and a valid fire type to switch to alt fire mode
	if( FiringStatesArray[1] == '' || WeaponFireTypes[1] == EWFT_None )
	{
		return;
	}

	if( bUseAltFireMode )
	{
		// Clear fire now since StopFire will now be converted to default fire
		StopFire(ALTFIRE_FIREMODE);
		bUseAltFireMode = false;
	}
	else
	{
		// Clear fire now since StopFire will now be converted to alt fire
		StopFire(DEFAULT_FIREMODE);
		bUseAltFireMode = true;
	}

	Instigator.PlaySoundBase( KFInventoryManager(InvManager).SwitchFireModeEvent );
}

/** Player released switch fire mode button */
simulated function AltFireModeRelease()
{
	// Weapons that call StartFire() in SwitchFireMode() need to also call StopFire()
	// For most weapons this is unnecessary, but harmless
	if ( PendingFire(ALTFIRE_FIREMODE) )
	{
		StopFire(ALTFIRE_FIREMODE);
	}
}

 /**
 * Send weapon to proper firing state
 * Also sets the CurrentFireMode.
 * Network: LocalPlayer and Server
 *
 * @param	FireModeNum Fire Mode.
 */
simulated function SendToFiringState(byte FireModeNum)
{
	local KFPawn_Human KFPH;

    if( FireModeNum == GRENADE_FIREMODE && !GetPerk().GetGrenadeClass().default.bAllowTossDuringZedGrabRotation )
    {
		// Don't let us toss a grenade right after being grabbed and spun
		// so we don't blow ourselves up.
        if( `TimeSince(ZedGrabGrenadeTossCooldown) < 0 )
		{
            //`log("Can't toss a nade because just got grabbed!!! Cooldown: "$`TimeSince(ZedGrabGrenadeTossCooldown));
            return;
		}
    }

	// Custom reload handling for better ammo synchronization
	if ( FireModeNum == RELOAD_FIREMODE && Instigator.IsLocallyControlled() )
	{
		InitializeReload();
	}

    //End emote before reload starts so 1P anims get triggered properly
    KFPH = KFPawn_Human(Instigator);
	if( KFPH != none )
	{
		KFPH.CheckAndEndActiveEMoteSpecialMove();
	}

    super.SendToFiringState(FireModeNum);
}

/**
 * This function returns the world location for spawning the visual effects
 * Overridden to only use the X portion of the offset when we are  in ironsights
 */
simulated event vector GetMuzzleLoc()
{
    local vector X, Y, Z;
    local Rotator ViewRotation;

	if( Instigator != none )
	{
        if( bUsingSights )
        {
            ViewRotation = Instigator.GetViewRotation();

        	// Add in the free-aim rotation
        	if ( KFPlayerController(Instigator.Controller) != None )
        	{
        		ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;
        	}

            GetAxes(ViewRotation, X, Y, Z);

            return Instigator.GetWeaponStartTraceLocation() + X * FireOffset.X;
		}
		else
		{
            ViewRotation = Instigator.GetViewRotation();

        	// Add in the free-aim rotation
        	if ( KFPlayerController(Instigator.Controller) != None )
        	{
        		ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;
        	}

            return Instigator.GetPawnViewLocation() + (FireOffset >> ViewRotation);
		}

	}

	return Location;
}

/** returns ID of muzzle to spawn projectile at / play effects at (overridden in dual) */
simulated function byte GetCurrentMuzzleID()
{
	return 0;
}

/** Store the KFPlayerController holding this weapon so it doesn't have to be casted over and over */
simulated function CacheKFPlayerController()
{
	if( Instigator == None )
	{
		KFPlayer = None;
	}
	else
	{
		KFPlayer = KFPlayerController(Instigator.Controller);
	}
}

/**
 * FireAmmunition: Perform all logic associated with firing a shot
 * - Fires ammunition (instant hit or spawn projectile)
 * - Consumes ammunition
 * - Plays any associated effects (fire sound and whatnot)
 *
 * Network: LocalPlayer and Server
 */
simulated function FireAmmunition()
{
    // Let the accuracy tracking system know that we fired
    HandleWeaponShotTaken( CurrentFireMode );

	// Handle the different fire types
	switch( WeaponFireTypes[CurrentFireMode] )
	{
		case EWFT_InstantHit:
            // Launch a projectile if we are in zed time, and this weapon has a projectile to launch for this mode
            if( `IsInZedTime(self) && WeaponProjectiles[CurrentFireMode] != none )
            {
                ProjectileFire();
            }
            else
            {
                InstantFireClient();
            }
			break;

		case EWFT_Projectile:
			ProjectileFire();
			break;

		case EWFT_Custom:
			CustomFire();
			break;
	}

	// Decrement Ammo.  Called after Fire() for weapons that can fire a variable ammo amount (e.g. nail shotgun)
	ConsumeAmmo( CurrentFireMode );

	NotifyWeaponFired( CurrentFireMode );

	// Play fire effects now (don't wait for WeaponFired to replicate)
	PlayFireEffects(CurrentFireMode, vect(0,0,0));
}


/** Notification that a weapon attack has has happened */
function HandleWeaponShotTaken( byte FireMode )
{
    if( KFPlayer != None )
	{
        KFPlayer.AddShotsFired(GetNumProjectilesToFire(FireMode));
	}
}

/**
 * CalcWeaponFire: Simulate an instant hit shot.
 * This doesn't deal any damage nor trigger any effect. It just simulates a shot and returns
 * the hit information, to be post-processed later.
*/
simulated function ImpactInfo CalcWeaponFire(vector StartTrace, vector EndTrace, optional out array<ImpactInfo> ImpactList, optional vector Extent)
{
	local ImpactInfo CurrentImpact;
	local int i;
	local Actor HitActor;
	local bool bFirst;

	bFirst = (ImpactList.Length == 0);
	CurrentImpact = Super.CalcWeaponFire(StartTrace, EndTrace, ImpactList, Extent);

	// When recursion is finished process all impacts to find hit zones
	if ( bFirst )
	{
		// For pawn hits calculate an improved hit zone and direction.  The return, CurrentImpact, is
		// unaffected which is fine since it's only used for it's HitLocation and not by ProcessInstantHit()
		TraceImpactHitZones(StartTrace, EndTrace, ImpactList);

		// Iterate though ImpactList, find water, return water Impact as 'realImpact'
		// This is needed for impact effects on non-blocking water
		for (i = 0; i < ImpactList.Length; i++)
		{
			HitActor = ImpactList[i].HitActor;
			if ( HitActor != None && !HitActor.bBlockActors && HitActor.IsA('KFWaterMeshActor')  )
			{
				return ImpactList[i];
			}
		}
	}

	return CurrentImpact;
}

/** Replaces ImpactInfo entries with hit zone information */
simulated function TraceImpactHitZones(vector StartTrace, vector EndTrace, out array<ImpactInfo> ImpactList)
{
	local int i;
	local array<ImpactInfo> HitZoneImpactList;

	for (i = 0; i < ImpactList.Length; i++)
	{
		if ( ImpactList[i].HitActor != None
			&& ImpactList[i].HitActor.bCanBeDamaged
			&& ImpactList[i].HitActor.IsA('KFPawn') )
		{
			// Getting the SkelMeshComp here requires (BlockZeroExtent && CollideActors && !Cylinder.BlockZeroExtent)
			TraceAllPhysicsAssetInteractions(SkeletalMeshComponent(ImpactList[i].HitInfo.HitComponent), EndTrace, StartTrace, HitZoneImpactList, vect(0,0,0), true);

			// replace impact entry with the first hitzone impact, if the list is empty we
			// missed all hit zones.  Handle in KFPawn.AdjustDamage().
			if ( HitZoneImpactList.Length > 0 )
			{
				HitZoneImpactList[0].StartTrace = ImpactList[i].StartTrace;
				HitZoneImpactList[0].RayDir = ImpactList[i].RayDir;
				ImpactList[i] = HitZoneImpactList[0];
			}
		}
	}
}

/** handles pawn penetration (why was this function static?) */
simulated function bool PassThroughDamage(Actor HitActor)
{
    local KFPawn KFP;

	if ( HitActor.bBlockActors )
	{
		KFP = KFPawn(HitActor);
		if ( PenetrationPowerRemaining > 0 && KFP != none )
		{
			PenetrationPowerRemaining -= KFP.PenetrationResistance;
			return true;
		}
	}

	return (!HitActor.bBlockActors && (HitActor.IsA('Trigger') || HitActor.IsA('TriggerVolume')
		|| HitActor.IsA('InteractiveFoliageActor') || HitActor.IsA('KFWaterMeshActor')));
}

/**
 * Adds any fire spread offset to the passed in rotator
 * Overridden for KF Spread modifiers
 * @param Aim the base aim direction
 * @return the adjusted aim direction
 */
simulated function rotator AddSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local float CurrentSpread, RandY, RandZ;

	// when there are multiple pellets, will use AddMultiShotSpread when spawning the projectiles
	if ( CurrentFireMode >= Spread.Length || NumPellets[CurrentFireMode] > 1)
	{
		return BaseAim;
	}

	CurrentSpread = GetUpgradedSpread(CurrentFireMode);

	if( bUsingSights )
	{
		CurrentSpread *= IronSightsSpreadMod;
	}
	else if( MovingSpreadMod > 1.0 && VSizeSq(Instigator.Velocity) > 0 )
	{
		CurrentSpread *= MovingSpreadMod;
	}

	if( Instigator.bIsCrouched )
	{
		CurrentSpread *= CrouchSpreadMod;
	}

	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// There might be a perk active that reduces the spread
		if ( GetPerk() != none )
		{
			GetPerk().ModifySpread(CurrentSpread);
		}

		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		RandY = FRand() - 0.5;
		RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}
}

/** Same as AddSpread(), but used with MultiShotSpread */
static function rotator AddMultiShotSpread(rotator BaseAim, float CurrentSpread, byte PelletNum)
{
	local vector X, Y, Z;
	local float RandY, RandZ;

	if (CurrentSpread == 0)
	{
		return BaseAim;
	}
	else
	{
		// Add in any spread.
		GetAxes(BaseAim, X, Y, Z);
		RandY = FRand() - 0.5;
		RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
		return rotator(X + RandY * CurrentSpread * Y + RandZ * CurrentSpread * Z);
	}
}

/** Returns number of projectiles to fire from SpawnProjectile */
simulated function byte GetNumProjectilesToFire(byte FireModeNum)
{
	return NumPellets[CurrentFireMode];
}

// Overridden if we want to add recoil modifiers
simulated function ModifyRecoil( out float CurrentRecoilModifier )
{
	GetPerk().ModifyRecoil( CurrentRecoilModifier, self );
}

/**
 * Called on the client when the weapon is fired calculate the recoil parameters
 * Network: LocalPlayer
 */
simulated event HandleRecoil()
{
	local rotator NewRecoilRotation;
	local float CurrentRecoilModifier;

	local KFPawn KFP;

	if ( Instigator == none  || !Instigator.IsFirstPerson() )
	{
		return;
	}

	if (MedicComp != none)
	{
		MedicComp.AdjustRecoil(CurrentFireMode);
	}

	CurrentRecoilModifier = GetUpgradedRecoilModifier(CurrentFireMode);

	NewRecoilRotation.Pitch = RandRange( minRecoilPitch, maxRecoilPitch );
	NewRecoilRotation.Yaw = RandRange( minRecoilYaw, maxRecoilYaw );

	if ( Instigator.Physics == PHYS_Falling )
	{
		CurrentRecoilModifier *= FallingRecoilModifier;
	}

	// Handle weapon posture recoil modifiers
	KFP = KFPawn(Instigator);
	if ( KFP != none  )
	{
		if( VSizeSq(Instigator.Velocity) > 50 )
		{
			if( Instigator.bIsWalking )
			{
				CurrentRecoilModifier *= WalkingRecoilModifier;
			}
			else
			{
				CurrentRecoilModifier *= JoggingRecoilModifier;
			}
		}
		if ( Instigator.bIsCrouched )
		{
			CurrentRecoilModifier *= StanceCrouchedRecoilModifier;
		}

		if( !bUsingSights )
		{
			CurrentRecoilModifier *= HippedRecoilModifier;
		}
	}

	// Add any additional recoil mods for children
	ModifyRecoil( CurrentRecoilModifier );

	NewRecoilRotation *= CurrentRecoilModifier;
    LastRecoilModifier = CurrentRecoilModifier;

	// Need to set this value per weapon
	SetRecoil(NewRecoilRotation,RecoilRate);
}

/**
 * Called on the client to set new recoil parameters to be processed
 * Network: LocalPlayer
 *
 * @param	NewRecoilRotation	The new recoil rotation to add
 * @param	NewRecoilSpeed		How long it should take to process this recoil
 */
simulated function SetRecoil(rotator NewRecoilRotation, float NewRecoilSpeed)
{
	local float UsedRecoilScale;

	// If we haven't process all the recoil from the previous fire, scale down the
	// recoil rotator by how much recoil is left before adding in new recoil
	if( RecoilTimeLeft > 0 )
	{
		UsedRecoilScale = RecoilTimeLeft/RecoilSpeed;
	}
	else
	{
		UsedRecoilScale = 0.0;
	}

	RecoilRotator *= UsedRecoilScale;
	RecoilRotator += NewRecoilRotation;

	RecoilSpeed = NewRecoilSpeed;
	RecoilTimeLeft = NewRecoilSpeed;
}

/**
 * Returns the type of projectile to spawn.  We use a function so subclasses can
 * override it if needed (case in point, homing rockets).
 * Overriden to be simulated so the client can get the projectile class
 */
simulated function class<KFProjectile> GetKFProjectileClass()
{
	if( CurrentFireMode == GRENADE_FIREMODE )
	{
		return GetPerk().GetGrenadeClass();
	}
	else
	{
		return (CurrentFireMode < WeaponProjectiles.length) ? class<KFProjectile>( WeaponProjectiles[CurrentFireMode] ) : None;
	}
}

static simulated function class<KFProjectile> GetKFProjectileClassByFiringMode(int FiringMode, KFPerk Perk)
{
	if (FiringMode == GRENADE_FIREMODE)
	{
		return Perk.GetGrenadeClass();
	}
	else
	{
		return (FiringMode < default.WeaponProjectiles.length) ? class<KFProjectile>(default.WeaponProjectiles[FiringMode]) : None;
	}
}

/**
 * Fires a projectile.
 * Spawns the projectile, but also increment the flash count for remote client effects.
 * Network: Local Player and Server
 * Overriden to add maximum aim adjustment
 */
 simulated function Projectile ProjectileFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local vector DirA, DirB;
	local Quat Q;
	local class<KFProjectile> MyProjectileClass;

	// tell remote clients that we fired, to trigger effects
	if ( ShouldIncrementFlashCountOnFire() )
	{
		IncrementFlashCount();
	}

    MyProjectileClass = GetKFProjectileClass();

	if( Role == ROLE_Authority || (MyProjectileClass.default.bUseClientSideHitDetection
        && MyProjectileClass.default.bNoReplicationToInstigator && Instigator != none
        && Instigator.IsLocallyControlled()) )
	{
		// This is where we would start an instant trace. (what CalcWeaponFire uses)
		StartTrace = GetSafeStartTraceLocation();
		AimDir = Vector(GetAdjustedAim( StartTrace ));

		// this is the location where the projectile is spawned.
		RealStartLoc = GetPhysicalFireStartLoc(AimDir);

		if( StartTrace != RealStartLoc )
		{
			// if projectile is spawned at different location of crosshair,
			// then simulate an instant trace where crosshair is aiming at, Get hit info.
			EndTrace = StartTrace + AimDir * GetTraceRange();
			TestImpact = CalcWeaponFire( StartTrace, EndTrace );
			// Store the original aim direction without correction
            DirB = AimDir;

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);

            // Store the desired corrected aim direction
    		DirA = AimDir;

    		// Clamp the maximum aim adjustment for the AimDir so you don't get wierd
    		// cases where the projectiles velocity is going WAY off of where you
    		// are aiming. This can happen if you are really close to what you are
    		// shooting - Ramm
    		if ( (DirA dot DirB) < MaxAimAdjust_Cos )
    		{
    			Q = QuatFromAxisAndAngle(Normal(DirB cross DirA), MaxAimAdjust_Angle);
    			AimDir = QuatRotateVector(Q,DirB);
    		}
		}

		return SpawnAllProjectiles(MyProjectileClass, RealStartLoc, AimDir);
	}

	return None;
}

/** Called from ProjectileFire() */
simulated function bool ShouldIncrementFlashCountOnFire()
{
	return CurrentFireMode != GRENADE_FIREMODE;
}

simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local int ProjectilesToFire, i;
	local rotator AimRot;

	ProjectilesToFire = GetNumProjectilesToFire(CurrentFireMode);
	if (CurrentFireMode == GRENADE_FIREMODE || ProjectilesToFire <= 1)
	{
		return SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
	}

	// Spawn projectile(s)
	AimRot = rotator(AimDir);
	for (i = 0; i < ProjectilesToFire; i++)
	{
		SpawnProjectile(KFProjClass, RealStartLoc, vector(AddMultiShotSpread(AimRot, Spread[CurrentFireMode], i)));
	}

	return None;
}

simulated function KFProjectile SpawnProjectile( class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir )
{
	local KFProjectile	SpawnedProjectile;
	local int ProjDamage;

	// Spawn projectile
	SpawnedProjectile = Spawn( KFProjClass, Self,, RealStartLoc);
	if( SpawnedProjectile != none && !SpawnedProjectile.bDeleteMe )
	{
		// Mirror damage and damage type from weapon. This is set on the server only and
		// these properties are replicated via TakeHitInfo
		if ( InstantHitDamage.Length > CurrentFireMode && InstantHitDamageTypes.Length > CurrentFireMode )
		{
            ProjDamage = GetModifiedDamage(CurrentFireMode);
            SpawnedProjectile.Damage = ProjDamage;
            SpawnedProjectile.MyDamageType = InstantHitDamageTypes[CurrentFireMode];
		}

		// Set the penetration power for this projectile
		// because of clientside hit detection, we need two variables --
		// one that replicates on init and one that updates but doesn't replicate
		SpawnedProjectile.InitialPenetrationPower = GetInitialPenetrationPower(CurrentFireMode);
		SpawnedProjectile.PenetrationPower = SpawnedProjectile.InitialPenetrationPower;

		SpawnedProjectile.UpgradeDamageMod = GetUpgradeDamageMod();
		SpawnedProjectile.Init( AimDir );
	}

	if (MedicComp != none && KFProj_HealingDart(SpawnedProjectile) != None)
	{
		if (TargetingComp != none && TargetingComp.LockedTarget[1] != none)
		{
			KFProj_HealingDart(SpawnedProjectile).SeekTarget = TargetingComp.LockedTarget[1];
		}
	}

	// return it up the line
	return SpawnedProjectile;
}

/**
 * Get the starting penetration power for this FiringMode
 * @param FiringMode: The FiringMode to get penetration power for
 */
simulated event float GetInitialPenetrationPower(byte FiringMode)
{
	local KFPerk InstigatorPerk;
	local float UsedPenetrationPower;
	local KFPlayerController KFPC;

	// Set the initial penetration power for this shot
	if (PenetrationPower.Length > FiringMode)
    {
		UsedPenetrationPower = GetUpgradedPenetration(FiringMode);
    }

	InstigatorPerk = GetPerk();

    // Add in any extra penetration power from the perk
    if ( InstigatorPerk != none && InstantHitDamageTypes.Length > FiringMode && Instigator != none)
    {
    	KFPC = KFPlayerController(Instigator.Controller);
    	if(KFPC != none)
    	{
    		UsedPenetrationPower += InstigatorPerk.GetPenetrationModifier( KFPC.GetLevel(), class<KFDamageType>(InstantHitDamageTypes[FiringMode]) );
    	}
    }

    return UsedPenetrationPower;
}

/**
 * See Pawn.ProcessInstantHit
 * @param DamageReduction: Custom KF parameter to handle penetration damage reduction
 */
simulated function ProcessInstantHitEx(byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum)
{
	local int TotalDamage;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;
	local InterpCurveFloat PenetrationCurve;
    local KFPawn KFP;
    local float InitialPenetrationPower, OriginalPenetrationVal;
    local KFPerk CurrentPerk;
    local bool bNoPenetrationDmgReduction;

	if (MedicComp != none && FiringMode == ALTFIRE_FIREMODE)
	{
		if (MedicComp.ProcessInstantHitEx(Impact))
		{
			return;
		}
	}

	if (Impact.HitActor != None)
	{
        OriginalPenetrationVal = out_PenetrationVal;

        // default damage model is just hits * base damage
		NumHits = Max(NumHits, 1);
		TotalDamage = GetModifiedDamage(FiringMode) * NumHits;

		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( !WorldInfo.bDropDetail && WorldInfo.GetDetailMode() != DM_Low &&
				(HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}
		}
		// Handle PenetrationDamageReduction / DamageModifier if the weapon has penetration
		else if ( Impact.HitActor.bCanBeDamaged && GetInitialPenetrationPower(FiringMode) > 0  )
		{
            if ( out_PenetrationVal <= 0 )
			{
                return;
			}
			else
			{
                CurrentPerk = GetPerk();
                if( CurrentPerk != none )
                {
                	bNoPenetrationDmgReduction = CurrentPerk.IgnoresPenetrationDmgReduction();
				}

                PenetrationCurve = PenetrationDamageReductionCurve[FiringMode];
                if( !bNoPenetrationDmgReduction )
                {
               		TotalDamage *= EvalInterpCurveFloat(PenetrationCurve, out_PenetrationVal/GetInitialPenetrationPower(FiringMode));
               	}

                // Reduce penetration power for every KFPawn penetrated
                KFP = KFPawn(Impact.HitActor);
            	if ( KFP != none )
            	{
                    out_PenetrationVal -= KFP.PenetrationResistance;
            	}
			}
		}

		// The the skill tracking know that we got our initial impact for this shot
		if( KFPawn_Monster(Impact.HitActor) != none )
		{
			if ( KFPlayer != none )
			{
				InitialPenetrationPower = GetInitialPenetrationPower(FiringMode);
				if( InitialPenetrationPower <= 0 || OriginalPenetrationVal == InitialPenetrationPower )
				{
					KFPlayer.AddShotsHit(1);
				}
			}

			if (GetAmmoType(FiringMode) == 0)
			{
				ShotsHit++;
			}
		}

		Impact.HitActor.TakeDamage( TotalDamage, Instigator.Controller,
						Impact.HitLocation, InstantHitMomentum[FiringMode] * Impact.RayDir,
						InstantHitDamageTypes[FiringMode], Impact.HitInfo, self );
	}
}

/**
 * Handle a bullet this weapon has fired for client side hit detection impacting a Pawn
 * see 'InstantFireClient'
 */
simulated function HandleProjectileImpact(byte ProjectileFireMode, ImpactInfo Impact, optional float PenetrationValue)
{
	// local player only for clientside hit detection
	if ( Instigator != None && Instigator.IsLocallyControlled() )
	{
		if ( Instigator.Role < ROLE_Authority )
		{
			SendClientProjectileImpact(ProjectileFireMode, Impact, PenetrationValue);
		}

		ProcessInstantHitEx(ProjectileFireMode, Impact,, PenetrationValue, 0);
	}
}


/**
 * Handle a bullet this weapon has fired for client side hit detection impacting a Pawn
 * see 'InstantFireClient'

 SHOULD BE ONLY USED IN KFPROJ_ARCGENERATORSPHEREBLAST 
 */
simulated function HandleProjectileImpactSpecial(byte ProjectileFireMode, ImpactInfo Impact, Pawn OldInstigator, optional float PenetrationValue)
{
	// local player only for clientside hit detection
	if ( OldInstigator != None )
	{
		if ( Instigator.Role < ROLE_Authority )
		{
			SendClientProjectileImpact(ProjectileFireMode, Impact, PenetrationValue);
		}

		ProcessInstantHitEx(ProjectileFireMode, Impact,, PenetrationValue, 0);
	}
}

/** process local player fragment impact for clientside hit detection */
event RecieveClientFragmentImpact(const out ImpactInfo Impact, class<KFProjectile> Fragment)
{
    ProcessGrenadeProjectileImpact(Impact, Fragment);
}

/**
 * Handle a fragment for client side hit detection impacting a Pawn
 * @param Impact: The hit to process
 * @param Fragment: The type of fragment that impacted
 */
simulated function HandleGrenadeProjectileImpact(ImpactInfo Impact, class<KFProjectile> Fragment)
{
	// local player only for clientside hit detection
	if ( Instigator != None && Instigator.IsLocallyControlled() )
	{
		if ( Instigator.Role < ROLE_Authority )
		{
            SendClientFragmentImpact(Impact,Fragment);
		}

		ProcessGrenadeProjectileImpact(Impact, Fragment);
	}
}

/**
 * Process the damage for a grenade fragment impact
 * @param Impact: The hit to process
 * @param Fragment: The type of fragment that impacted
 */
simulated function ProcessGrenadeProjectileImpact(ImpactInfo Impact, class<KFProjectile> Fragment)
{
	local int TotalDamage;
	local KActorFromStatic NewKActor;
	local StaticMeshComponent HitStaticMesh;

	if (Impact.HitActor != None)
	{
		// apply weapon upgrades to the fragment damage
		TotalDamage = GetUpgradedStatValue(Fragment.default.Damage, CurrentFireMode == 0 ? EWUS_Damage0 : EWUS_Damage1, CurrentWeaponUpgradeIndex);
		if ( Impact.HitActor.bWorldGeometry )
		{
			HitStaticMesh = StaticMeshComponent(Impact.HitInfo.HitComponent);
			if ( (HitStaticMesh != None) && HitStaticMesh.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitStaticMesh);
				if ( NewKActor != None )
				{
					Impact.HitActor = NewKActor;
				}
			}
		}

		Impact.HitActor.TakeDamage( TotalDamage, Instigator.Controller,
						Impact.HitLocation, Fragment.default.MomentumTransfer * Impact.RayDir,
						Fragment.default.MyDamageType, Impact.HitInfo, Instigator );
	}
}

/** Can be overridden on a per-weapon or per-state basis */
simulated function bool IsHeavyWeapon();

/*********************************************************************************************
 * @name	Clientside Hit Detection
 *********************************************************************************************/

// Create RPC's of various sizes since we can't replicate dynamic arrays.  Don't need to be too exact here
// as there is only a small overhead for calling another RPC (e.g. 2 + 8 = 10)
// see https://udn.unrealengine.com/questions/158710/efficient-array-replication.html
reliable server final private native event ServerRegisterImpact1(byte FiringMode, ImpactRepInfo NetImpact);
reliable server final private native event ServerRegisterImpact2(byte FiringMode, ImpactRepInfo NetImpacts[2]);
reliable server final private native event ServerRegisterImpact3(byte FiringMode, ImpactRepInfo NetImpacts[3]);
reliable server final private native event ServerRegisterImpact4(byte FiringMode, ImpactRepInfo NetImpacts[4]);
reliable server final private native event ServerRegisterImpact5(byte FiringMode, ImpactRepInfo NetImpacts[5]);
reliable server final private native event ServerRegisterImpact6(byte FiringMode, ImpactRepInfo NetImpacts[6]);
reliable server final private native event ServerRegisterImpact7(byte FiringMode, ImpactRepInfo NetImpacts[7]);
reliable server final private native event ServerRegisterImpact8(byte FiringMode, ImpactRepInfo NetImpacts[8]);
reliable server final private native event ServerRegisterProjectileImpact(byte FiringMode, ImpactRepInfo NetImpact, optional byte PenetrationByte);
// special ammo types
reliable server final private native event ServerRegisterProjectileExplosion(vector ExplosionLocation, KFProjectile ExplodingProjectile);
reliable server final private native event ServerRegisterFragmentImpact(ImpactRepInfo NetImpact, class<KFProjectile> FragmentClass);

// Compress our impact into a ImpactRepInfo for replication (returns number of impacts sent)
simulated protected native function int SendClientImpactList(byte FiringMode, const array<ImpactInfo> ImpactList);
// Same as SendClientImpactList, but recieves a single impact with a penetration value
simulated protected native function int SendClientProjectileImpact(byte FiringMode, const out ImpactInfo Impact, float PenetrationFloat);
// Replicate a projectile explosion to the server
simulated protected native function int SendClientProjectileExplosion(vector ExplosionLocation, KFProjectile ExplodingProjectile);
// Compress our fragment impact into a ImpactRepInfo for replication (returns number of impacts sent)
simulated protected native function int SendClientFragmentImpact(const out ImpactInfo Impact, class<KFProjectile> FragmentClass);
simulated protected native function vector GetSafeStartTraceLocation();
simulated native function Actor DoTraceNative(out Vector OutLocation, Vector StartLocation, Vector EndLocation);
/**
 * Allows subclass to perform extra bullet traces
 * Network: Local Player
 */
simulated function InstantFireClient_AddImpacts(vector StartTrace, rotator Aim, out array<ImpactInfo> ImpactList);

/**
 * Performs an 'Instant Hit' shot.
 * Network: Local Player and Server
 */
simulated function InstantFireClient()
{
	local vector			StartTrace, EndTrace;
	local rotator			AimRot;
	local Array<ImpactInfo>	ImpactList;
	local int				Idx;
	local ImpactInfo		RealImpact;
	local float				CurPenetrationValue;

	// see Controller AimHelpDot() / AimingHelp()
	bInstantHit = true;

	// define range to use for CalcWeaponFire()
	StartTrace = GetSafeStartTraceLocation();
	AimRot = GetAdjustedAim(StartTrace);
	EndTrace = StartTrace + vector(AimRot) * GetTraceRange();

	bInstantHit = false;

    // Initialize penetration power
    PenetrationPowerRemaining = GetInitialPenetrationPower(CurrentFireMode);
    CurPenetrationValue = PenetrationPowerRemaining;

	// Perform shot
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	// Set flash location to trigger client side effects.  Bypass Weapon.SetFlashLocation since
	// that function is not marked as simulated and we want instant client feedback.
	// ProjectileFire/IncrementFlashCount has the right idea:
	//	1) Call IncrementFlashCount on Server & Local
	//	2) Replicate FlashCount if ( !bNetOwner )
	//	3) Call WeaponFired() once on local player
	if( Instigator != None )
	{
		Instigator.SetFlashLocation( Self, CurrentFireMode, RealImpact.HitLocation );
	}

	// local player only for clientside hit detection
	if ( Instigator != None && Instigator.IsLocallyControlled() )
	{
		// allow weapon to add extra bullet impacts (useful for shotguns)
		InstantFireClient_AddImpacts(StartTrace, AimRot, ImpactList);

		for (Idx = 0; Idx < ImpactList.Length; Idx++)
		{
			ProcessInstantHitEx(CurrentFireMode, ImpactList[Idx],, CurPenetrationValue, Idx);
		}

		if ( Instigator.Role < ROLE_Authority )
		{
            SendClientImpactList(CurrentFireMode, ImpactList);
		}
	}
}

/** process local player impact for clientside hit detection */
event RecieveClientImpact(byte FiringMode, const out ImpactInfo Impact, optional out float PenetrationValue, optional int ImpactNum)
{

	if( FiringMode == BASH_FIREMODE )
	{
		MeleeAttackHelper.ProcessMeleeHit(FiringMode, Impact);
	}
	else
	{
       if( KFPawn_Monster(Impact.HitActor) != none && PenetrationValue < GetInitialPenetrationPower( FiringMode ) )
       {
       		ImpactNum = 1;
       }

       ProcessInstantHitEx(FiringMode, Impact,, PenetrationValue, ImpactNum);
	}
}

/** process local player explosion for clientside explosion handling */
event RecieveClientProjectileExplosion(vector ExplosionLocation, KFProjectile ExplodingProjectile)
{
    // TODO: maybe validate the explosion normal on the client?
    ExplodingProjectile.CallExplode( ExplosionLocation, vect(0,0,1) );
}

/**
 * Replicate client side explosion to server
 */
simulated function HandleClientProjectileExplosion(vector ExplosionLocation, KFProjectile ExplodingProjectile)
{
    SendClientProjectileExplosion(ExplosionLocation, ExplodingProjectile);
}

/** process local player impact for clientside hit detection */
event RecieveClientImpactList(byte FiringMode, array<ImpactInfo> ImpactList)
{
	// deprecated, all impacts go through RecieveClientImpact
}

/*********************************************************************************************
 * @name	Ammunition
 *********************************************************************************************/

 /**
 * Returns which ammo pool a fire mode should pull from, primary or secondary.
 @ param    FiringMode  the fire mode we want to check against
 @ return   the ammo pool we should pull from for the input fire mode
 */
simulated function int GetAmmoType(byte FiringMode)
{
    if( FiringMode == ALTFIRE_FIREMODE && (UsesSecondaryAmmo() || MedicComp != none) )
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

 /**
 * Returns true if this weapon uses a secondary ammo pool
 */
static simulated event bool UsesAmmo()
{
    return default.SpareAmmoCapacity[0] > 0;
}

 /**
 * Returns true if this weapon uses a secondary ammo pool
 */
static simulated event bool UsesSecondaryAmmo()
{
    return default.MagazineCapacity[1] > 0;
}

static simulated event bool UsesAltSecondaryAmmo()
{
	return default.bUsesSecondaryAmmoAltHUD;
}

 /**
 * Returns true if this weapon uses greandes as secondary ammo
 */
static simulated event bool UsesGrenadesAsSecondaryAmmo()
{
    return default.bUseGrenadeAsSecondaryAmmo;
}

 /**
 * Returns true if this weapon uses a secondary ammo pool
 */
static simulated event bool CanRefillSecondaryAmmo()
{
 	return UsesSecondaryAmmo() && default.bCanRefillSecondaryAmmo;
}

/**
 * Initializes ammo counts, when weapon is spawned.
 */
function InitializeAmmo()
{
	local KFPerk CurrentPerk;

	InitializeAmmoCapacity();

	AmmoCount[0] = MagazineCapacity[0];
	AmmoCount[1] = MagazineCapacity[1];

	AddAmmo(default.InitialSpareMags[0] * default.MagazineCapacity[0]);

	CurrentPerk = GetPerk();
	if (CurrentPerk != none)
	{
		CurrentPerk.ModifySpareAmmoAmount(self, SpareAmmoCount[DEFAULT_FIREMODE]);
		CurrentPerk.ModifySpareAmmoAmount(self, SpareAmmoCount[ALTFIRE_FIREMODE], , true);
	}

	// HACK: Finalize our spare ammo values
	AddAmmo(0);

	bForceNetUpdate	= TRUE;
}

 /**
  * @brief Re-initializes ammo counts after perk and/or perk skills has/have changed.
  */
function ReInitializeAmmoCounts(KFPerk CurrentPerk)
{
	if( CurrentPerk != none )
	{
		MagazineCapacity[0]		= default.MagazineCapacity[0];
		MagazineCapacity[1]		= default.MagazineCapacity[1];
		SpareAmmoCapacity[0]	= default.SpareAmmoCapacity[0];
		SpareAmmoCapacity[1]	= default.SpareAmmoCapacity[1];

		InitializeAmmoCapacity(, CurrentPerk);

		// We don't want to modify current ammo, but spare ammo should respect perk and level
		AddAmmo(0);
	}
}

/**
 * @see Weapon::ConsumeAmmo
 */
simulated function ConsumeAmmo( byte FireModeNum )
{
    local byte AmmoType;
    local KFPerk InstigatorPerk;

`if(`notdefined(ShippingPC))
    if( bInfiniteAmmo )
    {
        return;
    }
`endif

	AmmoType = GetAmmoType(FireModeNum);

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none && InstigatorPerk.GetIsUberAmmoActive( self ) )
	{
		return;
	}

	// If AmmoCount is being replicated, don't allow the client to modify it here
	if ( Role == ROLE_Authority || bAllowClientAmmoTracking )
	{
	    // Don't consume ammo if magazine size is 0 (infinite ammo with no reload)
		if (MagazineCapacity[AmmoType] > 0 && AmmoCount[AmmoType] > 0)
		{
			// Ammo cost needs to be firemodenum because it is independent of ammo type.
			AmmoCount[AmmoType] = Max(AmmoCount[AmmoType] - AmmoCost[FireModeNum], 0);
		}
	}
}

/**
 * @see Weapon::AddAmmo
 */
function int AddAmmo(int Amount)
{
	local int OldSpareAmmo;

	// If we can't accept spare ammo, then abort
	if( GetMaxAmmoAmount(0) <= 0 )
	{
		return 0;
	}

	`log(self@"Add Amount =" @ Amount, bLogAmmo);
	`log(self@"SpareAmmoCapacity[0] =" @ GetMaxAmmoAmount(0), bLogAmmo);
	`log(self@"SpareAmmoCount[0] =" @ SpareAmmoCount[0], bLogAmmo);
	`log(self@"AmmoCount[0] =" @ AmmoCount[0], bLogAmmo);

	OldSpareAmmo = SpareAmmoCount[0];
	SpareAmmoCount[0]	= Min(SpareAmmoCount[0] + Amount, GetMaxAmmoAmount(0) - AmmoCount[0]);
	bForceNetUpdate	= TRUE;

	`log(self@"SpareAmmoCount[0] AFTER =" @ SpareAmmoCount[0], bLogAmmo);
	`log(self@"Added" @ SpareAmmoCount[0] - OldSpareAmmo @ "Ammo", bLogAmmo);

	return SpareAmmoCount[0] - OldSpareAmmo;
}

/** Add primary and secondary ammo to weapon based on trader transactions. Amounts could be negative. */
function AddTransactionAmmo( int TransactionPrimaryAmmo, int TransactionSecondaryAmmo )
{
	local int SpareAmmoToAdd, ExtraTransactionAmmo;

	if( TransactionPrimaryAmmo >= 0 )
	{
		AddAmmo( TransactionPrimaryAmmo );
	}
	else
	{
		// only subtract as much spare ammo as the gun actually has
		// (the passed-in values are from the trader/UI and include default spare and main ammo)
		SpareAmmoToAdd = Max( -SpareAmmoCount[0], TransactionPrimaryAmmo );

		// if there isn't enough spare ammo to subtract, keep track of the extra and subtract it from the main ammo
		ExtraTransactionAmmo = TransactionPrimaryAmmo - SpareAmmoToAdd;

		// subtract from spare ammo
		AddAmmo( SpareAmmoToAdd );

		// subtract any extra from ammo
		AmmoCount[0] = Max( 0, AmmoCount[0] + ExtraTransactionAmmo );

		ClientForceAmmoUpdate(AmmoCount[0], SpareAmmoCount[0]);
	}

	AddSecondaryAmmo( TransactionSecondaryAmmo );
}

/**
 * Add secondary ammo to weapon
 * @param	Amount to add.
 * @return	Amount actually added. (In case magazine is already full and some ammo is left
 *
 */
function int AddSecondaryAmmo(int Amount)
{
	local int OldAmmo;

	// If we can't accept spare ammo, then abort
	if( !CanRefillSecondaryAmmo() )
	{
		return 0;
	}

	OldAmmo = AmmoCount[1];
	AmmoCount[1]	= Min(AmmoCount[1] + Amount, MagazineCapacity[1]);
	bForceNetUpdate	= TRUE;

	// unlike AddAmmo, we're updating AmmoCount directly which if ClientAmmoTracking is enabled
	// will not be replicated.  Needs for replication via RPC
    if( bAllowClientAmmoTracking )
    {
        ClientForceSecondaryAmmoUpdate(AmmoCount[1]);
    }

	return AmmoCount[1] - OldAmmo;
}

/**
 * Force client to match server ammo counts
 *
 * @param	bAmmoSync	- If performing a sync the lowest value is typically the most correct
 */
reliable client function ClientForceAmmoUpdate(byte NewAmmoCount, int NewSpareAmmoCount, optional bool bAmmoSync)
{
	if ( Role < ROLE_Authority )
	{
		if ( bAmmoSync )
		{
			// detect sync errors
			`log(self@GetFuncName()@"ServerAmmo Primary:"$NewAmmoCount@"ClientAmmo Primary:"$AmmoCount[0]@"ServerSpareAmmo Primary:"$NewSpareAmmoCount@"ClientSpareAmmo Primary:"$SpareAmmoCount[0], bDebug);
			if ( NewAmmoCount != AmmoCount[0] )
			{
				`log(self@GetFuncName()@"Primary Ammo mismatch Server:"$NewAmmoCount@"Client:"$AmmoCount[0]);
			}
			if ( NewSpareAmmoCount != SpareAmmoCount[0] )
			{
				`log(self@GetFuncName()@"Primary SpareAmmo mismatch Server:"$NewSpareAmmoCount@"Client:"$SpareAmmoCount[0]);
			}

			AmmoCount[0] = Min(NewAmmoCount, AmmoCount[0]);
			SpareAmmoCount[0] = Min(NewSpareAmmoCount, SpareAmmoCount[0]);
		}
		else
		{
			AmmoCount[0] = NewAmmoCount;
			SpareAmmoCount[0] = NewSpareAmmoCount;
		}
		NotifyHUDofWeapon(Pawn(Owner));
	}
}

/** Force client to match server secondary ammo counts */
reliable client function ClientForceSecondaryAmmoUpdate(byte NewSecondaryAmmoCount)
{
	if ( Role < ROLE_Authority )
	{
		// detect sync errors
		`log(self@GetFuncName()@"ServerAmmo Secondary:"$NewSecondaryAmmoCount@"ClientAmmo Secondary:"$AmmoCount[1], bDebug);
		if ( NewSecondaryAmmoCount != AmmoCount[1] )
		{
			`log(self@GetFuncName()@"Secondary Ammo mismatch Server:"$NewSecondaryAmmoCount@"Client:"$AmmoCount[1]);
		}
		AmmoCount[1] = NewSecondaryAmmoCount;
		NotifyHUDofWeapon(Pawn(Owner));
	}
}

/** Notify the client that their weapon has been picked up and ready to show */
unreliable client function NotifyHUDofWeapon( Pawn P )
{
	local KFPlayerController KFPC;

	if ( Role < ROLE_Authority )
	{
		KFPC = KFPlayerController(P.Owner);

		if(KFPC != none && KFPC.MyGFxHUD != none)
		{
			KFPC.MyGFxHUD.NotifyHUDofWeapon();
		}
	}
}

/**
 * @see Weapon::HasAmmo
 */
simulated event bool HasAmmo( byte FireModeNum, optional int Amount )
{
	local KFPerk InstigatorPerk;
	// we can always do a melee attack
	if( FireModeNum == BASH_FIREMODE )
	{
		return TRUE;
	}
	else if ( FireModeNum == RELOAD_FIREMODE )
	{
		return CanReload();
	}
	else if ( FireModeNum == GRENADE_FIREMODE )
	{
        if( KFInventoryManager(InvManager) != none )
        {
            return KFInventoryManager(InvManager).HasGrenadeAmmo(Amount);
        }
	}

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none && InstigatorPerk.GetIsUberAmmoActive( self ) )
	{
		return true;
	}

	// If passed in ammo isn't set, use default ammo cost.
	if( Amount == 0 )
	{
		Amount = AmmoCost[FireModeNum];
	}

	return AmmoCount[GetAmmoType(FireModeNum)] >= Amount;
}

/**
 * @see Weapon::HasAnyAmmo
 */
simulated function bool HasAnyAmmo()
{
	if ( HasSpareAmmo() || HasAmmo(DEFAULT_FIREMODE) )
	{
		return true;
	}

	if (MedicComp != none)
	{
		return false;
	}

    if( UsesSecondaryAmmo() && (HasSpareAmmo(ALTFIRE_FIREMODE) || HasAmmo(ALTFIRE_FIREMODE) ))
    {
		return true;
	}

	return false;
}

/** Returns true if spare ammo is available (outside of current magazine) */
simulated event bool HasSpareAmmo(optional byte FireModeNum)
{
	return (bInfiniteSpareAmmo || SpareAmmoCount[GetAmmoType(FireModeNum)] > 0);
}

simulated event int GetTotalAmmoAmount(byte FiringMode)
{
	return AmmoCount[GetAmmoType(FiringMode)] + SpareAmmoCount[GetAmmoType(FiringMode)];
}

simulated event int GetMaxAmmoAmount(byte FiringMode)
{
	return SpareAmmoCapacity[GetAmmoType(FiringMode)] + MagazineCapacity[GetAmmoType(FiringMode)];
}

simulated event int GetMissingSpareAmmoAmount(byte FiringMode)
{
    return SpareAmmoCapacity[GetAmmoType(FiringMode)] - SpareAmmoCount[GetAmmoType(FiringMode)];
}

simulated function float GetAmmoPercentage(optional byte FiringMode)
{
	if( SpareAmmoCapacity[GetAmmoType(FiringMode)] == 0 )
	{
		return -1.f;
	}

	return float(GetTotalAmmoAmount(FiringMode)) / float(GetMaxAmmoAmount(FiringMode));
}

/** Determines the ammo left in magazine for HUD display */
simulated function int GetSpareAmmoForHUD()
{
    return SpareAmmoCount[0];
}

/** Determines string used to display non-standard ammo for HUD display */
simulated function string GetSpecialAmmoForHUD();

/** Determines the secondary ammo left for HUD display */
simulated function int GetSecondaryAmmoForHUD()
{
    return AmmoCount[1] + SpareAmmoCount[1];
}

/** Determines the secondary spare ammo  */
simulated function int GetSecondarySpareAmmoForHUD()
{
	return -1;
}

/** Determines if we have to reload the secondary ammo of the weapon (EX: m16 grenades)  */
simulated function bool HasToReloadSecondaryAmmoForHUD()
{
	return AmmoCount[1] == 0;
}

/**
 * Called by Player to force current weapon to be reloaded
 * NOTE: A reload will only begin once the weapons FireInterval has completed
 * Network: LocalPlayer
 */
simulated function bool ForceReload()
{
	// Make sure it's called for a locally controlled pawn.
	if (Instigator != None && Instigator.IsLocallyControlled())
	{
		// if we can reload,
		if( CanReload() )
		{
			StartFire(RELOAD_FIREMODE);
			return true;
		}
	}

	return false;
}

/** Returns true if weapon can potentially be reloaded */
simulated function bool CanReload(optional byte FireModeNum)
{
	local KFPawn	P;
	local bool		bInstigatorCanReload;
	local byte		AmmoType;

	P = KFPawn(Instigator);

	AmmoType = GetAmmoType(FireModeNum);

	// Cannot reload weapon when doing a special move
	bInstigatorCanReload = (P != None && P.CanReloadWeapon());

	return(	bCanBeReloaded                       &&	// Weapon can be reloaded
			bInstigatorCanReload                 &&	// Instigator can reload weapon
			AmmoCount[AmmoType] < MagazineCapacity[AmmoType]   &&	// we fired at least a shot
			HasSpareAmmo(AmmoType)					// and we have more ammo to fill current magazine
			);
}

/** Returns true if weapon should be auto-reloaded */
simulated function bool ShouldAutoReload(byte FireModeNum)
{
    local bool bHasAmmo;

    bHasAmmo = HasAmmo(FireModeNum);

    // do dry fire or auto switch
    if( !bHasAmmo && Instigator != none && Instigator.IsLocallyControlled() )
    {
		if ( bPendingAutoSwitchOnDryFire )
		{
			if( CanSwitchWeapons() )
			{
                if ( !HasAnyAmmo() )
    			{
    				Instigator.Controller.ClientSwitchToBestWeapon(false);
    			}
			}

			bPendingAutoSwitchOnDryFire = false;
		}
		else
		{
			WeaponPlaySound(WeaponDryFireSnd[FireModeNum]);
			if( Role < ROLE_Authority )
			{
				ServerPlayDryFireSound(FireModeNum);
			}
			bPendingAutoSwitchOnDryFire = !HasAnyAmmo();
		}
    }

	return !bHasAmmo && CanReload();
}

simulated function bool ShouldAutoReloadGunslinger( byte FireModeNum )
{
    local KFPerk InstigatorPerk;
    local KFWeapon NewWeapon;
    local KFInventoryManager KFIM;
    local bool bHasAmmo;

    bHasAmmo = HasAmmo( FireModeNum );

	InstigatorPerk = GetPerk();
	if( !bHasAmmo &&  CanSwitchWeapons() && InstigatorPerk != none &&
		InstigatorPerk.ShouldInstantlySwitchWeapon( self ) )
	{
		KFIM = KFInventoryManager(InvManager);
		if( KFIM != none )
		{
			NewWeapon = KFIM.GetBestPerkWeaponWithAmmo( InstigatorPerk.class, true );
			if( NewWeapon != none )
			{
				KFIM.SetCurrentWeapon( NewWeapon );
				return false;
			}
		}
	}

    // do dry fire or auto switch
    if( !bHasAmmo && Instigator != none && Instigator.IsLocallyControlled() )
    {
		if( bPendingAutoSwitchOnDryFire )
		{
			if( CanSwitchWeapons() )
			{
                if( !HasAnyAmmo() )
    			{
    				Instigator.Controller.ClientSwitchToBestWeapon(false);
    			}
			}

			bPendingAutoSwitchOnDryFire = false;
		}
		else
		{
			WeaponPlaySound( WeaponDryFireSnd[FireModeNum] );

			if( Role < ROLE_Authority )
			{
				ServerPlayDryFireSound(FireModeNum);
			}
			bPendingAutoSwitchOnDryFire = !HasAnyAmmo();
		}
    }

	return !bHasAmmo && CanReload();
}

/** Play the dry fire sound on the server */
reliable server protected function ServerPlayDryFireSound(byte FireModeNum)
{
    WeaponPlaySound(WeaponDryFireSnd[FireModeNum]);
}

/*********************************************************************************************
 * @name	Rendering Methods
********************************************************************************************* */

/** Set the lighting channels on all the appropriate weapon meshes */
simulated function SetMeshLightingChannels(LightingChannelContainer NewLightingChannels)
{
	Mesh.SetLightingChannels(NewLightingChannels);

	if( LaserSight != none )
	{
	   LaserSight.SetMeshLightingChannels(NewLightingChannels);
	}
}

/*********************************************************************************************
 * @name	Debug info
 *********************************************************************************************/

/**
 * list important Weapon variables on canvas.  HUD will call DisplayDebug() on the current ViewTarget when
 * the ShowDebug exec is used
 *
 * @param	HUD		- HUD with canvas to draw on
 * @input	out_YL		- Height of the current font
 * @input	out_YPos	- Y position on Canvas. out_YPos += out_YL, gives position to draw text for next debug line.
 */

simulated function GetWeaponDebug( out Array<String> DebugInfo )
{
	super.GetWeaponDebug( DebugInfo );

	DebugInfo[DebugInfo.Length] = "AmmoCount Primary:" $ AmmoCount[0] @ "MagazineSize Primary:" $ MagazineCapacity[0];
	DebugInfo[DebugInfo.Length] = "SpareAmmoCount Primary:" $ SpareAmmoCount[0] @ "SpareAmmoCapacity Primary:" $ GetMaxAmmoAmount(0);
	DebugInfo[DebugInfo.Length] = "AmmoCount Secondary:" $ AmmoCount[1] @ "MagazineSize Secondary:" $ MagazineCapacity[1];
	if( KFInventoryManager(InvManager) != none )
	{
		DebugInfo[DebugInfo.Length] = "GrenadeCount:" $ KFInventoryManager(InvManager).GrenadeCount @ "MaxGrenades:" $ GetPerk().MaxGrenadeCount;
	}
}

/**
 * list important LFWeapon variables on canvas.  HUD will call DisplayDebug() on the current ViewTarget when
 * the ShowDebug exec is used
 *
 * @param	HUD		- HUD with canvas to draw on
 * @input	out_YL		- Height of the current font
 * @input	out_YPos	- Y position on Canvas. out_YPos += out_YL, gives position to draw text for next debug line.
 */
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local string CurAnim, CurHandAnim;
	// Recoil Debugging
	local vector FADebugLineStart,FADebugLineEnd,FADebugLineUL,FADebugLineUR,FADebugLineLL,FADebugLineLR;
	local rotator FADebugLineRot, FADebugViewRotation;
	local int UsedMaxYawLimit, UsedMaxPitchLimit, UsedMinYawLimit, UsedMinPitchLimit;
	local Rotator AimRotation, WeaponBufferRot;

	super.DisplayDebug(HUD, out_YL, out_YPos);

	if (HUD.ShouldDisplayDebug('Camera'))
	{
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText("---------- KFWeapon: Camera ----------");
		out_YPos += out_YL;

		HUD.Canvas.DrawText("WEAPONCAMERA MeshFOV="$MeshFOV @ "MeshIronSightFOV="$MeshIronSightFOV @ "CameraIronSightFOV="$PlayerIronSightFOV @" CurrentMeshFOV = "$MySkelMesh.FOV);
		out_YPos += out_YL;
		HUD.Canvas.SetPos(4, out_YPos);
	}

	if (HUD.ShouldDisplayDebug('Zooming'))
	{
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText("---------- KFWeapon: Zooming ----------");
		out_YPos += out_YL;

		HUD.Canvas.DrawText("ZOOMING ZoomRotInterp="$ZoomRotInterp @ "bDoingQuickDownZoom="$bDoingQuickDownZoom @ "QuickWeaponDownRotation="$QuickWeaponDownRotation @" ZoomInRotation = "$ZoomInRotation$" PlayerViewOffset= "$PlayerViewOffset);
		out_YPos += out_YL;
		HUD.Canvas.SetPos(4, out_YPos);
	}

	if (HUD.ShouldDisplayDebug('FireOffset'))
	{
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText("---------- KFWeapon: FireOffset ----------");
		out_YPos += out_YL;

		HUD.Canvas.DrawText("PROJECTILE SPAWNING FireOffset="$FireOffset);
		out_YPos += out_YL;
		HUD.Canvas.SetPos(4, out_YPos);

		if(Instigator.IsFirstPerson())
		{
            HUD.DrawDebugSphere( GetMuzzleLoc(), 3, 6, 255, 0, 0 );
		}
		else
		{
            if( CurrentFireMode == GRENADE_FIREMODE )
            {
                HUD.DrawDebugSphere( (Instigator.GetPawnViewLocation() + (GrenadeFireOffset >> Instigator.Rotation)), 3, 6, 0, 255, 0 );
            }
            else
            {
                HUD.DrawDebugSphere( (Instigator.GetPawnViewLocation() + (FireOffset >> Instigator.Rotation)), 3, 6, 255, 0, 0 );
            }
		}
	}

	if (HUD.ShouldDisplayDebug('animation'))
	{
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText("---------- KFWeapon: animation ----------");
		out_YPos += out_YL;

		if ( GetWeaponAnimNodeSeq() != none )
		{
			CurAnim = string(GetWeaponAnimNodeSeq().AnimSeqName);

			HUD.Canvas.DrawText("WEAPON WeaponAnim="$CurAnim$" Rate: "$GetWeaponAnimNodeSeq().Rate$" Position: "$GetWeaponAnimNodeSeq().CurrentTime);
			out_YPos += out_YL;
			HUD.Canvas.SetPos(4, out_YPos);
		}
		if ( GetArmAnimNodeSeq() != none )
		{
			CurHandAnim = string(GetArmAnimNodeSeq().AnimSeqName);

			HUD.Canvas.DrawText("WEAPON HandAnim="$CurHandAnim$" Rate: "$GetArmAnimNodeSeq().Rate$" Position: "$GetArmAnimNodeSeq().CurrentTime);
			out_YPos += out_YL;
			HUD.Canvas.SetPos(4, out_YPos);
		}
	}

	if (HUD.ShouldDisplayDebug('aim3d'))
	{
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText("---------- KFWeapon: aim3d ----------");
		out_YPos += out_YL;

		if( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).GetPlayerViewPoint(FADebugLineStart, AimRotation);
		}

    	if( bDebugRecoilPosition )
    	{
            WeaponBufferRot.Pitch = RecoilISMaxPitchLimit;
            WeaponBufferRot.Yaw += TotalRecoilRotator.Yaw;
            WeaponBufferRot.Pitch += TotalRecoilRotator.Pitch;
    	}
    	else
    	{
            WeaponBufferRot = KFPlayerController(Instigator.Controller).WeaponBufferRotation;
    	}


		FADebugLineRot.Yaw = AimRotation.Yaw + WeaponBufferRot.Yaw;
		FADebugLineRot.Pitch = AimRotation.Pitch + WeaponBufferRot.Pitch;

		FADebugLineEnd = FADebugLineStart + 400 * vector(FADebugLineRot);
		DrawDebugSphere(FADebugLineEnd, 5, 8, 0,255,0, false);
	}

	if (HUD.ShouldDisplayDebug('recoil3d'))
	{
		HUD.Canvas.SetPos(4,out_YPos);
		HUD.Canvas.DrawText("---------- KFWeapon: recoil3d ----------");
		out_YPos += out_YL;

		if( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).GetPlayerViewPoint(FADebugLineStart, FADebugViewRotation);
		}

		// Draw where the weapon is currently recoiling to
		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + TotalRecoilRotator.Yaw;
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + TotalRecoilRotator.Pitch;
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		DrawDebugBox(FADebugLineEnd, vect(0.1,0.1,0.1), 255,255,0, false);

		// Draw where the free-aim buffer is currently at
		FADebugLineRot.Yaw = FADebugViewRotation.Yaw;
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch;
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		DrawDebugBox(FADebugLineEnd, vect(0.1,0.1,0.1), 255,0,128, false);


		// Draw where the recoil limits are
		if( bUsingSights )
		{
			UsedMaxYawLimit = RecoilISMaxYawLimit;
			UsedMinYawLimit = RecoilISMinYawLimit;
			UsedMaxPitchLimit = RecoilISMaxPitchLimit;
			UsedMinPitchLimit = RecoilISMinPitchLimit;
		}
		else
		{
			UsedMaxYawLimit = RecoilMaxYawLimit;
			UsedMinYawLimit = RecoilMinYawLimit;
			UsedMaxPitchLimit = RecoilMaxPitchLimit;
			UsedMinPitchLimit = RecoilMinPitchLimit;
		}

		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + UsedMinYawLimit;
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + UsedMaxPitchLimit;
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		FADebugLineUL = FADebugLineEnd;

		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + UsedMaxYawLimit;
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + UsedMaxPitchLimit;
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		FADebugLineUR = FADebugLineEnd;

		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + UsedMinYawLimit;
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + UsedMinPitchLimit;
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		FADebugLineLL = FADebugLineEnd;

		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + UsedMaxYawLimit;
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + UsedMinPitchLimit;
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		FADebugLineLR = FADebugLineEnd;

		DrawDebugLine(FADebugLineUL,FADebugLineUR, 255,0,255,false);
		DrawDebugLine(FADebugLineUR,FADebugLineLR, 255,0,255,false);
		DrawDebugLine(FADebugLineLR,FADebugLineLL, 255,0,255,false);
		DrawDebugLine(FADebugLineLL,FADebugLineUL, 255,0,255,false);

		// Draw where the full recoil starts to blend in
		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + (UsedMinYawLimit + ((65535-UsedMinYawLimit) * (1.0 - FullRecoilYawPct)));
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + UsedMaxPitchLimit * FullRecoilPitchPct;
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		FADebugLineUL = FADebugLineEnd;

		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + UsedMaxYawLimit * FullRecoilYawPct;
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + UsedMaxPitchLimit * FullRecoilPitchPct;
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		FADebugLineUR = FADebugLineEnd;

		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + (UsedMinYawLimit + ((65535-UsedMinYawLimit) * (1.0 - FullRecoilYawPct)));
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + (UsedMinPitchLimit + ((65535-UsedMinPitchLimit) * (1.0 - FullRecoilYawPct)));
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		FADebugLineLL = FADebugLineEnd;

		FADebugLineRot.Yaw = FADebugViewRotation.Yaw + UsedMaxYawLimit * FullRecoilYawPct;
		FADebugLineRot.Pitch = FADebugViewRotation.Pitch + (UsedMinPitchLimit + ((65535-UsedMinPitchLimit) * (1.0 - FullRecoilYawPct)));
		FADebugLineEnd = FADebugLineStart + 20 * vector(FADebugLineRot);
		FADebugLineLR = FADebugLineEnd;

		DrawDebugLine(FADebugLineUL,FADebugLineUR, 128,255,255,false);
		DrawDebugLine(FADebugLineUR,FADebugLineLR, 128,255,255,false);
		DrawDebugLine(FADebugLineLR,FADebugLineLL, 128,255,255,false);
		DrawDebugLine(FADebugLineLL,FADebugLineUL, 128,255,255,false);
	}
}

/*********************************************************************************************
 * @name	Perks
********************************************************************************************* */
simulated static event class<KFPerk> GetWeaponPerkClass( class<KFPerk> InstigatorPerkClass )
{
	if( default.AssociatedPerkClasses.Length > 1 )
	{
        if (default.AssociatedPerkClasses.Find(InstigatorPerkClass) != INDEX_NONE)
        {
            return InstigatorPerkClass;
        }
	}

	return default.AssociatedPerkClasses[0];
}

simulated static function bool AllowedForAllPerks()
{
    return false;
}

static event array< Class<KFPerk> > GetAssociatedPerkClasses()
{
	return default.AssociatedPerkClasses;
}

simulated static event class<KFPerk> GetWeaponPerkClassByIndex(int Index)
{
	return default.AssociatedPerkClasses[Index];
}

simulated static function bool IsMultiPerkWeapn()
{
	return default.AssociatedPerkClasses.Length > 1;
}

/*********************************************************************************************
 * @name	States
********************************************************************************************* */

/** Gets a weapon state identifier for third person anims */
simulated function byte GetWeaponStateId()
{
	return WEP_Idle;
}

/** Gets the current animation rate, scaled or not */
simulated function float GetThirdPersonAnimRate()
{
	return 1.0f;
}

/** Sets the animation rate on the (human) owner for 3rd person anim syncing */
simulated function UpdateWeaponAttachmentAnimRate( float Rate )
{
	local KFPawn_Human KFPH;

	KFPH = KFPawn_Human( Instigator );
	if( KFPH != none )
	{
		KFPH.SetWeaponAttachmentAnimRateByte( Rate );
	}
}

/** Register new state with owning pawn */
simulated function NotifyBeginState()
{
	UpdateWeaponAttachmentAnimRate( GetThirdPersonAnimRate() );
	KFPawn(Instigator).WeaponStateChanged(GetWeaponStateId());
}

/** Register new state with owning pawn */
simulated function NotifyEndState()
{
	UpdateWeaponAttachmentAnimRate( 1.0f );
	KFPawn(Instigator).WeaponStateChanged(WEP_Idle);
}

/*********************************************************************************************
* @name	Weapon Upgrades
********************************************************************************************* */

function bool CanUpgradeWeapon()
{
	`log(self @ "-" @ GetFuncName() @ "- CurrentWeaponUpgradeIndex + 1:" @ (CurrentWeaponUpgradeIndex + 1) @ "WeaponUpgrades.length:" @ WeaponUpgrades.length, bLogWeaponUpgrade);
	return CurrentWeaponUpgradeIndex + 1 < WeaponUpgrades.length;
}

simulated function UpgradeWeapon()
{
	if(CanUpgradeWeapon())
	{
		SetWeaponUpgradeLevel(CurrentWeaponUpgradeIndex + 1);
	}
}

simulated function SetWeaponUpgradeLevel(int WeaponUpgradeLevel)
{
	`log(self @ "-" @ GetFuncName() @ "- Setting Upgrade Index to" @ WeaponUpgradeLevel, bLogWeaponUpgrade);
	CurrentWeaponUpgradeIndex = WeaponUpgradeLevel;

	InitializeAmmoCapacity();

	bNetDirty = TRUE;
}

simulated function InitializeAmmoCapacity(optional int UpgradeIndex = INDEX_NONE, optional KFPerk CurrentPerk)
{
	ModifyMagSizeAndNumber(MagazineCapacity[DEFAULT_FIREMODE], DEFAULT_FIREMODE, UpgradeIndex, CurrentPerk);
	ModifyMagSizeAndNumber(MagazineCapacity[ALTFIRE_FIREMODE], ALTFIRE_FIREMODE, UpgradeIndex, CurrentPerk);

	ModifySpareAmmoCapacity(SpareAmmoCapacity[DEFAULT_FIREMODE], DEFAULT_FIREMODE, UpgradeIndex, CurrentPerk);
	ModifySpareAmmoCapacity(SpareAmmoCapacity[ALTFIRE_FIREMODE], ALTFIRE_FIREMODE, UpgradeIndex, CurrentPerk);
}

simulated static function GetUpgradeStatInc(EWeaponUpgradeStat Stat, int UpgradeIndex, out float OutScale, out int OutAdd)
{
	local int i;

	OutScale = 1.f;
	OutAdd = 0;

	if (UpgradeIndex < 0 || UpgradeIndex >= default.WeaponUpgrades.Length)
	{
		`warn(default.Class$"::GetUpgradeStatInc - UpgradeIndex "$UpgradeIndex$" is out of range (WeaponUpgrades.Length is "$default.WeaponUpgrades.Length$"). Returning unmodified input values.", default.bLogWeaponUpgrade);
		return;
	}

	for (i = 0; i < default.WeaponUpgrades[UpgradeIndex].Stats.Length; ++i)
	{
		if (default.WeaponUpgrades[UpgradeIndex].Stats[i].Stat == Stat)
		{
			OutScale = default.WeaponUpgrades[UpgradeIndex].Stats[i].Scale;
			OutAdd = default.WeaponUpgrades[UpgradeIndex].Stats[i].Add;
			return;
		}
	}

	`warn(default.Class$"::GetUpgradeStatInc - Could not find stat "$Stat$". Returning default values.", default.bLogWeaponUpgrade);
}

simulated static function float GetUpgradeStatScale(EWeaponUpgradeStat Stat, int UpgradeIndex)
{
	local float StatScale;
	local int StatAdd;
	GetUpgradeStatInc(Stat, UpgradeIndex, StatScale, StatAdd);
	return StatScale;
}

simulated static function int GetUpgradeStatAdd(EWeaponUpgradeStat Stat, int UpgradeIndex)
{
	local float StatScale;
	local int StatAdd;
	GetUpgradeStatInc(Stat, UpgradeIndex, StatScale, StatAdd);
	return StatAdd;
}

simulated static function float GetUpgradedStatValue(float InStatVal, EWeaponUpgradeStat Stat, int UpgradeIndex)
{
	local float StatScale;
	local int StatAdd;

	if (UpgradeIndex < 0 || UpgradeIndex >= default.WeaponUpgrades.Length)
	{
		`warn(default.Class$"::GetUpgradedStatValue - UpgradeIndex "$UpgradeIndex$" is out of range (WeaponUpgrades.Length is "$default.WeaponUpgrades.Length$"). Returning unmodified input value.", default.bLogWeaponUpgrade);
		return InStatVal;
	}

	GetUpgradeStatInc(Stat, UpgradeIndex, StatScale, StatAdd);
	return (InStatVal * StatScale) + StatAdd;
}

// Upgrade: Weight

simulated function int GetModifiedWeightValue()
{
	return GetUpgradedStatValue(InventorySize, EWUS_Weight, CurrentWeaponUpgradeIndex);
}

simulated static function int GetDefaultModifiedWeightValue(int UpgradeIndex)
{
	return GetUpgradedStatValue(default.InventorySize, EWUS_Weight, UpgradeIndex);
}

simulated static function int GetUpgradeWeight(int UpgradeIndex)
{
	return GetUpgradeStatAdd(EWUS_Weight, UpgradeIndex);
}

// Upgrade: Damage

simulated function float GetUpgradeDamageMod(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return GetUpgradeStatScale(EWeaponUpgradeStat(EWUS_Damage0 + UpgradeFireModes[FireMode]), UpgradeIndex);
}

simulated function float GetUpgradedDamage(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return int(GetUpgradedStatValue(default.InstantHitDamage[FireMode], EWeaponUpgradeStat(EWUS_Damage0 + UpgradeFireModes[FireMode]), UpgradeIndex));
}

// Upgrade: Heal

simulated static function float GetUpgradeHealMod(int UpgradeIndex)
{
	return GetUpgradeStatScale(EWUS_Heal, UpgradeIndex);
}

// Upgrade: Heal Recharge

simulated static function float GetUpgradeHealRechargeMod(int UpgradeIndex)
{
	return GetUpgradeStatScale(EWUS_HealFullRecharge, UpgradeIndex);
}

// Upgrade: Magazine Capacity

simulated function int GetUpgradedMagCapacity(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return int(GetUpgradedStatValue(default.MagazineCapacity[FireMode], EWeaponUpgradeStat(EWUS_MagCapacity0 + UpgradeFireModes[FireMode]), UpgradeIndex));
}

simulated function ModifyMagSizeAndNumber(out int InMagazineCapacity, optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE, optional KFPerk CurrentPerk)
{
	if (FireMode == BASH_FIREMODE)
	{
		return;
	}
	
	InMagazineCapacity = GetUpgradedMagCapacity(FireMode, UpgradeIndex);

	if (CurrentPerk == none)
	{
		CurrentPerk = GetPerk();
	}

	if (CurrentPerk != none)
	{
		CurrentPerk.ModifyMagSizeAndNumber(self, InMagazineCapacity, AssociatedPerkClasses, FireMode == ALTFIRE_FIREMODE, Class.Name);
	}
}

// Upgrade: Spare Ammo Capacity

simulated function int GetUpgradedSpareAmmoCapacity(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return int(GetUpgradedStatValue(default.SpareAmmoCapacity[FireMode], EWeaponUpgradeStat(EWUS_SpareCapacity0 + UpgradeFireModes[FireMode]), UpgradeIndex));
}

simulated function ModifySpareAmmoCapacity(out int InSpareAmmo, optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE, optional KFPerk CurrentPerk)
{
	if (FireMode == BASH_FIREMODE)
	{
		return;
	}

	InSpareAmmo = GetUpgradedSpareAmmoCapacity(FireMode, UpgradeIndex);

	if (CurrentPerk == none)
	{
		CurrentPerk = GetPerk();
	}

	if (CurrentPerk != none)
	{
		CurrentPerk.ModifyMaxSpareAmmoAmount(self, InSpareAmmo,, FireMode == ALTFIRE_FIREMODE);
	}
}

// Upgrade: Spread

simulated function float GetUpgradedSpread(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return GetUpgradedStatValue(default.Spread[FireMode], EWeaponUpgradeStat(EWUS_Spread0 + UpgradeFireModes[FireMode]), UpgradeIndex);
}

// Upgrade: Penetration

simulated function float GetUpgradedPenetration(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return int(GetUpgradedStatValue(default.PenetrationPower[FireMode], EWeaponUpgradeStat(EWUS_Penetration0 + UpgradeFireModes[FireMode]), UpgradeIndex));
}

// Upgrade: Explosion Radius

simulated function ModifyExplosionRadius(out float InRadius, optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	InRadius = GetUpgradedStatValue(InRadius, EWeaponUpgradeStat(EWUS_ExploRadius0 + UpgradeFireModes[FireMode]), UpgradeIndex);
}

// Upgrade: Reload Speed

simulated function float GetUpgradedReloadRateScale(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return GetUpgradeStatScale(EWeaponUpgradeStat(EWUS_ReloadRate0 + UpgradeFireModes[FireMode]), UpgradeIndex);
}

// Upgrade: Recoil

simulated function float GetUpgradedRecoilModifier(optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	return GetUpgradeStatScale(EWeaponUpgradeStat(EWUS_Recoil0 + UpgradeFireModes[FireMode]), UpgradeIndex);
}

// Upgrade: Melee speed

simulated function ModifyMeleeAttackSpeed(out float InSpeed, optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE, optional KFPerk CurrentPerk)
{
	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	InSpeed = GetUpgradedStatValue(InSpeed, EWeaponUpgradeStat(EWUS_MeleeSpeed0 + UpgradeFireModes[FireMode]), UpgradeIndex);

	if (CurrentPerk == none)
	{
		CurrentPerk = GetPerk();
	}

	if (CurrentPerk != none)
	{
		CurrentPerk.ModifyMeleeAttackSpeed(InSpeed, self);
	}
}

// Upgrade: Afflictions

simulated function float GetUpgradedAfflictionPower(EAfflictionType AfflictionType, float InPower, optional int FireMode = INDEX_NONE, optional int UpgradeIndex = INDEX_NONE)
{
	local EWeaponUpgradeStat BaseAfflictStat;

	if (FireMode == INDEX_NONE)
	{
		FireMode = CurrentFireMode;
	}

	if (UpgradeIndex == INDEX_NONE)
	{
		UpgradeIndex = CurrentWeaponUpgradeIndex;
	}

	// Get the stat index for the affliction type
	// (EWUS_AfflictEmp0 is the first affliction stat, and there are 3 firemodes for each stat)
	BaseAfflictStat = EWeaponUpgradeStat(EWUS_AfflictEmp0 + AfflictionType * 3);

	return GetUpgradedStatValue(InPower, EWeaponUpgradeStat(BaseAfflictStat + UpgradeFireModes[FireMode]), UpgradeIndex);
}

// Upgrade: Block/Parry (implemented in KFWeap_MeleeBase)

static simulated function float GetUpgradedBlockDamageMitigation(int UpgradeIndex);
static simulated function float GetUpgradedParryDamageMitigation(int UpgradeIndex);

/*********************************************************************************************
 * state Inactive
 * This state is the default state.  It needs to make sure Zooming is reset when entering/leaving
 *********************************************************************************************/

auto state Inactive
{
	ignores ForceReload, ShouldAutoReload, AllowIronSights;

	simulated function BeginState(name PreviousStateName)
	{
		// Reset ironsights
		if ( bUsingSights )
		{
			// do this locally and replicate to avoid sync errors w/ bIronSightOnBringUp
			if ( Instigator.IsLocallyControlled() )
			{
				SetIronSights(false);
			}
		}
		else if( !bHasIronSights )
		{
			// If this weapon doesn't have ironsights, clear altfire.  Fixes a bug where
			// when switching to a weapon that does have ironsights it will immediately alt-fire
			ClearPendingFire(ALTFIRE_FIREMODE);
		}

		// Clear pending reload - Fixes an issue where you can set a pending reload while
		// switching weapons and it will carry over to the new weapon.
		ClearPendingFire(RELOAD_FIREMODE);

		// force an update when switching weapons so we can detect sync errors
		if ( bAllowClientAmmoTracking && Role == ROLE_Authority && WorldInfo.TimeSeconds > CreationTime )
		{
			ClientForceAmmoUpdate(AmmoCount[0], SpareAmmoCount[0], true);
			ClientForceSecondaryAmmoUpdate(AmmoCount[1]);
		}

		bPendingAutoSwitchOnDryFire = false;

		Super.BeginState(PreviousStateName);
	}

	/** For weapons, this function starts the Equipping process. */
	simulated function Activate()
	{
		Global.Activate();
		UpdateOutOfAmmoEffects(0.0f);
	}
}

/**
 * Called from PerformReload when bAllowClientAmmoTracking==TRUE
 * This was moved up in the file because it has to be defined before state active
 */
reliable server function ServerSyncReload(int ClientSpareAmmoCount)
{
	local int ClientReloadAmount;

	// Checks the initial spare ammo values on both the server and client, so any ammo received won't throw off the reload.
	if ( bAllowClientAmmoTracking && ClientSpareAmmoCount < InitialReloadSpareAmmo )
	{
		// clamp to spare ammo size
		ClientReloadAmount = Min(InitialReloadSpareAmmo - ClientSpareAmmoCount, InitialReloadSpareAmmo);
		// consume spare ammo
		SpareAmmoCount[0] -= ClientReloadAmount;

		// increment and clamp magazine ammo
		AmmoCount[0] = Min(AmmoCount[0] + ClientReloadAmount, MagazineCapacity[0]);
	}
}

/*********************************************************************************************
 * State Active
 * A Weapon this is being held by a pawn should be in the active state.  In this state,
 * a weapon should loop any number of idle animations, as well as check the PendingFire flags
 * to see if a shot has been fired.
 *********************************************************************************************/

simulated function Activate()
{
	if (!WeaponContentLoaded)
	{
		AttachOnContentLoad = true;
		return;
	}

	// Clear opposite firemode when coming from another weapon, this is required since
	// StopFire() will only clear current firemode when the button is released.
	if ( bUseAltFireMode )
	{
		ClearPendingFire(DEFAULT_FIREMODE);
	}
	else
	{
		ClearPendingFire(ALTFIRE_FIREMODE);
	}

	// The weapon is equipped, attach it to the mesh.
	AttachWeaponTo( Instigator.Mesh );

	// Due to delayed content loading, PostInitAnimTree won't be called (from UnSkeletalComponent::InitAnimTree)
	// before being attached (because component owner will be None). So, if we have a FirstPersonAnimTree
	// but no WeaponAnimSeqNode, call PostInitAnimTree now that we've attached.
	if (MySkelMesh != none && MySkelMesh.bAnimTreeInitialised && WeaponAnimSeqNode == none && Len(FirstPersonAnimTree) > 0)
	{
		PostInitAnimTree(MySkelMesh);
	}

	super.Activate();
}

/** Global defs for active state */
simulated function PlayIdleAnim();
simulated function StartIdleFidgetTimer();
simulated function IdleFidgetTimer();
simulated function bool CanPlayIdleFidget(optional bool bOnReload);
simulated function bool PlayIdleFidgetAnim();
simulated function ANIMNOTIFY_EnableAdditiveBob();

simulated state Active
{
	simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		if ( WorldInfo.NetMode != NM_DedicatedServer )
		{
			PlayIdleAnim();
		}
	}

	simulated function PlayIdleAnim()
	{
		local int IdleIndex;

		if ( Instigator.IsLocallyControlled() )
		{
			if( bUsingSights && IdleSightedAnims.Length > 0 )
			{
				IdleIndex = Rand(IdleSightedAnims.Length);
				PlayAnimation(IdleSightedAnims[IdleIndex], 0.0, true, 0.1);
			}
			else if ( IdleAnims.Length > 0 )
			{
				IdleIndex = Rand(IdleAnims.Length);
				PlayAnimation(IdleAnims[IdleIndex], 0.0, true, 0.2);
			}

			StartIdleFidgetTimer();
			ToggleAdditiveBobAnim(!bUsingSights);
		}
	}

	/** Change states */
	simulated function GotoWeaponSprinting()
	{
		GotoState('WeaponSprinting');
	}

	/** Initialize the weapon as being active and ready to go. */
	simulated event BeginState(Name PreviousStateName)
	{
		// Cache a reference to the KFPlayerController
		if (Role == ROLE_Authority)
		{
			CacheKFPlayerController();
		}

		// In case this flag is still set
		bIronSightOnBringUp = false;

		// Initialize recoil blend out settings
		if( RecoilRate > 0 && RecoilBlendOutRatio > 0 )
		{
			RecoilYawBlendOutRate = maxRecoilYaw/RecoilRate * RecoilBlendOutRatio;
			RecoilPitchBlendOutRate = maxRecoilPitch/RecoilRate * RecoilBlendOutRatio;
		}

		// restore idle animation
		if( !WeaponIsAnimating() || !IsTimerActive(nameof(OnAnimEnd)) )
			OnAnimEnd(none, 0.f, 0.f);

		// restore skel controls
		bEnableTiltSkelControl = true;

		if (InvManager != none && InvManager.LastAttemptedSwitchToWeapon != none)
		{
			if (InvManager.LastAttemptedSwitchToWeapon != self)
			{
				InvManager.LastAttemptedSwitchToWeapon.ClientWeaponSet(true);
			}
			InvManager.LastAttemptedSwitchToWeapon = none;
		}

		// test ironsights in the same way Super.BeginState() tests pending fire
		CheckPendingIronsights();

		// do this last so the above code happens before any state changes
		Super.BeginState(PreviousStateName);
	}

	/** Event called when weapon leaves this state */
	simulated event EndState(Name NextStateName)
	{
		ClearTimer(nameof(IdleFidgetTimer));
		ToggleAdditiveBobAnim(false);

		Super.EndState(NextStateName);
	}

	/** Animation */
	simulated function StartIdleFidgetTimer()
	{
		if ( IdleFidgetAnims.Length > 0 )
		{
			SetTimer(RandRange(1.f, 10.f), false, nameof(IdleFidgetTimer));
		}
	}

	/** Animation */
	simulated function IdleFidgetTimer()
	{
		local bool bIsPlaying;

		if ( CanPlayIdleFidget() )
		{
			bIsPlaying = PlayIdleFidgetAnim();
		}

		// Otherwise keep trying.  When OnAnimEnd is called the timer will restart with a
		// random interval, but this allows anims to keep trying if one doesn't play.
		if ( !bIsPlaying )
		{
			SetTimer(20.f, false, nameof(IdleFidgetTimer));
		}
	}

	/** Returns true if IdleFidget anim is allowed (i.e. not in combat).  This has some
	 * hardcoded numbers, but it's easy to override in a subclass if needed
	 */
	simulated function bool CanPlayIdleFidget(optional bool bOnReload)
	{
		local Pawn P;

		if ( Instigator == none )
			return false;
		if ( bCanBeReloaded && !HasAmmo(DEFAULT_FIREMODE) )
			return false; // only when Ammo > 0 since most anims check magazine
		if ( bUsingSights )
			return false;

		if ( !bOnReload )
		{
			// played randomly via the StartIdleFidgetTimer/IdleFidgetTimer
			if ( `TimeSince(LastIdleFidgetAnimTime) < 20.f )
				return false;
			if ( `TimeSince(Instigator.LastPainTime) < 10.f )
				return false;
			if ( `TimeSince(KFPawn(Instigator).LastWeaponFireTime) < 10.f )
				return false;

			// Is enemy visible on screen.  Using class'Pawn' to avoid cast
			foreach WorldInfo.AllPawns( class'Pawn', P )
			{
				if ( `TimeSince(P.LastRenderTime) < 1.f && P.GetTeamNum() != Instigator.GetTeamNum() )
				{
					return false;
				}
			}
		}
		else
		{
			// slightly modified rules when it's player activited
			if ( `TimeSince(LastIdleFidgetAnimTime) < 1.f )
				return false;
			if ( !Instigator.IsLocallyControlled() )
				return false;
		}

		return true;
	}

	/** Play a random animation from the IdleFidget list */
	simulated function bool PlayIdleFidgetAnim()
	{
		local name AnimName;

		AnimName = IdleFidgetAnims[Rand(IdleFidgetAnims.Length)];
		if ( MySkelMesh.FindAnimSequence(AnimName) != None )
		{
			// disable the additive move bob temporarily
			ToggleAdditiveBobAnim(false);

			PlayAnimation(AnimName);
			LastIdleFidgetAnimTime = WorldInfo.TimeSeconds;

			return true;
		}

		return false;
	}

	/** Returns true if weapon can potentially be reloaded */
	simulated function bool CanReload(optional byte FireModeNum)
	{
		if ( Global.CanReload(FireModeNum) )
		{
			return true;
		}

		// If this attempt to reload failed try to play a idle fidget instead
		if ( PendingFire(RELOAD_FIREMODE) && CanPlayIdleFidget(true) )
		{
			PlayIdleFidgetAnim();
		}
		return false;
	}

	/** called during the settle portion of certain weapon actions */
	simulated function ANIMNOTIFY_EnableAdditiveBob()
	{
		if ( !bUsingSights )
		{
			ToggleAdditiveBobAnim(true, 0.3f);
		}
		else
		{
			// Should never happen, but some notifies have been placed in IS anims?!
			//`log(self@"called ANIMNOTIFY_EnableAdditiveBob while in ironsights");
		}
	}

	/**
	 * Perform pending fire modes.  This prevents a missed oppurtunity if the server was out
	 * of ammo during reload and has already called 'Active' BeginState.
	 */
	reliable server function ServerSyncReload(int ClientSpareAmmoCount)
	{
		local int i;

		Global.ServerSyncReload(ClientSpareAmmoCount);

		for( i=0; i<GetPendingFireLength(); i++ )
		{
			if( PendingFire(i) )
			{
				BeginFire(i);
			}
		}
	}

	/**
	 * Called when the weapon runs out of ammo after firing
	 */
	simulated function WeaponEmpty()
	{
		// Check firemodes that don't require ammo, since Weapon.Active.BeginState()
		// will skip it's PendingFire check when !HasAnyAmmo().
		if ( PendingFire(GRENADE_FIREMODE) && HasAmmo(GRENADE_FIREMODE) )
		{
			BeginFire(GRENADE_FIREMODE);
		}
		else if ( PendingFire(BASH_FIREMODE) && HasAmmo(BASH_FIREMODE) )
		{
			BeginFire(BASH_FIREMODE);
		}
	}
}

/** test ironsights in the same way Super.BeginState() tests pending fire */
simulated function CheckPendingIronsights()
{
	local PlayerController PC;

	if ( Instigator.IsLocallyControlled() )
	{
		PC = PlayerController(Instigator.Controller);
		if ( PC != None && PC.PlayerInput != None )
		{
			if ( KFPlayerInput(PC.PlayerInput).bIronsightsHeld )
			{
				SetIronsights(true);
			}
		}
	}
}

/*********************************************************************************************
 * State WeaponEquipping
 * The Weapon is in this state while transitioning from Inactive to Active state.
 * Typically, the weapon will remain in this state while its selection animation is being played.
 * While in this state, the weapon cannot be fired.
*********************************************************************************************/

simulated state WeaponEquipping
{
	simulated function byte GetWeaponStateId()
	{
		return WEP_Equipping;
	}

	simulated function bool TryPutDown()
	{
		bWeaponPutDown = true;

		if (!IsTimerActive('WeaponEquipped'))
		{
			PutDownWeapon();
		}
		else
		{
			// We want the abort to be the same amount of time as
			// we have already spent equipping
			EquipAbortTime = PutDownTime * GetTimerCount('WeaponEquipped') / GetTimerRate('WeaponEquipped');
			GotoState('WeaponAbortEquip');
		}

		return true;
	}

	simulated function BeginState(Name PreviousStateName)
	{
		local KFPerk InstigatorPerk;
		local float PerkZedTimeResist;

		super.BeginState(PreviousStateName);

		// see if we need to start in ironsights
		if( bIronSightOnBringUp && bHasIronSights )
		{
			bIronSightOnBringUp = false;
			SetIronSights(true);
		}
		else
		{
			// handle the bindable button hold version
			CheckPendingIronsights();
		}

		InstigatorPerk = GetPerk();
		if ( InstigatorPerk != none )
		{
			PerkZedTimeResist = InstigatorPerk.GetZedTimeModifier(self);
		}

		SetZedTimeResist(0.375f + PerkZedTimeResist);
		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		ClearTimer('WeaponEquipped');
		ClearZedTimeResist();
		NotifyEndState();
	}

	/** Gets the current animation rate, scaled or not */
	simulated function float GetThirdPersonAnimRate()
	{
		local KFPerk CurrentPerk;
		local float ScaledRate;

		ScaledRate = 1.0f;
		CurrentPerk = GetPerk();
		if( CurrentPerk != none )
		{
			CurrentPerk.ModifyWeaponSwitchTime( ScaledRate );
		}

		return 1.f / ScaledRate;
	}
}

/**
 * Sets the timing for equipping a weapon.
 * The WeaponEquipped event is trigged when expired
 */
simulated function TimeWeaponEquipping()
{
	local KFPerk InstigatorPerk;
	local float ModifiedEquipTime;

	if (!WeaponContentLoaded)
	{
		return;
	}

	ModifiedEquipTime = MySkelMesh.GetAnimLength( EquipAnim );

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		InstigatorPerk.ModifyWeaponSwitchTime( ModifiedEquipTime );
	}

	// Play the animation
	PlayWeaponEquip( ModifiedEquipTime );

	SetTimer( EquipTime>0 ? EquipTime : 0.01, false, nameof( WeaponEquipped ) );
}

simulated function WeaponEquipped();

/**
 * Show the weapon begin equipped
 */
simulated function PlayWeaponEquip( float ModifiedEquipTime )
{
	// Play the animation for the weapon being equipped
	PlayAnimation( GetEquipAnimName(), ModifiedEquipTime );
}

/** Get equip anim name (overridden as necessary) */
simulated function name GetEquipAnimName()
{
	return EquipAnim;
}

/*********************************************************************************************
 * State WeaponPuttingDown
 * Putting down weapon in favor of a new one.
 * Weapon is transitioning to the Inactive state.
*********************************************************************************************/

simulated state WeaponPuttingDown
{
	simulated function byte GetWeaponStateId()
	{
		return WEP_PutAway;
	}

	simulated function BeginState( Name PreviousStateName )
	{
		local KFPerk InstigatorPerk;
		local float PerkZedTimeResist;

		TimeWeaponPutDown();
		bWeaponPutDown = false;

		InstigatorPerk = GetPerk();
		if ( InstigatorPerk != none )
		{
			PerkZedTimeResist = InstigatorPerk.GetZedTimeModifier(self);
		}

		SetZedTimeResist(0.375f + PerkZedTimeResist);
		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);

		ClearZedTimeResist();
		NotifyEndState();
	}

	simulated function Activate();

	/** Gets the current animation rate, scaled or not */
	simulated function float GetThirdPersonAnimRate()
	{
		local KFPerk CurrentPerk;
		local float ScaledRate;

		ScaledRate = 1.0f;
		CurrentPerk = GetPerk();
		if( CurrentPerk != none )
		{
			CurrentPerk.ModifyWeaponSwitchTime( ScaledRate );
		}

		return 1.f / ScaledRate;
	}
}

// Control 'WeaponDownSimple' state
simulated function SetSimplePutDown(bool bPutDownWeapon)
{
	if ( bPutDownWeapon )
	{
		GotoState('WeaponDownSimple');
	}
}

simulated function bool CanSwitchWeapons()
{
    return WeaponContentLoaded;
}

/*********************************************************************************************
 * State WeaponDownSimple
 * Putting the weapon down off the screen, don't allow shooting or switching weapons
*********************************************************************************************/
simulated state WeaponDownSimple
{
	simulated function bool CanTransitionToIronSights();
	simulated function bool DenyClientWeaponSet() {return true;}
	simulated function bool CanReload(optional byte FireModeNum);
    simulated function SetIronSights(bool bNewIronSights){}
	simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime){}

	simulated function bool CanThrow()
	{
		return (Instigator == none || Instigator.Health <= 0);
	}

    simulated function bool CanSwitchWeapons();

    exec function SimplePutDown()
    {
        SetSimplePutDown(false);
    }

	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);

        bDoingQuickDownZoom = true;

    	if ( Instigator.IsLocallyControlled() )
    	{
            ZoomDown(true, QuickWeaponDownTime);
    	}

		// Go to a looping idle animation to avoid screen clipping
		if( Instigator.IsFirstPerson() )
		{
			PlayAnimation(IdleAnims[0], 0.0, true, 0.2);
		}

		StopFire(CurrentFireMode);
	}

    /**
     * Zoom the weapon down, off the screen
     *
     * @param bAnimateTransition whether or not to animate this zoom transition
     * @param ZoomTimeToGo how much zoom time is left
     */
    simulated function ZoomDown(bool bAnimateTransition, float ZoomTimeToGo)
    {
    	if( bAnimateTransition )
    	{
    		ZoomInTime=ZoomTimeToGo;

    		// If the zoom out was interrupted, set the parameters for the native code to interpolate the zoom from the proper position
    		if( bZoomingOut )
    		{
    			bZoomingOut=false;
    			// Flag so the native code knows the zoom was interupted
    			bZoomOutInterrupted=true;
    			// Set the zoom time relative to how far along we were when zooming out
    			ZoomTime=ZoomInTime - ZoomTime;
    			// Let the native code know where/when the zoom was interrupted
    			ZoomPartialTime=ZoomTime;
    			ZoomStartOffset=PlayerViewOffset;
    			ZoomRotStartOffset=ZoomRotInterp;
    		}
    		else
    		{
    			ZoomTime=ZoomInTime;
    			ZoomStartOffset=PlayerViewOffset;
    		}

            // Zoom down to hipped offset
    		ZoomTargetOffset=default.PlayerViewOffset;

    		if( MySkelMesh != none )
    		{
    			ZoomWeaponFOVStart=MySkelMesh.FOV;
    		}
    		else
    		{
    			ZoomWeaponFOVStart=MeshFOV;
    		}

        	if( WorldInfo.NetMode != NM_DedicatedServer && Instigator != none )
        	{
        		EnableIronSightsDoF(false);
        		EnablePlayerZoom(false);
        	}

    		bZoomingIn=true;
    	}
    }

	simulated function EndState(name NextStateName)
	{
		Super.EndState(NextStateName);

		ClearTimer('EndWeaponDownSimpleTimer');

        bDoingQuickDownZoom=false;
	}

	simulated function EndWeaponDownSimpleTimer()
	{
		// we're done, leave state and go back to active
		GotoState('Active');
	}

	simulated function SetSimplePutDown(bool bPutDownWeapon)
	{
		if ( !bPutDownWeapon )
		{
			if ( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled() )
			{
				// Slightly faster on the server to prevent sync issues
				EndWeaponDownSimpleTimer();
			}
			else
			{
				SetTimer(QuickWeaponDownFinishTime, false, 'EndWeaponDownSimpleTimer');
        		if ( Instigator.IsLocallyControlled() )
            	{
                    ZoomOut(true, QuickWeaponDownFinishTime);
            	}
			}
		}
		else
		{
			ClearTimer('EndWeaponDownSimpleTimer');
        	if ( Instigator.IsLocallyControlled() )
        	{
                ZoomDown(true, QuickWeaponDownTime);
        	}
			StopFire(CurrentFireMode);
		}
	}
}

/**
 * Sets the timing for putting a weapon down.  The WeaponIsDown event is trigged when expired
*/
simulated function TimeWeaponPutDown()
{
	local KFPerk InstigatorPerk;
	local float ModifiedPutDownTime;

	ModifiedPutDownTime = PutDownTime;

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		InstigatorPerk.ModifyWeaponSwitchTime( ModifiedPutDownTime );
	}

	SetTimer( ModifiedPutDownTime > 0 ? ModifiedPutDownTime : 0.01, false, nameof(WeaponIsDown) );

	if( Instigator.IsFirstPerson() )
	{
		PlayWeaponPutDown( ModifiedPutDownTime );
	}
}

/**
 * Show the weapon being put away
 */
simulated function PlayWeaponPutDown( float ModifiedPutDownTime )
{
	// Play the animation for the weapon being put down
	PlayAnimation( GetWeaponPutDownAnimName(), ModifiedPutDownTime );
}

/** Get putdown anim name (overridden as necessary) */
simulated function name GetWeaponPutDownAnimName()
{
	return PutDownAnim;
}

/**
 * When attempting to put the weapon down, look to see if our MinFiringPutDownPct has been met.  If so just put it down
 */
simulated function bool TryPutDown()
{
	local float MinTimerTarget;
	local float TimerCount;

	bWeaponPutDown = true;

	if (!IsTimerActive('RefireCheckTimer'))
	{
		PutDownWeapon();
	}
	else
	{
		MinTimerTarget = GetTimerRate('RefireCheckTimer') * MinFiringPutDownPct;
		TimerCount = GetTimerCount('RefireCheckTimer');

		if (TimerCount >= MinTimerTarget)
		{
			PutDownWeapon();
		}
		else
		{
			// Shorten the wait time
			SetTimer(MinTimerTarget - TimerCount, false, nameof( FiringPutDownWeapon ) );
		}
	}

	return true;
}

simulated function FiringPutDownWeapon()
{
	if (bWeaponPutDown)
	{
		PutDownWeapon();
	}
}

/*********************************************************************************************
* State WeaponAbortEquip
* Special PuttingDown state used when WeaponEquipping is interrupted.  Must come after
* WeaponPuttingDown definition or this willextend the super version.
*********************************************************************************************/

simulated state WeaponAbortEquip extends WeaponPuttingDown
{
	simulated function TimeWeaponPutDown()
	{
		local AnimNodeSequence AnimNode;
		local float Rate;

		// Time the abort
		SetTimer(FMax(EquipAbortTime, 0.01),, nameof(WeaponIsDown) );

		if (WorldInfo.NetMode != NM_DedicatedServer)
		{
			// play anim
			AnimNode = GetWeaponAnimNodeSeq();
			if (AnimNode != None && AnimNode.AnimSeq != None)
			{
				AnimNode.SetAnim(PutDownAnim);
				Rate = AnimNode.AnimSeq.SequenceLength / PutDownTime;
				AnimNode.PlayAnim(false, Rate, AnimNode.AnimSeq.SequenceLength - EquipAbortTime * Rate);
			}
		}
	}
}

/*********************************************************************************************
 * state WeaponFiring
 * This is the default Firing State.  It's performed on both the client and the server.
 *********************************************************************************************/
simulated state WeaponFiring
{
	ignores AllowSprinting;

	simulated function BeginState(Name PrevStateName)
	{
		local KFPerk InstigatorPerk;

		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
		}

		if ( bLoopingFireAnim.Length > 0 || bLoopingFireSnd.Length > 0 )
		{
			StartLoopingFireEffects(CurrentFireMode);
		}

		super.BeginState(PrevStateName);
	}

	simulated event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

        // Stop the looping fire sound if we're in zed time and want to play single fire sounds
        if( bPlayingLoopingFireSnd && ShouldForceSingleFireSound() )
        {
    		StopLoopingFireSound(CurrentFireMode);
        }
	}

	/**
	 * Timer event, call is set up in Weapon::TimeWeaponFiring().
	 * The weapon is given a chance to evaluate if another shot should be fired.
	 * This event defines the weapon's rate of fire.
	 */
	simulated function RefireCheckTimer()
	{
		local KFPerk InstigatorPerk;

		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
		}

		super.RefireCheckTimer();
	}

	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);

		ClearZedTimeResist();

		// Simulate weapon firing effects on the local client
		if( WorldInfo.NetMode == NM_Client )
		{
			Instigator.WeaponStoppedFiring(self, false);
		}

		if ( bPlayingLoopingFireAnim || bPlayingLoopingFireSnd )
		{
			StopLoopingFireEffects(CurrentFireMode);
		}
	}

	/** Override to continue any looping fire anims */
	simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
	{
		local name WeaponFireAnimName;

		if ( WorldInfo.NetMode != NM_DedicatedServer )
		{
			// If loop start or another event such as IronSights transition ended, restart looping fire anim.
			if ( bPlayingLoopingFireAnim )
			{
				WeaponFireAnimName = GetLoopingFireAnim(CurrentFireMode);
				if ( WeaponFireAnimName != '' )
				{
					PlayAnimation(WeaponFireAnimName, MySkelMesh.GetAnimLength(WeaponFireAnimName), true, 0.f);
				}
			}
		}
	}

	/** don't allow for a pickup to switch the weapon */
	simulated function bool DenyClientWeaponSet()
	{
		return true;
	}

	/** Gets the current animation rate, scaled or not */
	simulated function float GetThirdPersonAnimRate()
	{
		local KFPerk CurrentPerk;
		local float ScaledRate;

		ScaledRate = 1.0f;
		CurrentPerk = GetPerk();
		if( CurrentPerk != none )
		{
			CurrentPerk.ModifyRateOfFire( ScaledRate, self );
		}

		return 1.f / ScaledRate;
	}
}

/**
 * Sets the timing for the firing state on server and local client.
 * By default, a constant looping Rate Of Fire (ROF) is set up.
 * When the delay has expired, the RefireCheckTimer event is triggered.
 *
 * Network: LocalPlayer and Server
 *
 * @param	FireModeNum		Fire Mode.
 */
simulated function TimeWeaponFiring( byte FireModeNum )
{
	local float AdjustedFireInterval;
	local KFPerk CurrentPerk;

	// if weapon is not firing, then start timer. Firing state is responsible to stopping the timer.
	if( !IsTimerActive('RefireCheckTimer') )
	{
		// Let the perk adjust the rate of fire if needed;
		AdjustedFireInterval = GetFireInterval(FireModeNum);

        CurrentPerk = GetPerk();
		if( CurrentPerk != none )
		{
            CurrentPerk.ModifyRateOfFire( AdjustedFireInterval, self );
		}

		SetTimer(AdjustedFireInterval, true, nameof(RefireCheckTimer) );
	}
}

/*********************************************************************************************
 * State WeaponSingleFiring
 * Fire must be released between every shot.
 *********************************************************************************************/

simulated state WeaponSingleFiring extends WeaponFiring
{
	/** Handle ClearPendingFire */
	simulated function FireAmmunition()
    {
		if (MedicComp != none)
		{
			MedicComp.OnWeaponFireAmmunition(CurrentFireMode);
		}

        Super.FireAmmunition();

		// ClearPendingFire flag each time so that player has to press fire button
		// again.  Called from BeginState and RefireCheckTimer
		ClearPendingFire(CurrentFireMode);
	}
}

/*********************************************************************************************
 * State WeaponBurstFiring
 * Fires a burst of bullets. Fire must be released between every shot.
 *********************************************************************************************/

simulated function int GetBurstAmount() { return 1; }

simulated state WeaponBurstFiring extends WeaponFiring
{
	simulated function BeginState(Name PrevStateName)
	{
		// Don't let us fire more shots than we have ammo for
		BurstAmount = GetBurstAmount();

		super.BeginState(PrevStateName);
	}

	simulated function int GetBurstAmount()
	{
		return Min( default.BurstAmount, AmmoCount[GetAmmoType(CurrentFireMode)] );
	}

	simulated function bool ShouldRefire()
	{
		// Stop firing when we hit the burst amount
		if( 0 >= BurstAmount )
		{
			return false;
		}
		// if doesn't have ammo to keep on firing, then stop
		else if( !HasAmmo( CurrentFireMode ) )
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	/**
	 * FireAmmunition: Perform all logic associated with firing a shot
	 * - Fires ammunition (instant hit or spawn projectile)
	 * - Consumes ammunition
	 * - Plays any associated effects (fire sound and whatnot)
	 * Overridden to decrement the BurstAmount
	 *
	 * Network: LocalPlayer and Server
	 */
	simulated function FireAmmunition()
	{
		super.FireAmmunition();
		BurstAmount--;
	}

	simulated event EndState( Name NextStateName )
	{
		Super.EndState(NextStateName);
		EndFire(CurrentFireMode);
	}
}

/*********************************************************************************************
 * State GrenadeFiring
 * Handles firing grenades.
 *********************************************************************************************/

/** Synchronize the server if it's not quite finished with another state */
reliable server private function ServerGotoGrenadeFiring()
{
	if( HasAmmo(GRENADE_FIREMODE) )
	{
		SendToFiringState(GRENADE_FIREMODE);
	}
}

/** Set the cooldown time for weak zed grab for the pawn holding this weapon */
function SetWeakZedGrabCooldownOnPawn(float WeakZedGrabCooldown)
{
	local KFPawn KFP;

    if( Role == ROLE_Authority )
    {
    	KFP = KFPawn(Instigator);

    	if( KFP != none )
    	{
            KFP.SetWeakGrabCoolDown(WeakZedGrabCooldown);
    	}
    }
}

simulated state GrenadeFiring extends WeaponSingleFiring
{
	simulated function byte GetWeaponStateId()
	{
		return WEP_Grenade;
	}

	// Overriden to not call FireAmmunition right at the start of the state
    simulated event BeginState( Name PreviousStateName )
	{
		`LogInv("PreviousStateName:" @ PreviousStateName);

		// Force exit ironsights (affects IS toggle key bind)
		if ( bUsingSights )
		{
			ZoomOut(false, default.ZoomOutTime);
		}

        // Don't let a weak zed grab us right after throwing a grenade
        SetWeakZedGrabCooldownOnPawn(GrenadeTossWeakZedGrabCooldown);

		PlayGrenadeThrow();
		TimeWeaponFiring(CurrentFireMode);
		ClearPendingFire(CurrentFireMode);

		// Consume ammo right away instead of when grenade is spawned.  This gives time
		// for the client to get an updated grenade count before GotoState('Active')
		if ( Role == ROLE_Authority && KFInventoryManager(InvManager) != none )
        {
            KFInventoryManager(InvManager).ConsumeGrenades();
        }
		else if ( Role < ROLE_Authority && Instigator.IsLocallyControlled() )
		{
			// force synchronize the server to spawn the projectile
			ServerGotoGrenadeFiring();
		}

		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		local byte FireModeSwap;

		Super.EndState(NextStateName);
		NotifyEndState();

		// ProjectileFire needs GRENADE_FIREMODE.  Could be something else if we're
		// going directly (rare) to another firing state.
		FireModeSwap = CurrentFireMode;
		CurrentFireMode = GRENADE_FIREMODE;
		// Spawn grenade, cannot be skipped once this state starts
		ProjectileFire();
		CurrentFireMode = FireModeSwap;
	}

    /**
     * This function returns the world location for spawning the visual effects
     * Overridden to use a special offset for throwing grenades
     */
    simulated event vector GetMuzzleLoc()
    {
        local Rotator ViewRotation;

		if( Instigator != none )
		{
			ViewRotation = Instigator.GetViewRotation();

			// Add in the free-aim rotation
			if ( KFPlayerController(Instigator.Controller) != None )
			{
				ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;
			}

			return Instigator.GetPawnViewLocation() + (GrenadeFireOffset >> ViewRotation);
		}

		return Location;
    }

	/** Never refires.  Must re-enter this state instead. */
	simulated function bool ShouldRefire()
	{
		return false;
	}
}

/** Play animation at the start of the GrenadeFiring state */
simulated function PlayGrenadeThrow()
{
    local name WeaponFireAnimName;

    PlayFiringSound(CurrentFireMode);

    if( Instigator != none && Instigator.IsFirstPerson() )
    {
    	WeaponFireAnimName = GetGrenadeThrowAnim();

    	if ( WeaponFireAnimName != '' )
    	{
    		PlayAnimation(WeaponFireAnimName, MySkelMesh.GetAnimLength(WeaponFireAnimName),,FireTweenTime);
    	}
    }
}

/** Get nade throw anim name (overridden as necessary) */
simulated function name GetGrenadeThrowAnim()
{
	return GrenadeThrowAnim;
}

/*********************************************************************************************
 * State Reloading
 * This is the default Reloading State.  It's performed on both the client and the server.
 *********************************************************************************************/

// Global declarations for reload state
simulated function ReloadStatusTimer();
simulated function ReloadAmmoTimer();
simulated function ReloadComplete();
simulated function AbortReload();

/** Called on local player when reload starts and replicated to server */
simulated function InitializeReload()
{
	ReloadAmountLeft		= Min(MagazineCapacity[0] - AmmoCount[0], SpareAmmoCount[0]);
	InitialReloadAmount		= ReloadAmountLeft;
	InitialReloadSpareAmmo	= SpareAmmoCount[0];

	if ( Role < ROLE_Authority )
	{
		ServerSendToReload(ReloadAmountLeft);
	}
}

/** Called from client when reload starts */
reliable server function ServerSendToReload(byte ClientReloadAmount)
{
	ReloadAmountLeft		= ClientReloadAmount;
	InitialReloadAmount		= ReloadAmountLeft;
	InitialReloadSpareAmmo	= SpareAmmoCount[0];
	SendToFiringState(RELOAD_FIREMODE);
}

/**
 * State Reloading
 * State the weapon is in when it is being reloaded (current magazine replaced with a new one, related animations and effects played).
 */
simulated state Reloading
{
	ignores ForceReload, ShouldAutoReload, AllowSprinting;

	simulated function byte GetWeaponStateId()
	{
		local KFPerk Perk;
		local bool bTacticalReload;

		Perk = GetPerk();
		bTacticalReload = (Perk != None && Perk.GetUsingTactialReload(self));

		if ( !bReloadFromMagazine )
		{
			if ( bTacticalReload )
			{
				return AmmoCount[0] > 0 ? WEP_ReloadSingle_Elite : WEP_ReloadSingleEmpty_Elite;
			}
			return AmmoCount[0] > 0 ? WEP_ReloadSingle : WEP_ReloadSingleEmpty;
		}
		else
		{
			if ( bTacticalReload )
			{
				return AmmoCount[0] > 0 ? WEP_Reload_Elite : WEP_ReloadEmpty_Elite;
			}
			return AmmoCount[0] > 0 ? WEP_Reload : WEP_ReloadEmpty;
		}
	}

	/** When we have our spare ammo count replicated while reloading, it will force spare ammo to show
		up incorrectly, as the server has not yet done it's reload in ServerSyncReload(). This fix forces
		the spare ammo to be correct on the client */
	simulated event ReplicatedEvent(name VarName)
	{
		local int ClientsideAmmoReloaded;

		if (VarName == nameof(SpareAmmoCount))
		{
			// If the reload has not yet begun (spare ammo count will be the same on client and server) do not do any corrections.
			ClientsideAmmoReloaded = (InitialReloadAmount - ReloadAmountLeft);

			if(Role < Role_Authority && ClientsideAmmoReloaded > 0 && bAllowClientAmmoTracking )
			{
				// Re-apply the work already done to the spare ammo because of our reload (the server does not reload at the same time as the client)
				SpareAmmoCount[0] -= Max(ClientsideAmmoReloaded, 0);
			}
		}
		else
		{
			Global.ReplicatedEvent(VarName);
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		local KFPerk InstigatorPerk;

		InstigatorPerk = GetPerk();
		if ( InstigatorPerk != none )
		{
			SetZedTimeResist(InstigatorPerk.GetZedTimeModifier(self));
		}

		// Leave ironsights
		if ( bUsingSights )
		{
			ZoomOut(false, default.ZoomOutTime);
		}

		bEnableTiltSkelControl = false;
		bPendingAutoSwitchOnDryFire = false;

		ReloadStatus = RS_None;
		TimeWeaponReloading();

		NotifyBeginState();

		`DialogManager.PlayReloadDialog( KFPawn(Instigator) );
	}

	simulated function EndState(Name NextStateName)
	{
		local int ActualReloadAmount;
		ClearZedTimeResist();
		ClearTimer(nameof(ReloadStatusTimer));
		ClearTimer(nameof(ReloadAmmoTimer));
		ClearPendingFire(RELOAD_FIREMODE);

`if(`USE_RELOAD_SYNC)
		if ( bAllowClientAmmoTracking && Role < ROLE_Authority )
		{
			// Get how much total ammo was reloaded on the client side over the entire course of the reload.
			ActualReloadAmount = InitialReloadAmount - ReloadAmountLeft;
			// Sync spare ammo counts using initial spare ammo, and how much ammo has been reloaded since reload began.
			ServerSyncReload(InitialReloadSpareAmmo - ActualReloadAmount);
		}
`endif

		CheckBoltLockPostReload();
		NotifyEndState();

		`DialogManager.PlayAmmoDialog( KFPawn(Instigator), float(SpareAmmoCount[0]) / float(GetMaxAmmoAmount(0)) );
		CurrentFireMode = DEFAULT_FIREMODE;

		ReloadStatus = RS_None;
	}

	simulated function BeginFire(byte FireModeNum)
	{
		Global.BeginFire(FireModeNum);

		// handle reload interrupts
		if ( FireModeNum != RELOAD_FIREMODE )
		{
			if ( !bReloadFromMagazine || CanOverrideMagReload(FireModeNum) )
			{
				// if able, immediately interupt/abort the reload state
				if( PendingFire(FireModeNum) && HasAmmo(FireModeNum) )
				{
					AbortReload();
				}
			}
		}
	}

	/** Cancel reload when going into ironsights */
	simulated function ZoomIn(bool bAnimateTransition, float ZoomTimeToGo)
	{
		if ( !bReloadFromMagazine )
		{
			// Do zoom first in case Abort takes us to a state where sights are disallowed
			Global.ZoomIn(bAnimateTransition, ZoomTimeToGo);

			AbortReload();
		}
		else if( Role == ROLE_Authority && !Instigator.IsLocallyControlled() )
		{
			// In client-server situations, allow the client to tell the server when it's zooming in and out
			Global.ZoomIn( bAnimateTransition, ZoomTimeToGo );
		}
	}

	/** @see Weapon::TryPutDown() */
	simulated function bool TryPutDown()
	{
		PutDownWeapon();
		return TRUE;
	}

	/** Update Reload Status */
	simulated function ReloadStatusTimer()
	{
		// If we haven't added ammo yet, do it now.  Handles reloading when the
		// weapon is missing notifies or the notify is very close to the end.
		if ( ReloadStatus == RS_Reloading && IsTimerActive(nameof(ReloadAmmoTimer)) )
		{
			PerformReload();
			ClearTimer(nameof(ReloadAmmoTimer));
		}

		TimeWeaponReloading();
	}

	/** Call Perform Reload */
	simulated function ReloadAmmoTimer()
	{
		PerformReload();
	}

	/** Cleanup reload state */
	simulated function ReloadComplete()
	{
		// we're done, leave state and go back to active
		GotoState('Active');
	}

	/** Called when reload animation is interrupted */
	simulated function AbortReload()
	{
		LastReloadAbortTime = WorldInfo.TimeSeconds;

		// we're done, leave state and go back to active
		GotoState('Active');
	}

	/** Gets the current animation rate, scaled or not */
	simulated function float GetThirdPersonAnimRate()
	{
		return 1.f / GetReloadRateScale();
	}
}

/** Called during reload state */
simulated function bool CanOverrideMagReload(byte FireModeNum)
{
	if ( FireModeNum == BASH_FIREMODE || FireModeNum == GRENADE_FIREMODE )
	{
		return true;
	}

	return false;
}

/**
 * Sets the timing for equipping a weapon.
 * The WeaponEquipped event is trigged when expired
 */
simulated function TimeWeaponReloading()
{
	local name AnimName;
	local float AnimLength, AnimRate;
	local float AmmoTimer, StatusTimer;

	ReloadStatus = GetNextReloadStatus();

	// If we're finished exit reload
	if ( ReloadStatus == RS_Complete || MySkelMesh == None )
	{
		ReloadComplete();
		return;
	}

    // get desired animation and play-rate
    AnimName = GetReloadAnimName( UseTacticalReload() );
    AnimRate = GetReloadRateScale();
	AnimLength = AnimRate * MySkelMesh.GetAnimLength(AnimName);

	if ( AnimLength > 0.f )
	{
		MakeNoise(0.5f,'PlayerReload'); // AI

		if ( Instigator.IsFirstPerson() )
		{
			PlayAnimation(AnimName, AnimLength);
		}

		// Start timer for when to give ammo (aka 'PerformReload')
		if ( ReloadStatus == RS_Reloading )
		{
			AmmoTimer = AnimRate * MySkelMesh.GetReloadAmmoTime(AnimName);
			SetTimer(AmmoTimer, FALSE, nameof(ReloadAmmoTimer));
		}

		// Start timer for when to continue (e.g. ReloadComplete, TimeWeaponReloading)
		if ( bReloadFromMagazine || ReloadStatus == RS_ClosingBolt )
		{
			StatusTimer = AnimRate * MySkelMesh.GetAnimInterruptTime(AnimName);
		}
		else
		{
			StatusTimer = AnimLength;
		}

		SetTimer(StatusTimer, FALSE, nameof(ReloadStatusTimer));
	}
	else
	{
		`warn("Reload duration is zero! Anim="$AnimName@"Rate:"$AnimRate);
		ReloadComplete();
	}
}

/** Returns an anim rate scale for reloading */
simulated function float GetReloadRateScale()
{
	local float Rate;
	local KFPerk MyPerk;

	//Rate = 1.f;
	Rate = GetUpgradedReloadRateScale(GetStateName() == 'Reloading' ? DEFAULT_FIREMODE : ALTFIRE_FIREMODE);

	MyPerk = GetPerk();
	if( MyPerk != None )
	{
		//Rate = MyPerk.GetReloadRateScale( self );
		Rate *= MyPerk.GetReloadRateScale(self);
	}

	return Rate;
}

/** Access perk skill for tactical reload */
simulated function bool UseTacticalReload()
{
	local KFPerk MyPerk;

	MyPerk = GetPerk();
	if ( MyPerk != None )
	{
		return MyPerk.GetUsingTactialReload(self);
	}

	return false;
}

/** Move to the next valid reload status */
simulated function EReloadStatus GetNextReloadStatus(optional byte FireModeNum)
{
	// Magazine reloading
	if ( bReloadFromMagazine )
	{
		if ( ReloadStatus < RS_Reloading )
		{
			return RS_Reloading;
		}
		return RS_Complete;
	}

	// Single shot reloading
	switch ( ReloadStatus )
	{
		case RS_None:
			return RS_OpeningBolt;
		case RS_OpeningBolt:
			return RS_Reloading;
		case RS_Reloading:
			if ( HasSpareAmmo(FiremodeNum) && ReloadAmountLeft > 0 )
			{
				return RS_Reloading;
			}
			return RS_ClosingBolt;
	}

	return RS_Complete;
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName( bool bTacticalReload )
{
	if ( !bReloadFromMagazine )
	{
		switch ( ReloadStatus )
		{
			case RS_OpeningBolt:
				if ( AmmoCount[0] == 0 )
				{
					// immediately skip reload status so that we start getting ammo
					ReloadStatus = GetNextReloadStatus();
					return bTacticalReload ? ReloadOpenInsertEliteAnim : ReloadOpenInsertAnim;
				}
				return (bTacticalReload) ? ReloadOpenEliteAnim : ReloadOpenAnim;
			case RS_ClosingBolt:
				return (bTacticalReload) ? ReloadCloseEliteAnim : ReloadCloseAnim;
		}

		return (bTacticalReload) ? ReloadSingleEliteAnim : ReloadSingleAnim;
	}

	// magazine relaod
	if ( AmmoCount[0] > 0 )
	{
		return (bTacticalReload) ? ReloadNonEmptyMagEliteAnim : ReloadNonEmptyMagAnim;
	}
	else
	{
		return (bTacticalReload) ? ReloadEmptyMagEliteAnim : ReloadEmptyMagAnim;
	}
}

/** Performs actual ammo reloading */
simulated function PerformReload(optional byte FireModeNum)
{
	local int ReloadAmount;
	local int AmmoType;

	AmmoType = GetAmmoType(FireModeNum);

	if ( bInfiniteSpareAmmo )
	{
		AmmoCount[AmmoType] = MagazineCapacity[AmmoType];
		ReloadAmountLeft = 0;
		return;
	}

	// Server only unless bAllowClientAmmoTracking
`if(`USE_RELOAD_SYNC)
	if ( (Role == ROLE_Authority && !bAllowClientAmmoTracking) || (Instigator.IsLocallyControlled() && bAllowClientAmmoTracking) )
`else
	if ( Role == ROLE_Authority || bAllowClientAmmoTracking )
`endif
	{
		if( GetMaxAmmoAmount(AmmoType) > 0 && SpareAmmoCount[AmmoType] > 0 )
		{
			if ( bReloadFromMagazine )
			{
				// clamp reload amount to spare ammo size
				ReloadAmount = Min(ReloadAmountLeft, SpareAmmoCount[AmmoType]);
			}
			else
			{
				ReloadAmount = 1;
			}

			// increment and clamp magazine ammo
			AmmoCount[AmmoType] = Min(AmmoCount[AmmoType] + ReloadAmount, MagazineCapacity[AmmoType]);

`if(`USE_RELOAD_SYNC)
			// Update SpareAmmo, even if this is the client (for immediate feedback).  This is safe as long as
			// the server doesn't consume SpareAmmo first which is enforced by ServerSyncReload
			SpareAmmoCount[AmmoType] -= ReloadAmount;
`else
			if ( Role == ROLE_Authority )
			{
				// Only update SpareAmmo on the server and make the client wait, so if the
				// server executes this code early the client won't consume ammo twice
				SpareAmmoCount[AmmoType] -= ReloadAmount;
			}
`endif
		}
	}

	// decrement ReloadAmountLeft
	if ( bReloadFromMagazine )
	{
		ReloadAmountLeft = 0;
	}
	else if ( ReloadAmountLeft > 0 )
	{
		ReloadAmountLeft--;
	}

	ShotsHit = 0;
}

/**
 * Called on reload end state if this weapon has unlocked the bolt
 * during reload.  If reload was interrupted before ammo was give
 * the bolt should revert to previous state
 */
simulated function CheckBoltLockPostReload()
{
	if ( bCheckBoltLockPostReload )
	{
		if ( ReloadStatus < RS_Complete )
		{
			UpdateOutOfAmmoEffects(0.f);
		}

		bCheckBoltLockPostReload = false;
	}
}

/*********************************************************************************************
 * State WeaponSprinting
 * This is the default Sprinting State.  It's performed on both the client and the server.
 *********************************************************************************************/

// Global declarations for sprinting state
simulated function SprintLoopTimer();
simulated function SprintRetryTimer();

/**
 * State WeaponSprinting
 * State the weapon is in when it is being reloaded (current magazine replaced with a new one, related animations and effects played).
 */
simulated state WeaponSprinting
{
	ignores ForceReload;

	simulated function BeginState(name PreviousStateName)
    {
   		PlaySprintStart();
	}

	simulated function EndState(Name NextStateName)
	{
		// skip the outro if sights interrupted because it interferes with the procedural anim
		if ( !bUsingSights )
		{
			PlaySprintEnd();
		}
	}

	simulated function SprintLoopTimer()
	{
		PlaySprintLoop();
	}

	simulated function SprintRetryTimer()
	{
		PlaySprintStart();
	}

	simulated function SetWeaponSprint(bool bNewSprintStatus)
	{
		if ( !bNewSprintStatus )
		{
			GotoState('Active');
		}
	}

	simulated function SetIronSights(bool bNewIronSights)
	{
		Global.SetIronSights(bNewIronSights);

		if ( bUsingSights )
		{
			StopPawnSprint(true);
		}
	}

	/** Override BeginFire so that shooting/attacking will interrupt sprinting */
	simulated function BeginFire(byte FireModeNum)
	{
		if( !bDeleteMe && Instigator != None )
		{
			Global.BeginFire(FireModeNum);

			if( PendingFire(FireModeNum) && HasAmmo(FireModeNum) )
			{
				StopPawnSprint(false);
			}
		}
	}
}

simulated function PlaySprintStart()
{
	local KFPlayerController KFPC;
	local name AnimName;
	local float AnimDuration;

	// Retry timer if we're in the middle of something that we don't want to interrupt
	if ( bZoomingOut )
	{
		SetTimer(0.1f, false, nameof(SprintRetryTimer));
		return;
	}

	AnimName = GetSprintStartAnimName();

	if( Instigator.IsLocallyControlled() )
	{
		KFPC = KFPlayerController(Instigator.Controller);
		if ( KFPC != None )
		{
			KFPC.HandleTransitionFOV(PlayerSprintFOV, 0.25);
		}

		PlayAnimation( AnimName );
	}

	// set timer to begin the looping state
	AnimDuration = MySkelMesh.GetAnimLength( AnimName );
	if ( AnimDuration > 0.f )
	{
		SetTimer(AnimDuration, false, nameof(SprintLoopTimer));
	}
	else
	{
		SprintLoopTimer();
	}
}

/** Get sprint start anim name (overridden as necessary) */
simulated function name GetSprintStartAnimName()
{
	return SprintStartAnim;
}

simulated function PlaySprintLoop()
{
	local name AnimName;

	if( Instigator.IsLocallyControlled() )
	{
		AnimName = GetSprintLoopAnimName();

		SprintAnimRate = GetSprintAnimRate();

		if (SprintCameraAnimInst != None)
		{
			SprintCameraAnimInst.Stop(TRUE);
		}

		if (SprintCameraAnim != None)
		{
			SprintCameraAnimInst = PlayCameraAnim(SprintCameraAnim, SprintAnimRate, SprintAnimRate, 0.3, 0.5, true, true);
		}

		PlayAnimation(AnimName, MySkelMesh.GetAnimLength(AnimName) / SprintAnimRate, true);
	}
}

/** Get sprint loop anim name (overridden as necessary) */
simulated function name GetSprintLoopAnimName()
{
	return SprintLoopAnim;
}

simulated function PlaySprintEnd()
{
	local KFPlayerController KFPC;
	local name AnimName;

	if ( Instigator.IsLocallyControlled() )
	{
		AnimName = GetSprintEndAnimName();

		KFPC = KFPlayerController(Instigator.Controller);
		if ( KFPC != None && !bUsingSights )
		{
			KFPC.HandleTransitionFOV(KFPC.DefaultFOV, 0.25);
		}

		PlayAnimation(AnimName);
	}
}

/** Get sprint end anim name (overridden as necessary) */
simulated function name GetSprintEndAnimName()
{
	return SprintEndAnim;
}

simulated function float GetSprintAnimRate()
{
	return 1.f;
}

/*********************************************************************************************
 * State MeleeAttackBasic
 * This is a basic melee state that's used as a base for other more advanced states
 *********************************************************************************************/

/** Is this weapon currently in a melee attack firemode/state */
simulated function bool IsMeleeing();
/** Checks to see if we can perform another melee strike without changing states */
simulated function bool ShouldContinueMelee(optional int ChainCount);
/** Notification from the melee helper that a melee strike connected */
simulated function NotifyMeleeCollision(Actor HitActor, optional vector HitLocation);

/**
 * state MeleeAttackBasic
 * State the weapon is in when doing a melee attack
 */
simulated state MeleeAttackBasic
{
	ignores AllowSprinting, AllowIronSights;

	simulated function bool IsMeleeing() { return TRUE; }

	simulated function BeginState(Name PreviousStateName)
	{
		local KFPerk InstigatorPerk;

		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
		}

		// Leave ironsights
		if ( bUsingSights )
		{
			ZoomOut(false, default.ZoomOutTime);
		}

		TimeWeaponFiring(CurrentFireMode);
		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		ClearZedTimeResist();
		ClearTimer( nameof(RefireCheckTimer) );
		NotifyEndState();
	}

    /** Override BeginFire so that it will enter the firing state right away.
     *  @dweiss - Copied from state active in Weapon.uc. Melee weapons were skipping
     *            this code path on servers when quickly activating parry.
     */
    simulated function BeginFire(byte FireModeNum)
    {
        if (!bDeleteMe && Instigator != None)
        {
            Global.BeginFire(FireModeNum);

            // in the active state, fire right away if we have the ammunition
            if (PendingFire(FireModeNum) && HasAmmo(FireModeNum))
            {
                SendToFiringState(FireModeNum);
            }
        }
    }

	/** Allow the MeleeAttackHelper to do damage and setup timing */
	simulated function TimeWeaponFiring(byte FireModeNum)
	{
		// For standard melee attacks, use the helper object
		MeleeAttackHelper.BeginMeleeAttack();

		// Unless this a loop/chain attack, clear pending fire.
		// Do this at the beginning of an attack not the end, just like WeaponSingleFiring
		if( PendingFire(CurrentFireMode) && !ShouldContinueMelee() )
		{
			ClearPendingFire(CurrentFireMode);
		}
	}

	simulated function byte GetWeaponStateId()
	{
		return WEP_MeleeBasic;
	}

	/** Gets the current animation rate, scaled or not */
	simulated function float GetThirdPersonAnimRate()
	{
		local float ScaledRate;

		ScaledRate = 1.0f;
		ModifyMeleeAttackSpeed(ScaledRate, CurrentFireMode);

		return 1.f / ScaledRate;
	}
}

/** Called from the MeleeHelper class to allow for the weapon to override settings */
simulated function PlayMeleeAnimation(name AnimName, out float out_Rate, float BlendTime)
{
	local float Duration;

	ModifyMeleeAttackSpeed(out_Rate, CurrentFireMode);
	Duration = MySkelMesh.GetAnimLength(AnimName);
	Duration *= out_Rate; // scale by desired rate
	PlayAnimation(AnimName, Duration,, BlendTime);
}

simulated function int GetModifiedDamage(byte FireModeNum, optional vector RayDir)
{
	return GetUpgradedStatValue(InstantHitDamage[FireModeNum], FireModeNum == 0 ? EWUS_Damage0 : EWUS_Damage1, CurrentWeaponUpgradeIndex);
}

/** returns the damage amount for this attack */
simulated function int GetMeleeDamage(byte FireModeNum, optional vector RayDir)
{
	return InstantHitDamage[FireModeNum];
}

/*********************************************************************************************
 * State WeaponSingleFireAndReload
 * Fires a single shot and then calls ForceReload(). For server-side projectiles we also
 * sync the firing state because of ammo/state sync issues.
 *********************************************************************************************/

simulated function float GetForceReloadDelay();

/** Detect/fix single fire projectile weapon network synchronization errors */
reliable private server function ServerSyncWeaponFiring( byte FireModeNum )
{
	local bool bNeedsToSync;

	if( IsInState('Reloading') )
	{
		// Perform our reload if we haven't yet
		if( ReloadStatus == RS_Reloading && IsTimerActive(nameOf(ReloadAmmoTimer)) )
		{
			PerformReload();
			ClearTimer( nameOf(ReloadAmmoTimer) );
		}

		// Flag reload as complete
		ReloadStatus = RS_Complete;

		// May have not recieved ServerSyncReload yet!  Do something!
		if ( bAllowClientAmmoTracking && !HasAmmo(FireModeNum) )
		{
			ServerSyncReload(InitialReloadSpareAmmo - 1);
		}

		bNeedsToSync = true;
	}
	else if( IsInState('WeaponEquipping') || IsInState('MeleeAttackBasic') || IsInState('WeaponSprinting') )
	{
		bNeedsToSync = true;
	}

	if( bNeedsToSync )
	{
		// Move immediately to the firing state, as long as we have ammo
		if( HasAmmo(FireModeNum) )
		{
			SendToFiringState( FireModeNum );
		}
		else
		{
			`warn("KFWeapon::ServerSyncWeaponFiring()."$GetStateName()$" - Failed to sync weapon ammo.");
		}
	}
}

simulated state WeaponSingleFireAndReload extends WeaponSingleFiring
{
	// It is technically possible for ServerSyncWeaponFiring to call before the ServerSyncReload in the Reload state.
	// If this happens, we don't want to allow ServerSyncReload to be called twice.
	ignores ServerSyncReload;

	simulated function FireAmmunition()
	{
		local float ReloadDelay;

		Super.FireAmmunition();

		if( Instigator.IsLocallyControlled() )
		{
			if( HasSpareAmmo() )
			{
				ReloadDelay = GetForceReloadDelay();
				if ( ReloadDelay > 0.f )
				{
					SetTimer( ReloadDelay + GetFireInterval(CurrentFireMode), false, nameOf(ForceReload) );
				}
				else
				{
					// Reload after every shot, sets PendingFire for next 'active' state entry
					StartFire( RELOAD_FIREMODE );
				}
			}

			if( Instigator.Role < ROLE_Authority )
			{
				ServerSyncWeaponFiring( CurrentFireMode );
			}
		}
	}
}

///////////////////////////////////////////////////////////////////////////////////////////
//
// Trader
//
///////////////////////////////////////////////////////////////////////////////////////////

/** Allows weapon to calculate its own stats for display in trader */
static simulated event SetTraderWeaponStats( out array<STraderItemWeaponStats> WeaponStats )
{
	WeaponStats.Length = 4;

	WeaponStats[0].StatType = TWS_Damage;
	WeaponStats[0].StatValue = CalculateTraderWeaponStatDamage();

	WeaponStats[1].StatType = TWS_Penetration;
	WeaponStats[1].StatValue = default.PenetrationPower[DEFAULT_FIREMODE];

	WeaponStats[2].StatType = TWS_Range;
	// This is now set in native since EffectiveRange has been moved to KFWeaponDefinition
	//WeaponStats[2].StatValue = CalculateTraderWeaponStatRange();

	WeaponStats[3].StatType = TWS_RateOfFire;
	WeaponStats[3].StatValue = CalculateTraderWeaponStatFireRate();
}

/** Allows weapon to calculate its own damage for display in trader */
static simulated function float CalculateTraderWeaponStatDamage()
{
	local float BaseDamage, DoTDamage;
	local class<KFDamageType> DamageType;

	BaseDamage = default.InstantHitDamage[DEFAULT_FIREMODE];

	DamageType = class<KFDamageType>(default.InstantHitDamageTypes[DEFAULT_FIREMODE]);
	if (DamageType != none && DamageType.default.DoT_Type != DOT_None)
	{
		DoTDamage = (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (BaseDamage * DamageType.default.DoT_DamageScale);
	}

	return BaseDamage * default.NumPellets[DEFAULT_FIREMODE] + DoTDamage;
}

/** Allows weapon to calculate its own fire rate for display in trader */
static simulated function float CalculateTraderWeaponStatFireRate()
{
	return 60.f / default.FireInterval[DEFAULT_FIREMODE]; // attacks per minute
}

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter();

static simulated event EFilterTypeUI GetAltTraderFilter()
{
	return FT_None;
}

// when the weapon was pending equip and then overriden by another pending equip
simulated function NotifyRemovedPending();

defaultproperties
{
	Begin Object class=KFAnimSeq_Tween Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object

	Begin Object Class=KFSkeletalMeshComponent Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_Foreground
		bOnlyOwnerSee=true
		CastShadow=true
		bCastDynamicShadow=true
		bAllowPerObjectShadows=true
		bAllowBooleanPreshadows=false
		bOverrideAttachmentOwnerVisibility=true
		bPerBoneMotionBlur=false
		bUpdateSkelWhenNotRendered=true // always update so we get notifies in third person
		//Animations=MeshSequenceA
		AnimTreeTemplate=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Animtree_Master'
		// Default to outdoor. If indoor, this will be set when TWIndoorLightingVolume::Touch() event is received at spawn.
		LightingChannels=(Outdoor=TRUE,bInitialized=TRUE)
	End Object
	Mesh=FirstPersonMesh

	/** Default pickup mesh */
	Begin Object Class=StaticMeshComponent Name=StaticPickupComponent
		StaticMesh=StaticMesh'EngineMeshes.Cube'
		CastShadow=false
	End Object
	PickupFactoryMesh=StaticPickupComponent
	DroppedPickupMesh=StaticPickupComponent
	DroppedPickupClass=class'KFDroppedPickup'

	// Ignore third person pawn rotation (handled by SetPosition)
	// Now, calling P.SetRotation() after SetPosition is called will no longer cause problems
	bIgnoreBaseRotation=true

	// FOV
	MeshFOV=86
	MeshIronSightFOV=75
	PlayerIronSightFOV=75
	PlayerSprintFOV=95

	// Depth of field
	DOF_bOverrideEnvironmentDOF=true
	DOF_SharpRadius=500.0
	DOF_FocalRadius=1000.0
	DOF_MinBlurSize=0.0
	DOF_MaxNearBlurSize=2.0
	DOF_MaxFarBlurSize=0.0
	DOF_ExpFalloff=1.0
	DOF_MaxFocalDistance=2000.0

	DOF_BlendInSpeed=1.0
	DOF_BlendOutSpeed=1.0

	DOF_FG_FocalRadius=50
	DOF_FG_SharpRadius=0
	DOF_FG_MinBlurSize=0
	DOF_FG_MaxNearBlurSize=3
	DOF_FG_ExpFalloff=1

	// Zooming/Position
	PlayerViewOffset=(X=1.0,Y=9,Z=-3)
	IronSightPosition=(X=0,Y=0,Z=0)
	ZoomInTime=0.15
	ZoomOutTime=0.15
	FastZoomOutTime=0.1
	ZoomInRotation=(Pitch=-910,Yaw=0,Roll=2910)
	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=16384)
	QuickWeaponDownTime=0.4
	QuickWeaponDownFinishTime=0.2

	// DEFAULT_FIREMODE
	FireModeIconPaths[DEFAULT_FIREMODE]=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	FireInterval(DEFAULT_FIREMODE)=+1.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic'
	InstantHitMomentum(DEFAULT_FIREMODE)=1.0
	PenetrationPower(DEFAULT_FIREMODE)=0.0
	PenetrationDamageReductionCurve(DEFAULT_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f)))
	AmmoCost(DEFAULT_FIREMODE)=1

	// ALTFIRE_FIREMODE
	FireModeIconPaths[ALTFIRE_FIREMODE]=none
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	FireInterval(ALTFIRE_FIREMODE)=+1.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic'
	InstantHitMomentum(ALTFIRE_FIREMODE)=1.0
	PenetrationPower(ALTFIRE_FIREMODE)=0.0
	PenetrationDamageReductionCurve(ALTFIRE_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f)))
	AmmoCost(ALTFIRE_FIREMODE)=1

	// RELOAD
	FiringStatesArray(RELOAD_FIREMODE)="Reloading"
	WeaponFireTypes(RELOAD_FIREMODE)=EWFT_InstantHit

	// Pickup
    AmmoPickupScale[0]=1.0
    AmmoPickupScale[1]=1.0

	// BASH_FIREMODE
	FiringStatesArray(BASH_FIREMODE)=MeleeAttackBasic
	WeaponFireTypes(BASH_FIREMODE)=EWFT_Custom
	InstantHitMomentum(BASH_FIREMODE)=30000.f
	InstantHitDamage(BASH_FIREMODE)=15.0

	// GRENADE_FIREMODE
	FiringStatesArray(GRENADE_FIREMODE)=GrenadeFiring
	WeaponFireTypes(GRENADE_FIREMODE)=EWFT_Projectile
	FireInterval(GRENADE_FIREMODE)=0.6
	GrenadeFireOffset=(X=25,Y=-15)
	GrenadeTossWeakZedGrabCooldown=1.0

	// spread variables
	IronSightsSpreadMod=0.5
	CrouchSpreadMod=0.75
	MovingSpreadMod=1.0

	// recoil variables
	RecoilRate=0.09
	RecoilBlendOutRatio=1.25
	LastRecoilModifier=1.0
	RecoilMaxYawLimit=2000
	RecoilMinYawLimit=63535
	RecoilMaxPitchLimit=1500
	RecoilMinPitchLimit=64035
	RecoilISMaxYawLimit=500
	RecoilISMinYawLimit=65035
	RecoilISMaxPitchLimit=350
	RecoilISMinPitchLimit=65185
	RecoilViewRotationScale=0.4
	FullRecoilPitchPct=0.75
	FullRecoilYawPct=0.75
	RecoilCompensationScale=1.5
	SuppressRecoilSpeed=0.08
	SuppressRecoilViewRotationScale=0.5
	WalkingRecoilModifier=1.25
	JoggingRecoilModifier=1.5
	FallingRecoilModifier=1.0
	HippedRecoilModifier=1.75
	StanceCrouchedRecoilModifier=0.75
	IronSightMeshFOVCompensationScale=1.0

	// Weaponlag
	LagTensionHorizontal=0.8
	LagVerticalTension=0.8
	LagResistanceHorizontal=0.2
	LagResistanceVertical=0.2
	LagLimit=5.0
	LagYawCoefficient=0.00005 // 0.00005 = Approx 3.25/65535.0 Represents 3.25 linear units per second == 360(65535) degrees per second.
	LagStrengthIronSights=3.0
	LagStrengthWalk=0.7
	LagStrengthJog=0.6
	LagStrengthSprint=0.5
	LagStrengthCrouch=1.5
	StrafeLagLimit=4.0
	StrafeLagRate=0.025
	StrafeLagReturnRate=10.0

	// Melee
	Begin Object Class=KFMeleeHelperWeapon Name=MeleeHelper_0
		bUseMeleeHitTimer=false
		MaxHitRange=175
	End Object
	MeleeAttackHelper=MeleeHelper_0

	// Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=()
	ShakeScaleStandard=1.0
	ShakeScaleSighted=0.4
	SingleFireSoundIndex=FIREMODE_NONE
	NumBloodMapMaterials=1

	BobDamping=0.85000
	JumpDamping=1.0

	LaserSightTemplate=KFLaserSightAttachment'FX_LaserSight_ARCH.Default_LaserSight_1P'

	// Animation Blending
	DefaultAnimSpeed=1.0
	FireTweenTime=0.05
	bUseAdditiveMoveAnim=true

	//////////////////////////////////////
	// Animation Names
	/////////////////////////////////////
	// Shooting Animations
	FireAnim=Shoot
	FireSightedAnims[0]=Shoot_Iron
	FireLastAnim=Shoot_Last
	FireLastSightedAnim=Shoot_Iron_Last
	FireLoopAnim=ShootLoop
	FireLoopSightedAnim=ShootLoop_Iron
	FireLoopEndLastAnim=ShootLoop_End_Last
	FireLoopEndLastSightedAnim=ShootLoop_Iron_End_Last

	// Equip/Idle
	PutDownAnim=PutAway
	EquipAnim=Equip
	IdleAnims(0)=Idle
	IdleSightedAnims(0)=Idle_Iron
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3)

	// Advanced Looping (High RPM) Fire Effects
	FireLoopStartAnim=ShootLoop_Start
	FireLoopStartSightedAnim=ShootLoop_Iron_Start
	FireLoopEndAnim=ShootLoop_End
	FireLoopEndSightedAnim=ShootLoop_Iron_End

	// melee
	MeleeAttackAnims=(Bash)

	// Equip/PutDown
	EquipTime=+0.45
	PutDownTime=+0.33
	MinFiringPutDownPct=0.80
	bUseAnimLenEquipTime=true

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Default_Recoil'

	BonesToLockOnEmpty=(RW_Bolt)

	// inventory
	InventoryGroup=IG_Primary
	GroupPriority=0
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_AR15'
	SecondaryAmmoTexture=Texture2D'UI_SecondaryAmmo_TEX.GasTank'
	bCanRefillSecondaryAmmo=true
	bUseGrenadeAsSecondaryAmmo=false
	bNoMagazine=false
	bAllowClientAmmoTracking=true

	// Aim assist
    bTargetFrictionEnabled=True
	TargetFrictionDistanceMax=4000.0f
    bTargetAdhesionEnabled=True
    TargetAdhesionDistanceMax=2000.0f

 	// AI Warning
    MaxAIWarningDistSQ=6250000
    MaxAIWarningDistFromPointSQ=5625

    TargetAdhesionDistanceScaleCurve={(Points=((InVal=0.100000,OutVal=1.000000),
    											(InVal=0.200000,OutVal=0.600000),
    											(InVal=0.300000,OutVal=0.400000),
    											(InVal=0.400000,OutVal=0.300000,InterpMode=CIM_CurveAuto),
    											(InVal=1.000000,OutVal=0.000000,InterpMode=CIM_CurveAuto)))}
    TargetAdhesionOffsetScaleCurve={(Points=((InVal=0.000000,OutVal=1.000000),
    										(InVal=0.700000,OutVal=0.700000,InterpMode=CIM_CurveAuto),
    										(InVal=1.000000,OutVal=0.000000,InterpMode=CIM_CurveAuto)))}

    TargetFrictionDistanceScaleCurve={(Points=((InVal=0.500000,OutVal=1.000000,InterpMode=CIM_CurveAuto),
    											(InVal=0.800000,OutVal=0.800000,InterpMode=CIM_CurveAuto),
    											(InVal=1.000000,OutVal=0.000000,InterpMode=CIM_CurveAuto)))}
    TargetFrictionOffsetScaleCurve={(Points=((InVal=0.000000,OutVal=1.000000),
    										(InVal=0.900000,OutVal=0.900000,InterpMode=CIM_CurveAuto),
    										(InVal=1.000000,OutVal=0.000000,InterpMode=CIM_CurveAuto)))}

	// This needs to remain, this is the base for all weapons that are not upgraded.
	WeaponUpgrades[0]=(Stats=((Stat=EWUS_Damage0, Scale=1.f, Add=0), (Stat=EWUS_Weight, Scale=1.f, Add=0)))

	// NOTE: In general, a weapon upgrade is applied by taking the base stat value, multiplying it by "Scale", and then adding "Add", i.e. (Base * Scale) + Add
	// For example,
	//		WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=2.f, Add=10))) on a weapon with a base primary damage of 20
	// will set the upgraded primary weapon damage to 50 ((Base * Scale) + Add) --> ((20 * 2) + 10)

	// NOTE: To set an upgraded stat to an absolute (i.e. not relative) value, set "Scale" to 0.f and "Add" to the absolute value.
	// For example,
	//		WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=0.f, Add=50))) on a weapon with a base primary damage of 20
	// will set the upgraded primary weapon damage to 50 ((Base * Scale) + Add) --> ((20 * 0) + 50)

	UpgradeFireModes(DEFAULT_FIREMODE)=0
	UpgradeFireModes(ALTFIRE_FIREMODE)=1
	UpgradeFireModes(RELOAD_FIREMODE)=0
	UpgradeFireModes(BASH_FIREMODE)=2
	UpgradeFireModes(GRENADE_FIREMODE)=0

	MovementSpeedMod=1.f;
	OverrideGroundSpeed=-1.f; // defaults to -1 (disabled)
	OverrideSprintSpeed=-1.f; // defaults to -1 (disabled)

	bStorePreviouslyEquipped=true

	NumPellets(DEFAULT_FIREMODE)=1
	NumPellets(ALTFIRE_FIREMODE)=1
	NumPellets(BASH_FIREMODE)=1
	NumPellets(GRENADE_FIREMODE)=1
	NumPellets(CUSTOM_FIREMODE)=1

	bKeepIronSightsOnJump=false

	bUsesSecondaryAmmoAltHUD=false
	bForceHandleImpacts=false
}

