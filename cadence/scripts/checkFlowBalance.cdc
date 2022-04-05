import FungibleToken from "../contracts/FungibleToken.cdc"
import FlowToken from "../contracts/FlowToken.cdc"

// Check a user if he / she has Partner NFT
pub fun main(addr: Address) : UFix64 {

    let ref = getAccount(addr).getCapability<&FlowToken.Vault{FungibleToken.Balance}>(/public/flowTokenBalance).borrow() ?? panic("Cannot borrow flow vault reference.")

    return ref.balance

}