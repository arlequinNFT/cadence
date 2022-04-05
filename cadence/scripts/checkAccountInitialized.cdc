import Arlequin from "../contracts/Arlequin.cdc"
import ArleePartner from "../contracts/ArleePartner.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"

// Check a user if he / she has Partner NFT
pub fun main(addr: Address) : Bool {

    var initializedPartnerCollection = false 
    var initializedSceneCollection =false

    if getAccount(addr).getCapability<&ArleePartner.Collection{ArleePartner.CollectionPublic}>(ArleePartner.CollectionPublicPath).borrow() != nil {
        initializedPartnerCollection = true
    }

    if getAccount(addr).getCapability<&ArleeScene.Collection{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath).borrow() != nil {
        initializedSceneCollection = true
    }

    return initializedPartnerCollection && initializedSceneCollection
}