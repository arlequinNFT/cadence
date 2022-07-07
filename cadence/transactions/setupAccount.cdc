import MetadataViews from "../contracts/lib/MetadataViews.cdc"
import NonFungibleToken from "../contracts/lib/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleePartner from "../contracts/ArleePartner.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"
import ArleeSceneVoucher from "../contracts/ArleeSceneVoucher.cdc"

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

        if acct.borrow<&ArleeSceneVoucher.Collection>(from: ArleeSceneVoucher.CollectionStoragePath) == nil {
            acct.save(<- ArleeSceneVoucher.createEmptyCollection(), to: ArleeSceneVoucher.CollectionStoragePath)
            acct.link<&ArleeSceneVoucher.Collection{ArleeSceneVoucher.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (ArleeSceneVoucher.CollectionPublicPath, target:ArleeSceneVoucher.CollectionStoragePath)
        }
    }

    execute {

    }

}