
import EggFloat from "../../contracts/EggFloat.cdc"
import NonFungibleToken from "../../contracts/lib//NonFungibleToken.cdc"

pub fun main(): {UInt64: EggFloat.Egg} {
    return EggFloat.getEggs()
}