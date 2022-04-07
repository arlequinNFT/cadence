import Arlequin from "../../contracts/Arlequin.cdc"
import Voter from "../../contracts/Voter.cdc"

pub fun main(addr: Address, id: UInt64) : &Voter.NFT? {
    let collectionCap = getAccount(addr).getCapability<&Voter.Collection{Voter.CollectionPublic}>(Voter.CollectionPublicPath)
    let collectionRef = collectionCap.borrow() ?? panic("Cannot get reference of Voter Collection")

    return collectionRef.borrowVoter(id:id)
}