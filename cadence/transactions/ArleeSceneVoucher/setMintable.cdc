import Arlequin from 0x47cbd3edd044cb5d

transaction(mintable: Bool) {

    let arleeSceneVoucherAdmin : &Arlequin.ArleeSceneVoucherAdmin

    prepare(acct: AuthAccount) {
        self.arleeSceneVoucherAdmin = acct.borrow<&Arlequin.ArleeSceneVoucherAdmin>(from: Arlequin.ArleeSceneVoucherAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleeScene Admin")
    }

    execute {
        self.arleeSceneVoucherAdmin.setMintable(mintable: mintable)
    }

}