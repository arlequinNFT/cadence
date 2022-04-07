import Arlequin from "../../contracts/Arlequin.cdc"
import Voter from "../../contracts/Voter.cdc"

pub fun main(addr: Address) : [&Voter.NFT]? {
    let collectionCap = getAccount(addr).getCapability<&Voter.Collection{Voter.CollectionPublic}>(Voter.CollectionPublicPath)
    if collectionCap.borrow() == nil {return nil}
    let collectionRef = collectionCap.borrow()!

    let ids = Arlequin.getVoterNFTIDs(addr: addr)!
    var list : [&Voter.NFT] = []
    for id in ids {
        list.append(collectionRef.borrowVoter(id:id)!)
    }

    return list
}
