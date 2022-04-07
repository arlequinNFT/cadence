import Arlequin from "../../contracts/Arlequin.cdc"
import Voter from "../../contracts/Voter.cdc"

pub fun main() : {String : Voter.Royalty} {
    return Arlequin.getVoterRoyalties()
}