import Arlequin from "../../contracts/Arlequin.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"

pub fun main(addr: Address, id: UInt64) : &ArleeScene.NFT? {
    let collectionCap = getAccount(addr).getCapability<&{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath)
    let collectionRef = collectionCap.borrow() ?? panic("Cannot get reference of Arlee Scene Collection")

    return collectionRef.borrowArleeScene(id:id)
}
