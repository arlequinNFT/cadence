import Arlequin from "../../contracts/Arlequin.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"

pub fun main(addr: Address) : [&ArleeScene.NFT]? {
    let collectionCap = getAccount(addr).getCapability<&ArleeScene.Collection{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath)
    if collectionCap.borrow() == nil {return nil}
    let collectionRef = collectionCap.borrow()!

    let ids = Arlequin.getArleeSceneNFTIDs(addr: addr)!
    var list : [&ArleeScene.NFT] = []
    for id in ids {
        list.append(collectionRef.borrowArleeScene(id:id)!)
    }

    return list
}
