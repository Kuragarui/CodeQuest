extends Area2D

const SECOND_DUNGEON_SCENE = "res://scenes/second_dungeon.tscn"

@onready var fade = get_node_or_null("/root/ThirdDungeon/CanvasLayer/FadeControl")

var is_transitioning := false
var can_use := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	print("=== Dungeon 3 exit door ready ===")
	print("Fade found:", fade != null)
	
	await get_tree().create_timer(1.0).timeout
	can_use = true
	print("Exit enabled")

func _on_body_entered(body: Node2D) -> void:
	var is_player = body.name == "Player" or body.is_in_group("player")
	
	if not is_player or is_transitioning or not can_use:
		return
	
	print("✓ Player exiting dungeon 3 to dungeon 2...")
	is_transitioning = true
	_exit_dungeon()

func _exit_dungeon() -> void:
	# Replace X, Y with your FromThirdDungeonSpawn marker position
	GlobalData.spawn_position = Vector2(-141.0, 233.0)  # ← SET THIS
	
	print("💾 Saved spawn position:", GlobalData.spawn_position)
	print("📍 Returning to:", SECOND_DUNGEON_SCENE)
	
	if fade:
		print("Using fade transition...")
		var fade_out = create_tween()
		fade_out.tween_property(fade, "modulate:a", 1.0, 0.5)
		await fade_out.finished
		get_tree().change_scene_to_file(SECOND_DUNGEON_SCENE)
	else:
		print("No fade found, instant transition")
		get_tree().change_scene_to_file(SECOND_DUNGEON_SCENE)
