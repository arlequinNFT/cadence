import EggFloat from "../../contracts/EggFloat.cdc"

// This transaction registers a floatEventID mapped to a list of eggs
// the weights for the eggs 

transaction(eventID: UInt64, cids: [String], metadata: [{String: String}], weights: [UInt64]) {
    prepare(signer: AuthAccount) {
        let admin = signer.borrow<&EggFloat.Admin>(from: EggFloat.EggAdminStoragePath)

        let eggs: [EggFloat.Egg] = []

        for i, cid  in cids {
            eggs.append(
                EggFloat.Egg(
                    cid: cid,
                    metadata: metadata[i],
                    weight: weights[i]
                )
            )

        }

        admin!.registerEvent(eventID: eventID, eggs: eggs)
        log(metadata)
        log(EggFloat.getEggsForEvent(id: eventID))
    }
}