extends Control

var countriesData := [] : 
	set(value):
		if countriesData != value:
			countriesData = value
			queue_redraw()

func _ready():
	CountryLoader.loading_countries_finished.connect(self._on_country_loader_loading_countries_finished)

func _on_country_loader_loading_countries_finished(loadedCountries):
	countriesData = loadedCountries
	
func _draw():
	if not countriesData.is_empty():
		for country in countriesData:
			for polygon in country.polygons:
				var pol := Array(polygon)
				
				#draw_colored_polygon(polygon, Color.SPRING_GREEN)
				draw_polyline(polygon, Color.BLACK, 2.0, true)
				#draw_colored_polygon(polygon, Color.WHITE)
