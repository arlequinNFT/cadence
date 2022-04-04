import MetadataViews from "../contracts/MetadataViews.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleePartner from "../contracts/ArleePartner.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"

transaction() {

    prepare(acct: AuthAccount) {

        let partnerNFTStoragePath = ArleePartner.CollectionStoragePath
        let partnerNFTPublicPath = ArleePartner.CollectionPublicPath

        let sceneNFTStoragePath = ArleeScene.CollectionStoragePath
        let sceneNFTPublicPath = ArleeScene.CollectionPublicPath

        if acct.borrow<&ArleePartner.Collection>(from: partnerNFTStoragePath) == nil {
            acct.save(<- ArleePartner.createEmptyCollection(), to: partnerNFTStoragePath)
            acct.link<&{ArleePartner.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.Resolver}>
                (ArleePartner.CollectionPublicPath, target:ArleePartner.CollectionStoragePath)
        }

        if acct.borrow<&ArleeScene.Collection>(from: sceneNFTStoragePath) == nil {
            acct.save(<- ArleeScene.createEmptyCollection(), to: sceneNFTStoragePath)
            acct.link<&{ArleeScene.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.Resolver}>
                (ArleeScene.CollectionPublicPath, target:ArleeScene.CollectionStoragePath)
        }
    }

    execute {

    }

}