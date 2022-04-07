import Arlequin from "../../contracts/Arlequin.cdc"

transaction(creditor: String, addr: Address, cut: UFix64) {

    let voterAdmin : &Arlequin.VoterAdmin

    prepare(acct: AuthAccount) {
        self.voterAdmin = acct.borrow<&Arlequin.VoterAdmin>(from: Arlequin.VoterAdminStoragePath) 
            ?? panic (" Cannot borrow reference to Voter Admin")
    }

    execute {
        self.voterAdmin.addPartnerRoyaltyCut(creditor: creditor, addr: addr, cut: cut)
    }

}