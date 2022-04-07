import MetadataViews from "../../contracts/MetadataViews.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Arlequin from "../../contracts/Arlequin.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"

transaction() {

    prepare(acct: AuthAccount) {


        let sceneNFTStoragePath = ArleeScene.CollectionStoragePath
        let sceneNFTPublicPath = ArleeScene.CollectionPublicPath

        if acct.borrow<&AnyResource>(from: /storage/ArleePartner) != nil {
            let oldCollection <- acct.load<@AnyResource>(from: /storage/ArleePartner) ?? panic("Cannot find arleepartner Collection")
            destroy oldCollection
        }
        
        if acct.borrow<&AnyResource>(from: /storage/ArleeScene) != nil {
            let oldddCollection <- acct.load<@AnyResource>(from: /storage/ArleeScene) ?? panic("Cannot find scene Collection")
            destroy oldddCollection
        }

        if acct.borrow<&AnyResource>(from: /storage/ArleePartnerAdmin) != nil {
            let adminCollection <- acct.load<@AnyResource>(from: /storage/ArleePartnerAdmin) ?? panic("Cannot find admin 1 Collection")
            destroy adminCollection
        }

        if acct.borrow<&AnyResource>(from: /storage/ArleeSceneAdmin) != nil {
            let adminAlsoCollection <- acct.load<@AnyResource>(from: /storage/ArleeSceneAdmin) ?? panic("Cannot find admin 2 Collection")
            destroy adminAlsoCollection
        }

        if acct.borrow<&AnyResource>(from: /storage/VoterAdmin) != nil {
            let admin1AlsoCollection <- acct.load<@AnyResource>(from: /storage/VoterAdmin) ?? panic("Cannot find admin 3 Collection")
            destroy admin1AlsoCollection
        }
    }

    execute {

    }

}