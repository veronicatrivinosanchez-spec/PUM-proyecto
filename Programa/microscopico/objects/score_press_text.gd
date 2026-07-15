extends Control

func SetTextInfo(text: String):
	$ScoreLevelText.text = "[center]" + text
	var color = Color("5a5758")
	match text:
		"PERFECT":
			color = Color("ffbe00")
		"GREAT", "GOOD":
			color = Color("e2dd25")
		"OK":
			color = Color("8dbfc7")
	$ScoreLevelText.set("theme_override_colors/default_color", color)
