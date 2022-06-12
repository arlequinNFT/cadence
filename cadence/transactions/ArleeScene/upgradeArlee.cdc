import MetadataViews from "../contracts/MetadataViews.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleePartner from "../contracts/ArleePartner.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"
import FungibleToken from "../contracts/FungibleToken.cdc"
import FlowToken from "../contracts/FlowToken.cdc"

transaction(arleeID: UInt64, cid: String) {

    let adminRef: &Arlequin.ArleeSceneAdmin
    let arlee: @NonFungibleToken.NFT
    let collection: &ArleeScene.Collection
    let payerVaultRef : &FlowToken.Vault

    prepare(acct: AuthAccount, adminAcct: AuthAccount) {
        //acct setup
        if acct.borrow<&ArleeScene.Collection>(from: ArleeScene.CollectionStoragePath) == nil {
            acct.save(<- ArleeScene.createEmptyCollection(), to: ArleeScene.CollectionStoragePath)
            acct.link<&ArleeScene.Collection{ArleeScene.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (ArleeScene.CollectionPublicPath, target:ArleeScene.CollectionStoragePath)
        }
        self.collection = acct.borrow<&ArleeScene.Collection>(from: ArleeScene.CollectionStoragePath)!
        self.arlee <- self.collection.withdraw(withdrawID: arleeID)

        // prepare payer vault
        self.payerVaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
            ?? panic("Cannot find the flow token vault")

        self.adminRef = adminAcct.borrow<&Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) ?? panic("Couldn't borrow ArleeSceneAdmin resource")
    }

    execute {
        // get the price of the upgrade 
        let price = Arlequin.getArleeSceneUpgradePrice()

        // prepare for payment
        let paymentVault <- self.payerVaultRef.withdraw(amount: price)
        let buyerAddr = self.payerVaultRef.owner!.address

        let updatedArlee <- Arlequin.updateArleeCID(arlee: <- self.arlee, paymentVault: <- paymentVault, cid: cid, adminRef: self.adminRef)
        self.collection.deposit(token: <- updatedArlee)
    }

}