class_name TextData
""" Utility script for loading text data from JSON files.
	
	
	"""


const TEXT_DATA_PATH := "res://text_data"
const JSON_EXT := ".json"


static func get_data(filename : String, locality : String):
	var file = File.new()
	var filepath = TEXT_DATA_PATH + "/" + locality + "/" + filename + JSON_EXT
	
	if file.file_exists(filepath):
		file.open(filepath, file.READ)
	else:
		print_debug(filepath + " failed to load!")
		return null
	
	var json = file.get_as_text()
	var json_result = JSON.parse(json).result
	
	if json_result.has("dialogue_data"):
		for dialogue in json_result["dialogue_data"]:
			for i in json_result["dialogue_data"][dialogue].size():
				var temp = json_result["dialogue_data"][dialogue][i]
				
				json_result["dialogue_data"][dialogue][i] = sanitize_text(temp)
	
	if json_result.has("prompt_data"):
		for prompt in json_result["prompt_data"]:
			var temp = json_result["prompt_data"][prompt]["text"]
			
			json_result["prompt_data"][prompt]["text"] = sanitize_text(temp)
	
	file.close()
	
	return json_result


static func sanitize_text(text : String) -> String:
	text = text.dedent()
	
	if text.begins_with("\n"):
		text.erase(0,1)
	
	return text

