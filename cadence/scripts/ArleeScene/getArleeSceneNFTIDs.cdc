import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main(addr: Address) : [UInt64]? {
    return Arlequin.getArleeSceneNFTIDs(addr: addr)
}