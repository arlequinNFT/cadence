import MetadataViews from "../contracts/MetadataViews.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleeSceneVoucher from "../contracts/ArleeSceneVoucher.cdc"
import FungibleToken from "../contracts/FungibleToken.cdc"
import FlowToken from "../contracts/FlowToken.cdc"

transaction(species: String) {

    let adminRef: &Arlequin.ArleeSceneAdmin
    let payerVaultRef : &FlowToken.Vault

    prepare(userAcct: AuthAccount, adminAcct: AuthAccount) {

        // setup voucher collection if user
        if userAcct.borrow<&ArleeSceneVoucher.Collection>(from: ArleeSceneVoucher.CollectionStoragePath) == nil {
            userAcct.save(<- ArleeSceneVoucher.createEmptyCollection(), to: ArleeSceneVoucher.CollectionStoragePath)
            userAcct.link<&ArleeSceneVoucher.Collection{ArleeSceneVoucher.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (ArleeSceneVoucher.CollectionPublicPath, target:ArleeSceneVoucher.CollectionStoragePath)
        }

        // prepare payer vault
        self.payerVaultRef = userAcct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
            ?? panic("Cannot find the flow token vault")

        // borrow admin reference to authorize transaction
        self.adminRef = adminAcct.borrow<&Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) ?? panic("Couldn't borrow ArleeSceneAdmin resource")
    }

    execute {
        // get the price of the mint 
        let price = Arlequin.getArleeSceneVoucherMintPrice()

        // prepare for payment
        let paymentVault <- self.payerVaultRef.withdraw(amount: price)
        let buyerAddr = self.payerVaultRef.owner!.address

        Arlequin.mintVoucherNFT(buyer: buyerAddr, species: species, paymentVault: <- paymentVault, adminRef: self.adminRef)

    }

}