extends Node

signal quest_changed(text)

var quest_text := "Defeat The TypeError Titan"
var quest_completed := false


func get_quest_text():
	if quest_completed:
		return "🎉 Game Completed!"
	return quest_text


func complete_final_quest():
	if quest_completed:
		return
	quest_completed = true
	print("🎉 Final boss defeated, game completed!")
	emit_signal("quest_changed", get_quest_text())
