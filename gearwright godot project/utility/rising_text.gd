extends Label

const speed = 8.0

func _ready():
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.0,1.0,1.0,0.0), $Timer.wait_time)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_EXPO)

func _process(delta: float) -> void:
	position += Vector2(0, -1) * speed * delta

func _on_timer_timeout() -> void:
	queue_free()
