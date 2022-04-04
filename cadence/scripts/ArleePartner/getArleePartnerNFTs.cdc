import Arlequin from "../../contracts/Arlequin.cdc"
import ArleePartner from "../../contracts/ArleePartner.cdc"

pub fun main(addr: Address) : [&ArleePartner.NFT]? {
    let collectionCap = getAccount(addr).getCapability<&{ArleePartner.CollectionPublic}>(ArleePartner.CollectionPublicPath)
    if collectionCap.borrow() == nil {return nil}
    let collectionRef = collectionCap.borrow()!

    let ids = Arlequin.getArleePartnerNFTIDs(addr: addr)!
    var list : [&ArleePartner.NFT] = []
    for id in ids {
        list.append(collectionRef.borrowArleePartner(id:id)!)
    }

    return list
}
