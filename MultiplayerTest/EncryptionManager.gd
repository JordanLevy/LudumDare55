extends Node

var aes = AESContext.new()
static var key: String = ""

func _ready():
	# Load encryption key from file
	key = load_key_from_file('res://key.txt')

func load_key_from_file(file_path: String) -> String:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text().strip_edges(true, true)
	return content

func encrypt(data: String, key: String):
	print('key len ', key, ' ', key.length())
	# Encrypt ECB
	aes.start(AESContext.MODE_ECB_ENCRYPT, key.to_utf8_buffer())
	var encrypted = aes.update(data.to_utf8_buffer())
	aes.finish()
	return encrypted
	
func decrypt(encrypted: Array, key: String):
	# Decrypt ECB
	aes.start(AESContext.MODE_ECB_DECRYPT, key.to_utf8_buffer())
	var decrypted = aes.update(encrypted)
	aes.finish()
	return decrypted

func bytes_to_hex_string(data: Array) -> String:
	var hex_string = ""
	for byte in data:
		hex_string += "%02X" % byte
	return hex_string

func hex_string_to_bytes(hex_string: String) -> Array:
	var bytes = []
	for i in range(0, hex_string.length(), 2):
		var byte_str = hex_string.substr(i, 2)
		bytes.append(byte_str)
	return bytes

func buffer_to_string(data):
	var result = ""
	for i in data:
		result += char(i)
	return result
	
func pad_string(text: String, length: int) -> String:
	var spaces_needed = length - text.length()
	if spaces_needed <= 0:
		return text  # No spaces needed or text is already longer than the desired length

	var padded_text = text
	for i in range(spaces_needed):
		padded_text += " "  # Add spaces to the end of the string

	return padded_text
