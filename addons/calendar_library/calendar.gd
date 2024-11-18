## A utility library for generating calendar data.
##
## Calendar is a comprehensive library for creating calendar views, 
## including yearly, monthly, weekly overviews, and agendas. It adheres 
## to Godot's date handling conventions and [Time] singleton, with weeks 
## going from [code]Sunday = 0[/code] to [code]Saturday = 6[/code]. Just like [Time], 
## Calendar follows the Proleptic Gregorian Calendar, so the day before 
## 1582-10-15 is 1582-10-14, not 1582-10-04. Weekdays from 1582-10-15 are valid.
## [br][br]
## The Calendar library comes with a handy Date class (see [Calendar.Date]),
## which stores a date as [code]year[/code], [code]month[/code] and [code]day[/code], and comes with handy utility functions.
## [br][br]
## The library also facilitates formatted and localized date 
## representations through the CalendarLocale resource. Each Calendar 
## object is linked to a CalendarLocale, which can be customized 
## or replaced as needed.
class_name Calendar
extends RefCounted


const _POSIX_PLACEHOLDERS = "(%F|%Y|%y|%m|%B|%b|%-b|%d|%-d|%-m|%-y|%j|%-j|%A|%a|%-a|%u|%w)"

enum WeekdayFormat{
	## Show the weekday's full name
	WEEKDAY_FORMAT_FULL,
	## Show the weekday's name as an abbreviated version (e.g. "Mon" for "Monday")
	WEEKDAY_FORMAT_ABBR,
	## Show the weekday in a short form (e.g. "M" for "Monday")
	WEEKDAY_FORMAT_SHORT,
}

enum MonthFormat{
	## Show the month's full name
	MONTH_FORMAT_FULL,
	## Shows the month's name as an abbreviated version 
	## (e.g., "Jan" for "January").
	MONTH_FORMAT_ABBR,
	## Show month in a short form (e.g. "J" for "January")
	MONTH_FORMAT_SHORT,
}

enum WeekNumberSystem {
	## Calculates the week number where the first week
	## of the year is the one with at least four days. The starting day
	## of the week is determined by [param first_weekday].
	WEEK_NUMBER_FOUR_DAY,
	## Calculates the week number where the first week of the year is
	## always the one containing January 1.
	WEEK_NUMBER_TRADITIONAL,
}

## The weekday that is considered the first day of the week.
## Takes a [enum Time.Weekday] value where Sunday = 0 and Saturday = 6 
## (to align with Godot's Weekday standard)
var first_weekday: Time.Weekday

## The week number system to use when calculating week numbers.
## See [enum WeekNumberSystem]
var week_number_system : WeekNumberSystem

## The calendar's localization settings for retrieving
## preformatted values. Each calendar object is assigned a CalendarLocale
## resource which default to English. To customize localization, 
## create and configure a new CalendarLocale
## resource, then assign it to [code]calendar_locale[/code].
var calendar_locale: CalendarLocale


# Regex used for getting placeholder combinations in get_date_formatted()
var _posix_regex = RegEx.new()


func _init() -> void:
	first_weekday = Time.WEEKDAY_MONDAY
	week_number_system = WeekNumberSystem.WEEK_NUMBER_FOUR_DAY
	calendar_locale = CalendarLocale.new()
	_posix_regex.compile(_POSIX_PLACEHOLDERS)


## Returns the current date as a Date object.
func get_today() -> Date:
	var today = Time.get_date_dict_from_system()
	return Date.new(today.year, today.month, today.day)


## Returns an array with all weekdays in ascending order from [code]first_weekday[/code].
@warning_ignore("int_as_enum_without_cast")
func get_weekdays() -> Array[Time.Weekday]:
	var weekdays: Array[Time.Weekday] = []
	for i: Time.Weekday in range(7):
		weekdays.append((first_weekday + i) % 7)
	return weekdays


