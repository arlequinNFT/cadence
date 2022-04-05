import MetadataViews from "../../contracts/MetadataViews.cdc"
import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import Arlequin from "../../contracts/Arlequin.cdc"
import ArleePartner from "../../contracts/ArleePartner.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"

transaction() {

    prepare(acct: AuthAccount) {

        let partnerNFTStoragePath = ArleePartner.CollectionStoragePath
        let partnerNFTPublicPath = ArleePartner.CollectionPublicPath

        let sceneNFTStoragePath = ArleeScene.CollectionStoragePath
        let sceneNFTPublicPath = ArleeScene.CollectionPublicPath


        let oldCollection <- acct.load<@ArleePartner.Collection>(from: partnerNFTStoragePath) ?? panic("Cannot find partner Collection")
        destroy oldCollection

        let oldddCollection <- acct.load<@ArleeScene.Collection>(from: sceneNFTStoragePath) ?? panic("Cannot find scene Collection")
        destroy oldddCollection

        /* 
        let adminCollection <- acct.load<@Arlequin.ArleePartnerAdmin>(from: Arlequin.ArleePartnerAdminStoragePath) ?? panic("Cannot find admin 1 Collection")
        destroy adminCollection

        let adminAlsoCollection <- acct.load<@Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) ?? panic("Cannot find admin 2 Collection")
        destroy adminAlsoCollection
        */
    }

    execute {

    }

}