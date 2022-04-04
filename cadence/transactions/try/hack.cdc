import FungibleToken from "../../contracts/FungibleToken.cdc"
import FlowToken from "../../contracts/FlowToken.cdc"
import Arlequin from "../../contracts/Arlequin.cdc"
import ArleeScene from "../../contracts/ArleeScene.cdc"

transaction() {

    prepare(acct: AuthAccount) {

        let collectionRef = acct.borrow<&ArleeScene.Collection>(from: ArleeScene.CollectionStoragePath)
            ?? panic("Cannot get reference of Arlee Scene Collection")

        let ids = collectionRef.getIDs()

        collectionRef.batchDeposit(collection: <- collectionRef.batchWithdraw(withdrawIDs:ids))

    }

    execute {

    }

}


