import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main() : {String : Bool} {
    return Arlequin.getVoterMintable()
}