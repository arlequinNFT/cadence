//ArleeScene NFT Contract

/*  This contract defines ArleeScene NFTs.
    Users can mint this NFT with FLOW
    Users owning the Partner NFT can mint an Advanced One.
    The fund received will be deposited to the Admin wallet.

    Will be incorporated to Arlee Contract 
    ** The Marketpalce Royalty need to be confirmed.
 */

 import NonFungibleToken from "./NonFungibleToken.cdc"
 import MetadataViews from "./MetadataViews.cdc"


 pub contract ArleeScene : NonFungibleToken{

    // Total number of ArleeScene NFT in existance
    pub var totalSupply: UInt64 

    // Controls whether the PartnerNFT function
    // Stores all minted Scenes { ID : CID }
    access(account) var mintedScenes : {UInt64 : String}
    // Stores all ownedScenes { Owner : Scene IDs }
    access(account) var ownedScenes : {Address : [UInt64]}

    // Active Status
    pub var mintable: Bool

    // Whitelist and Status
    pub var whitelistMintable : Bool
    access(account) var whitelistAcct : {Address : UInt64}

    // Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Created(id: UInt64, cid:String, royalties: [Royalty], creator:Address)

    // Paths
    pub let CollectionStoragePath : StoragePath
    pub let CollectionPublicPath : PublicPath

    // Royalty
    pub var marketplaceCut: UFix64
    pub let arlequinWallet: Address

    // Royalty Struct (For later royalty and marketplace implementation)
    pub struct Royalty{
        pub let creditor: String
        pub let wallet: Address
        pub let cut: UFix64

        init(creditor:String, wallet: Address, cut: UFix64){
            self.creditor = creditor
            self.wallet = wallet
            self.cut = cut
        }
    }

    // ArleeScene NFT (includes the CID, description, creator, royalty)
    pub resource NFT : NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let cid: String
        pub let description: String
        pub let creator: Address
        access(contract) let royalties: [Royalty]

        init(cid: String, description:String, creator: Address, royalties:[Royalty]){
            self.id = ArleeScene.totalSupply
            self.cid = cid
            self.description = description
            self.creator = creator
            self.royalties = royalties

            // update totalSupply
            ArleeScene.totalSupply = ArleeScene.totalSupply +1
        }

        // Function to return royalty
        pub fun getRoyalties(): [Royalty] {
            return self.royalties
        }

        // MetadataViews Implementation
        pub fun getViews(): [Type] {
          return [Type<MetadataViews.Display>(), 
                  Type<[Royalty]>()]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                    let displayUrl = "https://painter.arlequin.gg/".concat(self.cid)
                    return MetadataViews.Display(
                    name : "Arlee Scene NFT" ,
                    description : "This is the NFT created with Arlequin Painter." ,
                    thumbnail : MetadataViews.HTTPFile(url:displayUrl)
                    )

                case Type<[Royalty]>():
                    return self.royalties
            } 
            return nil
        }
    }
    

    // Collection Interfaces Needed for borrowing NFTs
    pub resource interface CollectionPublic {
        pub fun getIDs() : [UInt64]
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun batchDeposit(collection: @NonFungibleToken.Collection)
        pub fun borrowNFT(id : UInt64) : &NonFungibleToken.NFT
        pub fun borrowArleeScene(id : UInt64) : &ArleeScene.NFT? {
            // If the result isn't nil, the id of the returned reference
            // should be the same as the argument to the function
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow Component reference: The ID of the returned reference is incorrect"
            }
        }

        /* MetadataViews Implementation */
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver}
    }


    // Collection that implements NonFungible Token Standard with Collection Public and MetaDataViews
    pub resource Collection : CollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        pub var ownedNFTs : @{UInt64: NonFungibleToken.NFT}

        init(){
            self.ownedNFTs <- {}
        }

        destroy(){
            destroy self.ownedNFTs

            // remove all IDs owned in the contract upon destruction
            if self.owner != nil {
                ArleeScene.ownedScenes.remove(key: self.owner!.address)
            }
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot find Alree Scene NFT in your Collection, id: ".concat(withdrawID.toString()))

            emit Withdraw(id: token.id, from: self.owner?.address)
            
            // update IDs for contract record
            if self.owner != nil {
                ArleeScene.ownedScenes[self.owner!.address] = self.getIDs()
            }

            return <- token
        }

        pub fun batchWithdraw(withdrawIDs: [UInt64]): @NonFungibleToken.Collection{
            let collection <- ArleeScene.createEmptyCollection()
            for id in withdrawIDs {
                let nft <- self.ownedNFTs.remove(key: id) ?? panic("Cannot find Arlee Scene NFT in your Collection, id: ".concat(id.toString()))
                collection.deposit(token: <- nft) 
            }
            return <- collection
        }

        pub fun deposit(token: @NonFungibleToken.NFT){
            let token <- token as! @ArleeScene.NFT

            let id:UInt64 = token.id

            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id:id, to: self.owner?.address)

            // update IDs for contract record
            if self.owner != nil {
                ArleeScene.ownedScenes[self.owner!.address] = self.getIDs()
            }

            destroy oldToken
        }

        pub fun batchDeposit(collection: @NonFungibleToken.Collection){
            for id in collection.getIDs() {
                let token <- collection.withdraw(withdrawID: id)
                self.deposit(token: <- token)
            }
            destroy collection
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowArleeScene(id: UInt64): &ArleeScene.NFT? {
            if self.ownedNFTs[id] == nil {
                return nil
            }

            let nftRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let ref = nftRef as! &ArleeScene.NFT

            return ref
            
        }

        //MetadataViews Implementation
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let nftRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let ArleeSceneRef = nftRef as! &ArleeScene.NFT

            return ArleeSceneRef as &{MetadataViews.Resolver}
        }

    }

    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    /* Query Function (Can also be done in Arlee Contract) */
    // return true if the address holds the Partner NFT
    pub fun getArleeSceneIDs(addr: Address): [UInt64]? {
        let holderCap = getAccount(addr).getCapability<&{ArleeScene.CollectionPublic}>(ArleeScene.CollectionPublicPath)
        
        if holderCap.borrow == nil {
            return nil
        }
        
        let holderRef = holderCap.borrow() ?? panic("Cannot borrow Arlee Scene Collection Reference")
        return holderRef.getIDs()

    }

    pub fun getRoyalty(): [Royalty] {
        return [Royalty(creditor: "Arlequin", wallet: ArleeScene.arlequinWallet, cut: ArleeScene.marketplaceCut)]
    }

    pub fun getArleeSceneCID(id: UInt64): String? {
        return ArleeScene.mintedScenes[id]
    }

    pub fun getAllArleeSceneCID(): {UInt64 : String} {
        return ArleeScene.mintedScenes
    }

    pub fun getWhitelist(): {Address : UInt64} {
        return ArleeScene.whitelistAcct
    }

    pub fun getWhitelistQuota(addr: Address) : UInt64? {
        return ArleeScene.whitelistAcct[addr]
    }

    pub fun getOwner(id: UInt64) : Address? {
        for addr in ArleeScene.ownedScenes.keys{
            if ArleeScene.ownedScenes[addr]!.contains(id) {
                return addr
            }
        }
        return nil
    }


    /* Admin Function */
    access(account) fun setMarketplaceCut(cut: UFix64) {
        ArleeScene.marketplaceCut = cut
    }

    access(account) fun mintSceneNFT(recipient:&{ArleeScene.CollectionPublic}, cid:String, description:String) {
        pre{
            ArleeScene.mintable : "Public minting is not available at the moment."
        }
        // further checks
        assert(recipient.owner != nil , message:"Cannot pass in a Collection reference with no owner")
        let ownerAddr = recipient.owner!.address

        let royalties = ArleeScene.getRoyalty()
        let newNFT <- create ArleeScene.NFT(cid: cid, description: description, creator: ownerAddr, royalties:royalties)
        
        ArleeScene.mintedScenes[newNFT.id] = cid
        emit Created(id:newNFT.id, cid:cid, royalties:royalties, creator: ownerAddr)
        recipient.deposit(token: <- newNFT) 
    }

    access(account) fun mintSceneWhitelistNFT(recipient:&{ArleeScene.CollectionPublic}, cid:String, description:String){
        pre{
            ArleeScene.whitelistMintable : "Whitelist minting is not available at the moment."
        }
        // further check if the recipient is in whitelist
        assert(recipient.owner != nil , message:"Cannot pass in a Collection reference with no owner")
        let ownerAddr = recipient.owner!.address
        assert(ArleeScene.whitelistAcct[ownerAddr] != nil, message: "You are not in the whitelist")
        assert(ArleeScene.whitelistAcct[ownerAddr]! > 0, message: "You already ran out of mintable quotas")

        let royalties = ArleeScene.getRoyalty()
        let newNFT <- create ArleeScene.NFT(cid: cid, description: description, creator: ownerAddr, royalties:royalties)
        
        // minus 1 in the whitelist mintable quota
        ArleeScene.whitelistAcct[ownerAddr] = ArleeScene.whitelistAcct[ownerAddr]! - 1

        ArleeScene.mintedScenes[newNFT.id] = cid
        emit Created(id:newNFT.id, cid:cid, royalties:royalties, creator: ownerAddr)
        recipient.deposit(token: <- newNFT) 
    }

    access(account) fun addWhitelistAcct(addr: Address, mint:UInt64) {
        pre{
            ArleeScene.whitelistAcct[addr] == nil : "This address is already given Whitelist, please use other functions for altering"
        }
        ArleeScene.whitelistAcct[addr] = mint
    }

    access(account) fun batchAddWhitelistAcct(list:{Address : UInt64}) {
        for addr in list.keys {
            ArleeScene.addWhitelistAcct(addr: addr, mint:list[addr]!)
        }
    }

    access(account) fun removeWhitelistAcct(addr: Address) {
        pre{
            ArleeScene.whitelistAcct[addr] != nil : "This address is not given Whitelist"
        }
        ArleeScene.whitelistAcct.remove(key: addr)
    }

    access(account) fun setWhitelistAcctMint(addr: Address, mint: UInt64) {
        pre{
            mint > 0 : "Minting limit cannot be smaller than 1"
            ArleeScene.whitelistAcct[addr] != nil : "This address is not given Whitelist"
        }
        ArleeScene.whitelistAcct[addr] = mint
    }

    access(account) fun addWhitelistAcctMint(addr: Address, additionalMint: UInt64) {
        pre{
            ArleeScene.whitelistAcct[addr] != nil : "This address is not given Whitelist"
        }
        ArleeScene.whitelistAcct[addr] = additionalMint + ArleeScene.whitelistAcct[addr]!
    }

    access(account) fun setMintable(mintable: Bool) {
        ArleeScene.mintable = mintable
    }

    access(account) fun setWhitelistMintable(mintable: Bool) {
        ArleeScene.whitelistMintable = mintable
    }

    init(){
        self.totalSupply = 0

        self.mintedScenes = {}
        self.ownedScenes = {}

        self.mintable = false
        
        self.whitelistMintable = false
        self.whitelistAcct = {}

        // Paths
        self.CollectionStoragePath = /storage/ArleeScene
        self.CollectionPublicPath = /public/ArleeScene

        // Royalty
        self.marketplaceCut = 0.05
        self.arlequinWallet = self.account.address

        // Setup Account
        self.account.save(<- ArleeScene.createEmptyCollection() , to: ArleeScene.CollectionStoragePath)
        self.account.link<&{ArleeScene.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.Resolver}>(ArleeScene.CollectionPublicPath, target:ArleeScene.CollectionStoragePath)
    }
        
 }