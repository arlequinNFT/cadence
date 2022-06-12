import Arlequin from 0x47cbd3edd044cb5d

transaction(mintable: Bool) {

    let arleeSceneAdmin : &Arlequin.ArleeSceneAdmin

    prepare(acct: AuthAccount) {
        self.arleeSceneAdmin = acct.borrow<&Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleeScene Admin")
    }

    execute {
        self.arleeSceneAdmin.setMintable(mintable: mintable)
    }

}