import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main(id: UInt64) : Address? {
    return Arlequin.getArleePartnerOwner(id: id)
}