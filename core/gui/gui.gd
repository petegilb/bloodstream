class_name Gui
extends Control

@onready var current_room_label = $MarginContainer/VBoxContainer/HBoxContainer/CurrentRoom

func set_current_room_label(new_text: String) -> void:
    current_room_label.text = new_text
