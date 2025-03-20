extends Node2D

@onready var panel_container = $PanelContainer  # Adjust path if necessary

func _ready() -> void:
	panel_container.visible = false  # Ensure the panel is hidden at start

func _on_menu_button_pressed() -> void:  # Ensure this matches your button signal
	panel_container.visible = true  # Show the panel when the Menu button is clicked
