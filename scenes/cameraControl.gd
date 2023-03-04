extends Node3D

func _process(delta):
	var speed = ($Camera3D.fov / 75) * delta
	
	if Input.is_action_pressed("ui_left"):
		rotation.y += speed
	if Input.is_action_pressed("ui_right"):
		rotation.y -= speed
	if Input.is_action_pressed("ui_up"):
		rotation.x -= speed
	if Input.is_action_pressed("ui_down"):
		rotation.x += speed
		
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if $Camera3D.fov > 1:
					$Camera3D.fov -= $Camera3D.fov / (75/3)
				#$Camera3D.position.z += 0.05 * $Camera3D.position.distance_to(self.position)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if $Camera3D.fov < 75:
					$Camera3D.fov += $Camera3D.fov / (75/3)
				#$Camera3D.position.z -= 0.05 * $Camera3D.position.distance_to(self.position)
