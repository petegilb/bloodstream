extends Node3D

func _ready() -> void:
    pass

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()
