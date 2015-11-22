Type TStarfarerWeapon
	Field id$
	Field specClass$
	Field type_$
	Field size$
	Field turretSprite$
	Field turretUnderSprite$
	Field turretGunSprite$
	Field turretGlowSprite$
	Field hardpointSprite$
	Field hardpointUnderSprite$
	Field hardpointGunSprite$
	Field hardpointGlowSprite$
	Field everyFrameEffect$
	Field displayArcRadius#
	Field numFrames% 
	Field frameRate# 
	Field visualRecoil#
	Field renderHints$[]
	Field fringeColor%[]
	Field coreColor%[]
	Field glowColor%[]
	Field darkCore%
	Field convergeOnPoint%
	Field width#
	Field height#
	Field textureType:Object 'String, String[]
	Field textureScrollSpeed#
	Field pixelsPerTexel#
	Field turretOffsets#[]
	Field turretAngleOffsets#[]
	Field hardpointOffsets#[]
	Field hardpointAngleOffsets#[]
	Field barrelMode$
	Field animationType$
	Field interruptibleBurst%
	Field muzzleFlashSpec:TStarfarerWeaponMuzzleFlashSpec
	Field smokeSpec:TStarfarerWeaponSmokeSpec
	Field projectileSpecId$
	Field pierceSet$[]
	Field autocharge%
	Field requiresFullCharge%
	Field fireSoundOne$
	Field fireSoundTwo$
	Field specialWeaponGlowHeight#
	Field specialWeaponGlowWidth#
	Field alwaysAnimate$
	Field renderBelowAllWeapons%
	Field showDamageWhenDecorative%
	Field collisionClass$
	Field collisionClassByFighter$
	Field beamFireOnlyOnFullCharge%
	Field beamEffect$

	Method New()
	End Method
EndType


Function predicate_omit_if_single_frame%( val:TValue, root:TValue )
	'omit val if numFrames <= 1 or does not exist
	Local numFrames:TNumber = TNumber(TObject(root).Get("numFrames"))
	If numFrames <> Null
		Return numFrames.value <= 1.0
	Else
		Return True
	EndIf
EndFunction

Function predicate_omit_if_single_barrel%( val:TValue, root:TValue )
	'omit val if turretAngleOffsets.length <= 1
	Local turretAngleOffsets:TArray = TArray(TObject(root).Get("turretAngleOffsets"))
	Return turretAngleOffsets.elements.Count() <= 1
EndFunction

Function predicate_omit_if_not_muzzle_flash%( val:TValue, root:TValue )
	'omit muzzleFlashSpec if animationType != MUZZLE_FLASH
	Local animationType:TString = TString(TObject(root).Get("animationType"))
	Return animationType.value <> "MUZZLE_FLASH"
EndFunction

Function predicate_omit_if_not_type_energy%( val:TValue, root:TValue )
	'omit val if type != ENERGY
	Local type_:TString = TString(TObject(root).Get("type"))
	Return type_.value <> "ENERGY"
EndFunction

Function predicate_omit_if_not_type_missile%( val:TValue, root:TValue )
	'omit val if type != ENERGY
	Local type_:TString = TString(TObject(root).Get("type"))
	Return type_.value <> "MISSILE"
EndFunction

Function predicate_omit_if_not_type_ballistic%( val:TValue, root:TValue )
	'omit val if type != ENERGY
	Local type_:TString = TString(TObject(root).Get("type"))
	Return type_.value <> "BALLISTIC"
EndFunction

