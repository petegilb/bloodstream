class_name SpawnManager
extends Node3D

enum DIFFICULTY_STAGES {HEALTHY, SNIFFLES, UNDER_WEATHER, VIRAL, FEVER, CHOLESTEROL, BLOOD_PRESSURE, HEART}

var virus_scene = preload("res://prefabs/cells/virus.tscn")
var carrot_scene = preload("res://core/pickups/carrot_pickup.tscn")
var pill_scene = preload("res://core/pickups/pill_pickup.tscn")
var navigation_region: NavigationRegion3D = null
var is_initialized = false

var pickup_scenes := []

# TODO add high cholesterol or high blood pressure
var difficulty_stages = {
    DIFFICULTY_STAGES.HEALTHY: 'Healthy',
    DIFFICULTY_STAGES.SNIFFLES: 'Case of the Sniffles',
    DIFFICULTY_STAGES.UNDER_WEATHER: 'Under the Weather',
    DIFFICULTY_STAGES.VIRAL: 'Viral Infection',
    DIFFICULTY_STAGES.FEVER: 'Fever',
    DIFFICULTY_STAGES.CHOLESTEROL: 'High Cholesterol',
    DIFFICULTY_STAGES.BLOOD_PRESSURE: 'High Blood Pressure',
    DIFFICULTY_STAGES.HEART: 'Heart Attack',
}

var difficulty_modifiers = {
    DIFFICULTY_STAGES.HEALTHY: 0.0,
    DIFFICULTY_STAGES.SNIFFLES: 1.0,
    DIFFICULTY_STAGES.UNDER_WEATHER: 2.0,
    DIFFICULTY_STAGES.VIRAL: 4.0,
    DIFFICULTY_STAGES.FEVER: 5.0,
    DIFFICULTY_STAGES.CHOLESTEROL: 7.0,
    DIFFICULTY_STAGES.BLOOD_PRESSURE: 8.0,
    DIFFICULTY_STAGES.HEART: 10.0,
}

# when to switch to next difficulty stage (in elapsed minutes)
var difficulty_timing = {
    DIFFICULTY_STAGES.HEALTHY: 0.0,
    DIFFICULTY_STAGES.SNIFFLES: .5,
    DIFFICULTY_STAGES.UNDER_WEATHER: 1.5,
    DIFFICULTY_STAGES.VIRAL: 3.0,
    DIFFICULTY_STAGES.FEVER: 4.0,
    DIFFICULTY_STAGES.CHOLESTEROL: 6.0,
    DIFFICULTY_STAGES.BLOOD_PRESSURE: 9.0,
    DIFFICULTY_STAGES.HEART: 12.0,
}

const ENEMY_SPAWN_INTERVAL := 8.0
const PICKUP_SPAWN_INTERVAL := 15.0
const SPAWN_DISTANCE := 50.0
const MIN_SPAWN_DISTANCE := 40
const MAX_SPAWN_DISTANCE := 100
const MAX_ENEMIES_PER_FRAME := 5
var current_difficulty_stage = DIFFICULTY_STAGES.HEALTHY
var next_difficulty_stage = 1
var spawn_timer := 0.0
var pickup_spawn_timer := 0.0

func _ready() -> void:
    update_difficulty_stage_label()

func update_difficulty_stage_label(fading_message:= false):
    if GameManager.gui != null and GameManager.gui.difficulty_stage_label != null:
        GameManager.gui.difficulty_stage_label.text = difficulty_stages.get(current_difficulty_stage)
        if fading_message:
            GameManager.gui.set_fading_message("Difficulty has Increased to %s" % difficulty_stages.get(current_difficulty_stage), 2.0)

func initialize(nav_region: NavigationRegion3D):
    navigation_region = nav_region
    pickup_scenes.append(pill_scene)
    pickup_scenes.append(carrot_scene)
    is_initialized = true

