import Arlequin from "../../contracts/Arlequin.cdc"

transaction(cut: UFix64) {

    let arleepartnerAdmin : &Arlequin.ArleePartnerAdmin

    prepare(acct: AuthAccount) {
        self.arleepartnerAdmin = acct.borrow<&Arlequin.ArleePartnerAdmin>(from: Arlequin.ArleePartnerAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleePartner Admin")
    }

    execute {
        self.arleepartnerAdmin.setMarketplaceCut(cut: cut)
    }

}