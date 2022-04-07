import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main() : UFix64 {
    return Arlequin.getVoterMintPrice()
}