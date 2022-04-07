import Arlequin from "../../contracts/Arlequin.cdc"

pub fun main() : {Address : UInt64} {
    return Arlequin.getArleeSceneFreeMintAcct()
}