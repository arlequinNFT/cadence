import MetadataViews from "../contracts/MetadataViews.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleePartner from "../contracts/ArleePartner.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"
import FungibleToken from "../contracts/FungibleToken.cdc"
import FlowToken from "../contracts/FlowToken.cdc"

transaction(name: String, partner: String) {

    let payerVaultRef : &FlowToken.Vault

    prepare(acct: AuthAccount) {
        //acct setup
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

        // prepare payer vault
        self.payerVaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
            ?? panic("Cannot find the flow token vault")

    }

    execute {
        // get the price of the mint 
        let price = Arlequin.getArleePartnerMintPrice()

        // prepare for payment
        let paymentVault <- self.payerVaultRef.withdraw(amount: price )
        let buyerAddr = self.payerVaultRef.owner!.address

        Arlequin.mintPartnerNFT(buyer: buyerAddr, name: name, partner: partner, paymentVault: <- paymentVault)

    }

}