# lerped by hand, no physics engine. once you drop you get no control back
# until it's home again.
extends Node2D

signal cycle_finished(result: Dictionary)
# tank listens for this to charge the budget. claw has no idea what it costs.
signal drop_started()

const H_SPEED := 220.0
const DESCEND_SPEED := 160.0
const RISE_SPEED := 200.0
const CLOSE_TIME := 0.30
const CABLE_TEXTURE_HEIGHT := 64.0
const GRAB_OFFSET := 110.0 ## grab point below the claw origin
const GRAB_RADIUS := 46.0 ## must match GrabArea's CollisionShape2D
const ITEM_RADIUS := 40.0 ## must match tank_item.tscn's CollisionShape2D

enum State { IDLE, DESCEND, CLOSE, RISE }

@export var rail_y: float = 26.0
@export var min_x: float = 70.0
@export var max_x: float = 930.0
@export var max_depth: float = 215.0

# console buttons write this, gets added to the keyboard axis
var button_axis: float = 0.0
var can_drop: bool = true
# false on the desk tab. a cycle already in the air still finishes.
var input_enabled: bool = true

var state: State = State.IDLE
var carried: Node2D = null
var _close_timer: float = 0.0
var _grip_ok: bool = false
var _slip_y: float = -1.0
var _move_sfx_cooldown: float = 0.0
# only non-zero if the equipped upgrade traded rail speed away
var _rail_lockout: float = 0.0

# set by the tank every frame. the grab resolves to this exact node so the %
# shown before the drop can't belong to a different item.
var predicted_target: Node2D = null

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var cable: Sprite2D = $Cable
@onready var grab_area: Area2D = $GrabArea


func _ready() -> void:
	position = Vector2((min_x + max_x) * 0.5, rail_y)
	sprite.play(&"open")
	_update_cable()


func is_busy() -> bool:
	return state != State.IDLE


func is_rail_locked() -> bool:
	return _rail_lockout > 0.0


func _physics_process(delta: float) -> void:
	match state:
		State.IDLE: _process_idle(delta)
		State.DESCEND: _process_descend(delta)
		State.CLOSE: _process_close(delta)
		State.RISE: _process_rise(delta)
	_update_cable()


func _process_idle(delta: float) -> void:
	if not input_enabled:
		return
	_rail_lockout = maxf(0.0, _rail_lockout - delta)
	var axis := clampf(Input.get_axis(&"claw_left", &"claw_right") + button_axis, -1.0, 1.0)
	if not is_zero_approx(axis) and not is_rail_locked():
		position.x = clampf(
			position.x + axis * H_SPEED * Game.move_speed_multiplier() * delta,
			min_x, max_x)
		_move_sfx_cooldown -= delta
		if _move_sfx_cooldown <= 0.0:
			_move_sfx_cooldown = 0.22
			Events.sfx_requested.emit(&"claw_move")
	if can_drop and Input.is_action_just_pressed(&"claw_drop"):
		start_drop()


# public so the console button hits the same path as the key
func start_drop() -> void:
	if state != State.IDLE or not can_drop:
		return
	state = State.DESCEND
	sprite.play(&"open")
	drop_started.emit()
	Events.sfx_requested.emit(&"claw_drop")


func _process_descend(delta: float) -> void:
	position.y += DESCEND_SPEED * delta
	# stop early on contact, close around whatever it reached
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
	# failed grip = slips at a random height on the way up
	if carried != null and not _grip_ok and _slip_y > 0.0 and position.y <= _slip_y:
		_slip()
	if position.y <= rail_y:
		position.y = rail_y
		_rail_lockout = Game.post_drop_lockout()
		_finish_cycle()


# has to find the target the same way the descent will - FIRST contact, not
# nearest in x. these two disagreed for ages and the preview kept naming the
# wrong item when two overlapped.
func predict_target(candidates: Array) -> Node2D:
	var reach := GRAB_RADIUS + ITEM_RADIUS
	var best: Node2D = null
	var earliest := INF
	for node: Node in candidates:
		if not (node is Node2D) or not ("data" in node):
			continue
		var item := node as Node2D
		var dx: float = absf(item.position.x - position.x)
		if dx >= reach:
			continue
		# claw height where the grab circle first touches this one
		var contact_y: float = item.position.y - sqrt(reach * reach - dx * dx) - GRAB_OFFSET
		if contact_y > max_depth:
			continue
		if contact_y < earliest:
			earliest = contact_y
			best = item
	return best


func _resolve_grab() -> void:
	var target := _preferred_target()
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
		# somewhere in the middle of the rise so they actually see it happen
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


# honour the prediction if the descent really reached it, else whatever is
# actually in there
func _preferred_target() -> Node2D:
	var overlapping := grab_area.get_overlapping_areas()
	if predicted_target != null and predicted_target in overlapping:
		return predicted_target
	return _nearest_overlap()


# nearest overlap to the grab point
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


# cable is one PNG stretched, not a drawn line
func _update_cable() -> void:
	var length := maxf(1.0, position.y)
	cable.position.y = -length * 0.5
	cable.scale.y = length / CABLE_TEXTURE_HEIGHT
