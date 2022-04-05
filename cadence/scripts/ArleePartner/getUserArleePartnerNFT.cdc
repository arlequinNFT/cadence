import Arlequin from "../../contracts/Arlequin.cdc"
import ArleePartner from "../../contracts/ArleePartner.cdc"

pub fun main(addr: Address, id: UInt64) : &ArleePartner.NFT? {
    let collectionCap = getAccount(addr).getCapability<&ArleePartner.Collection{ArleePartner.CollectionPublic}>(ArleePartner.CollectionPublicPath)
    let collectionRef = collectionCap.borrow() ?? panic("Cannot get reference of Arlee Partner Collection")

    return collectionRef.borrowArleePartner(id:id)
}