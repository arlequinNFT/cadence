import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main(addr: Address) : [String]? {
    return Arlequin.getArleePartnerNFTNames(addr: addr)
}