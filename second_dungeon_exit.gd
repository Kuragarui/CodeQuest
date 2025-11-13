extends Area2D

const MAIN_GAME_SCENE = "res://scenes/game.tscn"

var is_transitioning := false
var can_use := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	await get_tree().create_timer(1.0).timeout
	can_use = true
	
	print("=== Dungeon 2 exit door ready ===")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or is_transitioning or not can_use:
		return
	
	print("✓ Player exiting dungeon 2 to main game...")
	is_transitioning = true
	_exit_dungeon()

func _exit_dungeon() -> void:
	# Save spawn position for returning to main game
	GlobalData.spawn_position = Vector2(232, 595)  # Your FromSecondDungeonSpawn marker position
	
	print("💾 Saved spawn position:", GlobalData.spawn_position)
	print("📍 Returning to:", MAIN_GAME_SCENE)
	
	get_tree().change_scene_to_file(MAIN_GAME_SCENE)
