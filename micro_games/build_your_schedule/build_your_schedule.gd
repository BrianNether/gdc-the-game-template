extends MicroGame
class_name BuildYourSchedule

const DAY_COUNT = 5
enum Difficulty {EASY, NORMAL, HARD}

static var hook_installed := false
static var difficulty := Difficulty.EASY
var running := false
var time: float = game_duration
var selected_courses: Array[BuildScheduleCourse]

func _ready() -> void:
	generate_courses()
	update_difficulty()
	start.connect(on_start)
	if is_testing(): on_start()
	update_selected_courses()
	%SubmitButton.pressed.connect(on_win)
	
func _process(delta: float) -> void:
	if not running: return
	time -= delta
	time = max(time, 0)
	if time <= 0: on_lose()
	update_timer()
	
func is_testing() -> bool:
	return get_parent() == get_tree().root
	
func on_win() -> void:
	win.emit()
	running = false
	%SubmitButton.disabled = true
	%EndingPopup.appear(true)
	
func on_lose() -> void:
	running = false
	%EndingPopup.appear(false)
	
func on_start() -> void:
	time = game_duration
	running = true
	
func click_offered_course(course: BuildScheduleCourse) -> void:
	if course in selected_courses: deselect_course(course)
	else: select_course(course)
	
func select_course(course: BuildScheduleCourse) -> void:
	course.set_faded(true)
	selected_courses.append(course)
	update_selected_courses()
	$Select.play()
	
func deselect_course(course: BuildScheduleCourse) -> void:
	course.set_faded(false)
	selected_courses.erase(course)
	update_selected_courses()
	$Deselect.play()
	
func get_child_courses(node: Node) -> Array[BuildScheduleCourse]:
	var courses: Array[BuildScheduleCourse] = []
	for child in node.get_children():
		if child is BuildScheduleCourse: courses.append(child)
	return courses
	
func generate_courses() -> void:
	var styles = range(BuildScheduleCourse.STYLE_COUNT)
	styles.shuffle()
	for child in get_child_courses(%RequirementArea):
		child.set_style(styles.pop_front())
		child.set_days([])
	var long_style := get_child_courses(%RequirementArea)[0].style
	var short_style_a := get_child_courses(%RequirementArea)[1].style
	var short_style_b := get_child_courses(%RequirementArea)[2].style
	var extra_style: int = styles.pop_front()
	var free_days := range(DAY_COUNT)
	free_days.shuffle()
	var offered_courses := get_child_courses(%BrowserArea)
	offered_courses.shuffle()
	offered_courses[0].set_style(long_style)
	if difficulty == Difficulty.EASY:
		offered_courses[0].set_days([free_days.pop_front()])
	else:
		offered_courses[0].set_days([free_days.pop_front(), free_days.pop_front()])
	offered_courses[1].set_style(short_style_a)
	offered_courses[1].set_days([free_days.pop_front()])
	offered_courses[2].set_style(short_style_b)
	offered_courses[2].set_days([free_days.pop_front()])
	var offered_styles: Array
	if difficulty == Difficulty.HARD:
		offered_styles = [long_style, short_style_a, short_style_b, extra_style, extra_style]
	else:
		offered_styles = [long_style, short_style_a, short_style_b, short_style_a, short_style_b]
	offered_styles.shuffle()
	for course in offered_courses.slice(3):
		course.set_style(offered_styles.pop_front())
		var days := range(DAY_COUNT)
		for i in range(30):
			days.shuffle()
			if difficulty != Difficulty.EASY and (course.style == long_style or course.style == extra_style and randf() < 0.5):
				course.set_days([days[0], days[1]])
			else:
				course.set_days([days[0]])
			var overlap = false
			for other_course in offered_courses:
				if other_course == course: continue
				if other_course.style != course.style: continue
				if other_course.days == course.days:
					overlap = true
					break
			if not overlap: break
	for course in offered_courses:
		course.clicked.connect(click_offered_course.bind(course))
		
func update_selected_courses() -> void:
	for course in get_child_courses(%ScheduleArea):
		if course.associated_course not in selected_courses:
			course.shrink_out()
	for day in range(DAY_COUNT):
		var label: Label = %ScheduleArea/Weekdays.get_child(day)
		var course_position := label.global_position + label.size * Vector2.RIGHT
		var day_courses: Array[BuildScheduleCourse]
		for course in selected_courses:
			if day in course.days: day_courses.append(course)
		for i in range(len(day_courses)):
			var day_course := day_courses[i]
			var faux_course: BuildScheduleCourse = null
			for other_faux_course in get_child_courses(%ScheduleArea):
				if other_faux_course.associated_day != day: continue
				if other_faux_course.associated_course == day_course:
					faux_course = other_faux_course
					break
			if not faux_course:
				faux_course = preload("res://micro_games/build_your_schedule/course.tscn").instantiate()
				%ScheduleArea.add_child(faux_course)
				faux_course.grow_in()
				faux_course.clicked.connect(deselect_course.bind(day_course))
				faux_course.associated_course = day_course
				faux_course.associated_day = day
			if faux_course.tween:
				faux_course.tween.custom_step(999)
				faux_course.tween.kill()
			var faux_course_size := BuildScheduleCourse.BASE_SIZE
			faux_course_size.x /= len(day_courses)
			faux_course.set_deferred("size", faux_course_size)
			faux_course.set_deferred("global_position", course_position + Vector2.RIGHT * faux_course_size.x * i)
			faux_course.set_style(day_course.style)
			faux_course.set_days([])
	update_submit_button()
	
func update_submit_button() -> void:
	var conflict = false
	var missing_required = false
	for day in range(DAY_COUNT):
		var day_courses: Array[BuildScheduleCourse]
		for course in selected_courses:
			if day in course.days: day_courses.append(course)
		if len(day_courses) > 1:
			conflict = true
			break
	for required_course in get_child_courses(%RequirementArea):
		var had := false
		for course in selected_courses:
			if course.style == required_course.style:
				had = true
				break
		if not had:
			missing_required = true
			break
	%MissingCoursesLabel.visible = missing_required
	%ConflictLabel.visible = conflict
	var was_disabled = %SubmitButton.disabled
	%SubmitButton.disabled = missing_required or conflict
	%SubmitButton.mouse_default_cursor_shape = Input.CURSOR_ARROW if %SubmitButton.disabled else Input.CURSOR_POINTING_HAND
	if was_disabled and not %SubmitButton.disabled: $SubmitAvailable.play()
			
func update_timer() -> void:
	%Timer.text = "00:%02d" % floor(time)
	
func update_difficulty() -> void:
	if difficulty == Difficulty.EASY: difficulty = Difficulty.NORMAL
	elif difficulty == Difficulty.NORMAL: difficulty = Difficulty.HARD
	if not hook_installed:
		hook_installed = true
		GameManager.exit_screen.connect(_on_screen_exited)
		
static func _on_screen_exited(screen: GameManager.Screen) -> void:
	if screen == GameManager.Screen.Game:
		difficulty = Difficulty.EASY