## Returns an array with all the weekday names, starting from [code]first_weekday[/code].
## [codeblock]
## cal.set_weekday(Time.WEEKDAY_THURSDAY)
## cal.get_weekdays_formatted(WeekdayFormat.WEEKDAY_FORMAT_FULL)
## # Outputs Thursday, Friday, Saturday, Sunday, Monday, Tuesday, Wednesday
## [/codeblock]
func get_weekdays_formatted(weekday_format: WeekdayFormat = WeekdayFormat.WEEKDAY_FORMAT_ABBR) -> Array[String]:
	var weekday_format_prefix: String = ""
	match weekday_format:
		WeekdayFormat.WEEKDAY_FORMAT_FULL:
			weekday_format_prefix = ""
		WeekdayFormat.WEEKDAY_FORMAT_ABBR:
			weekday_format_prefix = "abbr_"
		WeekdayFormat.WEEKDAY_FORMAT_SHORT:
			weekday_format_prefix = "short_"
	
	var all_weekdays: Array[String] = [
		calendar_locale.get(weekday_format_prefix + "sunday"),
		calendar_locale.get(weekday_format_prefix + "monday"),
		calendar_locale.get(weekday_format_prefix + "tuesday"),
		calendar_locale.get(weekday_format_prefix + "wednesday"),
		calendar_locale.get(weekday_format_prefix + "thursday"),
		calendar_locale.get(weekday_format_prefix + "friday"),
		calendar_locale.get(weekday_format_prefix + "saturday"),
	]
	
	var weekdays_formatted: Array[String] = []
	for i in range(7):
		var day_index: int = (first_weekday + i) % 7
		weekdays_formatted.append(all_weekdays[day_index])
	return weekdays_formatted


## Returns an array with all the month's names from "January" to "December".
func get_months_formatted(month_format: MonthFormat = MonthFormat.MONTH_FORMAT_ABBR) -> Array[String]:
	var month_format_prefix: String = ""
	match month_format:
		MonthFormat.MONTH_FORMAT_FULL:
			month_format_prefix = ""
		MonthFormat.MONTH_FORMAT_ABBR:
			month_format_prefix = "abbr_"
		MonthFormat.MONTH_FORMAT_SHORT:
			month_format_prefix = "short_"
	
	var months_formatted: Array[String] = [
		calendar_locale.get(month_format_prefix + "january"),
		calendar_locale.get(month_format_prefix + "february"),
		calendar_locale.get(month_format_prefix + "march"),
		calendar_locale.get(month_format_prefix + "april"),
		calendar_locale.get(month_format_prefix + "may"),
		calendar_locale.get(month_format_prefix + "june"),
		calendar_locale.get(month_format_prefix + "july"),
		calendar_locale.get(month_format_prefix + "august"),
		calendar_locale.get(month_format_prefix + "september"),
		calendar_locale.get(month_format_prefix + "october"),
		calendar_locale.get(month_format_prefix + "november"),
		calendar_locale.get(month_format_prefix + "december"),
	]
	
	return months_formatted


## Returns [code]true[/code] or [code]false[/code] depending on whether
## [param year] is a leap year or not.
func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and (year % 100 != 0 or year % 400 == 0))


## Returns the number of leap days between [param from_year] and
## [param to_year]. By default, [param to_year] is exclusive. This
## can be changed by setting [param exclusive_to] to [code]false[/code].
@warning_ignore("integer_division")
func get_leap_days(from_year: int, to_year: int, exclusive_to: bool = true) -> int:
	from_year -= 1
	to_year -= exclusive_to as int
	var leap_from: int = from_year / 4 - from_year / 100 + from_year / 400
	var leap_to: int = to_year / 4 - to_year / 100 + to_year / 400
	return leap_to - leap_from


## Returns the weekday of a given date as a [code]Time.Weekday[/code] value 
## where Sunday = 0 and Saturday = 6 (to align with Godot's Weekday standard).
@warning_ignore("integer_division")
func get_weekday(year: int, month: int, day: int) -> Time.Weekday:
	# Zeller's Congruence algorithm to find the day of the week
	if month < 3:
		month += 12
		year -= 1
	var k: int = year % 100
	var j: int = int(year / 100)
	var f: int = day + (13 * (month + 1) / 5) + k + (k / 4) + (j / 4) - 2 * j
	# Adjusted Zeller's Congruence for Godot's Sunday = 0
	return (f + 6) % 7 as Time.Weekday


## Returns the weekday name for a given date.
func get_weekday_formatted(year: int, month: int, day: int, weekday_format: WeekdayFormat = WeekdayFormat.WEEKDAY_FORMAT_FULL) -> String:
	var weekday = get_weekday(year, month, day)
	var weekday_format_prefix: String = ""
	match weekday_format:
		WeekdayFormat.WEEKDAY_FORMAT_FULL:
			weekday_format_prefix = ""
		WeekdayFormat.WEEKDAY_FORMAT_ABBR:
			weekday_format_prefix = "abbr_"
		WeekdayFormat.WEEKDAY_FORMAT_SHORT:
			weekday_format_prefix = "short_"
	
	match weekday:
		1: return calendar_locale.get(weekday_format_prefix + "monday")
		2: return calendar_locale.get(weekday_format_prefix + "tuesday")
		3: return calendar_locale.get(weekday_format_prefix + "wednesday")
		4: return calendar_locale.get(weekday_format_prefix + "thursday")
		5: return calendar_locale.get(weekday_format_prefix + "friday")
		6: return calendar_locale.get(weekday_format_prefix + "saturday")
		0: return calendar_locale.get(weekday_format_prefix + "sunday")
		7: return calendar_locale.get(weekday_format_prefix + "sunday")
	return ""


