extends Control


func _ready() -> void:
	cal.set_first_weekday(Time.WEEKDAY_MONDAY)
	cal.week_number_system = Calendar.WeekNumberSystem.WEEK_NUMBER_FOUR_DAY
	
	selected_date = Calendar.Date.today()
	weekdays_formatted = cal.get_weekdays_formatted(Calendar.WeekdayFormat.WEEKDAY_FORMAT_SHORT)
	months_formatted = cal.get_months_formatted(Calendar.MonthFormat.MONTH_FORMAT_FULL)
	
	populate_year_calendar()
	populate_date_picker()
	set_date_label(selected_date)



############################################################
#########
#########   YEAR CALENDAR AND SETTINGS
#########
############################################################


var cal: Calendar = Calendar.new()
var year = 2024

var months_formatted: Array[String]
var weekdays_formatted: Array[String]

var selected_date: Calendar.Date
var selected_date_label: Label

var show_weeks: bool = true

var week_number_system: Calendar.WeekNumberSystem

var show_week_number: bool = true


func populate_year_calendar():
	# Get a full years dates in a nested array. Iterate through the array [months, weeks, days]
	# and create necessary UI nodes for the calendar.
	var year_calendar = cal.get_calendar_year(year, true)
	%YearLabel.text = str(year)
	
	var month = 1
	for months in year_calendar:
		# Add a GridContainer for each month
		var month_container = _add_month_grid_container(month)
		
		# If "Show week numbers" is ON an empty space has to be added before the weekday names
		if show_weeks:
			var weekday_label = CalendarLabel.new("")
			month_container.add_child(weekday_label)
		# Add the weekday strings to the grid. Each weekday label will be in a cell
		for weekday in weekdays_formatted:
			var weekday_label = CalendarLabel.new(weekday)
			month_container.add_child(weekday_label)
		
		# Make a referense to the current date so it can be colored in the calendar.
		var todays_date := Calendar.Date.today()
		
		# Iterate through every week in every month
		for week in months:
			# If show_weeks is true show the week number before all the day labels
			if show_weeks:
				var first_date = week[0]
				var week_number = cal.get_week_number(first_date.year, first_date.month, first_date.day)
				var week_label = CalendarLabel.new(str(week_number))
				week_label.label_settings.font_color = Color("#848d9c")
				month_container.add_child(week_label)
				
			for date in week:
				var date_label = CalendarLabel.new(str(date.day), true)
				if date.month == month:
					if date.is_equal(todays_date):
						date_label.label_settings.font_color = Color("#70bafa")
					else:
						date_label.label_settings.font_color = Color("#cdced2")
				else:
					date_label.label_settings.font_color = Color("#414853")
				
				date_label.pressed.connect(_on_date_pressed.bind(date, date_label))
				month_container.add_child(date_label)
				
				if date.is_equal(selected_date):
					set_selected_state(date_label)
		
		month += 1


func _on_date_pressed(date: Calendar.Date, date_label: Label):
	set_selected_state(date_label)
	set_date_label(date)
	selected_date = date


func set_selected_state(date_label: Label):
	if selected_date_label and selected_date_label.get_child_count() > 0:
		selected_date_label.get_child(0).queue_free()
	var selected_rect: ColorRect = ColorRect.new()
	selected_rect.size = Vector2(20, 20)
	selected_rect.position += Vector2(-4, -2)
	selected_rect.color = Color("#414853")
	selected_rect.show_behind_parent = true
	date_label.add_child(selected_rect)
	selected_date_label = date_label


func set_date_label(date: Calendar.Date):
	%DateLabel.text = cal.get_date_formatted(date.year, date.month, date.day, "%A, %-d %B")


func _add_month_grid_container(p_month: int):
	var month_container = VBoxContainer.new()
	month_container.set("theme_override_constants/separation", 10)
	
	var month_title = CalendarLabel.new(months_formatted[p_month - 1])
	month_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	month_title.label_settings.font_color = Color("#ffffff")
	month_container.add_child(month_title)
	
	var month_grid = GridContainer.new()
	month_grid.columns = 8 if show_weeks else 7
	month_grid.set("theme_override_constants/h_separation", 14)
	month_grid.set("theme_override_constants/v_separation", 6)
	month_container.add_child(month_grid)
	%YearCalendar.add_child(month_container)
	return month_grid


func clear_year_calendar():
	selected_date_label = null
	for child in %YearCalendar.get_children():
		child.queue_free()


#### Signal handlers #####

func _on_first_weekday_option_button_item_selected(index: int) -> void:
	match index:
		0: cal.set_first_weekday(Time.WEEKDAY_MONDAY)
		1: cal.set_first_weekday(Time.WEEKDAY_TUESDAY)
		2: cal.set_first_weekday(Time.WEEKDAY_WEDNESDAY)
		3: cal.set_first_weekday(Time.WEEKDAY_THURSDAY)
		4: cal.set_first_weekday(Time.WEEKDAY_FRIDAY)
		5: cal.set_first_weekday(Time.WEEKDAY_SATURDAY)
		6: cal.set_first_weekday(Time.WEEKDAY_SUNDAY)
	
	weekdays_formatted = cal.get_weekdays_formatted(Calendar.WeekdayFormat.WEEKDAY_FORMAT_SHORT)
	
	clear_year_calendar()
	populate_year_calendar()


