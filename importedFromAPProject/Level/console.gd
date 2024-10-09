extends Control

@onready var console = $Screen  # Reference to the TextEdit node

# Call this function whenever you want to log something to the in-game console
func log_message(msg: String) -> void:
	console.text += msg + "\n"  # Append the message and a newline to the text
	console.scroll_vertical = console.get_line_count()  # Scroll to the bottom
