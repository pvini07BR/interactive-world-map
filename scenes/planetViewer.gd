extends Node3D

func _on_resolution_value_changed(value):
	$planet.resolution = value
	$planet.generateAll()

func _on_relief_height_value_changed(value):
	$planet.get_node("Up").material_override.set_shader_parameter("reliefHeight", value)