func _on_week_number_system_option_button_item_selected(index: int) -> void:
	match index:
		0: cal.set_week_number_system(Calendar.WeekNumberSystem.WEEK_NUMBER_FOUR_DAY)
		1: cal.set_week_number_system(Calendar.WeekNumberSystem.WEEK_NUMBER_TRADITIONAL)
		
	clear_year_calendar()
	populate_year_calendar()


func _on_week_numbers_check_button_toggled(toggled_on: bool) -> void:
	show_weeks = toggled_on
	
	clear_year_calendar()
	populate_year_calendar()


func _on_year_minus_pressed() -> void:
	year -= 1
	
	clear_year_calendar()
	populate_year_calendar()


func _on_year_plus_pressed() -> void:
	year += 1
	
	clear_year_calendar()
	populate_year_calendar()


func _on_language_option_button_item_selected(index: int) -> void:
	match index:
		0:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_EN.tres")
		1:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_DE.tres")
		2:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_ES.tres")
		3:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_CN.tres")
		4:
			cal.set_calendar_locale("res://addons/calendar_library/demo/calendar_locale_SE.tres")
	
	weekdays_formatted = cal.get_weekdays_formatted(Calendar.WeekdayFormat.WEEKDAY_FORMAT_SHORT)
	months_formatted = cal.get_months_formatted(Calendar.MonthFormat.MONTH_FORMAT_FULL)
	
	clear_year_calendar()
	populate_year_calendar()
	set_date_label(selected_date)


############################################################
#########
#########   MONTH CALENDAR DROP DOWN
#########
############################################################


var month = 2

func populate_date_picker():
	var month_calendar = cal.get_calendar_month(year, month, true)
	var month_container = _date_picker_add_month_grid_container(month)
	
	# If "Show week numbers" is ON an empty space has to be added before the weekday names
	if show_weeks:
		var weekday_label = CalendarLabel.new("")
		month_container.add_child(weekday_label)
	# Add the weekday strings to the grid. Each weekday label will be in a cell
	for weekday in weekdays_formatted:
		var weekday_label = CalendarLabel.new(weekday)
		month_container.add_child(weekday_label)
	
	var todays_date := Calendar.Date.today()
	for week in month_calendar:
		# If show_weeks is true show the week number before all the day labels
		if show_weeks:
			var first_date = week[0]
			var week_number = cal.get_week_number(first_date.year, first_date.month, first_date.day)
			var week_label = CalendarLabel.new(str(week_number))
			week_label.label_settings.font_color = Color("#848d9c")
			month_container.add_child(week_label)
			
		for date in week:
			var date_label: CalendarLabel
			if date.month == month:
				date_label = CalendarLabel.new(str(date.day))
			else:
				date_label = CalendarLabel.new("")
				
			if date.month == month:
				if date.is_equal(todays_date):
					date_label.label_settings.font_color = Color("#70bafa")
				else:
					date_label.label_settings.font_color = Color("#cdced2")
			else:
				date_label.label_settings.font_color = Color("#414853")
			
			date_label.pressed.connect(_on_date_pressed.bind(date, date_label))
			month_container.add_child(date_label)
			
			if date.is_equal(selected_date):
				set_selected_state(date_label)


func _date_picker_add_month_grid_container(p_month: int):
	var container_padding = MarginContainer.new()
	container_padding.set("theme_override_constants/margin_left", 20)
	container_padding.set("theme_override_constants/margin_right", 20)
	container_padding.set("theme_override_constants/margin_top", 20)
	container_padding.set("theme_override_constants/margin_bottom", 20)
	
	var month_container = VBoxContainer.new()
	month_container.set("theme_override_constants/separation", 10)
	
	var title_string = "%s, %s" % [months_formatted[p_month - 1], year]
	var month_title = CalendarLabel.new(title_string)
	month_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	month_title.label_settings.font_color = Color("#ffffff")
	month_container.add_child(month_title)
	
	var month_grid = GridContainer.new()
	month_grid.columns = 8 if show_weeks else 7
	month_grid.set("theme_override_constants/h_separation", 14)
	month_grid.set("theme_override_constants/v_separation", 6)
	month_container.add_child(month_grid)
	container_padding.add_child(month_container)
	%PopupPanel.add_child(container_padding)
	return month_grid


func _on_date_picker_toggled(toggled_on: bool) -> void:
	%PopupPanel.visible = toggled_on



# Helper class for generating date labels.
class CalendarLabel:
	extends Label
	
	var clickable: bool = false
	
	signal pressed()
	
	
	func _init(p_text: String, p_clickable: bool = false):
		text = p_text
		horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_settings = LabelSettings.new()
		set_font_size()
		if p_clickable:
			clickable = p_clickable
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			mouse_filter = Control.MOUSE_FILTER_STOP
	
	
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed:
			if clickable:
				pressed.emit()
	
	
	func set_font_size(font_size: int = 12):
		label_settings.font_size = font_size
