import FLOAT from "../../contracts/lib/FLOAT.cdc"
import EggFloat from "../../contracts/EggFloat.cdc"

pub fun main(account: Address, id: UInt64) {
    EggFloat.registerEvent(eventID: 12)
}