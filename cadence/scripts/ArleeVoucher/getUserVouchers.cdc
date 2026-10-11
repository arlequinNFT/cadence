import ArleeSceneVoucher from "../../contracts/ArleeSceneVoucher.cdc"

pub struct Voucher {
    pub let id: UInt64
    pub let species: String

    init(id: UInt64, species: String) {
        self.id = id
        self.species = species
    }
}

pub fun main(addr: Address) : [Voucher]? {
    let collectionCap = getAccount(addr).getCapability<&ArleeSceneVoucher.Collection{ArleeSceneVoucher.CollectionPublic}>(ArleeSceneVoucher.CollectionPublicPath)
    if collectionCap.borrow() == nil {return nil}
    let collectionRef = collectionCap.borrow()!

    var list : [Voucher] = []
    for id in collectionRef.getIDs() {
        let voucher = collectionRef.borrowArleeSceneVoucher(id: id)!
        list.append(Voucher(id: voucher.id, species: voucher.species))
    }

    return list
}
