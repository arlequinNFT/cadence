import Arlequin from "../contracts/Arlequin.cdc"
import Voter from "../contracts/Voter.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"

// Check a user if he / she has Voter NFT
pub fun main(addr: Address) : Bool {

    var initializedVoterCollection = false 
    var initializedSceneCollection =false

    if getAccount(addr).getCapability<&Voter.Collection{Voter.CollectionPublic}>(Voter.CollectionPublicPath).borrow() != nil {
        initializedVoterCollection = true
    }

    if getAccount(addr).getCapability<&ArleeScene.Collection{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath).borrow() != nil {
        initializedSceneCollection = true
    }

    return initializedVoterCollection && initializedSceneCollection
}