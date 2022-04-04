import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main(id: UInt64) : Address? {
    return Arlequin.getArleeSceneOwner(id: id)
}