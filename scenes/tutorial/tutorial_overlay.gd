# The guided tour. Darkens the screen, punches one hole over the thing being
# talked about, and puts a caption next to it.
#
# The hole is a shader on a full-screen ColorRect rather than four rects around
# a gap, because four rects cannot make a round corner and the cutout has to sit
# on things like the GRAB button, which is a circle.
#
# The tour is narration, not a checklist: the overlay eats every input while it
# is up and a click anywhere moves on. Nothing underneath can be pressed, so
# there is no way to get the game into a state the next step does not expect.
# The tree is paused for the same reason - a shift that ends by itself halfway
# through the tour would leave the caption talking about a screen that is gone.
#
# One kind of step breaks that, and only that far: a step carrying "wait_for"
# asks the player to press the thing being lit, and will not move on until they
# have. The pause is what makes it safe rather than something to work around -
# only the lit control is switched to PROCESS_MODE_ALWAYS, so it is the single
# live thing on a frozen screen, and the caption's Next button goes away so
# there is no way past it except doing the thing. Everything is put back the
# moment the step is answered.
#
# There is no skip. It runs once per launch, on the first run of that sitting,
# and a player who skips it is exactly the player who then does not know what a
# bin does. Whoever wants it back sooner than that has a button for it in
# settings and in the pause menu.
extends Control

# how far the caption sits from the lit rect, and from the screen edge
const CAPTION_GAP := 26.0
const SCREEN_MARGIN := 24.0
const DIM := Color(0.02, 0.05, 0.12, 0.84)

@onready var _dim: ColorRect = $Dim
@onready var _caption: NinePatchRect = $Caption
@onready var _title: Label = $Caption/Title
@onready var _body: Label = $Caption/Body
@onready var _progress: Label = $Caption/Progress
@onready var _next: Button = $Caption/NextButton

var _steps: Array = []
var _index: int = 0
var _scene_root: Node = null

# set while a "wait_for" step is up: the action being waited on, the controls
# thawed to allow it, and the click-blocking this overlay does the rest of the
# time. all three are undone together in _stop_waiting.
var _waiting_for: StringName = &""
var _thawed: Array[Node] = []
var _blocking: int = Control.MOUSE_FILTER_STOP


func _ready() -> void:
	_next.pressed.connect(_advance)
	gui_input.connect(_on_dim_clicked)
	Events.tutorial_requested.connect(_on_tutorial_requested)
	Events.tutorial_action_performed.connect(_on_action_performed)
	_blocking = mouse_filter
	visible = false


## Main hands this over on every scene swap, so the step paths resolve against
## whatever is on screen now.
func set_scene_root(node: Node) -> void:
	_scene_root = node


func _on_tutorial_requested(segment: StringName) -> void:
	var steps := TutorialSteps.segment(segment)
	if steps.is_empty():
		return
	# the scene that asked is still mid-_ready, so its controls have no size
	# yet. one frame later they do, and the spotlight lands on real rects.
	_begin.call_deferred(steps)


func _begin(steps: Array) -> void:
	_steps = steps
	_index = 0
	visible = true
	get_tree().paused = true
	_show_step()


# A click anywhere that isn't one of the caption's own buttons moves on. This
# is gui_input rather than _input so the buttons still get their clicks - the
# root is MOUSE_FILTER_STOP, so everything else lands here.
func _on_dim_clicked(event: InputEvent) -> void:
	if _waiting_for != &"":
		return
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
		accept_event()


# The tree is paused while the tour is up, so nothing underneath is listening -
# this only has to cover the overlay's own keys.
func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or _waiting_for != &"":
		return
	if event.is_action_pressed(&"advance") or event.is_action_pressed(&"claw_drop"):
		_advance()
	else:
		return
	get_viewport().set_input_as_handled()


func _advance() -> void:
	_stop_waiting()
	Events.sfx_requested.emit(&"ui_click")
	_index += 1
	if _index >= _steps.size():
		_finish()
	else:
		_show_step()


func _finish() -> void:
	if not visible:
		return
	_stop_waiting()
	visible = false
	_steps = []
	get_tree().paused = false
	Events.tutorial_segment_finished.emit()


## Dropped rather than finished - the screen it was describing has gone. Main
## already unpauses on a swap, so this only has to put the caption away.
func cancel() -> void:
	_stop_waiting()
	visible = false
	_steps = []


