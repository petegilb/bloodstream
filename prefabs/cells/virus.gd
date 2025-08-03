class_name Virus
extends CharacterBody3D

enum VIRUS_STATE {WANDER, CHASE, ATTACK}

@export var movement_speed: float = 5.0
@export var rotation_speed: float = 4.0
@export var fast_rotation_speed: float = 20.0
@export var detection_radius := 100.0
@export var close_enough_radius := 5.0
@export var attack_radius := 5.0
@export var base_damage := 5
@export var show_debug := false

var particle = preload("res://core/particles/small_explosion.tscn")

@onready var navigation_agent = $NavigationAgent3D
@onready var debug_label = $DebugLabel

var has_target := false
var current_room: RoomBounds = null
var virus_state: VIRUS_STATE = VIRUS_STATE.WANDER

# func _unhandled_input(event: InputEvent) -> void:
#     #navigation_agent.target_position = 
#     pass

func _ready() -> void:
    debug_label.visible = show_debug

func set_current_room(new_room: RoomBounds):
    current_room = new_room

func set_target(new_target: Vector3):
    navigation_agent.target_position = new_target
    has_target = true

func attack():
    # keep moving closer to player
    var player_position = GameManager.player.global_position
    if navigation_agent.target_position.distance_to(player_position) > close_enough_radius:
        set_target(player_position)
    
    # handle damage here
    GameManager.player.add_health(-base_damage)
    initiate_death()

func _process(_delta: float) -> void:
    if show_debug:
        debug_label.text = "%s" % [VIRUS_STATE.keys()[virus_state]]

func _physics_process(delta: float) -> void:
    if not GameManager.player:
        return
    
    # set current state
    var player_position = GameManager.player.global_position
    var distance = global_position.distance_to(player_position)
    if distance <= attack_radius:
        virus_state = VIRUS_STATE.ATTACK
    elif str(GameManager._current_room) == str(current_room) or distance <= detection_radius:
        if virus_state != VIRUS_STATE.CHASE:
            AudioManager.create_3d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.VIRUS_SPAWNED)
        virus_state = VIRUS_STATE.CHASE
    else:
        virus_state = VIRUS_STATE.WANDER

    # move to target if we have one
    if has_target:
        var destination = navigation_agent.get_next_path_position()
        var local_destination = global_position.direction_to(destination)

        var direction = local_destination.normalized()

        velocity = direction * movement_speed

        if navigation_agent.is_navigation_finished():
            has_target = false
            velocity = Vector3.ZERO

        var target_rotation := direction.signed_angle_to(Vector3.MODEL_FRONT, Vector3.DOWN)
        if abs(target_rotation - rotation.y) > deg_to_rad(60):
            rotation.y = move_toward(rotation.y, target_rotation, delta * fast_rotation_speed)
        else:
            rotation.y = move_toward(rotation.y, target_rotation, delta * rotation_speed)
    
    # handle next target based on state
    if virus_state == VIRUS_STATE.CHASE:
        if navigation_agent.target_position.distance_to(player_position) > close_enough_radius:
            set_target(player_position)
    elif virus_state == VIRUS_STATE.WANDER:
        if not has_target:
            set_target(GameManager.rooms.pick_random().global_position)
    elif virus_state == VIRUS_STATE.ATTACK:
        attack()

    move_and_slide()

func initiate_death():
    AudioManager.create_3d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.EXPLOSION)
    if particle:
        var new_particle = particle.instantiate()
        get_tree().current_scene.add_child(new_particle)
        new_particle.global_position = global_position
    self.queue_free()

func kill():
    print('virus killed!')
    AudioManager.create_3d_audio_at_location(global_position, SoundEffect.SOUND_EFFECT_TYPE.VIRUS_DEATH)
    queue_free()