import NonFungibleToken from "../contracts/lib/NonFungibleToken.cdc"
import ArleeSceneVoucher from "../contracts/ArleeSceneVoucher.cdc"

transaction(recipient: Address, withdrawID: UInt64) {

    let collectionRef: &ArleeSceneVoucher.Collection
    let depositRef: &{NonFungibleToken.CollectionPublic}
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        self.collectionRef = acct.borrow<&ArleeSceneVoucher.Collection>(from: ArleeSceneVoucher.CollectionStoragePath)
            ?? panic("Could not borrow a reference to the owner's collection")
    
        self.depositRef = getAccount(recipient)
            .getCapability(ArleeSceneVoucher.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not borrow a reference to the receiver's collection")

        self.nft <- self.collectionRef.withdraw(withdrawID: withdrawID)
    }

    execute {
        self.depositRef.deposit(token: <- self.nft)    
    }

}