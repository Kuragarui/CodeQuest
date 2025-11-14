extends Node2D

# ⚡ ADD THIS SIGNAL - This is what was missing!
signal defeated

# Movement variables
const SPEED = 60
var direction = 1

# Puzzle variables
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var puzzle_scene = preload("res://DragDropPuzzle_enemy3_2D.tscn")
@onready var area2d = $Area2D2
@onready var animated_sprite = $AnimatedSprite2D

var puzzle_instance: Control = null
var canvas_layer = null
var puzzle_active := false
var is_defeated := false
var npc_name = "wally_bayola"
var has_played_defeat_animation := false

# Movement nodes
@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft

func _ready():
	if area2d:
		area2d.connect("body_entered", Callable(self, "_on_body_entered"))
		area2d.connect("body_exited", Callable(self, "_on_body_exited"))
		print("✅ Signals connected!")
	else:
		print("❌ Area2D2 NOT FOUND!")

func _process(delta):
	# Only move if NOT defeated and NO active puzzle
	if not is_defeated and not puzzle_active:
		# Move left/right
		position.x += direction * SPEED * delta
		
		# Flip direction when hitting a wall or edge
		if ray_cast_right.is_colliding():
			direction = -1
			animated_sprite.flip_h = true
		elif ray_cast_left.is_colliding():
			direction = 1
			animated_sprite.flip_h = false

func _on_body_entered(body):
	if body.is_in_group("Player") and not puzzle_active and not is_defeated:
		print("Player entered enemy3_2d area — starting puzzle")
		puzzle_active = true
		_show_puzzle()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		print("Player left enemy3_2d area")
		_close_puzzle()

func _show_puzzle():
	print("🔍 Creating puzzle with CanvasLayer...")
	
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	get_tree().root.add_child(canvas_layer)
	
	puzzle_instance = puzzle_scene.instantiate()
	canvas_layer.add_child(puzzle_instance)
	
	print("✅ Puzzle added to CanvasLayer!")
	
	puzzle_instance.connect("puzzle_completed", Callable(self, "_on_puzzle_completed"))

func _close_puzzle():
	if puzzle_instance:
		print("🚪 Closing puzzle...")
		puzzle_instance.queue_free()
		puzzle_instance = null
	
	if canvas_layer:
		canvas_layer.queue_free()
		canvas_layer = null
	
	puzzle_active = false

func _on_puzzle_completed(success: bool):
	if success:
		print("✅ Puzzle complete! Enemy defeated.")
		is_defeated = true
		_play_defeat_animation()
	else:
		print("❌ Puzzle failed.")
	
	puzzle_active = false
	_close_puzzle()

func _play_defeat_animation():
	if not has_played_defeat_animation:
		has_played_defeat_animation = true
		
		# 🔥 EMIT SIGNAL IMMEDIATELY - Before animation starts!
		emit_signal("defeated")
		print("⚡ Defeated signal emitted!")
		
		# Phase 1: Initial impact (0.3s) - scale up & flash red
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3)
		tween.tween_property(self, "modulate", Color.RED, 0.3)
		await tween.finished
		
		# Phase 2: Death fade (1.0s) - fall, fade, shrink
		var tween2 = create_tween()
		tween2.set_parallel(true)
		tween2.tween_property(self, "position:y", position.y + 50, 1.0)
		tween2.tween_property(self, "modulate:a", 0.0, 1.0)
		tween2.tween_property(self, "scale", Vector2(0.5, 0.5), 1.0)
		await tween2.finished
		
		print("💀 Enemy3 defeated with scene change!")
		
		# Small delay to ensure quest system processes the signal
		await get_tree().create_timer(0.2).timeout
		
		# Remove enemy from scene
		queue_free()
	else:
		# Fallback
		queue_free()
