import Arlequin from "../../contracts/Arlequin.cdc"

transaction(partner: String, name: String) {

    let voterAdmin : &Arlequin.VoterAdmin

    prepare(acct: AuthAccount) {
        self.voterAdmin = acct.borrow<&Arlequin.VoterAdmin>(from: Arlequin.VoterAdminStoragePath) 
            ?? panic (" Cannot borrow reference to Voter Admin")
    }

    execute {
        self.voterAdmin.adminMintVoterNFT(partner: partner, name:name)
    }

}