## Returns the name for a given month (1-12).
func get_month_formatted(month: int, month_format: MonthFormat = MonthFormat.MONTH_FORMAT_ABBR) -> String:
	var month_format_prefix: String = ""
	match month_format:
		MonthFormat.MONTH_FORMAT_FULL:
			month_format_prefix = ""
		MonthFormat.MONTH_FORMAT_ABBR:
			month_format_prefix = "abbr_"
		MonthFormat.MONTH_FORMAT_SHORT:
			month_format_prefix = "short_"
	
	match month:
		1: return calendar_locale.get(month_format_prefix + "january")
		2: return calendar_locale.get(month_format_prefix + "february")
		3: return calendar_locale.get(month_format_prefix + "march")
		4: return calendar_locale.get(month_format_prefix + "april")
		5: return calendar_locale.get(month_format_prefix + "may")
		6: return calendar_locale.get(month_format_prefix + "june")
		7: return calendar_locale.get(month_format_prefix + "july")
		8: return calendar_locale.get(month_format_prefix + "august")
		9: return calendar_locale.get(month_format_prefix + "september")
		10: return calendar_locale.get(month_format_prefix + "october")
		11: return calendar_locale.get(month_format_prefix + "november")
		12: return calendar_locale.get(month_format_prefix + "december")
	
	return ""


## Returns the number of days in a month. If [param year]
## is a leap year February will return 29 days.
func get_days_in_month(year: int, month: int) -> int:
	var days_in_month: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 and is_leap_year(year):
		return 29
	return days_in_month[month - 1]


## Returns the number of days in the given year (i.e., 365 or 366 if [param year] is a leap year.
func get_days_in_year(year: int) -> int:
	return 365 if not is_leap_year(year) else 366


## Returns an array representing each month of a given year. Each 
## month is also an array of Date objects corresponding to each day in that month.
## [br][br]
## [param include_adjacent_days] If [code]true[/code], includes dates from adjacent 
## months in the starting and ending weeks. If [code]false[/code], 
## the positions in the array for these dates are set to [code]0[/code].
## [br][br]
## Set [param force_six_weeks] to [code]true[/code] to ensure the 
## return of six weeks for each month, even if the month spans 
## fewer than six weeks. This is beneficial for consistent presentation 
## across multiple months.
func get_calendar_year(year: int, include_adjacent_days: bool = false, force_six_weeks: bool = true) -> Array:
	var year_calendar: Array = []
	
	for month in range(1, 13):  # For each month in the year
		var month_calendar = get_calendar_month(year, month, include_adjacent_days, force_six_weeks)
		year_calendar.append(month_calendar)

	return year_calendar


## Returns an array of weeks, where each week is an array of Date objects 
## for every day in the specified [param year] and [param month].
## [br][br]
## [param include_adjacent_days] If [code]true[/code], includes dates from adjacent 
## months in the starting and ending weeks. If [code]false[/code], 
## the positions in the array for these dates are set to [code]0[/code].
## [br][br]
## Set [param force_six_weeks] to [code]true[/code] to ensure the 
## return of six weeks for each month, even if the month spans 
## fewer than six weeks. This is beneficial for consistent presentation 
## across multiple months.
@warning_ignore("int_as_enum_without_cast")
func get_calendar_month(year: int, month: int, include_adjacent_days: bool = false, force_six_weeks: bool = false) -> Array:
	var days_in_month: int = get_days_in_month(year, month)
	var first_day_weekday: Time.Weekday = get_weekday(year, month, 1)
	
	# Adjust for the first weekday setting
	first_day_weekday = (first_day_weekday - first_weekday + 7) % 7
	
	var calendar: Array = []
	var week: Array = [0, 0, 0, 0, 0, 0, 0]
	var day: int = 1 - first_day_weekday
	
	while day <= days_in_month or (force_six_weeks and calendar.size() < 6):
		for i in range(7):
			if day > 0 and day <= days_in_month:
				week[i] = Date.new(year, month, day)
			elif include_adjacent_days:
				var adj_year = year
				var adj_month = month
				var adj_day = day
				
				if day <= 0:
					adj_month -= 1
					if adj_month < 1:
						adj_month = 12
						adj_year -= 1
					var prev_month_days: int = get_days_in_month(adj_year, adj_month)
					adj_day = prev_month_days + day
				elif day > days_in_month:
					adj_day = day - days_in_month
					adj_month += 1
					if adj_month > 12:
						adj_month = 1
						adj_year += 1
				
				week[i] = Date.new(adj_year, adj_month, adj_day)
			else:
				week[i] = 0
			
			day += 1
		
		calendar.append(week.duplicate())
		week.fill(0)
	
	return calendar


