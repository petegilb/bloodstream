class_name Main
extends Node3D

@onready var navigation_region: NavigationRegion3D = $NavigationRegion3D

func _ready() -> void:
    pass

func _input(_event: InputEvent) -> void:
    # if event.is_action_pressed("ui_cancel"):
    #     get_tree().quit()
    pass
