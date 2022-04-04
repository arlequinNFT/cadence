import Arlequin from "../../contracts/Arlequin.cdc"
import ArleePartner from "../../contracts/ArleePartner.cdc"

pub fun main(partner: String) : ArleePartner.Royalty? {
    return Arlequin.getArleePartnerRoyaltiesByPartner(partner: partner)
}