## Returns an array of Date objects for each day in the week containing 
## the specified [param year], [param month], and [param day]. 
## Use [param days_in_week] to define the number of days included, 
## useful for representing shortened weeks such as workweeks.
@warning_ignore("int_as_enum_without_cast")
func get_calendar_week(year: int, month: int, day: int, days_in_week: int = 7) -> Array[Date]:
	var dates : Array[Date] = []
	var day_of_week: Time.Weekday = get_weekday(year, month, day)
	
	var current_day: Time.Weekday = day - ((day_of_week - first_weekday + 7) % 7)
	var current_month: int = month
	var current_year: int = year
	
	for i in range(days_in_week):
		if current_day <= 0:
			current_month -= 1
			if current_month < 1:
				current_month = 12
				current_year -= 1
			current_day = get_days_in_month(current_year, current_month) + current_day
		elif current_day > get_days_in_month(current_year, current_month):
			current_day = 1
			current_month += 1
			if current_month > 12:
				current_month = 1
				current_year += 1
		
		var date = Date.new(current_year, current_month, current_day)
		dates.append(date)
		current_day += 1
	
	return dates


## Sets the first day of the week for the calendar. Any day can be chosen.
## Accepts a value from [enum Time.Weekday], where Sunday = 0 and
## Saturday = 6.
## [codeblock]
## # Set the calendar's first day of the week to Monday.
## var cal = Calendar.new()
## cal.set_first_weekday(Time.WEEKDAY_MONDAY)
## [/codeblock]
@warning_ignore("shadowed_variable")
func set_first_weekday(first_weekday : Time.Weekday) -> void:
	self.first_weekday = first_weekday


## Assign a [code]CalendarLocale[/code] resource to the calendar.
func set_calendar_locale(path: String) -> void:
	calendar_locale = load(path) as CalendarLocale


## Set which week number system to use when calculating week numbers.
## See [enum WeekNumberSystem]
@warning_ignore("shadowed_variable")
func set_week_number_system(week_number_system: WeekNumberSystem):
	self.week_number_system = week_number_system


## Returns the week number for the given [param year], [param month] and [param day].
@warning_ignore("integer_division")
func get_week_number(year: int, month: int, day: int) -> int:
	match week_number_system:
		WeekNumberSystem.WEEK_NUMBER_FOUR_DAY:
			# Construct the date object
			var date: Date = Date.new(year, month, day)
			
			# Find the first Thursday of the year
			var jan_first_day_of_week: int = _get_shifted_weekday(year, 1, 1)
			var days_to_first_majority_day: int = (4 - jan_first_day_of_week + 7) % 7
			var first_majority_day_of_year: Date = Date.new(year, 1, 1)
			first_majority_day_of_year.add_days(days_to_first_majority_day)
			
			# Calculate the week number
			var shifted_weekday: int = _get_shifted_weekday(date.year, date.month, date.day)
			if date.is_before(first_majority_day_of_year) and shifted_weekday in [1, 2, 3]:
				return 1
			elif date.is_after(Date.new(date.year, 12, 28)) and shifted_weekday in [1, 2, 3]:
				return 1
			else:
				return ceili( float(date.days_to(first_majority_day_of_year)) / 7 + 1 )
		
		WeekNumberSystem.WEEK_NUMBER_TRADITIONAL:
			var date: Date = Date.new(year, month, day)
			var start_of_year = Date.new(year, 1, 1)
			
			# Handling the end of the year
			if date.month == 12:
				var days_in_december = (Date.new(year, 12, 31)).get_day_of_year()
				var remaining_days = days_in_december - date.get_day_of_year()
			
			# If the remaining days in December are less than a week and January 1st is not the first day of the week
				var jan_first_day_of_week = (Date.new(year + 1, 1, 1)).get_weekday_iso()
				if remaining_days < 7 and jan_first_day_of_week != _get_first_weekday_iso():
					return 1
			
			var day_of_week_of_jan_first = start_of_year.get_weekday_iso()
			var offset = (7 + _get_first_weekday_iso() - day_of_week_of_jan_first) % 7
			
			if offset > 3:
				offset -= 7
			
			var days_since_start_of_year = date.get_day_of_year() - 1
			var adjusted_days = days_since_start_of_year + offset
			
			return int(ceil(adjusted_days / 7.0)) + 1
	
	return 0


