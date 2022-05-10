import Arlequin from "../../contracts/Arlequin.cdc"

transaction(buyer: Address, cid: String, metadata: {String: String}) {

    let arleeSceneAdmin : &Arlequin.ArleeSceneAdmin

    prepare(acct: AuthAccount) {
        self.arleeSceneAdmin = acct.borrow<&Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleeScene Admin")
    }

    execute {
        self.arleeSceneAdmin.mintSceneNFT(buyer: buyer, cid: cid, metadata: metadata)
    }

}