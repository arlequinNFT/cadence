import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main(id: UInt64) : String? {
    return Arlequin.getArleeSceneCID(id: id)
}