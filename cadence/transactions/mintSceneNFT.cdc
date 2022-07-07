import MetadataViews from "../contracts/lib/MetadataViews.cdc"
import NonFungibleToken from "../contracts/lib/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleePartner from "../contracts/ArleePartner.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"
import FungibleToken from "../contracts/lib/FungibleToken.cdc"
import FlowToken from "../contracts/lib/FlowToken.cdc"

transaction(cid: String, metadata: {String: String}) {

    let adminRef: &Arlequin.ArleeSceneAdmin
    let payerVaultRef : &FlowToken.Vault

    prepare( adminAcct: AuthAccount) {
        //acct setup
        let acct = adminAcct
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

        // prepare payer vault
        self.payerVaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
            ?? panic("Cannot find the flow token vault")

        self.adminRef = adminAcct.borrow<&Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) ?? panic("Couldn't borrow ArleeSceneAdmin resource")
    }

    execute {
        // get the price of the mint 
        let price = Arlequin.getArleeSceneMintPrice()

        // prepare for payment
        let paymentVault <- self.payerVaultRef.withdraw(amount: price )
        let buyerAddr = self.payerVaultRef.owner!.address

        Arlequin.mintSceneNFT(buyer: buyerAddr, cid: cid, metadata: metadata, paymentVault: <- paymentVault, adminRef: self.adminRef)

    }

}