func _process(delta: float) -> void:
    spawn_timer += delta
    pickup_spawn_timer += delta

    var current_timer = GameManager.get_timer()
    if difficulty_timing.get(next_difficulty_stage)*60 <= current_timer:
        current_difficulty_stage = next_difficulty_stage as DIFFICULTY_STAGES
        next_difficulty_stage += 1
        on_new_stage()
        print("Difficulty stage updated: %s to %s" % [difficulty_stages.get(current_difficulty_stage-1), difficulty_stages.get(current_difficulty_stage)])

    if spawn_timer >= ENEMY_SPAWN_INTERVAL:
        spawn_enemies()
        spawn_timer = 0.0

    if pickup_spawn_timer >= PICKUP_SPAWN_INTERVAL:
        spawn_pickups()
        pickup_spawn_timer = 0.0

func on_new_stage():
    update_difficulty_stage_label(true)

func check_spawn_point(spawn_point: Vector3) -> bool:
    var checks_out = false
    var distance_to_player := spawn_point.distance_to(GameManager.player.global_position)
    if distance_to_player >= MIN_SPAWN_DISTANCE and distance_to_player <= MAX_SPAWN_DISTANCE:
        checks_out = true
    return checks_out

func spawn_enemy() -> bool:
    # try to spawn them behind the player, if that's too close or too far try to spawn in front, if not that -> spawn in room
    # would be cool to spawn behind in the veins but idk if that's possible in the time limit
    var nav_map := navigation_region.get_navigation_map()
    var spawn_point := NavigationServer3D.map_get_closest_point(nav_map, GameManager.player.get_behind_camera(SPAWN_DISTANCE))
    if not check_spawn_point(spawn_point):
        spawn_point = NavigationServer3D.map_get_closest_point(nav_map, GameManager.player.get_behind_camera(SPAWN_DISTANCE, true))
    if (not check_spawn_point(spawn_point)) and GameManager._current_room != null:
        spawn_point = NavigationServer3D.map_get_closest_point(nav_map, GameManager._current_room.global_position)
    if not check_spawn_point(spawn_point):
        return false
    var new_enemy = virus_scene.instantiate()
    GameManager.enemies_node.add_child(new_enemy)
    new_enemy.global_position = spawn_point
    return true

func spawn_enemies():
    # for now i'll just do the num to spawn per interval as the modifier but that should also change enemy health etc.
    # also different types of enemies if i get there
    var num_enemies: int = difficulty_modifiers.get(current_difficulty_stage)
    var successfully_spawned := 0
    for idx in num_enemies:
        var did_spawn_enemy = spawn_enemy()
        successfully_spawned += 1 if did_spawn_enemy else 0
    
    print('spawned %d / %d enemies...' % [successfully_spawned, num_enemies])

func spawn_pickup(nav_map):
    var scene_to_spawn = pill_scene if randi_range(0, 2) == 0 else carrot_scene
    var spawn_point : Vector3
    var set_spawn_point := false
    
    var random_choice := randi_range(0, 2)
    if random_choice == 0:
        spawn_point = NavigationServer3D.map_get_closest_point(nav_map, GameManager.player.get_behind_camera(SPAWN_DISTANCE, true))
        set_spawn_point = true
    else:
        if GameManager._current_room != null:
            spawn_point = NavigationServer3D.map_get_closest_point(nav_map, GameManager._current_room.global_position + Vector3(randf_range(-5.0, 5.0), 0 ,0)  )
            set_spawn_point = true
        elif len(GameManager.shortest_path_arr) > 1 and GameManager.room_name_to_resource.get(GameManager.shortest_path_arr[1]):
            spawn_point = GameManager.room_to_bounds.get(GameManager.room_name_to_resource.get(GameManager.shortest_path_arr[1])).global_position
            spawn_point = NavigationServer3D.map_get_closest_point(nav_map, spawn_point)
            set_spawn_point = true

    if set_spawn_point:
        var new_pickup = scene_to_spawn.instantiate()
        GameManager.pickups_node.add_child(new_pickup)
        new_pickup.global_position = spawn_point + Vector3(0, 1, 0)
        new_pickup.initialize()
        print('spawned pickup successfully')
    else:
        print('failed to spawn pickup')

func spawn_pickups():
    var nav_map := navigation_region.get_navigation_map()
    var num_pickups = randi_range(1, 2)
    for idx in num_pickups:
        spawn_pickup(nav_map)
