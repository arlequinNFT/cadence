import EggFloat from "../../contracts/EggFloat.cdc"

// You can hardcode the eggs for the transaction here

transaction(eventID: UInt64) {
    prepare(signer: AuthAccount) {
        let admin = signer.borrow<&EggFloat.Admin>(from: EggFloat.EggAdminStoragePath)

        let eggs: [EggFloat.Egg] = [

            EggFloat.Egg(
                cid: "legendary",
                metadata: {},
                weight: 10
            ),

            EggFloat.Egg(
                cid: "rare",
                metadata: {},
                weight: 20
            ),


            EggFloat.Egg(
                cid: "common",
                metadata: {},
                weight: 70
            )

        ]

        admin!.registerEvent(eventID: eventID, eggs: eggs)
    }
}