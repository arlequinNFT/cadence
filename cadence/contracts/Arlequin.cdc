import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"
import FlowToken from "./FlowToken.cdc"
import Voter from "./Voter.cdc"
import ArleeScene from "./ArleeScene.cdc"

pub contract Arlequin {
    
    pub var voterNFTPrice : UFix64 
    pub var sceneNFTPrice : UFix64

    // This is the ratio to partners in voterNFT sales, ratio to Arlequin will be (1 - partnerSplitRatio)
    pub var partnerSplitRatio : UFix64

    // Paths
    pub let VoterAdminStoragePath : StoragePath
    pub let ArleeSceneAdminStoragePath : StoragePath

    // Query Functions
    /* For Voter */
    pub fun checkVoterNFT(addr: Address): Bool {
        return Voter.checkVoterNFT(addr: addr)
    }

    pub fun getVoterNFTIDs(addr: Address) : [UInt64]? {
        return Voter.getVoterNFTIDs(addr: addr)
    }

    pub fun getVoterNFTName(id: UInt64) : String? {
        return Voter.getVoterNFTName(id: id)
    }

    pub fun getVoterNFTNames(addr: Address) : [String]? {
        return Voter.getVoterNFTNames(addr: addr)
    }

    pub fun getVoterAllNFTNames() : {UInt64 : String} {
        return Voter.getAllVoterNFTNames()
    }

    pub fun getVoterRoyalties() : {String : Voter.Royalty} {
        return Voter.getRoyalties()
    }

    pub fun getVoterRoyaltiesByPartner(partner: String) : Voter.Royalty? {
        return Voter.getPartnerRoyalty(partner: partner)
    }

    pub fun getVoterOwner(id: UInt64) : Address? {
        return Voter.getOwner(id: id)
    }

    pub fun getVoterMintable() : {String : Bool} {
        return Voter.getMintable()
    }

    pub fun getVoterTotalSupply() : UInt64 {
        return Voter.totalSupply
    }

    // For Minting 
    pub fun getVoterMintPrice() : UFix64 {
        return Arlequin.voterNFTPrice
    }

    pub fun getVoterSplitRatio() : UFix64 {
        return Arlequin.partnerSplitRatio
    }



    /* For ArleeScene */
    pub fun getArleeSceneNFTIDs(addr: Address) : [UInt64]? {
        return ArleeScene.getArleeSceneIDs(addr: addr)
    }

    pub fun getArleeSceneRoyalties() : [ArleeScene.Royalty] {
        return ArleeScene.getRoyalty()
    }

    pub fun getArleeSceneCID(id: UInt64) : String? {
        return ArleeScene.getArleeSceneCID(id: id)
    }

    pub fun getAllArleeSceneCID() : {UInt64 : String} {
        return ArleeScene.getAllArleeSceneCID()
    }

    pub fun getArleeSceneFreeMintAcct() : {Address : UInt64} {
        return ArleeScene.getFreeMintAcct()
    }

    pub fun getArleeSceneFreeMintQuota(addr: Address) : UInt64? {
        return ArleeScene.getFreeMintQuota(addr: addr)
    }

    pub fun getArleeSceneOwner(id: UInt64) : Address? {
        return ArleeScene.getOwner(id: id)
    }

    pub fun getArleeSceneMintable() : Bool {
        return ArleeScene.mintable
    }

    pub fun getArleeSceneTotalSupply() : UInt64 {
        return ArleeScene.totalSupply
    }

    // For Minting 
    pub fun getArleeSceneMintPrice() : UFix64 {
        return Arlequin.sceneNFTPrice
    }



    pub resource VoterAdmin {
        // Voter NFT Admin Functinos
        pub fun addPartnerRoyaltyCut(creditor: String, addr: Address, cut: UFix64 ) {
            Voter.addPartnerRoyaltyCut(creditor: creditor, addr: addr, cut: cut )
        }

        pub fun setMarketplaceCut(cut: UFix64) {
            Voter.setMarketplaceCut(cut: cut)
        }

        pub fun setPartnerCut(partner: String, cut: UFix64) {
            Voter.setPartnerCut(partner: partner, cut: cut)
        }

        pub fun setMintable(mintable: Bool) {
            Voter.setMintable(mintable: mintable)
        }

        pub fun setSpecificPartnerNFTMintable(partner:String, mintable: Bool) {
            Voter.setSpecificPartnerNFTMintable(partner:partner, mintable: mintable)
        }

        // for Minting
        pub fun setVoterMintPrice(price: UFix64) {
            Arlequin.voterNFTPrice = price
        }

        pub fun setVoterSplitRatio(ratio: UFix64) {
            pre{
                ratio <= 1.0 : "The spliting ratio cannot be greater than 1.0"
            }
            Arlequin.partnerSplitRatio = ratio
        }

        // Add flexibility to giveaway : an Admin mint function.
        pub fun adminMintVoterNFT(partner: String, name:String){
            // get all merchant receiving vault references 
            let recipientCap = getAccount(Arlequin.account.address).getCapability<&Voter.Collection{Voter.CollectionPublic}>(Voter.CollectionPublicPath)
            let recipient = recipientCap.borrow() ?? panic("Cannot borrow Arlequin's Collection Public")

            // deposit
            Voter.adminMintVoterNFT(recipient:recipient, partner: partner, name:name)
        }
    }

    pub resource ArleeSceneAdmin {
        // Arlee Scene NFT Admin Functinos
        pub fun setMarketplaceCut(cut: UFix64) {
            ArleeScene.setMarketplaceCut(cut: cut)
        }

        pub fun addFreeMintAcct(addr: Address, mint:UInt64) {
            ArleeScene.addFreeMintAcct(addr: addr, mint:mint)
        }

        pub fun batchAddFreeMintAcct(list:{Address : UInt64}) {
            ArleeScene.batchAddFreeMintAcct(list: list)
        }

        pub fun removeFreeMintAcct(addr: Address) {
            ArleeScene.removeFreeMintAcct(addr: addr)
        }

        // set an acct's free minting limit
        pub fun setFreeMintAcctQuota(addr: Address, mint: UInt64) {
            ArleeScene.setFreeMintAcctQuota(addr: addr, mint: mint)
        }

        // add to an acct's free minting limit
        pub fun addFreeMintAcctQuota(addr: Address, additionalMint: UInt64) {
            ArleeScene.addFreeMintAcctQuota(addr: addr, additionalMint: additionalMint)
        }

        pub fun setMintable(mintable: Bool) {
            ArleeScene.setMintable(mintable: mintable)
        }

        // for minting
        pub fun setArleeSceneMintPrice(price: UFix64) {
            Arlequin.sceneNFTPrice = price
        }

    }

    /* Public Minting for VoterNFT */
    pub fun mintVoterNFT(buyer: Address, name: String, partner: String, paymentVault:  @FungibleToken.Vault) {
        pre{
            paymentVault.balance >= Arlequin.voterNFTPrice: "Insufficient payment amount."
            paymentVault.getType() == Type<@FlowToken.Vault>(): "payment type not in FlowToken.Vault."
        }

        // get all merchant receiving vault references 
        let arlequinVault = self.account.borrow<&FlowToken.Vault{FungibleToken.Receiver}>(from: /storage/flowTokenVault) ?? panic("Cannot borrow Arlequin's receiving vault reference")

        let partnerRoyalty = self.getVoterRoyaltiesByPartner(partner:partner) ?? panic ("Cannot find partner : ".concat(partner))
        let partnerAddr = partnerRoyalty.wallet
        let partnerVaultCap = getAccount(partnerAddr).getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let partnerVault = partnerVaultCap.borrow() ?? panic("Cannot borrow partner's receiving vault reference")

        let recipientCap = getAccount(buyer).getCapability<&Voter.Collection{Voter.CollectionPublic}>(Voter.CollectionPublicPath)
        let recipient = recipientCap.borrow() ?? panic("Cannot borrow recipient's Collection Public")

        // splitting vaults for partner and arlequin
        let toPartnerVault <- paymentVault.withdraw(amount: paymentVault.balance * Arlequin.partnerSplitRatio)

        // deposit
        arlequinVault.deposit(from: <- paymentVault)
        partnerVault.deposit(from: <- toPartnerVault)

        Voter.mintVoterNFT(recipient:recipient, partner: partner, name:name)
    }

    /* Public Minting for ArleeSceneNFT */
    pub fun mintSceneNFT(buyer: Address, cid: String, description:String, paymentVault:  @FungibleToken.Vault) {
        pre{
            paymentVault.balance >= Arlequin.sceneNFTPrice: "Insufficient payment amount."
            paymentVault.getType() == Type<@FlowToken.Vault>(): "payment type not in FlowToken.Vault."
        }

        // get all merchant receiving vault references 
        let arlequinVault = self.account.borrow<&FlowToken.Vault{FungibleToken.Receiver}>(from: /storage/flowTokenVault) ?? panic("Cannot borrow Arlequin's receiving vault reference")

        let recipientCap = getAccount(buyer).getCapability<&ArleeScene.Collection{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath)
        let recipient = recipientCap.borrow() ?? panic("Cannot borrow recipient's Collection Public")

        // deposit
        arlequinVault.deposit(from: <- paymentVault)

        ArleeScene.mintSceneNFT(recipient:recipient, cid:cid, description:description)
    }

    /* Free Minting for ArleeSceneNFT */
    pub fun mintSceneFreeMintNFT(buyer: Address, cid: String, description:String) {
        pre{
            Arlequin.getArleeSceneFreeMintQuota(addr: buyer) != nil : "You are not given free mint quotas"
            Arlequin.getArleeSceneFreeMintQuota(addr: buyer)! > 0 : "You ran out of free mint quotas"
        }

        let recipientCap = getAccount(buyer).getCapability<&ArleeScene.Collection{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath)
        let recipient = recipientCap.borrow() ?? panic("Cannot borrow recipient's Collection Public")

        ArleeScene.freeMintAcct[buyer] = ArleeScene.freeMintAcct[buyer]! - 1

        // deposit
        ArleeScene.mintSceneNFT(recipient:recipient, cid:cid, description:description)
    }

    init(){
        self.voterNFTPrice = 10.0
        self.sceneNFTPrice = 10.0

        self.partnerSplitRatio = 0.4

        self.VoterAdminStoragePath = /storage/VoterAdmin
        self.ArleeSceneAdminStoragePath = /storage/ArleeSceneAdmin              
        
        self.account.save(<- create VoterAdmin(), to:Arlequin.VoterAdminStoragePath)
        self.account.save(<- create ArleeSceneAdmin(), to:Arlequin.ArleeSceneAdminStoragePath)
        
    }


}
 