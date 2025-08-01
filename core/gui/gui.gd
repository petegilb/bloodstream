class_name Gui
extends Control

@onready var current_room_label = $MarginContainer/VBoxContainer/HBoxContainer/CurrentRoom
@onready var current_mission_label = $MarginContainer2/VBoxContainer/HBoxContainer2/CurrentMission
@onready var next_location_label = $MarginContainer2/VBoxContainer/HBoxContainer/NextLocation

func set_current_room_label(new_text: String) -> void:
    current_room_label.text = new_text

func set_current_mission_label(new_text: String) -> void:
    current_mission_label.text = new_text

func set_next_location_label(new_text: String) -> void:
    next_location_label.text = new_text
