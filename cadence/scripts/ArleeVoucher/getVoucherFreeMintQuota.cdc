import ArleeSceneVoucher from "../../contracts/ArleeSceneVoucher.cdc"

pub fun main(addr: Address) : UInt64? {
    return ArleeSceneVoucher.getFreeMintQuota(addr: addr)
}
