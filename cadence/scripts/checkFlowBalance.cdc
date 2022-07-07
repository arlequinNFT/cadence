import FungibleToken from "../contracts/lib/FungibleToken.cdc"
import FlowToken from "../contracts/lib/FlowToken.cdc"

pub fun main(addr: Address) : UFix64 {

    let ref = getAccount(addr).getCapability<&FlowToken.Vault{FungibleToken.Balance}>(/public/flowTokenBalance).borrow() ?? panic("Cannot borrow flow vault reference.")

    return ref.balance

}