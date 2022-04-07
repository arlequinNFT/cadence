import Arlequin from "../../contracts/Arlequin.cdc"

transaction(creditor: String, addr: Address, cut: UFix64) {

    let arleepartnerAdmin : &Arlequin.ArleePartnerAdmin

    prepare(acct: AuthAccount) {
        self.arleepartnerAdmin = acct.borrow<&Arlequin.ArleePartnerAdmin>(from: Arlequin.ArleePartnerAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleePartner Admin")
    }

    execute {
        self.arleepartnerAdmin.addPartnerRoyaltyCut(creditor: creditor, addr: addr, cut: cut)
    }

}