
Type TModalSetVariant Extends TSubroutine
	Const MAX_WEAPON_GROUPS% = 5
	Field MAX_GROUP_OFFSET% = (MAX_WEAPON_GROUPS - 1) '[ 0, 1, 2, 3, 4 ]
	'///
	Field i%,g%
	Field ni%
	Field wi%
	Field line_i%
	Field img_x#,img_y#
	Field wx%,wy%
	Field x%,y%
	Field w%,h%
	Field fg_color%
	Field count%
	Field left_click%
	Field found%
	Field modified%
	Field nearest%
	Field display_str$
	Field skip_lines%
	'///
	Field wep_op_str$
	Field weapon_slot_id$
	Field weapon_id$
	Field weapon_name$
	Field weapon_slot_ids$[]
	Field weapon_ids$[]
	Field weapon_list$[]
	Field wep_i%
	Field weapon_stats:TMap
	Field weapon_slot:TStarfarerShipWeapon
	Field weapon_list_widget:TextWidget
	Field wep_names$
	Field wep_names_tw:TextWidget
	Field wep_g_tw:TextWidget	
	Field op_current%
	Field op_max%
	Field op_str$
	Field op_widget:TextWidget
	Field group_i%
	Field group_offsets%[]
	Field group:TStarfarerVariantWeaponGroup
	Field wep_g$
	Field wep_g_a$
	Field wep_g_i$
	Field fluxMods_max%
	Field selected_hullMod:TMap
	Field hullMods_count%
	Field hullMod:TMap
	Field hullMods:TMap[]
	Field hullMods_lines$[]
	Field hullMods_c$[]
	Field hullmod_id$ 
	Field hullmod_op% 
	Field hullMods_widget:TextWidget
	Field hullMods_cursor:TextWidget
	'///
	Field cursor_widget:TextWidget

	Method Activate( ed:TEditor, data:TData, sprite:TSprite )
		ed.program_mode = "variant"
		ed.last_mode = "normal"
		ed.mode = "normal"
		ed.weapon_lock_i = -1
		ed.variant_hullMod_i = -1
		ed.group_field_i = -1
		'clear key queues
		MouseHit( MOUSE_LEFT )
	EndMethod

	Method Update( ed:TEditor, data:TData, sprite:TSprite )
		If Not data.ship.center Then Return
		fluxMods_max = ed.get_max_fluxMods( data.ship.hullSize )
		hullMods_count = count_keys( ed.stock_hullmod_stats )
		'get input
		left_click = MouseHit( 1 )
		sprite.get_img_xy( MouseX(), MouseY(), img_x, img_y )
		'locate nearest entity
		ni = data.find_nearest_variant_weapon_slot( img_x, img_y )
		
		'choose a weapon from a nice vertical list for the clicked slot
		If ed.weapon_lock_i <> -1
			'load valid weapons list for the slot
			weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
			weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
			'bounds enforce (extra check)
			If ed.select_weapon_i > (weapon_list.length - 1)
				ed.select_weapon_i = (weapon_list.length - 1)
			ElseIf ed.select_weapon_i < 0
				ed.select_weapon_i = 0
			EndIf
			'process input
			If KeyHit( KEY_ENTER )
				data.unassign_weapon_from_slot( weapon_slot.id )
				data.assign_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i], 0 )
				data.update_variant()
				ed.weapon_lock_i = -1
			EndIf
			If KeyHit( KEY_ESCAPE )
				ed.weapon_lock_i = -1
			EndIf
			If KeyHIT( KEY_BACKSPACE ) And ed.variant_hullMod_i = -1
				data.unassign_weapon_from_slot( weapon_slot.id )
				data.update_variant()
				ed.weapon_lock_i = -1
			EndIf
			modified = False
			If KeyHit( KEY_DOWN )
				ed.select_weapon_i :+ 1
				If ed.select_weapon_i > (weapon_list.length - 1)
					ed.select_weapon_i = (weapon_list.length - 1)
				Else
					modified = True
				EndIf
			EndIf
			If KeyHit( KEY_UP )
				ed.select_weapon_i :- 1
				If ed.select_weapon_i < 0
					ed.select_weapon_i = 0
				Else
					modified = True
				EndIf
			EndIf
			If modified
				data.unassign_weapon_from_slot( weapon_slot.id )
				data.assign_weapon_to_slot( weapon_slot.id, weapon_list[ed.select_weapon_i], 0 )
				data.update_variant()
			EndIf
		
		'use the mouse to choose a slot to select
		Else 'ed.weapon_lock_i = -1
			If ni <> -1
				weapon_slot = data.ship.weaponSlots[ni]
				'select weapon slot to assign weapon to
				'block attempts to assign if the weapon is considered built-in
				If left_click And Not weapon_slot.is_builtin()
					ed.weapon_lock_i = ni
					'try to find currently assigned weapon and select it in the list
					weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
					found = false
					For group = EachIn data.variant.weaponGroups
						For weapon_slot_id = EachIn group.weapons.Keys()
							If weapon_slot.id = weapon_slot_id
								weapon_id = String( group.weapons.ValueForKey( weapon_slot_id ))
								For i = 0 Until weapon_list.length
									If weapon_list[i] = weapon_id
										ed.select_weapon_i = i
										found = true
										Exit
									EndIf
								Next
								If found Then Exit
							EndIf
						Next
						If found Then Exit
					Next
				EndIf
				'can't let user strip built-in weapon slots either
				If KeyHIT( KEY_BACKSPACE ) And Not weapon_slot.is_builtin()
					data.unassign_weapon_from_slot( weapon_slot.id )
					data.update_variant()
				EndIf
			EndIf
			If KeyHit( KEY_F )
				data.modify_fluxVents( fluxMods_max, SHIFT Or CONTROL Or ALT )
				data.update_variant()
			EndIf
			If KeyHit( KEY_C )
				data.modify_fluxCapacitors( fluxMods_max, SHIFT Or CONTROL Or ALT )
				data.update_variant()
			EndIf
			
			'selecting a hullmod
			If ed.variant_hullMod_i <> -1
				hullMods = New TMap[hullMods_count]
				i = 0
				For hullMod = EachIn ed.stock_hullmod_stats.Values()
					hullMods[i] = hullMod
					if i = ed.variant_hullMod_i
						selected_hullMod = hullMod
					Endif
					i :+ 1
				Next
				'bounds enforce (extra check)
				If ed.variant_hullMod_i > (hullMods_count - 1)
					ed.variant_hullMod_i = (hullMods_count - 1)
				ElseIf ed.select_weapon_i < 0
					ed.variant_hullMod_i = 0
				EndIf
				'process input
				If KeyHit( KEY_ENTER )
					'add/remove hullmod
					data.toggle_hullmod( String( selected_hullMod.ValueForKey("id")) )
					data.update_variant()
				EndIf
				If KeyHit( KEY_DOWN )
					ed.variant_hullMod_i :+ 1
				EndIf
				If KeyHit( KEY_UP )
					ed.variant_hullMod_i :- 1
				EndIf
				'bounds enforce
				If ed.variant_hullMod_i > (hullMods_count - 1)
					ed.variant_hullMod_i = (hullMods_count - 1)
				ElseIf ed.variant_hullMod_i < 0
					ed.variant_hullMod_i = 0
				EndIf
				If KeyHit( KEY_ESCAPE )
					ed.variant_hullMod_i = -1
				EndIf
				If KeyHIT( KEY_H )
					ed.variant_hullMod_i = -1
				EndIf
			Else
				'allow to select a hullmod
				If KeyHIT( KEY_H )
					ed.variant_hullMod_i = 0
				EndIf
			EndIf

			'edit weapon groups
			If ed.group_field_i <> -1
				For g = 0 Until data.variant.weaponGroups.length
					count :+ count_keys( data.variant.weaponGroups[g].weapons )
				Next
				weapon_slot_ids = new String[count]
				weapon_ids = new String[count]
				group_offsets = new Int[count]
				group_i = 0
				wep_i = 0
				For group = EachIn data.variant.weaponGroups
					For weapon_slot_id = EachIn group.weapons.Keys()
						weapon_slot_ids[wep_i] = weapon_slot_id
						weapon_ids[wep_i] = String( group.weapons.ValueForKey( weapon_slot_id ))
						group_offsets[wep_i] = group_i
						wep_i :+ 1
					Next
					group_i :+ 1
				Next
				If KeyHit( KEY_DOWN )
					ed.group_field_i :+ 1
					If ed.group_field_i > (count - 1)
						ed.group_field_i = (count - 1)
					Else
						reset_cursor_color_period()
					EndIf
				EndIf
				If KeyHit( KEY_UP )
					ed.group_field_i :- 1
					If ed.group_field_i < 0
						ed.group_field_i = 0
					Else
						reset_cursor_color_period()
					EndIf
				EndIf
				modified = False
				If KeyHit( KEY_RIGHT )
					If group_offsets[ed.group_field_i] < MAX_GROUP_OFFSET
						data.unassign_weapon_from_slot( weapon_slot_ids[ed.group_field_i] )
						data.assign_weapon_to_slot( weapon_slot_ids[ed.group_field_i], weapon_ids[ed.group_field_i], group_offsets[ed.group_field_i] + 1 )
						data.update_variant()
						modified = True
						reset_cursor_color_period()
					EndIf
				EndIf
				If KeyHit( KEY_LEFT )
					If group_offsets[ed.group_field_i] > 0
						data.unassign_weapon_from_slot( weapon_slot_ids[ed.group_field_i] )
						data.assign_weapon_to_slot( weapon_slot_ids[ed.group_field_i], weapon_ids[ed.group_field_i], group_offsets[ed.group_field_i] - 1 )
						data.update_variant()
						modified = True
						reset_cursor_color_period()
					EndIf
				EndIf
				If KeyHit( KEY_A )
					data.toggle_weapon_group_autofire( group_offsets[ed.group_field_i] )
					data.update_variant()
				EndIf
				If modified
					reset_cursor_color_period()
					'locate slot again
					wep_i = 0
					For group = EachIn data.variant.weaponGroups
						For weapon_slot_id = EachIn group.weapons.Keys()
							If weapon_slot_id = weapon_slot_ids[ed.group_field_i]
								ed.group_field_i = wep_i
								Exit
							EndIf
							wep_i :+ 1
						Next
					Next
				EndIf
				If KeyHit( KEY_ESCAPE )
					ed.group_field_i = -1
				EndIf
				'editing groups
				If KeyHit( KEY_G )
					ed.group_field_i = -1
				EndIf
			Else
				'allow to edit groups
				If KeyHit( KEY_G )
					ed.group_field_i = 0
				EndIf
			EndIf
		EndIf
	End Method

	Method Draw( ed:TEditor, data:TData, sprite:TSprite ) 
		If Not data.ship.center Then Return
		'draw HUD
		op_current = calc_variant_used_ordnance_points( ed, data )
		op_max = get_ship_csv_ordnance_points( ed, data )
		fg_color = $FFFFFF
		If op_current > op_max Then fg_color = $FF2020
		op_str = ..
			"   Ordnance Points  "+op_current+"/"+op_max+"~n"+..
			"        Flux Vents  "+data.variant.fluxVents+"~n"+..
			"   Flux Capacitors  "+data.variant.fluxCapacitors+"~n"+..
			"Hull Modifications  "+data.variant.hullMods.length+"x"
		op_widget = TextWidget.Create( op_str )
		draw_container( W_MID,3-10, op_widget.w+20,op_widget.h+20, 0.5,0.0 )
		draw_string( op_widget, W_MID,3, fg_color,$000000, 0.5,0.0 )
		
		If ed.weapon_lock_i <> -1
			ni = ed.weapon_lock_i
		End If
		'prepare to show list of weapons
		If ed.weapon_lock_i <> -1
			weapon_slot = data.ship.weaponSlots[ed.weapon_lock_i]
			weapon_list = ed.select_weapons( weapon_slot.type_, weapon_slot.size )
			For wi = 0 Until weapon_list.length
				weapon_id = weapon_list[wi]
				weapon_stats = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
				If weapon_stats
					weapon_name = String( weapon_stats.ValueForKey( "name" ))
					wep_op_str = String( weapon_stats.ValueForKey( "OPs" ))
					If weapon_name
						weapon_list[wi] = RSet(wep_op_str,3)+"  "+weapon_name
					EndIf
				Endif
			Next
			weapon_list_widget = TextWidget.Create( weapon_list )
			cursor_widget = TextWidget.Create( weapon_list[..] )
			For i = 0 Until cursor_widget.lines.length
				If i <> ed.select_weapon_i
					cursor_widget.lines[i] = ""
				Else 'is current
					'do nothing
				EndIf
			Next
		EndIf
		If ed.group_field_i = -1
			'draw pointers
			nearest = false
			
			'FIRST PASS: draw text boxes but make "really faint" if zoomed out too far
			For i = 0 Until data.ship.weaponSlots.Length
				If Not data.ship.weaponSlots[i].is_visible_to_variant()
					Continue 'skip these
				EndIf
				weapon_slot = data.ship.weaponSlots[i]
				wx = sprite.sx + ( weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
				wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
				If ni = i
					nearest = True
				Else
					nearest = False
				EndIf
				If Not nearest And ed.weapon_lock_i <> -1 Then Continue ' do not draw other weapons when selecting a weapon
				'TODO: handle weapon slots with multiple locations (launch-bays)
				SetRotation( 0 )
				SetScale( 1, 1 )
				SetAlpha( 1 )
				'draw_dot( wx, wy, nearest )
				If Not nearest
					SetAlpha( Min( 0.5, 0.5*(sprite.scale/3.0) ))
				EndIf
				draw_weapon_slot_info( ed,data,sprite, weapon_slot )
				If Not weapon_list_widget 'the select-a-weapon list will be drawn instead if it's non-null
					draw_assigned_weapon_info( ed,data,sprite, weapon_slot )
				EndIf
			Next
			
			'SECOND PASS: draw slot mount icons
			For i = 0 Until data.ship.weaponSlots.Length
				If Not data.ship.weaponSlots[i].is_visible_to_variant()
					Continue 'skip these
				EndIf
				weapon_slot = data.ship.weaponSlots[i]
				wx = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
				wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
				If ni = i
					nearest = True
				Else
					nearest = False
				EndIf
				If Not nearest And ed.weapon_lock_i <> -1 Then Continue ' do not draw other weapons when selecting a weapon
				'TODO: handle weapon slots with multiple locations (launch-bays)
				SetRotation( 0 )
				SetScale( 1, 1 )
				SetAlpha( 1 )
				'draw_dot( wx, wy, nearest )
				If Not nearest
					SetAlpha( 0.5 )
				EndIf
				draw_variant_weapon_mount( wx, wy, weapon_slot )
			Next
			SetAlpha( 1 )
			
			If ni <> -1
				weapon_slot = data.ship.weaponSlots[ni]
				wx = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
				wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
				For group = EachIn data.variant.weaponGroups
					For weapon_slot_id = EachIn group.weapons.Keys()
						If weapon_slot_id = weapon_slot.id
							weapon_id = String( group.weapons.ValueForKey( weapon_slot_id ))
							Exit
						EndIf
					Next
				Next
				draw_weapon_slot_info( ed,data,sprite, weapon_slot )
				If Not weapon_list_widget 'the select-a-weapon list will be drawn instead if it's non-null
					draw_assigned_weapon_info( ed,data,sprite, weapon_slot )
				EndIf
				draw_variant_weapon_mount( wx, wy, weapon_slot )
				
				If weapon_list_widget
					'select new weapon
					SetColor( 0,0,0 )
					SetRotation( 0 )
					SetScale( 1, 1 )
					SetAlpha( 1 )
					SetImageFont( FONT )
					'draw box around text area
					'if applicable:
					'  draw lines connecting box to target weapon or engine
					'  draw actual weapon or engine preview
					x = wx - weapon_list_widget.w - 20 - 30 'W_MID/2 - weapon_list_widget.w/2 - 10
					y = wy - weapon_list_widget.h/2 - 10 'H_MID/2 - weapon_list_widget.h/2 - 10
					w = weapon_list_widget.w + 20
					h = weapon_list_widget.h + 20
					SetColor( 0,0,0 )
					SetAlpha( 0.40 )
					DrawRect( x,y, w,h )
					SetAlpha( 1 )
					SetColor( 0, 0, 0 )
					DrawRectLines( x-1, y-1, w+2, h+2 )
					DrawRectLines( x+1, y+1, w-2, h-2 )
					SetColor( 255, 255, 255 )
					DrawRectLines( x,y, w,h )
					'draw options
					draw_string( weapon_list_widget, (wx - 40),wy,,, 1.0,0.5 )
					SetColor( 0,0,0 )
					SetAlpha( 1 )
					'draw cursor
					draw_string( cursor_widget, (wx - 40),wy, get_cursor_color(),$000000, 1.0,0.5 )
					SetAlpha( 1 )

				ElseIf ed.variant_hullMod_i <> -1
					'show hullmods list and cursor
					hullMods_lines = New String[hullMods_count]
					hullMods_c = New String[hullMods_count]
					i = 0
					For hullMod = EachIn ed.stock_hullmod_stats.Values()
						hullmod_id = String( hullMod.ValueForKey("id"))
						display_str = String( hullMod.ValueForKey("name") )
						hullmod_op = get_hullmod_csv_ordnance_points( ed, data, hullmod_id )
						display_str = RSet( String.FromInt( hullmod_op ), 3 )+"  "+display_str
						If data.has_hullmod( hullmod_id )
							display_str = Chr(9679)+" "+display_str 'BLACK CIRCLE
						Else
							display_str = "  "+display_str
						EndIf
						hullMods_lines[i] = display_str
						If i = ed.variant_hullMod_i
							hullMods_c[i] = display_str
						EndIf
						i :+ 1
					Next
					hullMods_widget = TextWidget.create( hullMods_lines )
					hullMods_cursor = TextWidget.create( hullMods_c )
					hullMods_cursor.w = hullMods_widget.w
					draw_container( W_MID, H_MID, hullMods_widget.w + 20, hullMods_widget.h + 20, 0.5,0.5,,, 0.75 )
					draw_string( hullMods_widget, W_MID,H_MID,,, 0.5,0.5 )
					draw_string( hullMods_cursor, W_MID,H_MID, get_cursor_color(),, 0.5,0.5 )
				EndIf
			EndIf

		Else 'ed.group_field_i <> -1
			wep_names = "~n~n"
			skip_lines = 2
			'Local wep_g$ = "1 2 3 4 5~n"
			wep_g_a = ""
			wep_g_i = ""
			For g = 0 Until MAX_WEAPON_GROUPS
				If g < data.variant.weaponGroups.length And data.variant.weaponGroups[g].autofire.value
					wep_g_a :+ "a "
				Else
					wep_g_a :+ "  "
				EndIf
				wep_g_i :+ (g+1)+" "
			Next
			wep_g = wep_g_a+"~n"+wep_g_i+"~n"
			line_i = 0
			For g = 0 Until data.variant.weaponGroups.length
				group = data.variant.weaponGroups[g]
				For weapon_slot_id = EachIn group.weapons.Keys()
					If line_i = ed.group_field_i
						'draw weapon under consideration
						For weapon_slot = EachIn data.ship.weaponSlots
							If weapon_slot.id = weapon_slot_id
								wx = sprite.sx + (weapon_slot.locations[0] + data.ship.center[1])*sprite.Scale
								wy = sprite.sy + (-weapon_slot.locations[1] + data.ship.center[0])*sprite.Scale
								draw_weapon_slot_info( ed,data,sprite, weapon_slot )
								draw_assigned_weapon_info( ed,data,sprite, weapon_slot )
								draw_variant_weapon_mount( wx, wy, weapon_slot )
								Exit
							EndIf
						Next
					EndIf
					'add its name and group to the text edit widget
					weapon_id = String( group.weapons.ValueForKey( weapon_slot_id ))
					weapon_stats = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
					If weapon_stats
						weapon_name = String( weapon_stats.ValueForKey("name"))
						If weapon_name
							wep_names :+ weapon_name
						Else
							wep_names :+ weapon_id
						EndIf
					Else
						wep_names :+ weapon_id
					EndIf
					wep_names :+ "  ~n"
					If g > 0 Then wep_g :+ RSet("",2*g)
					wep_g :+ Chr(9679)+"~n"
					line_i :+ 1
				Next
			Next
			wep_names_tw = TextWidget.Create( wep_names )
			wep_g_tw = TextWidget.Create( wep_g )
			draw_container( W_MID - wep_names_tw.w - 10,H_MID, wep_names_tw.w + wep_g_tw.w + 20,wep_names_tw.h + 20, 0.0,0.5 )
			draw_string( wep_names_tw, W_MID,H_MID,,, 1.0,0.5 )
			draw_string( wep_g_tw,     W_MID,H_MID,,, 0.0,0.5 )
			cursor_widget = TextWidget.Create( wep_names )
			For i = skip_lines Until cursor_widget.lines.length
				If (i - skip_lines) <> ed.group_field_i
					cursor_widget.lines[i] = ""
				EndIf
			Next
			draw_string( cursor_widget, W_MID,H_MID, get_cursor_color(),$000000, 1.0,0.5 )
		EndIf
		SetAlpha( 1 )
	EndMethod


	Method Save( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	Method Load( ed:TEditor, data:TData, sprite:TSprite )
	EndMethod

	'/////////////////////

	Function get_ship_csv_ordnance_points%( ed:TEditor, data:TData )
		Local ship_stats:TMap = data.csv_row
		Local value$ = String( ship_stats.ValueForKey( "ordnance points" ))
		If Not value Then Return 0 'csv row found, but did not contain column
		Return value.ToInt()
	EndFunction

	Function calc_variant_used_ordnance_points%( ed:TEditor, data:TData )
		Local op% = 0
		'flux vents, flux capacitors, weapons, hullmods
		op :+ data.variant.fluxVents
		op :+ data.variant.fluxCapacitors
		For Local group:TStarfarerVariantWeaponGroup = EachIn data.variant.weaponGroups
			For Local weapon_slot_id$ = EachIn group.weapons.Keys()
				Local weapon_id$ = String( group.weapons.ValueForKey( weapon_slot_id ))
				If weapon_id
					Local weapon_op% = get_weapon_csv_ordnance_points( ed, data, weapon_id )
					If Not is_weapon_assigned_to_builtin_weapon_slot( ed, data, weapon_slot_id )
						op :+ weapon_op
					EndIf
				End If
			Next
		Next
		For Local hullMod_id$ = EachIn data.variant.hullMods
			Local hullMod_op% = get_hullmod_csv_ordnance_points( ed, data, hullMod_id )
			op :+ hullMod_op
		Next
		Return op
	EndFunction

	Function is_weapon_assigned_to_builtin_weapon_slot%( ed:TEditor, data:TData, weapon_slot_id$ )
		For Local weapon_slot:TStarfarerShipWeapon = EachIn data.ship.weaponSlots
			If weapon_slot.id = weapon_slot_id And weapon_slot.is_builtin()
				Return True
			EndIf
		Next
		Return False
	EndFunction

	Function get_weapon_csv_ordnance_points%( ed:TEditor, data:TData, weapon_id$ )
		Local weapon_stats:TMap = TMap( ed.stock_weapon_stats.ValueForKey( weapon_id ))
		If Not weapon_stats Then Return 0 'ID not found in csv data
		Local value$ = String( weapon_stats.ValueForKey( "OPs" ))
		If Not value Then Return 0 'csv row found, but did not contain column
		Return value.ToInt()
	EndFunction

	Function get_hullmod_csv_ordnance_points%( ed:TEditor, data:TData, hullMod_id$ )
		'uses ship size and hullmod data
		Local hullMod_stats:TMap = TMap( ed.stock_hullmod_stats.ValueForKey( hullMod_id ))
		If Not hullMod_stats Then Return 0 'ID not found in csv data
		Local column_key$ = ""
		Select data.ship.hullSize
			Case "FRIGATE"
				column_key = "cost_frigate"
			Case "DESTROYER"
				column_key = "cost_dest"
			Case "CRUISER"
				column_key = "cost_cruiser"
			Case "CAPITAL_SHIP"
				column_key = "cost_capital"
			Default
				Return 0 'hullMod cost cannot be found
		EndSelect
		Local value$ = String( hullMod_stats.ValueForKey( column_key ))
		If Not value Then Return 0 'csv row found, but did not contain column
		Return value.ToInt()
	EndFunction

EndType
