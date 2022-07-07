import FLOAT from "../../contracts/lib/FLOAT.cdc"
import NonFungibleToken from "../../contracts/lib/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/lib/MetadataViews.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"
import EggFloat from "../../contracts/EggFloat.cdc"

transaction(eventID: UInt64, cid: String, metadata: {String: String}) {
    prepare(signer: AuthAccount) {
        let admin = signer.borrow<&EggFloat.Admin>(from: EggFloat.EggAdminStoragePath)
        admin!.registerEvent(eventID: eventID, cid: cid, metadata: metadata)
    }
}