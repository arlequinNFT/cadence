
import EggFloat from "../../contracts/EggFloat.cdc"
import NonFungibleToken from "../../contracts/lib//NonFungibleToken.cdc"

pub fun main(): [UInt64] {
    return EggFloat.getRegisteredEventIDs()
}