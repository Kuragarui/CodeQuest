extends CanvasLayer

@onready var up = $Up
@onready var left = $Left
@onready var right = $Right
@onready var down = $Down




func _on_up_pressed() -> void:
	up.modulate.a = 0.5


func _on_up_released() -> void:
	up.modulate.a = 1.0


func _on_left_pressed() -> void:
	left.modulate.a = 0.5


func _on_left_released() -> void:
	left.modulate.a = 1.0


func _on_right_pressed() -> void:
	right.modulate.a = 0.5


func _on_right_released() -> void:
	right.modulate.a = 1.0


func _on_down_pressed() -> void:
	down.modulate.a = 0.5


func _on_down_released() -> void:
	down.modulate.a = 1.0
