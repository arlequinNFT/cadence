import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main(id: UInt64) : Address? {
    // This is got from the mapping inside the contract, better double check with other functions
    let addr = Arlequin.getArleeSceneOwner(id: id)


    // Double check if the return address really has the NFT
    if addr == nil {
        return nil
    }

    // Nil if the user does not exist / does not have Collection set up
    if Arlequin.getArleeSceneNFTIDs(addr: addr!) == nil {
        return nil
    }

    // Nil if the user does not have the NFT even the mapping says yes
    if !Arlequin.getArleeSceneNFTIDs(addr: addr!)!.contains(id) {
        return nil
    }

    return addr
}