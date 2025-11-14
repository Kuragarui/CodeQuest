extends Node2D

@export var npc_node_path: NodePath  # Assign Malupiton in Inspector
@onready var collision = $StaticBody2D/CollisionShape2D
@onready var player = get_node_or_null("../Player")
@onready var npc = get_node_or_null(npc_node_path)

var door_locked = true
var message_label: Label = null
var message_timer: Timer = null
var last_message_time := 0.0

func _ready():
	if not player:
		print("⚠️ Player not found in scene!")
	else:
		print("Door ready - leads to Malupiton's chamber.")
	
	# Connect to NPC's defeated signal
	if npc:
		npc.connect("defeated", Callable(self, "_on_npc_defeated"))
		print("✅ Door connected to Malupiton's defeated signal")
	else:
		push_warning("⚠️ Malupiton not found! Set npc_node_path in Inspector")
	
	# Create on-screen message label
	_create_message_ui()

func _process(delta):
	if player:
		# Check distance between player and door
		var distance = player.global_position.distance_to(global_position)
		# When the player is close enough to the door
		if distance < 50:  # adjust range depending on tile size
			if door_locked:
				_check_unlock_condition()
			else:
				_open_door()

func _on_npc_defeated():
	print("🎯 Malupiton defeated! Door is now unlocked.")
	door_locked = false

func _check_unlock_condition():
	# Door unlocks after defeating Malupiton
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_message_time > 2.0:  # Show message every 2 seconds
		_show_message("🚫 Door is locked! Defeat Malupiton to unlock.")
		last_message_time = current_time
	print("🚫 Door is locked! Defeat Malupiton to unlock.")

func _open_door():
	# Disable the door's collider so the player can walk through
	if collision.disabled == false:
		collision.disabled = true
		_show_message("🚪 Door opened! Malupiton has been defeated...")
		print("🚪 Door opened! Malupiton has been defeated...")

func _create_message_ui():
	# Create a CanvasLayer for UI
	var canvas = CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)
	
	# Create label for messages
	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.position = Vector2(0, 500)  # Adjust Y position as needed
	message_label.size = Vector2(1152, 50)  # Full screen width
	message_label.add_theme_font_size_override("font_size", 24)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.add_theme_color_override("font_outline_color", Color.BLACK)
	message_label.add_theme_constant_override("outline_size", 8)
	message_label.modulate = Color(1, 1, 1, 0)  # Start invisible
	canvas.add_child(message_label)
	
	# Create timer for message fade
	message_timer = Timer.new()
	message_timer.wait_time = 2.0
	message_timer.one_shot = true
	message_timer.timeout.connect(_hide_message)
	add_child(message_timer)

func _show_message(text: String):
	if message_label:
		message_label.text = text
		message_label.modulate = Color(1, 1, 1, 1)  # Fully visible
		
		if message_timer:
			message_timer.start()

func _hide_message():
	if message_label:
		var tween = create_tween()
		tween.tween_property(message_label, "modulate", Color(1, 1, 1, 0), 0.5)
