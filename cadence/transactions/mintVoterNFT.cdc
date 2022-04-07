import MetadataViews from "../contracts/MetadataViews.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import Voter from "../contracts/Voter.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"
import FungibleToken from "../contracts/FungibleToken.cdc"
import FlowToken from "../contracts/FlowToken.cdc"

transaction(name: String, partner: String) {

    let payerVaultRef : &FlowToken.Vault

    prepare(acct: AuthAccount) {
        //acct setup
        if acct.borrow<&Voter.Collection>(from: Voter.CollectionStoragePath) == nil {
            acct.save(<- Voter.createEmptyCollection(), to: Voter.CollectionStoragePath)
            acct.link<&Voter.Collection{Voter.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (Voter.CollectionPublicPath, target:Voter.CollectionStoragePath)
        }

        if acct.borrow<&ArleeScene.Collection>(from: ArleeScene.CollectionStoragePath) == nil {
            acct.save(<- ArleeScene.createEmptyCollection(), to: ArleeScene.CollectionStoragePath)
            acct.link<&ArleeScene.Collection{ArleeScene.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (ArleeScene.CollectionPublicPath, target:ArleeScene.CollectionStoragePath)
        }

        // prepare payer vault
        self.payerVaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) 
            ?? panic("Cannot find the flow token vault")

    }

    execute {
        // get the price of the mint 
        let price = Arlequin.getVoterMintPrice()

        // prepare for payment
        let paymentVault <- self.payerVaultRef.withdraw(amount: price )
        let buyerAddr = self.payerVaultRef.owner!.address

        Arlequin.mintVoterNFT(buyer: buyerAddr, name: name, partner: partner, paymentVault: <- paymentVault)

    }

}