func _show_step() -> void:
	var step: Dictionary = _steps[_index]
	var key: String = str(step.get("key", ""))
	_title.text = Strings.t("tut_%s_title" % key)
	_body.text = Strings.t("tut_%s_body" % key)
	_progress.text = Strings.tf("tut_progress",
		{"n": _index + 1, "total": _steps.size()})
	_next.text = Strings.t("tut_done") if _index == _steps.size() - 1 \
		else Strings.t("tut_next")

	var hole := _step_rect(step)
	_apply_hole(hole)
	_place_caption(hole)
	_start_waiting(step)


# A step that asks for a real press. The lit controls are thawed so they answer
# while the rest of the tree stays paused, and this overlay stops swallowing
# clicks so they can be reached at all.
#
# A wait_for step whose targets resolve to nothing would be a dead end with no
# way out of it, so that falls back to an ordinary read-and-click step.
func _start_waiting(step: Dictionary) -> void:
	_stop_waiting()
	var action := StringName(step.get("wait_for", &""))
	if action == &"":
		return
	for path: String in step.get("targets", []):
		var node := _find(path)
		if node == null:
			continue
		node.process_mode = Node.PROCESS_MODE_ALWAYS
		_thawed.append(node)
	if _thawed.is_empty():
		return
	_waiting_for = action
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# no way past the step but through it
	_next.visible = false


func _stop_waiting() -> void:
	for node: Node in _thawed:
		if is_instance_valid(node):
			node.process_mode = Node.PROCESS_MODE_INHERIT
	_thawed.clear()
	_waiting_for = &""
	mouse_filter = _blocking
	_next.visible = true


func _on_action_performed(action: StringName) -> void:
	if _waiting_for == &"" or action != _waiting_for:
		return
	_advance()


# Rect2() with no size means "no target" - the screen dims flat and the caption
# goes in the middle.
func _step_rect(step: Dictionary) -> Rect2:
	if step.has("rect"):
		return _grow(step["rect"], float(step.get("pad", 12.0)))
	var union := Rect2()
	for path: String in step.get("targets", []):
		var node := _find(path)
		if node == null:
			continue
		var rect: Rect2 = node.get_global_rect()
		union = rect if union.size == Vector2.ZERO else union.merge(rect)
	if union.size == Vector2.ZERO:
		return Rect2()
	return _grow(union, float(step.get("pad", 12.0)))


func _find(path: String) -> Control:
	if _scene_root == null or not _scene_root.has_node(path):
		return null
	var node := _scene_root.get_node(path)
	return node as Control


func _grow(rect: Rect2, pad: float) -> Rect2:
	return rect.grow(pad)


func _apply_hole(hole: Rect2) -> void:
	var material: ShaderMaterial = _dim.material
	material.set_shader_parameter("rect_size", size)
	if hole.size == Vector2.ZERO:
		# far enough away that every pixel is outside it
		material.set_shader_parameter("hole_center", Vector2(-10000, -10000))
		material.set_shader_parameter("hole_half", Vector2.ZERO)
		material.set_shader_parameter("hole_radius", 0.0)
		material.set_shader_parameter("ring_alpha", 0.0)
		return
	var step: Dictionary = _steps[_index]
	var half := hole.size * 0.5
	# a radius larger than the box would invert the corners
	var radius: float = minf(float(step.get("radius", 18.0)), minf(half.x, half.y))
	material.set_shader_parameter("hole_center", hole.get_center())
	material.set_shader_parameter("hole_half", half - Vector2.ONE * radius)
	material.set_shader_parameter("hole_radius", radius)
	material.set_shader_parameter("ring_alpha", 1.0)


# Below the lit rect if there is room under it, above it otherwise, and always
# inside the screen. A caption that covers the thing it is describing is worse
# than one that is not where you expected.
func _place_caption(hole: Rect2) -> void:
	var box := _caption.size
	if hole.size == Vector2.ZERO:
		_caption.position = ((size - box) * 0.5).round()
		return
	var below: float = hole.end.y + CAPTION_GAP
	var above: float = hole.position.y - CAPTION_GAP - box.y
	var y: float = below
	if below + box.y > size.y - SCREEN_MARGIN:
		y = above if above >= SCREEN_MARGIN else \
			clampf(below, SCREEN_MARGIN, size.y - SCREEN_MARGIN - box.y)
	var x: float = hole.get_center().x - box.x * 0.5
	x = clampf(x, SCREEN_MARGIN, size.x - SCREEN_MARGIN - box.x)
	_caption.position = Vector2(x, y).round()