## Returns the ordinal day for the given [param year], [param month] and [param day].
func get_day_of_year(year: int, month: int, day: int) -> int:
	var days_in_month: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	
	if is_leap_year(year):
		days_in_month[1] = 29

	var day_number: int = day
	for i in range(month - 1):
		day_number += days_in_month[i]

	return day_number


## Returns an array of all the week numbers of the given month.
## [br][br]
## Set [param force_six_weeks] to [code]true[/code] to ensure the 
## return of six weeks for each month, even if the month spans 
## fewer than six weeks. This is beneficial for consistent presentation 
## across multiple months.
func get_weeks_of_month(year: int, month: int, force_six_weeks: bool = false) -> Array[int]:
	var weeks : Array[int] = []
	var day = 1
	var days_in_month = get_days_in_month(year, month)

	# Get the week number of the first day of the month
	var first_week = get_week_number(year, month, day)
	weeks.append(first_week)

	# Iterate through the month, week by week
	while day <= days_in_month:
		var current_week = get_week_number(year, month, day)
		if current_week != weeks[weeks.size() - 1]:
			weeks.append(current_week)
		day += 7  # Move to the next week

	# Ensure six weeks are returned, if needed
	if force_six_weeks and weeks.size() < 6:
		var next_month = month + 1
		var next_year = year
		if next_month > 12:
			next_month = 1
			next_year += 1
		var day_in_next_month = 1
		while weeks.size() < 6:
			var week_in_next_month = get_week_number(next_year, next_month, day_in_next_month)
			if week_in_next_month not in weeks:
				weeks.append(week_in_next_month)
			day_in_next_month += 7

	return weeks


## Returns an array of Date objects for a number of days, defined by [param days],
## starting from [param year], [param month], and [param day].
## Good for presenting a set of days or creating agenda-style overviews.
## [br][br]
## Set [param exclusive] to [code]true[/code] to include the last day
## in the range.
func get_days_of_range(days: int, year: int, month: int, day: int, exclusive: bool = false) -> Array[Date]:
	var days_range: Array[Date] = []
	var total_days: int = days - 1 if exclusive else days
	
	for _i in range(total_days):
		var date = Date.new(year, month, day)
		days_range.append(date)
		day += 1
		if day > get_days_in_month(year, month):
			day = 1
			month += 1
			if month > 12:
				month = 1
				year += 1

	return days_range


