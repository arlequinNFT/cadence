import FLOAT from "../../contracts/lib/FLOAT.cdc"
import FLOATVerifiers from "../../contracts/lib/FLOATVerifiers.cdc"
import NonFungibleToken from "../../contracts/lib/NonFungibleToken.cdc"
import MetadataViews from "../../contracts/lib/MetadataViews.cdc"
import GrantedAccountAccess from "../../contracts/lib/GrantedAccountAccess.cdc"
import FlowToken from "../../contracts/lib/FlowToken.cdc"

transaction {

  prepare(acct: AuthAccount) {
    // SETUP COLLECTION
    if acct.borrow<&FLOAT.Collection>(from: FLOAT.FLOATCollectionStoragePath) == nil {
        acct.save(<- FLOAT.createEmptyCollection(), to: FLOAT.FLOATCollectionStoragePath)
        acct.link<&FLOAT.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection, FLOAT.CollectionPublic}>
                (FLOAT.FLOATCollectionPublicPath, target: FLOAT.FLOATCollectionStoragePath)
    }

    // SETUP FLOATEVENTS
    if acct.borrow<&FLOAT.FLOATEvents>(from: FLOAT.FLOATEventsStoragePath) == nil {
      acct.save(<- FLOAT.createEmptyFLOATEventCollection(), to: FLOAT.FLOATEventsStoragePath)
      acct.link<&FLOAT.FLOATEvents{FLOAT.FLOATEventsPublic, MetadataViews.ResolverCollection}>
                (FLOAT.FLOATEventsPublicPath, target: FLOAT.FLOATEventsStoragePath)
    }

    // SETUP SHARED MINTING
    if acct.borrow<&GrantedAccountAccess.Info>(from: GrantedAccountAccess.InfoStoragePath) == nil {
        acct.save(<- GrantedAccountAccess.createInfo(), to: GrantedAccountAccess.InfoStoragePath)
        acct.link<&GrantedAccountAccess.Info{GrantedAccountAccess.InfoPublic}>
                (GrantedAccountAccess.InfoPublicPath, target: GrantedAccountAccess.InfoStoragePath)
    }
  }

  execute {
    log("Finished setting up the account for FLOATs.")
  }
}
