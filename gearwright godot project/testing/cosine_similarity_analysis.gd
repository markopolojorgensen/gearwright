extends Node2D

var a := Vector2.RIGHT
var b: Vector2

var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	var weight: float = remap(sin(time_elapsed), -1.0, 1.0, 0.0, 1.0)
	b = Vector2.RIGHT.rotated(deg_to_rad(-90) * weight)
	
	%AColorRect.rotation = Vector2.RIGHT.angle_to(a)
	%BColorRect.rotation = Vector2.RIGHT.angle_to(b)
	
	%AngleDiffLabel.text = "%.0f" % rad_to_deg(b.angle_to(a))
	
	var cosine_value = cos(a.angle_to(b))
	%CosineProgressBar.value = cosine_value
	%CosineLabel.text = "%.2f" % cosine_value
	
	var projection_value = a.normalized().project(b.normalized()).length()
	%ProjectionProgressBar.value = projection_value
	%ProjectionLabel.text = "%.2f" % projection_value
	
	time_elapsed += delta * 1.5













