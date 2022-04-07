import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main() : UInt64 {
    return Arlequin.getVoterTotalSupply()
}