extends Label

const speed = 8.0

func _process(delta: float) -> void:
	position += Vector2(0, -1) * speed * delta

func _on_timer_timeout() -> void:
	queue_free()
