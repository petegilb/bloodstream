class_name Gui
extends Control

@onready var current_room_label = $MarginContainer/VBoxContainer/HBoxContainer/CurrentRoom
@onready var current_mission_label = $MarginContainer2/VBoxContainer/HBoxContainer2/CurrentMission
@onready var next_location_label = $MarginContainer2/VBoxContainer/HBoxContainer/NextLocation
@onready var completed_deliveries = $MarginContainer/VBoxContainer/HBoxContainer2/CompletedDeliveries
@onready var delivery_status = $MarginContainer3/VBoxContainer/HBoxContainer/DeliveryStatus
@onready var game_over_screen = $GameOverScreen
@onready var pause_screen = $PauseScreen
@onready var health_bar: ProgressBar = $MarginContainer4/VBoxContainer/HealthBar
@onready var gas_bar: ProgressBar = $MarginContainer4/VBoxContainer/GasBar
@onready var volume_slider: Slider = $PauseScreen/VBoxContainer/HBoxContainer/VolumeSlider
@onready var sensitivity_slider: Slider = $PauseScreen/VBoxContainer/HBoxContainer2/SensitivitySlider
@onready var elapsed_time: Label = $MarginContainer3/VBoxContainer/HBoxContainer2/ElapsedTime
@onready var final_timer: Label = $GameOverScreen/VBoxContainer/FinalTimer

func _ready() -> void:
	game_over_screen.visible = false
	pause_screen.visible = false
	volume_slider.value = GameManager.volume_modifier
	sensitivity_slider.value = GameManager.mouse_sensitivity

func timer_readable(in_time: float) -> String:
	var minutes = floor(in_time / 60.0)
	var sec =  in_time - (minutes * 60)
	return "%02d : %02d" % [minutes, sec]

func set_timer(time_alive: float) -> void:
	elapsed_time.text = timer_readable(time_alive)

func set_current_room_label(new_text: String) -> void:
	current_room_label.text = new_text

func set_current_mission_label(new_text: String) -> void:
	current_mission_label.text = new_text

func set_next_location_label(new_text: String) -> void:
	next_location_label.text = new_text

func game_over():
	game_over_screen.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var final_string = "You survived for %s with a total of %d deliveries\nbefore you succumbed to the virus..."
	final_timer.text = final_string % [timer_readable(GameManager.player.time_alive), GameManager._completed_deliveries]

func _on_replay_button_pressed() -> void:
	GameManager.replay()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	pause_screen.visible = false
	GameManager.resume()

func _on_volume_slider_value_changed(value:float) -> void:
	GameManager.set_volume(value)

func _on_sensitivity_slider_value_changed(value:float) -> void:
	GameManager.mouse_sensitivity = value
