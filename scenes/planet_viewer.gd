extends Node3D

@export var mouseSensitivity : float = 0.3

var mousePressed : bool = false

@onready var planet = $planet
@onready var mapRendererViewport = $mapRendererViewport

func _ready():
	mapRendererViewport.size = CountryLoader.mapResolution
	
	$LoadingUI/Control.mouse_filter = Control.MOUSE_FILTER_STOP
	$LoadingUI.show()
	
	#CountryLoader.loading_countries_finished.connect(self._on_country_loader_loading_countries_finished)
	CountryLoader.call_deferred("start_country_generation")
	#compute_shader_setup.setup()

func _input(event):
	if event is InputEventMouseMotion:
		if mousePressed:
			$cameraPivot.rotation.y += deg_to_rad(-event.relative.x * mouseSensitivity)
			$cameraPivot.rotation.x += deg_to_rad(-event.relative.y * mouseSensitivity)
			
			$cameraPivot.rotation.x = clamp($cameraPivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if mousePressed == false:
				mousePressed = true

		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if mousePressed == true:
				mousePressed = false
				
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			$cameraPivot/Camera3D.position.z -= 0.1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			$cameraPivot/Camera3D.position.z += 0.1

#func _on_planet_radius_changed(value):
#	$LoadingUI/Control.mouse_filter = Control.MOUSE_FILTER_STOP
#	$LoadingUI.show()
#	CountryLoader.start_country_generation(value)

#func _on_country_loader_loading_countries_finished(_loadedCountries):
#	for country in loadedCountries:
#		for polygon in country.polygons:
#			var line := Line2D.new()
#			line.width = 2
#			line.round_precision = 3
#			line.joint_mode = Line2D.LINE_JOINT_BEVEL
#			line.begin_cap_mode = Line2D.LINE_CAP_ROUND
#			line.end_cap_mode = Line2D.LINE_CAP_ROUND
#			line.default_color = Color.BLACK
#			line.antialiased = true
#			for point in polygon:
#				line.add_point(point)
#			mapRenderer.add_child(line)
			
	#planet.material_override.set("shader_parameter/boundariesTexture", mapRenderer.get_texture())
				
	
func _on_map_renderer_draw():
	if not mapRendererViewport.get_node("mapRenderer").countriesData.is_empty():
		planet.material_override.set("shader_parameter/boundariesTexture", mapRendererViewport.get_texture())
		$LoadingUI.hide()
		$LoadingUI/Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
