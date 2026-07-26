extends VBoxContainer
class_name MenberContainer
@export_range(1,5) var grade:int =1

@onready var grade_label: Label = %Grade
@onready var menbers: Label = %Menbers
func _ready() -> void:
	grade_label.text = "%d年生" % grade

func set_menbers(values:Array[Description]) -> void:
	var names:Array[String] =[]
	var count :Dictionary[String,int]= {}
	for value in values:
		if value.game_auther == "":
			names.append("匿名")
		else:
			names.append(value.game_auther)
	for named in names:
		if count.has(named):
			count[named] += 1
		else:
			count[named] = 1

	var text := ""

	# 匿名以外を表示
	var lines:Array[String] = []

	# 匿名以外
	for named in count:
		if named == "匿名":
			continue

		if count[named] > 1:
			lines.append("%s x%d" % [named, count[named]])
		else:
			lines.append(named)

	# 最後に匿名
	if count.has("匿名"):
		if count["匿名"] > 1:
			lines.append("匿名 x%d" % count["匿名"])
		else:
			lines.append("匿名")

	menbers.text = "\n".join(lines)