## Returns a formatted string for a specified date, using the [param format] pattern.
## This function adheres to POSIX placeholder standards, limited to placeholders for 
## years, months, days, and weekdays (see list below of supported placeholders). The 
## pattern can include various placeholders and any dividers between them.
## [codeblock]
## var pattern = "%Y-%m-%d"
## var formatted_date = get_date_formatted(2023, 12, 03, pattern)
## print(formatted_date) # Will output 2023-12-03
## [/codeblock]
## [codeblock]
## var pattern = "%A, %B %d, %Y"
## var formatted_date = get_date_formatted(2023, 12, 03, pattern)
## print(formatted_date) # Will output Sunday, December 3, 2023
## [/codeblock]
## [b]%Y[/b] - Full year in four digits (e.g., 2023).[br]
## [b]%y[/b] - Year in two digits (e.g., 23 for 2023).[br]
## [b]%-y[/b] - Year in two digits without zero-padding (e.g., 3 for 2003).[br]
## [b]%m[/b] - Month as a zero-padded number (e.g., 02 for February).[br]
## [b]%-m[/b] - Month as a number without zero-padding (e.g., 2 for February).[br]
## [b]%d[/b] - Day of the month as a zero-padded number (e.g., 05).[br]
## [b]%-d[/b] - Day of the month without zero-padding (e.g., 5).[br]
## [b]%F[/b] - Date in ISO8601 standard format (e.g., 2023-02-05)[br]
## [br]
## [b]%B[/b] - Full month name from [code]CalendarLocale[/code] (e.g., February).[br]
## [b]%b[/b] - Abbreviated month name from [code]CalendarLocale[/code] (e.g., Feb).[br]
## [b]%-b[/b] - Short month name from [code]CalendarLocale[/code] (e.g., F for February).[br]
## [b]%A[/b] - Full weekday name from [code]CalendarLocale[/code] (e.g., Monday).[br]
## [b]%a[/b] - Abbreviated weekday name from [code]CalendarLocale[/code] (e.g., Mon).[br]
## [b]%-a[/b] - Short weekday name from [code]CalendarLocale[/code] (e.g., M for Monday).[br]
## [br]
## [b]%j[/b] - Day of the year as a zero-padded number (e.g., 065 for the 65th day).[br]
## [b]%-j[/b] - Day of the year without zero-padding (e.g., 65 for the 65th day).[br]
## [b]%u[/b] - Weekday as a number (Monday = 1, Sunday = 7).[br]
## [b]%w[/b] - Weekday as a number (Sunday = 0, Saturday = 6).[br]
@warning_ignore("unused_parameter")
func get_date_formatted(year: int, month: int, day: int, format: String = "%Y-%m-%d") -> String:
	var results: Array[RegExMatch] = _posix_regex.search_all(format)
	var format_posix_placeholders: Array = []
	for result in results:
		var matched_string = format.substr(result.get_start(), result.get_end() - result.get_start())
		format_posix_placeholders.append(matched_string)
	
	var format_mappings = {
		"%Y": func(y, m, d): return str(y),
		"%y": func(y, m, d): return str(y).right(2),
		"%-y": func(y, m, d): return str(y).substr(-2, 2).replace("0", ""),
		"%m": func(y, m, d): return str(m).pad_zeros(2),
		"%-m": func(y, m, d): return str(m).lstrip("0"),
		"%d": func(y, m, d): return str(d).pad_zeros(2),
		"%-d": func(y, m, d): return str(d).lstrip("0"),
		"%F": func(y, m, d): return "%s-%02d-%02d" % [year, month, day],
		
		"%B": func(y, m, d): return get_month_formatted(m, MonthFormat.MONTH_FORMAT_FULL),
		"%b": func(y, m, d): return get_month_formatted(m, MonthFormat.MONTH_FORMAT_ABBR),
		"%-b": func(y, m, d): return get_month_formatted(m, MonthFormat.MONTH_FORMAT_SHORT),
		"%A": func(y, m, d): return get_weekday_formatted(y, m, d, WeekdayFormat.WEEKDAY_FORMAT_FULL),
		"%a": func(y, m, d): return get_weekday_formatted(y, m, d, WeekdayFormat.WEEKDAY_FORMAT_ABBR),
		"%-a": func(y, m, d): return get_weekday_formatted(y, m, d, WeekdayFormat.WEEKDAY_FORMAT_SHORT),
		
		"%j": func(y, m, d): return str(get_day_of_year(y, m, d)).pad_zeros(3),
		"%-j": func(y, m, d): return str(get_day_of_year(y, m, d)),
		"%u": func(y, m, d): return str(get_weekday(y, m, d)).replace("0", "7"),
		"%w": func(y, m, d): return str(get_weekday(y, m, d)),
	}

	var result: String = format
	for format_posix_placeholder in format_posix_placeholders:
		result = result.replace(format_posix_placeholder, format_mappings[format_posix_placeholder].call(year, month, day))
	
	return result


## Returns the given [param year], [param month] and [param day] in the format specified 
## by the current CalendarLocale's Date Format and Divider Symbol.
## [br][br]
## Set [param four_digit_year] to [code]false[/code] to get the year with two digits instead of four.
func get_date_locale_format(year: int, month: int, day: int, four_digit_year: bool = true) -> String:
	var year_format: String = "%Y" if four_digit_year else "%y"
	var divider: String = calendar_locale.divider_symbol
	var format: String = ""
	
	var date_format: String = "%s%s%s%s%s"
	match calendar_locale.date_format:
		0: # "Year-Month-Day"
			format = date_format % [year_format, divider, "%m", divider, "%d"]
		1: # "Day-Month-Year"
			format = date_format % ["%d", divider, "%m", divider, year_format]
		2: # "Month-Day-Year"
			format = date_format % ["%m", divider, "%d", divider, year_format]
		3: # "Year-Day-Month"
			format = date_format % [year_format, divider, "%d", divider, "%m"]
	
	return get_date_formatted(year, month, day, format)


@warning_ignore("integer_division")
func _get_shifted_weekday(year: int, month: int , day: int) -> int:
	# This Zeller's work a bit different than get_weekday()
	# It shifts which day is 1 depending on first_weekday and should be used
	# separate so that get_weekday_formatted() can be used in isolation
	if month < 3:
		month += 12
		year -= 1
	var k: int = year % 100
	var j: int = int(year / 100)
	var f: int = day + (13 * (month + 1) / 5) + k + (k / 4) + (j / 4) - 2 * j
	var adjusted_weekday: int = (f + 7 - first_weekday + 7) % 7
	return adjusted_weekday


