class_name Gui
extends Control

@onready var current_room_label = $MarginContainer/VBoxContainer/HBoxContainer/CurrentRoom
@onready var current_mission_label = $MarginContainer2/VBoxContainer/HBoxContainer2/CurrentMission
@onready var next_location_label = $MarginContainer2/VBoxContainer/HBoxContainer/NextLocation
@onready var completed_deliveries = $MarginContainer/VBoxContainer/HBoxContainer2/CompletedDeliveries
@onready var delivery_status = $MarginContainer3/VBoxContainer/HBoxContainer/DeliveryStatus
@onready var game_over_screen = $GameOverScreen
@onready var health_bar: ProgressBar = $MarginContainer4/HealthBar

func _ready() -> void:
    game_over_screen.visible = false

func set_current_room_label(new_text: String) -> void:
    current_room_label.text = new_text

func set_current_mission_label(new_text: String) -> void:
    current_mission_label.text = new_text

func set_next_location_label(new_text: String) -> void:
    next_location_label.text = new_text

func game_over():
    game_over_screen.visible = true
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_replay_button_pressed() -> void:
    GameManager.replay()

func _on_quit_button_pressed() -> void:
    get_tree().quit()
