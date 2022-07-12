
import EggFloat from "../../contracts/EggFloat.cdc"
import NonFungibleToken from "../../contracts/lib//NonFungibleToken.cdc"

pub fun main(eventID: UInt64): [EggFloat.Egg] {
    return EggFloat.getEggsForEvent(id: eventID)
}