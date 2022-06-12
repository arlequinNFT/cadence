import NonFungibleToken from "../../contracts/NonFungibleToken.cdc"
import ArleeSceneVoucher from "../../contracts/ArleeSceneVoucher.cdc"

pub fun main(address: Address): [UInt64]? {
    let account  = getAccount(address)
    let collectionRef = account.getCapability(ArleeSceneVoucher.CollectionPublicPath).borrow<&{NonFungibleToken.CollectionPublic}>()
    return collectionRef?.getIDs()
}

