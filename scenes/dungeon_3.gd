extends Node2D

# Drag your Enemy3 (Wally Bayola) node here
@export var npc_path: NodePath
@onready var npc = get_node(npc_path)

@onready var collision = $StaticBody2D/CollisionShape2D

var is_open := false

func _ready() -> void:
	if npc:
		npc.connect("defeated", Callable(self, "_on_npc_defeated"))
		print("🚪 Door connected to Wally Bayola's defeated signal")
	else:
		print("❌ NPC path not set! Drag your enemy into npc_path in the Inspector.")


func _on_npc_defeated():
	if is_open:
		return

	is_open = true
	print("🔓 Door unlocked! Opening...")

	# Disable collision so player can walk through
	collision.disabled = true

	_open_animation()


func _open_animation():
	var tween = create_tween()
	
	# Move door upward
	tween.tween_property(self, "position:y", position.y - 80, 0.8)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
