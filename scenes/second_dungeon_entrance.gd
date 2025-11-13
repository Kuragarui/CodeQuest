extends Area2D

const SECOND_DUNGEON_SCENE = "res://scenes/second_dungeon.tscn"

@onready var fade = get_node_or_null("/root/Game/CanvasLayer2/FadeControl")

var is_transitioning := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("=== Second dungeon entrance ready ===")
	print("Fade found:", fade != null)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or is_transitioning:
		return
	
	print("✓ Player entering dungeon 2...")
	is_transitioning = true
	_enter_second_dungeon()

func _enter_second_dungeon() -> void:
	# Clear spawn position - player will spawn at PlayerSpawnPoint
	GlobalData.spawn_position = Vector2.ZERO
	
	print("Entering dungeon 2 - will spawn at PlayerSpawnPoint")
	
	if fade:
		print("Using fade transition...")
		var fade_out = create_tween()
		fade_out.tween_property(fade, "modulate:a", 1.0, 0.5)
		await fade_out.finished
		get_tree().change_scene_to_file(SECOND_DUNGEON_SCENE)
	else:
		print("No fade found, instant transition")
		get_tree().change_scene_to_file(SECOND_DUNGEON_SCENE)
