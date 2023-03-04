extends CanvasLayer

var mousePressed : bool = false
var dragging : bool = false

var menuOpen : bool = false
var countrySelected : bool = false

@onready var selected_country_flag = $Control/selectedCountryPanel/VBoxContainer/selectedCountryFlag
@onready var selected_country_name = $Control/selectedCountryPanel/VBoxContainer/selectedCountryName
@onready var selected_country_formal_name = $Control/selectedCountryPanel/VBoxContainer/selectedCountryFormalName
@onready var selected_country_acronym = $Control/selectedCountryPanel/VBoxContainer/selectedCountryAcronym

@onready var color = $color

@onready var countries = get_tree().root.get_node("mapViewer").get_node("Countries")

func _process(delta):
	var info = $Control/menu/MarginContainer/VBoxContainer/info
	info.text = "Tip: Press P for a wireframe view.
	
				FPS: " + str(Engine.get_frames_per_second()) +"
				Number of Countries: " + str(countries.get_child_count())

func _on_map_viewer_country_selected(country):
	if countrySelected:
		var t = create_tween()
		t.tween_property($Control/selectedCountryPanel, "modulate", Color(1,1,1,0), 0.1).from(Color(1,1,1,1))
		await t.finished
	if country != null:
		selected_country_name.text = country.name
		selected_country_flag.texture = country.flag
		selected_country_formal_name.text = country.formalName
		selected_country_acronym.text = country.acronym
		
		countrySelected = true
	else:
		selected_country_name.text = ""
		selected_country_flag.texture = null
		selected_country_formal_name.text = ""
		selected_country_acronym.text = ""
		
		countrySelected = false
	var t2 = create_tween()
	t2.tween_property($Control/selectedCountryPanel, "modulate", Color(1,1,1,1), 0.1).from(Color(1,1,1,0))
		
func _input(event):
	if event is InputEventMouseMotion:
		if mousePressed and not dragging and not menuOpen:
			var t = create_tween()
			t.tween_property(color, "color", Color(1,1,1,0.25), 0.1).from(Color(1,1,1,1))
			dragging = true
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not mousePressed:
				mousePressed = true
	
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if mousePressed:
				mousePressed = false
				
			if dragging and not menuOpen:
				var t = create_tween()
				t.tween_property(color, "color", Color(1,1,1,1), 0.1).from(Color(1,1,1,0.25))
				dragging = false
				

func _on_open_menu_pressed():
	if not menuOpen:
		$Control/openMenuButtonContainer.hide()
		var t = create_tween()
		t.tween_property($Control/menu, "position", Vector2(0, 0), 0.25).from(Vector2(-$Control/menu.size.x, 0))
		menuOpen = true

func _on_close_button_pressed():
	if menuOpen:
		var t = create_tween()
		t.tween_property($Control/menu, "position", Vector2(-$Control/menu.size.x, 0), 0.25).from(Vector2(0, 0))
		await t.finished
		$Control/openMenuButtonContainer.show()
		menuOpen = false
		
