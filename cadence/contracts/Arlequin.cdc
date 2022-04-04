import FungibleToken from "./FungibleToken.cdc"
import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"
import FlowToken from "./FlowToken.cdc"
import ArleePartner from "./ArleePartner.cdc"
import ArleeScene from "./ArleeScene.cdc"

pub contract Arlequin {
    
    pub var partnerNFTPrice : UFix64
    pub var sceneNFTPrice : UFix64
    pub var sceneNFTWhitelistPrice : UFix64

    // This is the ratio to partners in partnerNFT sales, ratio to Arlequin will be (1 - partnerSplitRatio)
    pub var partnerSplitRatio : UFix64

    // Paths
    pub let ArleePartnerAdminStoragePath : StoragePath
    pub let ArleeSceneAdminStoragePath : StoragePath

    // Query Functions
    /* For ArleePartner */
    pub fun checkArleePartnerNFT(addr: Address): Bool {
        return ArleePartner.checkArleePartnerNFT(addr: addr)
    }

    pub fun getArleePartnerNFTIDs(addr: Address) : [UInt64]? {
        return ArleePartner.getArleePartnerNFTIDs(addr: addr)
    }

    pub fun getArleePartnerNFTName(id: UInt64) : String? {
        return ArleePartner.getPartnerNFTName(id: id)
    }

    pub fun getArleePartnerNFTNames(addr: Address) : [String]? {
        return ArleePartner.getPartnerNFTNames(addr: addr)
    }

    pub fun getArleePartnerAllNFTNames() : {UInt64 : String} {
        return ArleePartner.getAllPartnerNFTNames()
    }

    pub fun getArleePartnerRoyalties() : {String : ArleePartner.Royalty} {
        return ArleePartner.getRoyalties()
    }

    pub fun getArleePartnerRoyaltiesByPartner(partner: String) : ArleePartner.Royalty? {
        return ArleePartner.getPartnerRoyalty(partner: partner)
    }

    pub fun getArleePartnerOwner(id: UInt64) : Address? {
        return ArleePartner.getOwner(id: id)
    }

    pub fun getArleePartnerMintable() : Bool {
        return ArleePartner.mintable
    }

    pub fun getArleePartnerTotalSupply() : UInt64 {
        return ArleePartner.totalSupply
    }

    // For Minting 
    pub fun getArleePartnerMintPrice() : UFix64 {
        return Arlequin.partnerNFTPrice
    }

    pub fun getArleePartnerSplitRatio() : UFix64 {
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

    pub fun getArleeSceneWhitelist() : {Address : UInt64} {
        return ArleeScene.getWhitelist()
    }

    pub fun getArleeSceneWhitelistQuota(addr: Address) : UInt64? {
        return ArleeScene.getWhitelistQuota(addr: addr)
    }

    pub fun getArleeSceneOwner(id: UInt64) : Address? {
        return ArleeScene.getOwner(id: id)
    }

    pub fun getArleeSceneMintable() : Bool {
        return ArleeScene.mintable
    }

    pub fun getArleeSceneWhitelistMintable() : Bool {
        return ArleeScene.whitelistMintable
    }

    pub fun getArleeSceneTotalSupply() : UInt64 {
        return ArleeScene.totalSupply
    }

    // For Minting 
    pub fun getArleeSceneMintPrice() : UFix64 {
        return Arlequin.sceneNFTPrice
    }

    pub fun getArleeSceneWhitelistMintPrice() : UFix64 {
        return Arlequin.sceneNFTWhitelistPrice
    }



    pub resource ArleePartnerAdmin {
        // Arlee Partner NFT Admin Functinos
        pub fun addPartnerRoyaltyCut(creditor: String, addr: Address, cut: UFix64 ) {
            ArleePartner.addPartnerRoyaltyCut(creditor: creditor, addr: addr, cut: cut )
        }

        pub fun setMarketplaceCut(cut: UFix64) {
            ArleePartner.setMarketplaceCut(cut: cut)
        }

        pub fun setPartnerCut(creditor: String, cut: UFix64) {
            ArleePartner.setPartnerCut(creditor: creditor, cut: cut)
        }

        pub fun setMintable(mintable: Bool) {
            ArleePartner.setMintable(mintable: mintable)
        }

        // for Minting
        pub fun setArleePartnerMintPrice(price: UFix64) {
            Arlequin.partnerNFTPrice = price
        }

        pub fun setArleePartnerSplitRatio(ratio: UFix64) {
            pre{
                ratio <= 1.0 : "The spliting ratio cannot be greater than 1.0"
            }
            Arlequin.partnerSplitRatio = ratio
        }
    }

    pub resource ArleeSceneAdmin {
        // Arlee Scene NFT Admin Functinos
        pub fun setMarketplaceCut(cut: UFix64) {
            ArleeScene.setMarketplaceCut(cut: cut)
        }

        pub fun addWhitelistAcct(addr: Address, mint:UInt64) {
            ArleeScene.addWhitelistAcct(addr: addr, mint:mint)
        }

        pub fun batchAddWhitelistAcct(list:{Address : UInt64}) {
            ArleeScene.batchAddWhitelistAcct(list: list)
        }

        pub fun removeWhitelistAcct(addr: Address) {
            ArleeScene.removeWhitelistAcct(addr: addr)
        }

        // set an already whitelisted acct's minting limit
        pub fun setWhitelistAcctMint(addr: Address, mint: UInt64) {
            ArleeScene.setWhitelistAcctMint(addr: addr, mint: mint)
        }

        // add to an already whitelisted acct's minting limit
        pub fun addWhitelistAcctMint(addr: Address, additionalMint: UInt64) {
            ArleeScene.addWhitelistAcctMint(addr: addr, additionalMint: additionalMint)
        }

        pub fun setMintable(mintable: Bool) {
            ArleeScene.setMintable(mintable: mintable)
        }

        pub fun setWhitelistMintable(mintable: Bool) {
            ArleeScene.setWhitelistMintable(mintable: mintable)
        }

        // for minting
        pub fun setArleeSceneMintPrice(price: UFix64) {
            Arlequin.sceneNFTPrice = price
        }

        pub fun setArleeSceneWhitelistMintPrice(price: UFix64) {
            Arlequin.sceneNFTWhitelistPrice = price
        }
    }

    /* Public Minting for ArleePartnerNFT */
    pub fun mintPartnerNFT(buyer: Address, name: String, partner: String, paymentVault:  @FungibleToken.Vault) {
        pre{
            paymentVault.balance >= Arlequin.partnerNFTPrice: "Insufficient payment amount."
            paymentVault.getType() == Type<@FlowToken.Vault>(): "payment type not in FlowToken.Vault."
        }

        // get all merchant receiving vault references 
        let arlequinVault = self.account.borrow<&{FungibleToken.Receiver}>(from: /storage/flowTokenVault) ?? panic("Cannot borrow Arlequin's receiving vault reference")

        let partnerRoyalty = self.getArleePartnerRoyaltiesByPartner(partner:partner) ?? panic ("Cannot find partner : ".concat(partner))
        let partnerAddr = partnerRoyalty.wallet
        let partnerVaultCap = getAccount(buyer).getCapability<&{FungibleToken.Receiver}>(/public/flowTokenReceiver)
        let partnerVault = partnerVaultCap.borrow() ?? panic("Cannot borrow partner's receiving vault reference")

        let recipientCap = getAccount(buyer).getCapability<&{ArleePartner.CollectionPublic}>(ArleePartner.CollectionPublicPath)
        let recipient = recipientCap.borrow() ?? panic("Cannot borrow recipient's Collection Public")

        // splitting vaults for partner and arlequin
        let toPartnerVault <- paymentVault.withdraw(amount: paymentVault.balance * Arlequin.partnerSplitRatio)

        // deposit
        arlequinVault.deposit(from: <- paymentVault)
        partnerVault.deposit(from: <- toPartnerVault)

        ArleePartner.mintPartnerNFT(recipient:recipient, partner: partner, name:name)
    }

    /* Public Minting for ArleeSceneNFT */
    pub fun mintSceneNFT(buyer: Address, cid: String, description:String, paymentVault:  @FungibleToken.Vault) {
        pre{
            paymentVault.balance >= Arlequin.sceneNFTPrice: "Insufficient payment amount."
            paymentVault.getType() == Type<@FlowToken.Vault>(): "payment type not in FlowToken.Vault."
        }

        // get all merchant receiving vault references 
        let arlequinVault = self.account.borrow<&{FungibleToken.Receiver}>(from: /storage/flowTokenVault) ?? panic("Cannot borrow Arlequin's receiving vault reference")

        let recipientCap = getAccount(buyer).getCapability<&{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath)
        let recipient = recipientCap.borrow() ?? panic("Cannot borrow recipient's Collection Public")

        // deposit
        arlequinVault.deposit(from: <- paymentVault)

        ArleeScene.mintSceneNFT(recipient:recipient, cid:cid, description:description)
    }

    /* Whitelist Minting for ArleeSceneNFT */
    pub fun mintSceneWhitelistNFT(buyer: Address, cid: String, description:String, paymentVault:  @FungibleToken.Vault) {
        pre{
            paymentVault.balance >= Arlequin.sceneNFTWhitelistPrice: "Insufficient payment amount."
            paymentVault.getType() == Type<@FlowToken.Vault>(): "payment type not in FlowToken.Vault."
        }

        // get all merchant receiving vault references 
        let arlequinVault = self.account.borrow<&{FungibleToken.Receiver}>(from: /storage/flowTokenVault) ?? panic("Cannot borrow Arlequin's receiving vault reference")

        let recipientCap = getAccount(buyer).getCapability<&{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath)
        let recipient = recipientCap.borrow() ?? panic("Cannot borrow recipient's Collection Public")

        // deposit
        arlequinVault.deposit(from: <- paymentVault)

        ArleeScene.mintSceneWhitelistNFT(recipient:recipient, cid:cid, description:description)
    }

    init(){
        self.partnerNFTPrice = 10.0
        self.sceneNFTPrice = 10.0
        self.sceneNFTWhitelistPrice = 10.0

        self.partnerSplitRatio = 0.4

        self.ArleePartnerAdminStoragePath = /storage/ArleePartnerAdmin
        self.ArleeSceneAdminStoragePath = /storage/ArleeSceneAdmin              

        self.account.save(<- create ArleePartnerAdmin(), to:Arlequin.ArleePartnerAdminStoragePath)
        self.account.save(<- create ArleeSceneAdmin(), to:Arlequin.ArleeSceneAdminStoragePath)
    }


}
 