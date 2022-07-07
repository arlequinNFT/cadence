
import EggFloat from "../../contracts/EggFloat.cdc"
import NonFungibleToken from "../../contracts/lib//NonFungibleToken.cdc"

pub fun main(): [EggFloat.Egg] {
    return EggFloat.getEggs()
}