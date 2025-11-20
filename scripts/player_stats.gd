extends Node

var max_health = 6
var current_health = 6

var current_dungeon := 1  # ⭐ Add this!

signal health_changed(new_health)
signal player_died()

func _ready():
	print("PlayerStats initialized - Health:", current_health)

func take_damage(amount: int = 1):
	current_health -= amount
	current_health = max(0, current_health)
	
	print("Player took", amount, "damage! Health:", current_health, "/", max_health)
	health_changed.emit(current_health)
	
	if current_health <= 0:
		print("💀 Player died!")
		player_died.emit()
		die()

func heal(amount: int = 1):
	current_health += amount
	current_health = min(current_health, max_health)
	
	print("💚 Player healed", amount, "! Health:", current_health, "/", max_health)
	health_changed.emit(current_health)

func reset_health():
	current_health = max_health
	health_changed.emit(current_health)
	print("🔄 Health reset to", max_health)

func die():
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/retry.tscn")
