extends CanvasLayer

signal upgrade_selected(choice)

func _on_button_1_pressed():
	upgrade_selected.emit(1)
	hide()
	get_tree().paused = false

func _on_button_2_pressed():
	upgrade_selected.emit(2)
	hide()
	get_tree().paused = false

func _on_button_3_pressed():
	upgrade_selected.emit(3)
	hide()
	get_tree().paused = false

func show_menu():
	show()
	get_tree().paused = true
