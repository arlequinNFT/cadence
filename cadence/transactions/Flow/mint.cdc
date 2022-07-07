// Demo transaction to setup mint flow for deploying contracts to admin account 

import FungibleToken from "../../contracts/lib/FungibleToken.cdc" 
import FlowToken from "../../contracts/lib/FlowToken.cdc"

transaction(amount: UFix64, address: Address) {
  prepare(signer: AuthAccount) {

    // get reference to flow admin resource
    let flowTokenAdmin = signer.borrow<&FlowToken.Administrator>(from: /storage/flowTokenAdmin) ?? panic("no flow token administrator found in storage")

    // create a new minter
    let minter <- flowTokenAdmin.createNewMinter(allowedAmount: amount)

    let tokens <- minter.mintTokens(amount: amount)
   
    destroy minter
    // save minter to storage
    
    // borrow recipients
    let account = getAccount(address)
          .getCapability(/public/flowTokenReceiver)
          .borrow<&{FungibleToken.Receiver}>()  ?? panic("Cannot borrow flowTokenReceiver Cap")

   
    account.deposit( from: <- tokens )
  }
}