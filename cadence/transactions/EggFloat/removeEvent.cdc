import EggFloat from "../../contracts/EggFloat.cdc"

transaction(eventID: UInt64) {
    prepare(signer: AuthAccount) {
        let admin = signer.borrow<&EggFloat.Admin>(from: EggFloat.EggAdminStoragePath)
        admin!.removeEvent(eventID: eventID)
    }
}