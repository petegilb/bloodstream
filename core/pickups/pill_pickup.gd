extends Pickup

@export var health_amount := 10

func _pickup(character: BoatCharacter):
    print('pill picked up')
    character.add_health(health_amount)
    super(character)