# Turns Godot's standard Sunday = 0, Saturday = 6 to the ISO8601 standard
# where Monday = 1, Sunday = 7.
func _get_weekday_iso(year, month, day) -> int:
	var weekday: int = get_weekday(year, month, day)
	return (weekday - 1) % 7 + 1


func _get_first_weekday_iso():
	return first_weekday if first_weekday != 0 else 7




## A utility class for storing and handling dates.
##
## Date stores data about a specific date, encompassing the year, month, and
## day. It is utilized by the [Calendar] library and is typically used in
## situations where information about the entire date is practical (rather
## than only a year, a month, or a day).
class Date:
	extends RefCounted
	
	## The year of this date.
	var year: int
	
	## The month of this date. An integer value from 1 to 12 representing January to December.
	var month: int
	
	## The day of this date. An integer value from 1 to 31.
	var day: int
	
	
	@warning_ignore("shadowed_variable")
	func _init(year: int, month: int, day: int) -> void:
		set_date(year, month, day)
	
	
	## Returns [code]true[/code] or [code]false[/code]
	## if the date is a valid date or not.
	func is_valid() -> bool:
		if month < 1 or month > 12:
			return false
		elif day < 1 or day > _get_days_in_month():
			return false
		
		if month == 2 and day == 29 and not is_leap_year():
			return false
		
		return true
	
	
	func _validate():
		var valid: bool = true
		var error_msg = "Date is not valid (%s, %s, %s): " % [year, month, day]
		if month < 1 or month > 12:
			error_msg += "Month has to be 1 - 12. "
			valid = false
		elif day < 1:
			error_msg += "Days can not be less than 1. "
			valid = false
		elif day > _get_days_in_month():
			error_msg += "Too many days in month. "
			valid = false
		if month == 2 and day == 29 and not is_leap_year():
			error_msg += "Day can not be 29 in a non-leap year February. "
			valid = false
		
		if not valid:
			push_error(error_msg)
			return false
		
		return true
	
	
	## Returns [code]true[/code] or [code]false[/code] depending on whether
	## the date is a leap year or not.
	func is_leap_year() -> bool:
		return (year % 4 == 0 and (year % 100 != 0 or year % 400 == 0))
	
	
	## Returns [code]true[/code] if this Date is before the provided date.
	func is_before(date: Date) -> bool:
		if year < date.year:
			return true
		elif year == date.year:
			if month < date.month:
				return true
			elif month == date.month:
				return day < date.day
		return false
	
	
	## Returns [code]true[/code] if this Date is after the provided date.
	func is_after(date: Date) -> bool:
		if year > date.year:
			return true
		elif year == date.year:
			if month > date.month:
				return true
			elif month == date.month:
				return day > date.day
		return false
	
	
	## Returns [code]true[/code] if this Date is the same as the provided date.
	func is_equal(date: Date) -> bool:
		if year == date.year and month == date.month and day == date.day:
			return true
		return false
	
	
	# Returns the number of days in the month. If the year
	# is a leap year February will return 29 days.
	func _get_days_in_month() -> int:
		var days_in_month: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		if month == 2 and is_leap_year():
			return 29
		return days_in_month[month - 1]
	
	
	## Returns the weekday of a given date as a [code]Time.Weekday[/code] 
	## value where Sunday = 0 and Saturday = 6.
	@warning_ignore("integer_division")
	func get_weekday() -> Time.Weekday:
		# Zeller's Congruence algorithm to find the day of the week
		if month < 3:
			month += 12
			year -= 1
		var k: int = year % 100
		var j: int = int(year / 100)
		var f = day + (13 * (month + 1) / 5) + k + (k / 4) + (j / 4) - 2 * j
		# Adjusted Zeller's Congruence for Godot's Sunday = 0
		return (f + 6) % 7 as Time.Weekday
	
	
	## Similar to [method get_weekday] but returns an integer value 
	## where Monday = 1 and Sunday = 7, according to the ISO8601 standard.
	func get_weekday_iso() -> int:
		var weekday: Time.Weekday = get_weekday()
		return weekday if weekday != 0 else 7
	
	
	## Add any number of days to this date.
	func add_days(days: int) -> void:
		day += days
		while day > _get_days_in_month():
			day -= _get_days_in_month()
			month += 1
			if month > 12:
				month = 1
				year += 1
	
	
	## Adds a specified number of months to the date. 
	## [br][br]
	## If the resulting date's day does not correspond to the number of days in the new month, 
	## it will be adjusted to the nearest valid day. For example, if the day 
	## is 31 and the new month is June, the day will be set to 30. Additionally, 
	## February 29 will be adjusted to February 28 in non-leap years.
	func add_months(months: int) -> void:
		month += months
		while month > 12:
			month -= 12
			year += 1
		var days_in_new_month: int = _get_days_in_month()
		if day > days_in_new_month:
			day = days_in_new_month
	
	
	## Adds any number of years to the date. February 29 will be set 
	## to February 28 if the new year is not a leap year.
	func add_years(years: int) -> void:
		year += years
		if month == 2 and day == 29 and not is_leap_year():
			day = 28
	
	
	## Subtract any number of days from this date.
	func subtract_days(days: int) -> void:
		day -= days
		while day < 1:
			month -= 1
			if month < 1:
				month = 12
				year -= 1
			day += _get_days_in_month()
	
	
	## Subtracts a specified number of months from the date. 
	## [br][br]
	## If the resulting date's day does not correspond to the number of days in the new month, 
	## it will be adjusted to the nearest valid day. For example, if the day 
	## is 31 and the new month is June, the day will be set to 30. Additionally, 
	## February 29 will be adjusted to February 28 in non-leap years.
	func subtract_months(months: int) -> void:
		month -= months
		while month < 1:
			month += 12
			year -= 1
		var days_in_new_month: int = _get_days_in_month()
		if day > days_in_new_month:
			day = days_in_new_month
	
	
	## Subtracts any number of years from the date. February 29 will be set 
	## to February 28 if the new year is not a leap year.
	func subtract_years(years: int) -> void:
		year -= years
		if month == 2 and day == 29 and not is_leap_year():
			day = 28
		
	
	## Set the year, month and day of this Date. Throws an error if the 
	## date is not a valid date.
	@warning_ignore("shadowed_variable")
	func set_date(year: int, month: int, day: int):
		self.year = year
		self.month = month
		self.day = day
		_validate()
	
	
	## Set this Date to today's date
	func set_today():
		var today_date: Dictionary = Time.get_date_dict_from_system()
		self.set_date(today_date.year, today_date.month, today_date.day)
	
	
	## Returns the ordinal day for the given [param year], [param month] and [param day].
	func get_day_of_year() -> int:
		var days_in_month: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
		
		if is_leap_year():
			days_in_month[1] = 29
		
		var day_number: int = day
		for i in range(month - 1):
			day_number += days_in_month[i]
		
		return day_number
	
	
	## Set this Date to the given dictionary's date. The
	## dictionary must contain a [code]year[/code], [code]month[/code]
	## and [code]day[/code] key. 
	## [br][br]
	## This function's main purpose is to convert dates returned from 
	## the built in [Time] singleton, which mainly return dictionaries.
	func from_dict(date: Dictionary):
		self.set_date(date.year, date.month, date.day)
	
	
	## Returns a new Date object which is a copy of this Date.
	func duplicate() -> Date:
		return Date.new(year, month, day)
	
	
	# Helper function to calculate how many days are between two Date objects
	@warning_ignore("integer_division")
	func _to_julian_day() -> int:
		# Algorithm to convert a Gregorian date to a Julian Day Number.
		# This is a simplified version and works for dates after 1582.
		var a: int = (14 - month) / 12
		var y: int = year + 4800 - a
		var m: int = month + 12 * a - 3
		var jdn: int = day + (153 * m + 2) / 5 + 365 * y + y / 4 - y / 100 + y / 400 - 32045
		return jdn
	
	
	## Return the number of days between two Date objects. Is only accurate
	## when dates are after the year 1582.
	func days_to(date: Date) -> int:
		return self._to_julian_day() - date._to_julian_day()
	
	
	## A static function that returns a Date object with todays date.
	## The date is fetched from the system.
	## [codeblock]
	## var todays_date = Calendar.Date.today()
	## print(todays_date) # Outputs the current date from the system
	## [/codeblock]
	static func today() -> Date:
		var date: Date = Date.new(1, 1, 1)
		var today_date: Dictionary = Time.get_date_dict_from_system()
		date.set_date(today_date.year, today_date.month, today_date.day)
		return date
	
	# Present the date as "Year-Month-Day" when printed (i.e., 2023-12-01).
	# This is a build in function froom Godot that changed how a class
	# behaves when printed.
	func _to_string() -> String:
		return "%s-%s-%s" % [year, month, day]
