import FLOAT from "../../contracts/lib/FLOAT.cdc"
import NonFungibleToken from "../../contracts/lib/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/lib/MetadataViews.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"
import EggFloat from "../../contracts/EggFloat.cdc"

transaction(withdrawID: UInt64) {
    prepare(signer: AuthAccount) {

        if signer.borrow<&ArleeScene.Collection>(from: ArleeScene.CollectionStoragePath) == nil {
            signer.save(<- ArleeScene.createEmptyCollection(), to: ArleeScene.CollectionStoragePath)
            signer.link<&ArleeScene.Collection{ArleeScene.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>
                (ArleeScene.CollectionPublicPath, target:ArleeScene.CollectionStoragePath)
        }

        let collection = signer.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) 
        
        if collection != nil {
            log("TEST")

            let floatRef = collection!.borrowFLOAT(id: withdrawID) ?? panic("Float not found")
            let floatUUID = floatRef.uuid
            if floatRef != nil {
                let cap = signer.link<&{NonFungibleToken.Provider}>(/private/ArleeEggFloatProvider, target: FLOAT.FLOATCollectionStoragePath)!
                EggFloat.hatchEgg(floatRef: floatRef, floatProviderCap: cap)
            }  
        }
    }
}