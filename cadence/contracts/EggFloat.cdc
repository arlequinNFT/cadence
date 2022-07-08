import FLOAT from "./lib/FLOAT.cdc"
import NonFungibleToken from "./lib/NonFungibleToken.cdc"
import ArleeScene from "./ArleeScene.cdc"

pub contract EggFloat {

    pub let eggsByID: {UInt64: Egg}

    pub let EggAdminStoragePath: StoragePath

    pub struct Egg {
        pub let eventID: UInt64
        pub let cid: String
        pub let metadata: {String: String}

        init(eventID: UInt64, cid: String, metadata: {String: String}) {
            self.eventID = eventID
            self.cid = cid
            self.metadata = metadata
        }
    }

    pub fun getEggs(): {UInt64: Egg} {
        return self.eggsByID
    }

    pub fun hatchEgg(floatRef: &FLOAT.NFT, floatProviderCap: Capability<&{NonFungibleToken.Provider}>) {
        pre {
            self.eggsByID.containsKey(floatRef.eventId): "This Float is not an Arlee Egg Float!"
        }
        let egg = self.eggsByID[floatRef.eventId]!
        let float <- floatProviderCap.borrow()!.withdraw(withdrawID: floatRef.uuid)
        assert(float.uuid == floatRef.uuid, message: "Mismatching IDs")

        let receipient = getAccount(floatProviderCap.address).getCapability<&ArleeScene.Collection{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath).borrow() ?? panic("Cannot borrow recipient's ArleeScene CollectionPublic")
        ArleeScene.mintSceneNFT(recipient: receipient, cid: egg.cid, metadata: egg.metadata)
    
        destroy float
    }

    pub resource Admin {
        pub fun registerEvent(eventID: UInt64, cid: String, metadata: {String: String}) {
            EggFloat.eggsByID.insert(key: eventID, Egg(eventID: eventID, cid: cid, metadata: metadata))
        }

        pub fun removeEvent(eventID: UInt64) {
            EggFloat.eggsByID.remove(key: eventID)
        }
    }   

    init() {
        self.eggsByID = {}
        self.EggAdminStoragePath = /storage/ArleeEggFloatAdminStoragePath
    
        destroy self.account.load<@AnyResource>(from: self.EggAdminStoragePath)
        self.account.save(<- create Admin(), to: self.EggAdminStoragePath)
    
    }

}