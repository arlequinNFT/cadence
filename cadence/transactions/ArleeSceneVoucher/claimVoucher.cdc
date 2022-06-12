import MetadataViews from "../contracts/MetadataViews.cdc"
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import Arlequin from "../contracts/Arlequin.cdc"
import ArleeSceneVoucher from "../contracts/ArleeSceneVoucher.cdc"
import ArleeScene from "../contracts/ArleeScene.cdc"

transaction(voucherID: UInt64) {

    let voucher: @NonFungibleToken.NFT // ArleeSceneVoucher.NFT
    let adminRef: &Arlequin.ArleeSceneAdmin

    prepare(userAcct: AuthAccount, adminAcct: AuthAccount) {
        if userAcct.borrow<&ArleeScene.Collection>(from: ArleeScene.CollectionStoragePath) == nil {
            userAcct.save(<- ArleeScene.createEmptyCollection(), to: ArleeScene.CollectionStoragePath)
            userAcct.link<&ArleeScene.Collection{ArleeScene.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (ArleeScene.CollectionPublicPath, target:ArleeScene.CollectionStoragePath)
        }

        self.voucher <- userAcct.borrow<&ArleeSceneVoucher.Collection>(from: ArleeSceneVoucher.CollectionStoragePath)?.withdraw(withdrawID: voucherID) 
            ?? panic("Voucher with id: ".concat(voucherID.toString()).concat(" not found!"))

        self.adminRef = adminAcct.borrow<&Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) 
            ?? panic("Couldn't borrow ArleeSceneAdmin resource")
    }

    execute {
        Arlequin.redeemVoucher(address: self.voucher.owner!.address, voucher: <- self.voucher, adminRef: self.adminRef)
    }

}