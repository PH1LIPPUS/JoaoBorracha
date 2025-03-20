<<<<<<< HEAD
extends Node2D

@onready var panel_container = $PanelContainer  # Adjust path if necessary

func _ready() -> void:
	panel_container.visible = false  # Ensure the panel is hidden at start

func _on_menu_button_pressed() -> void:  # Ensure this matches your button signal
	panel_container.visible = true  # Show the panel when the Menu button is clicked
=======
extends Control

@onready var panel_container = $PanelContainer
@onready var resume_button = $PanelContainer/Row/ResumeButton
@onready var back_button = $PanelContainer/Row/BackButton

func _ready() -> void:
	# Debugging: Check if nodes are assigned correctly
	print("Panel Container: ", panel_container)
	print("Resume Button: ", resume_button)
	print("Back Button: ", back_button)

	panel_container.visible = false  # Ensure the panel is hidden at start
	if resume_button:
		resume_button.visible = false  # Hide the Resume button initially
		resume_button.pressed.connect(_on_resume_pressed)  # Connect signal
	if back_button:
		back_button.visible = false  # Hide the Back button initially
		back_button.pressed.connect(_on_back_pressed)  # Connect signal

	# Connect Menu button signal (if not done in the editor)
	var menu_button = $MenuButton  # Adjust path to your Menu button
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)

func _on_menu_pressed() -> void:
	print("Menu button pressed")
	panel_container.visible = true  # Show the panel when the Menu button is clicked
	if resume_button:
		resume_button.visible = true  # Show the Resume button
	if back_button:
		back_button.visible = true  # Show the Back button
	get_tree().paused = true  # Pause the game

func _on_resume_pressed() -> void:
	print("Resume button pressed")
	panel_container.visible = false  # Hide the panel
	if resume_button:
		resume_button.visible = false  # Hide the Resume button
	if back_button:
		back_button.visible = false  # Hide the Back button
	get_tree().paused = false  # Unpause the game

func _on_back_pressed() -> void:
	print("Back button pressed")
	get_tree().paused = false  # Unpause the game
	get_tree().change_scene_to_file("res://Scene/main.tscn")  # Change to your main menu scene
>>>>>>> 066a3729576fb99ef01d20fd0265f33b81985d36
