import Arlequin from "../../contracts/Arlequin.cdc"
import ArleePartner from "../../contracts/ArleePartner.cdc"

pub fun main() : {String : ArleePartner.Royalty} {
    return Arlequin.getArleePartnerRoyalties()
}