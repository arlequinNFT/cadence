import Arlequin from "../../contracts/Arlequin.cdc"

transaction(creditor: String, cut: UFix64) {

    let arleePartnerAdmin : &Arlequin.ArleePartnerAdmin

    prepare(acct: AuthAccount) {
        self.arleePartnerAdmin = acct.borrow<&Arlequin.ArleePartnerAdmin>(from: Arlequin.ArleePartnerAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleePartner Admin")
    }

    execute {
        self.arleePartnerAdmin.setPartnerCut(creditor: creditor, cut: cut)
    }

}