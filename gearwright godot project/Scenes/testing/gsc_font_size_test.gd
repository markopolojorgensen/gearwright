extends Node2D

func _ready() -> void:
	var fish := GearwrightFish.new()
	fish.size = GearwrightFish.SIZE.SMALL
	fish.initialize()
	
	#print(%Label2.get_global_transform().get_scale())
	
	for gsc in [%GearSectionControl, %GearSectionControl2, %GearSectionControl3]:
		gsc.is_fish_mode = true
		gsc.update(fish.get_gear_section(GearwrightActor.GSIDS.FISH_BODY))

	await get_tree().create_timer(2.0).timeout
	for gsc in [%GearSectionControl2, %GearSectionControl3, %Label2, %Label3, %autosizer4]:
		gsc.scale = Vector2(1.0, 1.0) * 5.0
	
	await get_tree().create_timer(2.0).timeout
	# gsc 
	%GearSectionControl3.update(fish.get_gear_section(GearwrightActor.GSIDS.FISH_BODY))
	
	for label in [%Label3, %Label4]:
		var fancy_global_scale = label.get_global_transform().get_scale()
		#print(fancy_global_scale)
		var new_font_size = 16 * fancy_global_scale.x
		var new_label_scale = Vector2(1.0, 1.0) / fancy_global_scale
		label.add_theme_font_size_override("font_size", new_font_size)
		label.scale = new_label_scale




