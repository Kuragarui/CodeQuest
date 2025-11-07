extends Node2D

@onready var canvas_layer = CanvasLayer.new()

func _ready():
	add_child(canvas_layer)

func show_drag_drop_puzzle():
	var drag_drop_scene = preload("res://scenes/DragAndDrop.tscn")
	var puzzle_instance = drag_drop_scene.instantiate()

	# ✅ Make sure the signal exists
	if puzzle_instance is Control and puzzle_instance.has_signal("puzzle_completed"):
		puzzle_instance.puzzle_completed.connect(_on_puzzle_completed)
	else:
		push_error("DragAndDrop.tscn is not using drag_drop_puzzle.gd or signal missing!")

	# ✅ Add to canvas layer (so it shows on screen)
	canvas_layer.add_child(puzzle_instance)

	# ✅ Center the puzzle on screen
	puzzle_instance.global_position = get_viewport_rect().size / 2 - puzzle_instance.size / 2

func _on_puzzle_completed(success: bool):
	if success:
		print("✅ Puzzle solved!")
	else:
		print("❌ Incorrect answer!")
