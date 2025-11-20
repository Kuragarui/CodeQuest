extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var puzzle_scene = preload("res://BossPuzzleTyping.tscn")
@onready var area2d = $Area2D2
var puzzle_instance: Control = null
var canvas_layer = null
var puzzle_active := false
var is_defeated := false

func _ready():
	if area2d:
		area2d.connect("body_entered", Callable(self, "_on_body_entered"))
		area2d.connect("body_exited", Callable(self, "_on_body_exited"))
		print("🏆 BOSS ready!")

func _on_body_entered(body):
	if body.is_in_group("Player") and not puzzle_active and not is_defeated:
		print("🏆 BOSS FIGHT START!")
		puzzle_active = true
		_show_puzzle()

func _on_body_exited(body):
	if body.is_in_group("Player"):
		_close_puzzle()

func _show_puzzle():
	print("🏆 Starting BOSS puzzle...")
	
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
		print("🏆 BOSS DEFEATED!")
		is_defeated = true
		queue_free()
	else:
		print("❌ Boss fight failed.")
	_close_puzzle()
