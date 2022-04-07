import MetadataViews from "../../contracts/MetadataViews.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Arlequin from "../../contracts/Arlequin.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"

transaction() {

    prepare(acct: AuthAccount) {


        let sceneNFTStoragePath = ArleeScene.CollectionStoragePath
        let sceneNFTPublicPath = ArleeScene.CollectionPublicPath

        
        let oldCollection <- acct.load<@AnyResource>(from: /storage/ArleePartner) ?? panic("Cannot find voter Collection")
        destroy oldCollection
        
        let oldddCollection <- acct.load<@AnyResource>(from: /storage/ArleeScene) ?? panic("Cannot find scene Collection")
        destroy oldddCollection

        /* 
        let adminCollection <- acct.load<@AnyResource>(from: Arlequin.ArleePartnerAdminStoragePath) ?? panic("Cannot find admin 1 Collection")
        destroy adminCollection

        let adminAlsoCollection <- acct.load<@AnyResource>(from: Arlequin.ArleeSceneAdminStoragePath) ?? panic("Cannot find admin 2 Collection")
        destroy adminAlsoCollection
        */
    }

    execute {

    }

}