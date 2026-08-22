## The claw. Position is lerped and tweened by hand - there is no physics engine
## involved and no RigidBody2D. Real physics is a multi-day tuning sink and is
## out of scope.
##
## The whole cycle is one commitment: once the player drops, they have no
## control until the claw is back at the rail. That is the point.
extends Node2D

signal cycle_finished(result: Dictionary)

const H_SPEED := 220.0
const DESCEND_SPEED := 160.0
const RISE_SPEED := 200.0
const CLOSE_TIME := 0.30
const CABLE_TEXTURE_HEIGHT := 64.0
const GRAB_OFFSET := 110.0 ## grab point below the claw origin

enum State { IDLE, DESCEND, CLOSE, RISE }

@export var rail_y: float = 26.0
@export var min_x: float = 70.0
@export var max_x: float = 930.0
@export var max_depth: float = 215.0

## Set by the console buttons; added to the keyboard axis so mouse and keys
## drive exactly the same code path.
var button_axis: float = 0.0
var can_drop: bool = true

var state: State = State.IDLE
var carried: Node2D = null
var _close_timer: float = 0.0
var _grip_ok: bool = false
var _slip_y: float = -1.0
var _move_sfx_cooldown: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var cable: Sprite2D = $Cable
@onready var grab_area: Area2D = $GrabArea


func _ready() -> void:
	position = Vector2((min_x + max_x) * 0.5, rail_y)
	sprite.play(&"open")
	_update_cable()


func is_busy() -> bool:
	return state != State.IDLE


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE: _process_idle(delta)
		State.DESCEND: _process_descend(delta)
		State.CLOSE: _process_close(delta)
		State.RISE: _process_rise(delta)
	_update_cable()


func _process_idle(delta: float) -> void:
	var axis := clampf(Input.get_axis(&"claw_left", &"claw_right") + button_axis, -1.0, 1.0)
	if not is_zero_approx(axis):
		position.x = clampf(position.x + axis * H_SPEED * delta, min_x, max_x)
		_move_sfx_cooldown -= delta
		if _move_sfx_cooldown <= 0.0:
			_move_sfx_cooldown = 0.22
			Events.sfx_requested.emit(&"claw_move")
	if can_drop and Input.is_action_just_pressed(&"claw_drop"):
		start_drop()


## Public so the console drop button reaches exactly the same entry point.
func start_drop() -> void:
	if state != State.IDLE or not can_drop:
		return
	state = State.DESCEND
	sprite.play(&"open")
	Events.sfx_requested.emit(&"claw_drop")


func _process_descend(delta: float) -> void:
	position.y += DESCEND_SPEED * delta
	# Stop early on contact so the claw closes around whatever it reached.
	if position.y >= max_depth or not grab_area.get_overlapping_areas().is_empty():
		position.y = minf(position.y, max_depth)
		state = State.CLOSE
		_close_timer = CLOSE_TIME
		sprite.play(&"closing")


func _process_close(delta: float) -> void:
	_close_timer -= delta
	if _close_timer > 0.0:
		return
	sprite.play(&"closed")
	_resolve_grab()
	state = State.RISE


func _process_rise(delta: float) -> void:
	position.y -= RISE_SPEED * delta
	# A failed grip slips at a random height on the way up. That single
	# behaviour supplies all the roguelite risk this prototype needs.
	if carried != null and not _grip_ok and _slip_y > 0.0 and position.y <= _slip_y:
		_slip()
	if position.y <= rail_y:
		position.y = rail_y
		_finish_cycle()


func _resolve_grab() -> void:
	var target := _nearest_overlap()
	if target == null:
		Events.sfx_requested.emit(&"grab_fail")
		return
	var chance: float = target.grip_chance()
	_grip_ok = _roll_grip(chance)
	carried = target
	sprite.play(&"carrying")
	_attach(target)
	if _grip_ok:
		Events.sfx_requested.emit(&"grab_success")
	else:
		# Slip somewhere in the middle of the rise, never at the very top or
		# bottom, so the player always sees it happen.
		_slip_y = lerpf(position.y, rail_y, Game.rng.randf_range(0.25, 0.8))
		Events.sfx_requested.emit(&"grab_fail")


func _roll_grip(chance: float) -> bool:
	if Game.force_grip > 0:
		return true
	if Game.force_grip < 0:
		return false
	return Game.rng.randf() <= chance


func _attach(target: Node2D) -> void:
	if target.has_method("attach_to"):
		target.attach_to(self)
	else:
		target.reparent(self)
		target.position = Vector2(0, GRAB_OFFSET - 30.0)


func _slip() -> void:
	var slipped := carried
	carried = null
	_slip_y = -1.0
	sprite.play(&"open")
	if slipped.has_method("drop_into"):
		slipped.drop_into()
	Events.grip_failed.emit(slipped.data if "data" in slipped else null)
	Events.sfx_requested.emit(&"grab_fail")


func _finish_cycle() -> void:
	var result := {"kind": "miss", "item": null, "node": null}
	if carried != null:
		result["node"] = carried
		result["kind"] = "item"
		result["item"] = carried.data
	carried = null
	_slip_y = -1.0
	_grip_ok = false
	state = State.IDLE
	sprite.play(&"open")
	cycle_finished.emit(result)


## Nearest overlapping area to the grab point, so a crowded seabed still gives
## the player the thing they aimed at.
func _nearest_overlap() -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	var origin := grab_area.global_position
	for area: Area2D in grab_area.get_overlapping_areas():
		var d := origin.distance_to(area.global_position)
		if d < best_dist:
			best_dist = d
			best = area
	return best


## The cable is a texture stretched from the rail down to the claw - one PNG,
## no line drawing.
func _update_cable() -> void:
	var length := maxf(1.0, position.y)
	cable.position.y = -length * 0.5
	cable.scale.y = length / CABLE_TEXTURE_HEIGHT
