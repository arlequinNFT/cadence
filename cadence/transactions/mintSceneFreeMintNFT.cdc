import MetadataViews from "../contracts/lib/MetadataViews.cdc"
import NonFungibleToken from "../contracts/lib/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleePartner from "../contracts/ArleePartner.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"
import FungibleToken from "../contracts/lib/FungibleToken.cdc"
import FlowToken from "../contracts/lib/FlowToken.cdc"

transaction(cid: String, metadata: {String: String}) {

    let adminRef: &Arlequin.ArleeSceneAdmin
    let buyerAddr: Address

    prepare(acct: AuthAccount, adminAcct: AuthAccount) {
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

        self.buyerAddr = acct.address
        self.adminRef = adminAcct.borrow<&Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) ?? panic("Couldn't borrow ArleeSceneAdmin resource")
    }

    execute {
        Arlequin.mintSceneFreeMintNFT(buyer: self.buyerAddr, cid: cid, metadata: metadata, adminRef: self.adminRef)
    }

}
