Type TStarfarerShip
	Field bounds#[]
	Field center#[]
	Field collisionRadius#
	Field engineSlots:TStarfarerShipEngine[]
	Field height#
	Field width#
	Field hullId$
	Field hullName$
	Field hullSize$
	Field shieldCenter#[]
	Field shieldRadius#
	Field spriteName$
	Field style$
	Field viewOffset#
	Field weaponSlots:TStarfarerShipWeapon[]
	
	Method New()
		bounds = New Float[0]
		center = [ 0.0, 0.0 ]
		shieldCenter = [ 0.0, 0.0 ]
		engineSlots = New TStarfarerShipEngine[0]
		weaponSlots = New TStarfarerShipWeapon[0]
		hullId = "new_hull_id"
		hullName = "New Hull"
		hullSize = "CAPITAL_SHIP"
		spriteName = "graphics/ships/sprite.png"
		style = "HIGH_TECH"
	End Method
End Type

