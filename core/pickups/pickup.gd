class_name Pickup
extends Node3D

@export var tween_speed := 1
@export var rotation_speed := 2.0
var initial_position: Vector3
var position_tween: Tween

func _ready() -> void:
    initial_position = global_position
    position_tween = get_tree().create_tween()
    position_tween.set_loops(-1)
    position_tween.tween_property(self, "position", initial_position + Vector3(0, .5, 0), tween_speed).set_trans(Tween.TRANS_SINE)
    position_tween.tween_property(self, "position", initial_position, tween_speed).set_trans(Tween.TRANS_SINE)

    # tween.tween_callback(self.queue_free)

func _physics_process(delta: float) -> void:
    global_rotation += Vector3(0, rotation_speed * delta, 0)

func _on_area_3d_body_entered(body: Node3D) -> void:
    if body is BoatCharacter:
        position_tween.kill()
        _pickup(body)

func _pickup(_character: BoatCharacter):
    # AudioManager.create_3d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.YUM)
    AudioManager.create_audio(SoundEffect.SOUND_EFFECT_TYPE.YUM)
    self.queue_free()
