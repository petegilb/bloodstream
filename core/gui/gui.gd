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
@onready var difficulty_stage_label: Label = $MarginContainer3/VBoxContainer/HBoxContainer3/DifficultyStage
@onready var fading_message: Label = $FadingMessage
@onready var mouse_movement_debug: Label = $MouseMovementDebug
@onready var loading_screen = $LoadingScreen

var fading_messages: Array[String] = []
var fading_messages_timing: Array[float] = []
var is_fading_message := false

func _ready() -> void:
	loading_screen.visible = true
	game_over_screen.visible = false
	pause_screen.visible = false
	fading_message.visible = false
	mouse_movement_debug.visible = false
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

func _start_fading_message():
	is_fading_message = true
	var message = fading_messages.pop_front()
	var fading_message_speed = fading_messages_timing.pop_front()
	if not (fading_message and message):
		return
	fading_message.visible = true
	fading_message.modulate.a = 0.0
	fading_message.text = message
	# var target_modulate = fading_message.modulate
	# target_modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.tween_property(fading_message, "modulate:a", 1.0, 1)
	tween.tween_interval(fading_message_speed)
	tween.tween_property(fading_message, "modulate:a", 0.0, 1)
	tween.tween_callback(_finish_fading_message)

func _finish_fading_message():
	fading_message.visible = false
	if len(fading_messages) > 0:
		_start_fading_message()
	else:
		is_fading_message = false

# This is the method that should be called to set a fading message
func set_fading_message(new_message: String, fading_message_speed=1.0):
	fading_messages.append(new_message)
	fading_messages_timing.append(fading_message_speed)
	if is_fading_message == false:
		_start_fading_message()
	print('set new fading message %s' % new_message)
