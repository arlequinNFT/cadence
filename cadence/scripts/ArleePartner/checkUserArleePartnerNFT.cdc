import Arlequin from "../../contracts/Arlequin.cdc"

// Check a user if he / she has ArleePartner NFT
pub fun main(addr: Address) : Bool {
    return Arlequin.checkArleePartnerNFT(addr: addr)
}