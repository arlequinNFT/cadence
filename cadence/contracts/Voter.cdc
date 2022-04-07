//Arlee Partner NFT Contract

/*  This contract defines Voter NFTs.
    Users can buy this NFT whenever to enjoy advanced features on Arlequin paint.
    The fund received will not deposit to the Admin wallet, 
    but another wallet that will be shared to the partners.

    Minting the advanced ArleeScenes will require the holders holding the NFT.

    Will be incorporated to Arlee Contract 

    ** The Marketpalce Royalty need to be confirmed.
 */

 import NonFungibleToken from "./NonFungibleToken.cdc"
 import MetadataViews from "./MetadataViews.cdc"

 pub contract Voter : NonFungibleToken{

    // Total number of Voter NFT in existance
    pub var totalSupply: UInt64 

    // Minted Voter NFT maps with name {ID : Name}
    access(account) var mintedVoterNFTs : {UInt64 : String}

    // Stores all ownedScenes { Owner : Scene IDs }
    access(account) var ownedVoterNFTs : {Address : [UInt64]}

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

    // Dictionary to stores Partner names whether it is able to mint (i.e. acts as to enable / disable specific Voter NFT minting)
    access(account) var mintableVoterNFTList : {String : Bool}

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

    // VoterNFT (Will only be given name and royalty)
    pub resource NFT : NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub let name: String
        access(contract) let royalties: [Royalty]

        init(name: String, royalties:[Royalty]){
            self.id = Voter.totalSupply
            self.name = name
            self.royalties = royalties

            // update totalSupply
            Voter.totalSupply = Voter.totalSupply +1
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
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver}
        pub fun borrowVoter(id : UInt64) : &Voter.NFT? {
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
                Voter.ownedVoterNFTs.remove(key: self.owner!.address)
            }
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) 
                ?? panic("Cannot find Voter NFT in your Collection, id: ".concat(withdrawID.toString()))

            emit Withdraw(id: token.id, from: self.owner?.address)

            // update IDs for contract record
            if self.owner != nil {
                Voter.ownedVoterNFTs[self.owner!.address] = self.getIDs()
            }

            return <- token
        }

        pub fun batchWithdraw(withdrawIDs: [UInt64]): @NonFungibleToken.Collection{
            let collection <- Voter.createEmptyCollection()
            for id in withdrawIDs {
                let nft <- self.ownedNFTs.remove(key: id) ?? panic("Cannot find Voter NFT in your Collection, id: ".concat(id.toString()))
                collection.deposit(token: <- nft) 
            }
            return <- collection
        }

        pub fun deposit(token: @NonFungibleToken.NFT){
            let token <- token as! @Voter.NFT

            let id:UInt64 = token.id

            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id:id, to: self.owner?.address)

            // update IDs for contract record
            if self.owner != nil {
                Voter.ownedVoterNFTs[self.owner!.address] = self.getIDs()
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

        pub fun borrowVoter(id: UInt64): &Voter.NFT? {
            if self.ownedNFTs[id] == nil {
                return nil
            }

            let nftRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let ref = nftRef as! &Voter.NFT

            return ref
            
        }

        //MetadataViews Implementation
        pub fun borrowViewResolver(id: UInt64): &{MetadataViews.Resolver} {
            let nftRef = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let VoterRef = nftRef as! &Voter.NFT

            return VoterRef as &{MetadataViews.Resolver}
        }

    }

    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    /* Query Function (Can also be done in Arlee Contract) */
    // return true if the address holds the Voter NFT
    pub fun checkVoterNFT(addr: Address): Bool {
        let holderCap = getAccount(addr).getCapability<&Voter.Collection{Voter.CollectionPublic}>(Voter.CollectionPublicPath)
        
        if holderCap.borrow == nil {
            return false
        }
        
        let holderRef = holderCap.borrow() ?? panic("Cannot borrow Arlee Voter NFT Reference")
        let ids = holderRef.getIDs()
        if ids.length < 1{
            return false
        }
        return true
    }

    pub fun getVoterNFTIDs(addr: Address): [UInt64]? {
        let holderCap = getAccount(addr).getCapability<&Voter.Collection{Voter.CollectionPublic}>(Voter.CollectionPublicPath)
        
        if holderCap.borrow == nil {
            return nil
        }
        
        let holderRef = holderCap.borrow() ?? panic("Cannot borrow Arlee Voter Collection Reference")
        return holderRef.getIDs()

    }

    pub fun getVoterNFTName(id: UInt64) : String? {
        return Voter.mintedVoterNFTs[id]
    }

    pub fun getVoterNFTNames(addr: Address) : [String]? {
        let ids = Voter.getVoterNFTIDs(addr: addr)
        if ids == nil || ids!.length == 0 {
            return nil
        }

        var list : [String] = []
        for id in ids! {
            let name = Voter.getVoterNFTName(id: id) ?? panic("This id is not mapped to a Voter NFT Name")
            if !list.contains(name) {
                list.append(name)
            }
        }
        return list
    }

    pub fun getAllVoterNFTNames() : {UInt64 : String} {
        return Voter.mintedVoterNFTs
    }

    pub fun getRoyalties(): {String : Royalty} {
        let royalties = Voter.allRoyalties
        return Voter.allRoyalties
    }

    pub fun getPartnerRoyalty(partner: String) : Royalty? {
        for partnerName in Voter.allRoyalties.keys{
            if partnerName == partner{
                return Voter.allRoyalties[partnerName]!
            }
        }
        return nil
    }

    pub fun getOwner(id: UInt64) : Address? {
        for addr in Voter.ownedVoterNFTs.keys{
            if Voter.ownedVoterNFTs[addr]!.contains(id) {
                return addr
            }
        }
        return nil
    }

    pub fun getMintable() : {String : Bool} {
        var mintableDict :  {String : Bool} = {}
        // if mintable is disabled, return all false
        if !Voter.mintable {
            for key in Voter.mintableVoterNFTList.keys{
                mintableDict[key] = false
            }
            return mintableDict
        }

        return Voter.mintableVoterNFTList
    }





    /* Admin Function */
    // Add a new recipient as a partner to receive royalty cut
    access(account) fun addPartnerRoyaltyCut(creditor: String, addr: Address, cut: UFix64 ) {
        // check if this creditor already exist
        assert(!Voter.allRoyalties.containsKey(creditor), message:"This Royalty already exist")  

        let newRoyalty = Royalty(creditor:creditor, wallet: addr, cut: cut)
        // append royalties
        Voter.allRoyalties[creditor] = newRoyalty

        // add the partner name to the mintableVoterNFTList so by default it is mintable.
        Voter.mintableVoterNFTList[creditor] = true
    }

    access(account) fun setMarketplaceCut(cut: UFix64) {
        let partner = "Arlequin"
        let royaltyRed = &Voter.allRoyalties[partner] as! &Royalty
        royaltyRed.cut = cut
    }

    access(account) fun setPartnerCut(partner: String, cut: UFix64) {
        pre{
            Voter.allRoyalties.containsKey(partner) : "This creditor does not exist"
        }
        let royaltyRed = &Voter.allRoyalties[partner]  as! &Royalty
        royaltyRed.cut = cut
    }

    access(account) fun setMintable(mintable: Bool) {
        Voter.mintable = mintable
    }

    access(account) fun setSpecificPartnerNFTMintable(partner: String, mintable: Bool){
        pre{
            Voter.allRoyalties.containsKey(partner) : "This partner does not exist"
        }
        Voter.mintableVoterNFTList[partner] = mintable
    }

    access(account) fun mintVoterNFT(recipient:&{Voter.CollectionPublic}, partner: String, name:String) {
        pre{
            Voter.mintable : "Public minting is not available at the moment."
        }

        let overallRoyalties = Voter.getRoyalties()
        let partnerRoyalty = overallRoyalties[partner] ?? panic("Cannot find this partner royalty : ".concat(partner))

        // panic if the specific partner minting is disabled
        assert(Voter.mintableVoterNFTList[partner] != nil, message: "Cannot find this partner : ".concat(partner))
        assert(Voter.mintableVoterNFTList[partner]!, message: "This partner NFT minting is disabled. Partner :".concat(partner))

        let arlequinRoyalty = overallRoyalties["Arlequin"]!
        let newNFT <- create Voter.NFT(name: name, royalties:[arlequinRoyalty,partnerRoyalty])
        
        Voter.mintedVoterNFTs[newNFT.id] = newNFT.name

        emit Created(id:newNFT.id, royalties:newNFT.getRoyalties())
        recipient.deposit(token: <- newNFT) 
    }

    access(account) fun adminMintVoterNFT(recipient:&{Voter.CollectionPublic}, partner: String, name:String) {

        let overallRoyalties = Voter.getRoyalties()
        let partnerRoyalty = overallRoyalties[partner] ?? panic("Cannot find this partner royalty : ".concat(partner))

        // panic if the specific partner is missing, regardless of whether its mintable.
        assert(Voter.mintableVoterNFTList[partner] != nil, message: "Cannot find this partner : ".concat(partner))

        let arlequinRoyalty = overallRoyalties["Arlequin"]!
        let newNFT <- create Voter.NFT(name: name, royalties:[arlequinRoyalty,partnerRoyalty])
        
        Voter.mintedVoterNFTs[newNFT.id] = newNFT.name

        emit Created(id:newNFT.id, royalties:newNFT.getRoyalties())
        recipient.deposit(token: <- newNFT) 
    }



    init(){
        self.totalSupply = 0

        self.mintableVoterNFTList = {}

        self.mintedVoterNFTs = {}
        self.ownedVoterNFTs = {}

        self.mintable = false

        // Paths
        self.CollectionStoragePath = /storage/Voter
        self.CollectionPublicPath = /public/Voter

        // Royalty
        self.allRoyalties = {"Arlequin" : Royalty(creditor: "Arlequin", wallet: self.account.address, cut: 0.05)}

        // Setup Account
        
        self.account.save(<- Voter.createEmptyCollection() , to: Voter.CollectionStoragePath)
        self.account.link<&Voter.Collection{Voter.CollectionPublic, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>(Voter.CollectionPublicPath, target:Voter.CollectionStoragePath)
        
    }
        
 }
 