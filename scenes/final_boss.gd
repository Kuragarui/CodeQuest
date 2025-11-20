extends Node2D

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var puzzle_scene = preload("res://BossPuzzleTyping.tscn")
@onready var area2d = $Area2D2
var puzzle_instance: Control = null
var canvas_layer = null
var puzzle_active := false
var is_defeated := false

var has_played_defeat_animation = false
@onready var animated_sprite = $AnimatedSprite2D   # <-- Needed for animation


func _ready():
	if area2d:
		area2d.connect("body_entered", Callable(self, "_on_body_entered"))
		area2d.connect("body_exited", Callable(self, "_on_body_exited"))
		print("🏆 BOSS ready!")


func _on_body_entered(body):
	if body.is_in_group("Player") and not puzzle_active and not is_defeated:
		print("🏆 BOSS FIGHT START!")
		# stop movement if you have movement
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



# ---------------------------------------------------------
#  🎯 PUZZLE RESULT
# ---------------------------------------------------------
func _on_puzzle_completed(success: bool):
	if success:
		print("🏆 BOSS DEFEATED!")
		is_defeated = true

		# 🔥 UPDATE QUEST
		Quest3Manager.complete_final_quest()

		_play_defeat_animation()
	else:
		print("❌ Boss fight failed.")

	_close_puzzle()



# ---------------------------------------------------------
#  💀 DEFEAT ANIMATION (same as your other script)
# ---------------------------------------------------------
func _play_defeat_animation():
	if has_played_defeat_animation:
		return

	has_played_defeat_animation = true

	# Step 1 — flash red + scale up
	var tween1 = create_tween()
	tween1.set_parallel(true)
	tween1.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3)
	tween1.tween_property(self, "modulate", Color.RED, 0.3)
	await tween1.finished

	# Step 2 — drop + fade out
	var tween2 = create_tween()
	tween2.set_parallel(true)
	tween2.tween_property(self, "position:y", position.y + 50, 1.0)
	tween2.tween_property(self, "modulate:a", 0.0, 1.0)
	tween2.tween_property(self, "scale", Vector2(0.5, 0.5), 1.0)

	await tween2.finished

	# Remove boss from world
	queue_free()
	
	get_tree().change_scene_to_file("res://ending_scene/ending.tscn")
