extends Node2D

signal defeated  # ✅ Emitted when puzzle is completed successfully

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var puzzle_scene = preload("res://DragDropPuzzle.tscn")
@onready var area2d = $Area2D2
@onready var animated_sprite = $AnimatedSprite2D

var puzzle_instance: Control = null
var canvas_layer = null
var puzzle_active := false
var npc_name = "Malupiton"
var is_defeated := false
var has_played_defeat_animation := false

func _ready():
	if area2d:
		area2d.connect("body_entered", Callable(self, "_on_body_entered"))
		area2d.connect("body_exited", Callable(self, "_on_body_exited"))
		print("✅ Signals connected!")
	else:
		print("❌ Area2D2 NOT FOUND!")

func _on_body_entered(body):
	if body.is_in_group("Player") and not puzzle_active and not is_defeated:
		print("Player entered Malupiton area — starting puzzle")
		puzzle_active = true
		_show_puzzle()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		_close_puzzle()

func _show_puzzle():
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	get_tree().root.add_child(canvas_layer)
	
	puzzle_instance = puzzle_scene.instantiate()
	canvas_layer.add_child(puzzle_instance)
	puzzle_instance.connect("puzzle_completed", Callable(self, "_on_puzzle_completed"))

func _close_puzzle():
	if puzzle_instance:
		puzzle_instance.queue_free()
		puzzle_instance = null
	if canvas_layer:
		canvas_layer.queue_free()
		canvas_layer = null
	puzzle_active = false

func _on_puzzle_completed(success: bool):
	if success:
		is_defeated = true
		print("🎯 SUCCESS! Emitting 'defeated' signal now...")
		emit_signal("defeated")  # ✅ Notify door or other systems
		print("✅ Signal emitted!")
		_play_defeat_animation()
	else:
		print("❌ Puzzle failed.")
	_close_puzzle()

func _play_defeat_animation():
	if not has_played_defeat_animation and animated_sprite:
		has_played_defeat_animation = true
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3)
		tween.tween_property(self, "modulate", Color.RED, 0.3)
		await tween.finished
		
		var tween2 = create_tween()
		tween2.set_parallel(true)
		tween2.tween_property(self, "position:y", position.y + 50, 1.0)
		tween2.tween_property(self, "modulate:a", 0.0, 1.0)
		tween2.tween_property(self, "scale", Vector2(0.5, 0.5), 1.0)
		await tween2.finished
		
		print("💀 Malupiton defeated!")
		queue_free()
