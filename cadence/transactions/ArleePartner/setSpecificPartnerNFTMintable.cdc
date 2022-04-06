import Arlequin from "../../contracts/Arlequin.cdc"

transaction(partner:String, mintable: Bool) {

    let arleePartnerAdmin : &Arlequin.ArleePartnerAdmin

    prepare(acct: AuthAccount) {
        self.arleePartnerAdmin = acct.borrow<&Arlequin.ArleePartnerAdmin>(from: Arlequin.ArleePartnerAdminStoragePath) 
            ?? panic (" Cannot borrow reference to ArleePartner Admin")
    }

    execute {
        self.arleePartnerAdmin.setSpecificPartnerNFTMintable(partner: partner, mintable: mintable)
    }

}