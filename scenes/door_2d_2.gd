extends Node2D

@export var npc_path: NodePath    # Drag Baklang Thomas node here
@onready var npc = get_node(npc_path)

@onready var static_body = $StaticBody2D
@onready var collision = $StaticBody2D/CollisionShape2D

var is_open := false

func _ready():
	if npc:
		# Connects to Baklang Thomas defeated signal
		npc.connect("defeated", Callable(self, "_on_npc_defeated"))
		print("🚪 Door2 connected to Baklang Thomas 'defeated' signal")
	else:
		print("❌ NPC path not set in Door2 inspector!")


func _on_npc_defeated():
	if is_open:
		return

	is_open = true
	print("🔓 Door2 unlocked by Baklang Thomas defeat — opening door...")

	# Disable collision so player can pass through
	collision.disabled = true

	# Play door opening animation
	_open_animation()


func _open_animation():
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 80, 0.8)  # Slide upward
	tween.tween_property(self, "modulate:a", 0.0, 0.8)              # Fade out
