extends Node2D

var money = 1000.0
var price = 100.0
var coins = 0

func _ready():
	# Create the labels since they don't exist
	create_ui()
	update_labels()
	print("DEGEN DYNASTY BEGINS!")

func create_ui():
	# Create Money Label
	var money_label = Label.new()
	money_label.name = "MoneyLabel"
	money_label.position = Vector2(50, 50)
	money_label.add_theme_font_size_override("font_size", 32)
	add_child(money_label)
	
	# Create Price Label
	var price_label = Label.new()
	price_label.name = "PriceLabel"
	price_label.position = Vector2(500, 300)
	price_label.add_theme_font_size_override("font_size", 48)
	add_child(price_label)
	
	print("UI Created!")

# ADD THIS NEW FUNCTION HERE! 👇
func _process(delta):
	# SMOOTHER VOLATILITY
	var change = randf_range(-2, 2) * delta * 10  # Multiplied by delta for framerate independence
	price += change
	price = max(price, 1)  # Floor at $1
	price = min(price, 1000)  # Ceiling at $1000
	
	# Update the display
	update_labels()
	
	# Color based on movement
	if has_node("PriceLabel"):
		if change > 0:
			$PriceLabel.modulate = Color(0, 1, 0)  # GREEN!
		else:
			$PriceLabel.modulate = Color(1, 0, 0)  # RED!

func _on_buy_button_pressed():
	if money >= price:
		money -= price
		coins += 1
		print("BOUGHT! Coins: " + str(coins))
		update_labels()
		
		# ADD THIS JUICE! 👇
		if has_node("MoneyLabel"):
			var tween = create_tween()
			tween.tween_property($MoneyLabel, "scale", Vector2(1.5, 1.5), 0.1)
			tween.tween_property($MoneyLabel, "scale", Vector2(1.0, 1.0), 0.1)

func _on_sell_button_pressed():
	if coins > 0:
		money += price
		coins -= 1
		print("SOLD! Coins: " + str(coins))
		update_labels()

func update_labels():
	if has_node("MoneyLabel"):
		$MoneyLabel.text = "$" + str(int(money))
	if has_node("PriceLabel"):
		$PriceLabel.text = "COIN: $" + str(int(price))
