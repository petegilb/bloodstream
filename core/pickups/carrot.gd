extends Pickup

@export var gas_amount := 25

func _pickup(character: BoatCharacter):
    print('carrot picked up')
    character.add_gas(gas_amount)
    super(character)
