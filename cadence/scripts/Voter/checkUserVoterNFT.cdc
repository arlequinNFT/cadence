import Arlequin from "../../contracts/Arlequin.cdc"

// Check a user if he / she has Voter NFT
pub fun main(addr: Address) : Bool {
    return Arlequin.checkVoterNFT(addr: addr)
}