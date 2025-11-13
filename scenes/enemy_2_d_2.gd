extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var puzzle_scene = preload("res://DragDropPuzzle_enemy2_2D.tscn")
@onready var area2d = $Area2D2
@onready var animated_sprite = $AnimatedSprite2D  # Dagdag: para sa animation
var puzzle_instance: Control = null
var canvas_layer = null
var puzzle_active := false
var is_defeated := false  # Para hindi na mag-trigger ulit

func _ready():
	if area2d:
		area2d.connect("body_entered", Callable(self, "_on_body_entered"))
		area2d.connect("body_exited", Callable(self, "_on_body_exited"))
		print("✅ Signals connected!")
	else:
		print("❌ Area2D2 NOT FOUND!")

func _on_body_entered(body):
	if body.is_in_group("Player") and not puzzle_active and not is_defeated:
		print("Player entered enemy1_2d area — starting puzzle")
		puzzle_active = true
		_show_puzzle()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		print("Player left enemy1_2d area")
		_close_puzzle()  # Isara yung puzzle pag lumabas

func _show_puzzle():
	print("🔍 Creating puzzle with CanvasLayer...")
	
	# Create a CanvasLayer to ensure it renders on top
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	get_tree().root.add_child(canvas_layer)
	
	# Instantiate puzzle and add to CanvasLayer
	puzzle_instance = puzzle_scene.instantiate()
	canvas_layer.add_child(puzzle_instance)
	
	print("✅ Puzzle added to CanvasLayer!")
	
	# Connect signal
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
	if animated_sprite:
		# Play defeat animation
		animated_sprite.play("death")  # Palitan ng animation name mo
		
		# Wait for animation to finish
		await animated_sprite.animation_finished
		
		# Optional: Fade out effect
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		await tween.finished
		
		# Remove enemy
		queue_free()
		print("💀 Enemy removed from scene")
	else:
		# Kung walang animation, direkta na lang i-remove
		queue_free()
