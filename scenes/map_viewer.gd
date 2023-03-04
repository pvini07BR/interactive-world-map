extends Node3D

@export var alwaysRegenerateCountryMeshes := false

@export var countryColor : Color = Color(54.0/255.0, 57.0/255.0, 63.0/255.0, 1.0)
@export var countryBorderColor : Color = Color.LIGHT_GRAY

@export var selected_countryColor : Color = Color.DARK_GRAY
@export var selected_countryBorderColor : Color = Color.WHITE

var countryScn = load("res://scenes/country.tscn")
var jsonFile := FileAccess.open("res://assets/ne_50m_admin_0_countries_lakes.json", FileAccess.READ)
var parsedJson = JSON.parse_string(jsonFile.get_as_text())

var pressedPos := Vector2.ZERO
var releasedPos := Vector2.ZERO

var mousePressed := false
var mouseMiddlePressed := false

@onready var mapMesh := get_node("map").get_node("ground")
@onready var size : Vector2 = mapMesh.mesh.size

var selectedCountry

signal country_selected

func _init():
	RenderingServer.set_debug_generate_wireframes(true)

func _ready():
	generate_countries()

func coordinateToPoint(coordinate : Vector2) -> Vector3:
	var x := ((size.x/360.0) * (180 + coordinate.y)) - (size.x/2)
	var z := ((size.y/180.0) * (90 - coordinate.x)) - (size.y/2)
	return Vector3(x, 0, z)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if mouseMiddlePressed:
			$cameraPivot.rotation.x += deg_to_rad(event.relative.y)
			$cameraPivot.rotation.x = clamp($cameraPivot.rotation.x, deg_to_rad(0), deg_to_rad(90))
		
			#if $cameraPivot.rotation.x > 0.1:
			#	$cameraPivot/camera.projection = 0
			#else:
			#	$cameraPivot/camera.projection = 1
		
		if mousePressed:
			var prevMousePos = event.position + event.relative
			var mousePos = event.position
			
			var posProj = getRaycastResults(mousePos, false, true).position
			var prevProj = getRaycastResults(prevMousePos, false, true).position
			
			$cameraPivot.position += posProj - prevProj
			
			$cameraPivot.position.x = clamp($cameraPivot.position.x, -size.x/2, size.x/2)
			$cameraPivot.position.z = clamp($cameraPivot.position.z, -size.y/2, size.y/2)
			
			$UI/Control.mouse_default_cursor_shape = 6
		else:
			$UI/Control.mouse_default_cursor_shape = 0
	
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				$cameraPivot/camera.position.y -= $cameraPivot/camera.position.y / 12
				$cameraPivot/camera.position.y = clamp($cameraPivot/camera.position.y, 0.1, 35.0)
				
				#$cameraPivot/camera.size = $cameraPivot/camera.position.y + 19
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				$cameraPivot/camera.position.y += $cameraPivot/camera.position.y / 12
				$cameraPivot/camera.position.y = clamp($cameraPivot/camera.position.y, 0.01, 35.0)
				
				#$cameraPivot/camera.size = $cameraPivot/camera.position.y + 19
				
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressedPos = event.position
			
			if mousePressed == false:
				mousePressed = true

		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			releasedPos = event.position
			
			if mousePressed == true:
				mousePressed = false
				
			if pressedPos.distance_to(releasedPos) == 0:
				var results = getRaycastResults(releasedPos, true, false)
				if results.size() > 0:
					if selectedCountry != null:
						selectedCountry.call("setColor", countryColor)
						selectedCountry.call("setOutlineColor", countryBorderColor)
					selectedCountry = results["collider"]
					selectedCountry.call("setColor", selected_countryColor)
					selectedCountry.call("setOutlineColor", selected_countryBorderColor)
				else:
					if selectedCountry != null:
						selectedCountry.call("setColor", countryColor)
						selectedCountry.call("setOutlineColor", countryBorderColor)

						selectedCountry = null
						
				emit_signal("country_selected", selectedCountry)
						
		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			if mouseMiddlePressed == false:
				mouseMiddlePressed = true
		if event.button_index == MOUSE_BUTTON_MIDDLE and not event.pressed:
			if mouseMiddlePressed == true:
				mouseMiddlePressed = false
				
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		if vp.debug_draw == 0:
			vp.debug_draw = 4
		elif vp.debug_draw == 4:
			vp.debug_draw = 0

