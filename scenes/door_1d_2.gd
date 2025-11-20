extends Node2D

@export var npc_path: NodePath   # Drag enemy node here in inspector
@onready var npc = get_node(npc_path)
@onready var static_body = $StaticBody2D
@onready var collision = $StaticBody2D/CollisionShape2D

var is_open := false

func _ready():
	if npc:
		npc.connect("defeated", Callable(self, "_on_npc_defeated"))
		print("🚪 Door connected to enemy's defeated signal")
	else:
		print("❌ NPC path not set in inspector!")


func _on_npc_defeated():
	if is_open:
		return

	is_open = true
	print("🔓 Door unlocked! Opening...")

	# disable collision so player can walk through
	collision.disabled = true

	# VANISH animation
	_open_animation()


func _open_animation():
	var tween = create_tween()
	tween.set_parallel(true)

	# Fade to invisible
	tween.tween_property(self, "modulate:a", 0.0, 0.6)

	# Shrink to nothing
	tween.tween_property(self, "scale", Vector2(0, 0), 0.6)

	# Move slightly up
	tween.tween_property(self, "position:y", position.y - 20, 0.6)

	await tween.finished

	# Remove from scene (optional but clean)
	queue_free()
