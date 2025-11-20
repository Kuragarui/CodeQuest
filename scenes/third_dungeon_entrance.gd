extends Area2D

const THIRD_DUNGEON_SCENE = "res://scenes/third_dungeon.tscn"

var fade: Node

var is_transitioning := false

func _ready() -> void:
	fade = get_node_or_null("/root/SecondDungeon/CanvasLayer2/FadeControl")
	if not fade:
		fade = get_node_or_null("../../CanvasLayer2/FadeControl")
	
	body_entered.connect(_on_body_entered)
	print("=== Third dungeon entrance ready ===")
	print("Fade found:", fade != null)

func _on_body_entered(body: Node2D) -> void:
	var is_player = body.name == "Player" or body.is_in_group("player")
	
	if not is_player or is_transitioning:
		return
	
	print("✓ Player entering dungeon 3...")
	is_transitioning = true
	_enter_third_dungeon()

func _enter_third_dungeon() -> void:
	GlobalData.spawn_position = Vector2.ZERO
	
	print("Entering dungeon 3 - will spawn at PlayerSpawnPoint")
	
	if fade:
		print("🎬 Using fade transition...")
		var fade_out = create_tween()
		fade_out.tween_property(fade, "modulate:a", 1.0, 0.5)
		await fade_out.finished
		get_tree().change_scene_to_file(THIRD_DUNGEON_SCENE)
	else:
		print("⚡ No fade found, instant transition")
		get_tree().change_scene_to_file(THIRD_DUNGEON_SCENE)