func getRaycastResults(fromPos, colWithAreas : bool, colWithBody : bool):
	var from = $cameraPivot/camera.project_ray_origin(fromPos)
	var to = from + $cameraPivot/camera.project_ray_normal(fromPos) * ($cameraPivot/camera.position.distance_to($cameraPivot.position) * 6)
	
	var space_state = get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.create(from, to)
	params.collide_with_areas = colWithAreas
	params.collide_with_bodies = colWithBody
	return space_state.intersect_ray(params)

func _on_check_box_toggled(button_pressed):
	$map/water.visible = button_pressed
	
func _on_country_color_changed(color):
	countryColor = color
	for i in $Countries.get_children():
		i.call("setColor", color)
		
func _on_country_outline_color_changed(color):
	countryBorderColor = color
	for i in $Countries.get_children():
		i.call("setOutlineColor", color)
		
func _on_country_selected_color_changed(color):
	selected_countryColor = color
	if selectedCountry != null:
		selectedCountry.call("setColor", color)
		
func _on_country_selected_outline_color_changed(color):
	selected_countryBorderColor = color
	if selectedCountry != null:
		selectedCountry.call("setOutlineColor", color)
	
func generate_countries():
	if parsedJson != null:
		for country in parsedJson["features"]:
			if not FileAccess.file_exists("res://scenes/countries/"+country["properties"]["NAME_EN"]+".tscn") or alwaysRegenerateCountryMeshes:
				var newCountry = countryScn.instantiate()
				newCountry.name = country["properties"]["NAME_EN"]
				newCountry.formalName = country["properties"]["FORMAL_EN"]
				newCountry.acronym = country["properties"]["ADM0_A3_US"]
				newCountry.flag = load("res://assets/flags/" + newCountry.acronym + ".svg")
				newCountry.color = countryColor
				newCountry.outlineColor = countryBorderColor
				
				if newCountry.acronym == "VAT" or newCountry.acronym == "LSO" or newCountry.acronym == "SMR":
					newCountry.position.y = 0.01
				
				$Countries.add_child(newCountry)
				newCountry.set_owner(self)
				
				var geometry = country["geometry"]
				var type = geometry["type"]
				
				for useless in geometry["coordinates"]:
					if type == "Polygon":
						var v = PackedVector3Array()
						var exes := []
						var zeds := []
						for coordinate in useless:
							var latitude = coordinate[1]
							var longitude = coordinate[0]
							
							var c = coordinateToPoint(Vector2(latitude, longitude))
							v.append(c)
							exes.append(c.x)
							zeds.append(c.z)
							
						exes.sort()
						zeds.sort()
						
						var sizeBounds = Vector2((exes.max() - exes.min()), (zeds.max() - zeds.min()))
						var midPoint = Vector2((exes.min() + exes.max()) / 2, (zeds.min() + zeds.max()) / 2)
						newCountry.add_country_mesh(v, midPoint, sizeBounds)
						
					elif type == "MultiPolygon":
						for polygon in useless:
							var v2 = PackedVector3Array()
							var exes2 := []
							var zeds2 := []
							for coordinate in polygon:
								var latitude2 = coordinate[1]
								var longitude2 = coordinate[0]
								
								var c2 = coordinateToPoint(Vector2(latitude2, longitude2))
								v2.append(c2)
								exes2.append(c2.x)
								zeds2.append(c2.z)
								
							exes2.sort()
							zeds2.sort()
						
							var sizeBounds2 = Vector2((exes2.max() - exes2.min()), (zeds2.max() - zeds2.min()))
							var midPoint2 = Vector2((exes2.min() + exes2.max()) / 2, (zeds2.min() + zeds2.max()) / 2)
							newCountry.add_country_mesh(v2, midPoint2, sizeBounds2)
			else:
				var loadedCountry = load("res://scenes/countries/"+country["properties"]["NAME_EN"]+".tscn")
				$Countries.add_child(loadedCountry.instantiate())
		
		for i in $Countries.get_children():
			i.call("setColor", countryColor)
			i.call("setOutlineColor", countryBorderColor)
			if not FileAccess.file_exists("res://scenes/countries/"+i.name+".tscn") and not alwaysRegenerateCountryMeshes:
				var pc = PackedScene.new()
				#i.propagate_call("set", ["owner", i])
				pc.pack(i)
				ResourceSaver.save(pc, "res://scenes/countries/"+i.name+".tscn")
