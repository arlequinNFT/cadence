import Arlequin from "../../contracts/Arlequin.cdc"
import Voter from "../../contracts/Voter.cdc"

pub fun main(partner: String) : Voter.Royalty? {
    return Arlequin.getVoterRoyaltiesByPartner(partner: partner)
}