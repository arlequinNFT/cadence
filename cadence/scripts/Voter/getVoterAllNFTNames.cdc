import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main() : {UInt64 : String} {
    return Arlequin.getVoterAllNFTNames()
}