import Arlequin from "../../contracts/Arlequin.cdc"

transaction(addr: Address, additionalMint: UInt64) {

    let arleeSceneAdmin : &Arlequin.ArleeSceneAdmin

    prepare(acct: AuthAccount) {
        self.arleeSceneAdmin = acct.borrow<&Arlequin.ArleeSceneAdmin>(from: Arlequin.ArleeSceneAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleeScene Admin")
    }

    execute {
        self.arleeSceneAdmin.addWhitelistAcctMint(addr: addr, additionalMint: additionalMint)
    }

}