//Arlee Partner NFT Contract

/*  This contract defines Partner NFTs.
    Users can buy this NFT whenever to enjoy advanced features on Arlequin paint.
    The fund received will not deposit to the Admin wallet, 
    but another wallet that will be shared to the partners.

    Minting the advanced ArleeScenes will require the holders holding the NFT.

    Will be incorporated to Arlee Contract 

    ** The Marketpalce Royalty need to be confirmed.
 */

 import NonFungibleToken from "./NonFungibleToken.cdc"
 import MetadataViews from "./MetadataViews.cdc"

 pub contract ArleePartner : NonFungibleToken{

    // Total number of ArleePartner NFT in existance
    pub var totalSupply: UInt64 

    // Minted Partner NFT maps with name {ID : Name}
    access(account) var mintedPartnerNFTs : {UInt64 : String}

    // Stores all ownedScenes { Owner : Scene IDs }
    access(account) var ownedPartnerNFTs : {Address : [UInt64]}

    // Mint Status
    pub var mintable: Bool

    // Events
    pub event ContractInitialized()
    pub event Withdraw(id: UInt64, from: Address?)
    pub event Deposit(id: UInt64, to: Address?)
    pub event Created(id: UInt64, royalties: [Royalty])

    // Paths
    pub let CollectionStoragePath : StoragePath
    pub let CollectionPublicPath : PublicPath

    // All Royalties (Arlee + Partners Royalty)
    access(account) let allRoyalties: {String : Royalty}

    // Royalty Struct (For later royalty and marketplace implementation)
    pub struct Royalty{
        pub let creditor: String
        pub let wallet: Address
        pub(set) var cut: UFix64

        init(creditor:String, wallet: Address, cut: UFix64){
            self.creditor = creditor
            self.wallet = wallet
            self.cut = cut
        }
    }

    // PartnerNFT (Will only be given name and royalty)
    pub resource NFT : NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let name: String
        access(contract) let royalties: [Royalty]

        init(name: String, royalties:[Royalty]){
            self.id = ArleePartner.totalSupply
            self.name = name
            self.royalties = royalties

            // update totalSupply
            ArleePartner.totalSupply = ArleePartner.totalSupply +1
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
                    return MetadataViews.Display(
                    name : self.name ,
                    description : "Holder of the NFT can access advanced features of Arlequin Painter." ,
                    thumbnail : MetadataViews.HTTPFile(url:"https://painter.arlequin.gg/")
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
    pub fun borrowArleePartner(id : UInt64) : &ArleePartner.NFT? {
        // If the result isn't nil, the id of the returned reference
        // should be the same as the argument to the function
        post {
            (result == nil) || (result?.id == id):
                "Cannot borrow Component reference: The ID of the returned reference is incorrect"
        }
      }
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
                ArleePartner.ownedPartnerNFTs.remove(key: self.owner!.address)
            }
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot find Partner NFT in your Collection, id: ".concat(withdrawID.toString()))

            emit Withdraw(id: token.id, from: self.owner?.address)

            // update IDs for contract record
            if self.owner != nil {
                ArleePartner.ownedPartnerNFTs[self.owner!.address] = self.getIDs()
            }

            return <- token
        }

        pub fun batchWithdraw(withdrawIDs: [UInt64]): @NonFungibleToken.Collection{
            let collection <- ArleePartner.createEmptyCollection()
            for id in withdrawIDs {
                let nft <- self.ownedNFTs.remove(key: id) ?? panic("Cannot find Partner NFT in your Collection, id: ".concat(id.toString()))
                collection.deposit(token: <- nft) 
            }
            return <- collection
        }

        pub fun deposit(token: @NonFungibleToken.NFT){
            let token <- token as! @ArleePartner.NFT

            let id:UInt64 = token.id

            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id:id, to: self.owner?.address)

            // update IDs for contract record
            if self.owner != nil {
                ArleePartner.ownedPartnerNFTs[self.owner!.address] = self.getIDs()
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

        pub fun borrowArleePartner(id: UInt64): &ArleePartner.NFT? {
            if self.ownedNFTs[id] == nil {
                return nil
            }

            let nftRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let ref = nftRef as! &ArleePartner.NFT

            return ref
            
        }

        //MetadataViews Implementation
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let nftRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let ArleePartnerRef = nftRef as! &ArleePartner.NFT

            return ArleePartnerRef as &{MetadataViews.Resolver}
        }

    }

    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    /* Query Function (Can also be done in Arlee Contract) */
    // return true if the address holds the Partner NFT
    pub fun checkArleePartnerNFT(addr: Address): Bool {
        let holderCap = getAccount(addr).getCapability<&{ArleePartner.CollectionPublic}>(ArleePartner.CollectionPublicPath)
        
        if holderCap.borrow == nil {
            return false
        }
        
        let holderRef = holderCap.borrow() ?? panic("Cannot borrow Arlee Partner NFT Reference")
        let ids = holderRef.getIDs()
        if ids.length < 1{
            return false
        }
        return true
    }

    pub fun getArleePartnerNFTIDs(addr: Address): [UInt64]? {
        let holderCap = getAccount(addr).getCapability<&{ArleePartner.CollectionPublic}>(ArleePartner.CollectionPublicPath)
        
        if holderCap.borrow == nil {
            return nil
        }
        
        let holderRef = holderCap.borrow() ?? panic("Cannot borrow Arlee Partner Collection Reference")
        return holderRef.getIDs()

    }

    pub fun getPartnerNFTName(id: UInt64) : String? {
        return ArleePartner.mintedPartnerNFTs[id]
    }

    pub fun getPartnerNFTNames(addr: Address) : [String]? {
        let ids = ArleePartner.getArleePartnerNFTIDs(addr: addr)
        if ids == nil || ids!.length == 0 {
            return nil
        }

        var list : [String] = []
        for id in ids! {
            let name = ArleePartner.getPartnerNFTName(id: id) ?? panic("This id is not mapped to a Partner NFT Name")
            if !list.contains(name) {
                list.append(name)
            }
        }
        return list
    }

    pub fun getAllPartnerNFTNames() : {UInt64 : String} {
        return ArleePartner.mintedPartnerNFTs
    }

    pub fun getRoyalties(): {String : Royalty} {
        let royalties = ArleePartner.allRoyalties
        return ArleePartner.allRoyalties
    }

    pub fun getPartnerRoyalty(partner: String) : Royalty? {
        for partnerName in ArleePartner.allRoyalties.keys{
            if partnerName == partner{
                return ArleePartner.allRoyalties[partnerName]!
            }
        }
        return nil
    }

    pub fun getOwner(id: UInt64) : Address? {
        for addr in ArleePartner.ownedPartnerNFTs.keys{
            if ArleePartner.ownedPartnerNFTs[addr]!.contains(id) {
                return addr
            }
        }
        return nil
    }





    /* Admin Function */
    // Add a new recipient as a partner to receive royalty cut
    access(account) fun addPartnerRoyaltyCut(creditor: String, addr: Address, cut: UFix64 ) {
        // check if this creditor already exist
        assert(!ArleePartner.allRoyalties.containsKey(creditor), message:"This Royalty already exist")  

        let newRoyalty = Royalty(creditor:creditor, wallet: addr, cut: cut)
        // append royalties
        ArleePartner.allRoyalties[creditor] = newRoyalty
    }

    access(account) fun setMarketplaceCut(cut: UFix64) {
        let creditor = "Arlequin"
        let royaltyRed = &ArleePartner.allRoyalties[creditor] as! &Royalty
        royaltyRed.cut = cut
    }

    access(account) fun setPartnerCut(creditor: String, cut: UFix64) {
        pre{
            ArleePartner.allRoyalties.containsKey(creditor) : "This creditor does not exist"
        }
        let royaltyRed = &ArleePartner.allRoyalties[creditor]  as! &Royalty
        royaltyRed.cut = cut
    }

    access(account) fun mintPartnerNFT(recipient:&{ArleePartner.CollectionPublic}, partner: String, name:String) {
        pre{
            ArleePartner.mintable : "Public minting is not available at the moment."
        }

        let overallRoyalties = ArleePartner.getRoyalties()
        let partnerRoyalty = overallRoyalties[partner] ?? panic("Cannot find this partner royalty : ".concat(partner))
        let arlequinRoyalty = overallRoyalties["Arlequin"]!
        let newNFT <- create ArleePartner.NFT(name: name, royalties:[arlequinRoyalty,partnerRoyalty])
        
        ArleePartner.mintedPartnerNFTs[newNFT.id] = newNFT.name

        emit Created(id:newNFT.id, royalties:newNFT.getRoyalties())
        recipient.deposit(token: <- newNFT) 
    }

    access(account) fun setMintable(mintable: Bool) {
        ArleePartner.mintable = mintable
    }

    init(){
        self.totalSupply = 0

        self.mintedPartnerNFTs = {}
        self.ownedPartnerNFTs = {}

        self.mintable = false

        // Paths
        self.CollectionStoragePath = /storage/ArleePartner
        self.CollectionPublicPath = /public/ArleePartner

        // Royalty
        self.allRoyalties = {"Arlequin" : Royalty(creditor: "Arlequin", wallet: self.account.address, cut: 0.05)}

        // Setup Account
        self.account.save(<- ArleePartner.createEmptyCollection() , to: ArleePartner.CollectionStoragePath)
        self.account.link<&{ArleePartner.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.Resolver}>(ArleePartner.CollectionPublicPath, target:ArleePartner.CollectionStoragePath)
    }
        
 }
 