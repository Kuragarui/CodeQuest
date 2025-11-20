extends Control
signal puzzle_completed(success: bool)

@onready var question_label = $VBoxContainer/QuestionLabel
@onready var answer_input = $VBoxContainer/AnswerLineEdit
@onready var submit_button = $VBoxContainer/HBoxContainer/SubmitButton
@onready var feedback_label = $VBoxContainer/FeedbackLabel

# === 🏆 BOSS QUESTIONS (6 questions total) ===
var questions = [
	# Printing (2 questions)
	{
		"question": "Given:\nname = 'Patrick'\nWhat will print?\nprint(name)",
	"answer": "patrick",
	"topic": "Printing"
	},
	{
		"question": "Complete the code to print 'Hello':\n_____('Hello')",
		"answer": "print",
		"topic": "Printing"
	},
	
	# Arithmetic (2 questions)
	{
		"question": "What is the result of: 10 // 3\n(Integer division)",
		"answer": "3",
		"topic": "Arithmetic"
	},
	{
		"question": "What operator gives the remainder?\nExample: 17 _ 5 = 2",
		"answer": "%",
		"topic": "Arithmetic"
	},
	
	# If-Else (2 questions)
	{
		"question": "What keyword checks a condition in Python?",
		"answer": "if",
		"topic": "Conditional"
	},
	{
		"question": "What keyword is used for the default case?\nif x > 5:\n    print('Big')\n____:\n    print('Small')",
		"answer": "else",
		"topic": "Conditional"
	}
]

var current_index = 0
var current_question = {}

func _ready():
	print("🏆 BOSS PUZZLE - Typing Mode!")
	
	# Set to fullscreen
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0, 0.2, 0.9)  # Dark purple for boss!
	add_child(bg)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -1
	move_child(bg, 0)
	
	_center_vbox()
	
	# Shuffle questions for variety
	questions.shuffle()
	
	load_question(current_index)
	
	# Connect signals
	submit_button.pressed.connect(_on_submit_pressed)
	answer_input.text_submitted.connect(_on_text_submitted)  # Enter key
	
	# Focus on input so keyboard appears
	answer_input.grab_focus()
	
	print("✅ Boss puzzle setup complete!")

func _center_vbox():
	var vbox = $VBoxContainer
	await get_tree().process_frame  # Wait for size calculation
	var screen_size = get_viewport_rect().size
	vbox.position = Vector2(
		(screen_size.x - vbox.size.x) / 2,
		(screen_size.y - vbox.size.y) / 2
	)

func load_question(index: int):
	if index >= questions.size():
		puzzle_completed.emit(true)
		print("🏆 BOSS DEFEATED! All questions answered!")
		queue_free()
		return
	
	current_question = questions[index]
	question_label.text = "[" + current_question["topic"] + "]\n\n" + current_question["question"]
	answer_input.text = ""
	feedback_label.text = ""
	feedback_label.modulate = Color.WHITE
	
	# FORCE FOCUS - wait for scene to be ready
	await get_tree().process_frame
	answer_input.grab_focus()
	
	print("Question", index + 1, "loaded:", current_question["topic"])

func _on_submit_pressed():
	_check_answer()

func _on_text_submitted(_text: String):
	_check_answer()

func _check_answer():
	var player_answer = answer_input.text.strip_edges().to_lower()
	var correct_answer = current_question["answer"].to_lower()
	
	if player_answer == correct_answer:
		print("✅ Correct!")
		feedback_label.text = "✅ CORRECT!"
		feedback_label.modulate = Color.GREEN
		
		await get_tree().create_timer(0.8).timeout
		current_index += 1
		load_question(current_index)
		
	else:
		print("❌ Wrong answer:", player_answer)
		feedback_label.text = "❌ WRONG! Try again."
		feedback_label.modulate = Color.RED
		
		# 👇 DITO MAG-SETUP NG HEALTH SYSTEM ANG TEAMMATE MO!
		# PlayerStats.take_damage(1)
		# HINDI NAG-CLOSE YUNG PUZZLE - PWEDE PA MAG-TRY ULIT!
		
		# Shake effect (optional)
		_shake_feedback()
		
		# Clear input para mag-try ulit
		await get_tree().create_timer(1.0).timeout
		answer_input.text = ""
		feedback_label.text = ""
		answer_input.grab_focus()

func _shake_feedback():
	var original_pos = feedback_label.position
	var tween = create_tween()
	tween.tween_property(feedback_label, "position", original_pos + Vector2(10, 0), 0.05)
	tween.tween_property(feedback_label, "position", original_pos - Vector2(10, 0), 0.05)
	tween.tween_property(feedback_label, "position", original_pos, 0.05)
