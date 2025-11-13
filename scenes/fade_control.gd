extends ColorRect

# Duration of fade animations
@export var fade_time := 1.5

# Called when the node enters the scene tree
func _ready():
	modulate.a = 1.0  # Start fully black (for fade-in)
	fade_in()

# Smoothly fade from black to transparent
func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)

# Smoothly fade from transparent to black
func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)
	await tween.finished
	return true
