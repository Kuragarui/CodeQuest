extends Control
signal puzzle_completed(success: bool)

@onready var question_label = $VBoxContainer/QuestionLabel
@onready var drop_zone = $VBoxContainer/DropZone
@onready var drop_zone_label = $VBoxContainer/DropZone/DropZoneLabel
@onready var code_blocks_container = $VBoxContainer/CodeBlocksContainer
@onready var submit_button = $VBoxContainer/SubmitButton

# === 🧩 3 Fill-in-the-Blank Printing Questions ===
var questions = [
	{
		"question": "What will this code print?\n\nx = 10\n\nif x > 5:\n    print('Big')\nelse:\n    print('Small')",
		"choices": [
			{"text": "Big", "correct": true},
			{"text": "Small", "correct": false},
			{"text": "10", "correct": false}
		]
	},
	{
		"question": "What will this code print?\n\nage = 15\n\nif age >= 18:\n    print('Adult')\nelse:\n    print('Minor')",
		"choices": [
			{"text": "Minor", "correct": true},
			{"text": "Adult", "correct": false},
			{"text": "15", "correct": false}
		]
	},
	{
		"question": "What will this code print?\n\nnum = 8\n\nif num % 2 == 0:\n    print('Even')\nelse:\n    print('Odd')",
		"choices": [
			{"text": "Even", "correct": true},
			{"text": "Odd", "correct": false},
			{"text": "8", "correct": false}
		]
	}
]

var current_index = 0
var dropped_block: Button = null
var current_question = {}
var dragging_block: Button = null
var drag_offset = Vector2.ZERO

func _ready():
	print("🎮 DragDropPuzzle _ready() called!")
	
	# Set to fullscreen and ensure it's on top
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	
	# Make the background visible
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	add_child(bg)
	move_child(bg, 0)
	
	_center_vbox()
	load_question(current_index)
	submit_button.pressed.connect(_on_submit_pressed)
	
	print("✅ DragDropPuzzle setup complete!")

func _center_vbox():
	var vbox = $VBoxContainer
	var screen_size = get_viewport_rect().size
	vbox.position = Vector2(
		(screen_size.x - vbox.size.x) / 2,
		(screen_size.y - vbox.size.y) / 2
	)

func load_question(index: int):
	if index >= questions.size():
		puzzle_completed.emit(true)
		print("✅ All questions answered! Puzzle complete.")
		queue_free()
		return
	
	current_question = questions[index]
	dropped_block = null
	drop_zone_label.text = "Drop code here"
	submit_button.disabled = true
	drop_zone.modulate = Color.WHITE
	question_label.text = current_question["question"]
	
	var choices = current_question["choices"]
	choices.shuffle()
	
	for i in range(code_blocks_container.get_child_count()):
		var block = code_blocks_container.get_child(i)
		if i < choices.size():
			block.visible = true
			block.text = choices[i]["text"]
			block.set_meta("is_correct", choices[i]["correct"])
			# disconnect previous gui_input safely
			for c in block.gui_input.get_connections():
				block.gui_input.disconnect(c.callable)
			block.gui_input.connect(_on_block_gui_input.bind(block))
			block.modulate = Color.WHITE
		else:
			block.visible = false

func _on_block_gui_input(event: InputEvent, block: Button):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging_block = block
			drag_offset = block.get_global_mouse_position() - block.global_position
			block.z_index = 10
			block.modulate = Color(1, 1, 1, 0.7)
		elif dragging_block:
			var mouse_pos = get_global_mouse_position()
			if drop_zone.get_global_rect().has_point(mouse_pos):
				if dropped_block:
					dropped_block.visible = true
				dropped_block = dragging_block
				drop_zone_label.text = dragging_block.text
				dragging_block.visible = false
				submit_button.disabled = false
				drop_zone.modulate = Color(0.8, 1, 0.8)
			dragging_block.z_index = 0
			dragging_block.modulate = Color.WHITE
			dragging_block = null
	elif event is InputEventMouseMotion and dragging_block:
		dragging_block.global_position = event.global_position - drag_offset

func _on_submit_pressed():
	if not dropped_block:
		return
	
	var is_correct = dropped_block.get_meta("is_correct")
	if is_correct:
		print("✅ Question", current_index + 1, "correct!")
		current_index += 1
		await get_tree().create_timer(0.4).timeout
		load_question(current_index)
	else:
		print("❌ Question", current_index + 1, "wrong!")
		puzzle_completed.emit(false)
		queue_free()
