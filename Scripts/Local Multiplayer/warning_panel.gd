extends CanvasLayer

@onready var heading_label: Label = $"Control/PanelBg/HeadingBox/Label"
@onready var message_label: Label = $"Control/PanelBg/Label"
@onready var yes_button: Button = $"Control/PanelBg/Yes"
@onready var no_button: Button = $"Control/PanelBg/No"

var leave_match_mode: bool = true


func show_leave_match_warning() -> void:
	leave_match_mode = true
	heading_label.text = "Warning"
	message_label.text = "Are you sure you want to \nleave the match ! You will \nlose the match if you do so? "
	yes_button.visible = true
	yes_button.text = "YES"
	no_button.text = "NO"
	visible = true


func show_alert(message: String, heading: String = "Alert") -> void:
	leave_match_mode = false
	heading_label.text = heading
	message_label.text = message
	yes_button.visible = false
	no_button.text = "OK"
	visible = true


func _on_no_pressed() -> void:
	visible = false

func _on_yes_pressed() -> void:
	if leave_match_mode:
		UIManager.home()
