import MetadataViews from "../contracts/MetadataViews.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleePartner from "../contracts/ArleePartner.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"

transaction() {

    prepare(acct: AuthAccount) {
        //acct setup
        if acct.borrow<&ArleePartner.Collection>(from: ArleePartner.CollectionStoragePath) == nil {
            acct.save(<- ArleePartner.createEmptyCollection(), to: ArleePartner.CollectionStoragePath)
            acct.link<&ArleePartner.Collection{ArleePartner.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (ArleePartner.CollectionPublicPath, target:ArleePartner.CollectionStoragePath)
        }

        if acct.borrow<&ArleeScene.Collection>(from: ArleeScene.CollectionStoragePath) == nil {
            acct.save(<- ArleeScene.createEmptyCollection(), to: ArleeScene.CollectionStoragePath)
            acct.link<&ArleeScene.Collection{ArleeScene.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (ArleeScene.CollectionPublicPath, target:ArleeScene.CollectionStoragePath)
        }
    }

    execute {

    }

}