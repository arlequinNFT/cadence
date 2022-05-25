import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"

transaction(recipient: Address, withdrawID: UInt64) {

    let collectionRef: &ArleeScene.Collection
    let depositRef: &{NonFungibleToken.CollectionPublic}
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        self.collectionRef = acct.borrow<&ArleeScene.Collection>(from: ArleeScene.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    
        self.depositRef = getAccount(recipient)
            .getCapability(ArleeScene.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the receiver's collection")

        self.nft <- self.collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        self.depositRef.deposit(token: <- self.nft)    
    }

}