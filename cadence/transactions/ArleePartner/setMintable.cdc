import Arlequin from "../../contracts/Arlequin.cdc"

transaction(mintable: Bool) {

    let arleePartnerAdmin : &Arlequin.ArleePartnerAdmin

    prepare(acct: AuthAccount) {
        self.arleePartnerAdmin = acct.borrow<&Arlequin.ArleePartnerAdmin>(from: Arlequin.ArleePartnerAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleePartner Admin")
    }

    execute {
        self.arleePartnerAdmin.setMintable(mintable: mintable)
    }

}