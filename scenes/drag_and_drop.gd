extends Control

signal puzzle_completed(success: bool)

@onready var question_label = $PuzzleContainer/QuestionLabel
@onready var drop_zone = $PuzzleContainer/DropZone
@onready var drop_zone_label = $PuzzleContainer/DropZone/DropZoneLabel
@onready var code_blocks_container = $PuzzleContainer/CodeBlocksContainer
@onready var submit_button = $PuzzleContainer/SubmitButton

var correct_answer = "5 + 3"
var dropped_block = null
var dragging_block = null

func _ready():
	# Set up the question
	question_label.text = "Drag the correct Python code to calculate 5 + 3:"
	drop_zone_label.text = "Drop code here"
	submit_button.text = "Submit Answer"
	submit_button.disabled = true
	
	# Set up code blocks
	var code_blocks = [
		{"text": "5 + 3", "correct": true},
		{"text": "print(5 + 3)", "correct": false},
		{"text": "\"8\"", "correct": false}
	]
	
	# Shuffle blocks
	code_blocks.shuffle()
	
	# Create draggable buttons
	for i in range(code_blocks.size()):
		var block = code_blocks_container.get_child(i)
		block.text = code_blocks[i]["text"]
		block.set_meta("is_correct", code_blocks[i]["correct"])
		block.gui_input.connect(_on_code_block_input.bind(block))
	
	# Set up drop zone
	drop_zone.gui_input.connect(_on_drop_zone_input)
	submit_button.pressed.connect(_on_submit_pressed)

func _on_code_block_input(event: InputEvent, block: Button):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				dragging_block = block
				block.modulate = Color(1, 1, 1, 0.5)
			else:
				# Stop dragging
				if dragging_block:
					dragging_block.modulate = Color.WHITE
					dragging_block = null

func _on_drop_zone_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if dragging_block and drop_zone.get_global_rect().has_point(event.global_position):
				# Drop the block
				dropped_block = dragging_block
				drop_zone_label.text = dragging_block.text
				dragging_block.modulate = Color.WHITE
				dragging_block.visible = false
				dragging_block = null
				submit_button.disabled = false

func _on_submit_pressed():
	if dropped_block:
		var is_correct = dropped_block.get_meta("is_correct")
		puzzle_completed.emit(is_correct)
		queue_free()

func _process(_delta):
	# Visual feedback when dragging over drop zone
	if dragging_block:
		var mouse_pos = get_global_mouse_position()
		if drop_zone.get_global_rect().has_point(mouse_pos):
			drop_zone.modulate = Color(0.8, 1, 0.8)
		else:
			drop_zone.modulate = Color.WHITE
