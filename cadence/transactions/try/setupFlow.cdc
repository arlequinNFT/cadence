import FungibleToken from "../../contracts/lib/FungibleToken.cdc"
import FlowToken from "../../contracts/lib/FlowToken.cdc"


transaction() {

    prepare(acct: AuthAccount) {

        if acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault) == nil {
            acct.save(<- FlowToken.createEmptyVault(), to: /storage/flowTokenVault)
            acct.link<&{FungibleToken.Receiver}>
                (/public/flowTokenReceiver, target: /storage/flowTokenVault)
            acct.link<&FlowToken.Vault{FungibleToken.Balance}>
                (/public/flowTokenBalance, target: /storage/flowTokenVault)
            return
        } 

        panic("Already have the Vault")


    }

    execute {

    }

}