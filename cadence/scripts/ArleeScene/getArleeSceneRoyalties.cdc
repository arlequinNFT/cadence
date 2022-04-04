import Arlequin from "../../contracts/Arlequin.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"

pub fun main() : [ArleeScene.Royalty] {
    return Arlequin.getArleeSceneRoyalties()
}