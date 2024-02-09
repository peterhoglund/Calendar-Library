## A resource to define localized names for weekdays and months
##
## CalendarLocale is used by [Calendar] to represent the correct
## localized versions of weekday and month names. Create a new
## CalendarLocale resource and set the localized names in the Inspector.
## You can assign a new CalendarLocale to any [Calendar] object.
extends Resource
class_name CalendarLocale

@export_enum("Year-Month-Day", "Day-Month-Year", "Month-Day-Year", "Year-Day-Month") var date_format := 0
@export var divider_symbol := "-"

@export_category("Weekday")
@export var monday := "Monday"
@export var tuesday := "Tuesday"
@export var wednesday := "Wednesday"
@export var thursday := "Thursday"
@export var friday := "Friday"
@export var saturday := "Saturday"
@export var sunday := "Sunday"

@export_group("Weekday Abbreviation", "abbr_")
@export var abbr_monday := "Mon"
@export var abbr_tuesday := "Tue"
@export var abbr_wednesday := "Wed"
@export var abbr_thursday := "Thu"
@export var abbr_friday := "Fri"
@export var abbr_saturday := "Sat"
@export var abbr_sunday := "Sun"

@export_group("Weekday Short", "short_")
@export var short_monday := "M"
@export var short_tuesday := "T"
@export var short_wednesday := "W"
@export var short_thursday := "T"
@export var short_friday := "F"
@export var short_saturday := "S"
@export var short_sunday := "S"


@export_category("Month")
@export var january := "January"
@export var february := "February"
@export var march := "March"
@export var april := "April"
@export var may := "May"
@export var june := "June"
@export var july := "July"
@export var august := "August"
@export var september := "September"
@export var october := "October"
@export var november := "November"
@export var december := "December"

@export_group("Month Abbreviation", "abbr_")
@export var abbr_january := "Jan"
@export var abbr_february := "Feb"
@export var abbr_march := "Mar"
@export var abbr_april := "Apr"
@export var abbr_may := "May"
@export var abbr_june := "Jun"
@export var abbr_july := "Jul"
@export var abbr_august := "Aug"
@export var abbr_september := "Sep"
@export var abbr_october := "Oct"
@export var abbr_november := "Nov"
@export var abbr_december := "Dec"

@export_group("Month Short", "short_")
@export var short_january := "J"
@export var short_february := "F"
@export var short_march := "M"
@export var short_april := "A"
@export var short_may := "M"
@export var short_june := "J"
@export var short_july := "J"
@export var short_august := "A"
@export var short_september := "S"
@export var short_october := "O"
@export var short_november := "N"
@export var short_december := "D"
