# Bash script for testing contracts, transactions and scripts against the emulator. 
# 1. Create accounts 

# Create 3 accounts for testing purposes. 
# See README for additional details

echo "Creating Admin account: "
flow accounts create --key="2921bbc5acf75417b09ef1cc7981f2a57cc7ee00df71afaddde94991b6f26fb4da66a4b9bea1ee8a555dbba62626ba7c0437e4c6800d25203c915161bed6e4f2"

echo "Creating User1 account 0x179b6b1cb6755e31"
flow accounts create --key="e5b78d3e1d28ecccaa62bbf869df5b6b06a3f0330a46651b2e29c5a0e53b4cd9659f2a0a0555c6de55caedc08475a81e6670ec62c93acbcfe62a45a20226a323"

echo "Creating User2 account 0xf3fcd2c1a78f5eee"
flow accounts create --key="62410c9c523d7a04f8b5c1b478cbada16d70125be9c8e137baa843a16a430da70d215fb6d6fc9ca68d4b7b3f2e7624db8785006b3fe977e25ca459612178723a"

# 2. Mint Flow tokens

# Flow tokens required for admin-account to be able to deploy contracts without running out of storage space.
# mintFlowTokens amount recipientAddress
flow transactions send "./cadence/transactions/Flow/mint.cdc" 1000.0 0x01cf0e2f2f715450
flow transactions send "./cadence/transactions/Flow/mint.cdc" 1000.0 0x179b6b1cb6755e31
flow transactions send "./cadence/transactions/Flow/mint.cdc" 1000.0 0xf3fcd2c1a78f5eee


flow project deploy --network emulator

flow transactions send ./cadence/transactions/float/setup_account.cdc

flow transactions send ./cadence/transactions/ArleeScene/setMintable.cdc true 


flow transactions send ./cadence/transactions/mintSceneNFT.cdc hiCID {} 

flow transactions send ./cadence/transactions/setupAccount.cdc 
flow transactions send ./cadence/transactions/transferArleeScene.cdc f8d6e0586b0a20c7 0

# Float
flow transactions send ./cadence/transactions/float/setup_account.cdc

#  forHost: Address, 
#  claimable: Bool, 
#  name: String, 
#  description: String, 
#  image: String, 
#  url: String, 
#  transferrable: Bool, 
#  timelock: Bool, 
#  dateStart: UFix64, 
#  timePeriod: UFix64, 
#  secret: Bool, 
#  secretPK: String, 
#  limited: Bool, 
#  capacity: UInt64, 
#  initialGroups: [String], 
#  flowTokenPurchase: Bool, 
#  flowTokenCost: UFix64
flow transactions send ./cadence/transactions/float/create_event.cdc f8d6e0586b0a20c7 true TestName TestDescription "http://image.url" "https://test.url/" true false 1230000.0 1000.0 false "z" true 100 \[\] true 100.0

#    Type	A.f8d6e0586b0a20c7.FLOAT.FLOATEventCreated
#    Tx ID	889f982db6f3a7893306f7239290cffaa37b3f09ca856042d1ad3ea8b23bf426
#    Values
#		- eventId (UInt64): 42
#		- description (String): "TestDescription"
#		- host (Address): 0xf8d6e0586b0a20c7
#		- image (String): "http://image.url"
#		- name (String): "TestName"
#		- url (String): "https://test.url/"


# event, host, secret
flow transactions send ./cadence/transactions/float/claim.cdc 49 f8d6e0586b0a20c7 "1"

flow transactions send ./cadence/transactions/float/claim.cdc 49 f8d6e0586b0a20c7 "2" --signer emulator-user-account1


flow scripts execute ./cadence/scripts/float/get_float_ids.cdc f8d6e0586b0a20c7
flow scripts execute ./cadence/scripts/float/get_float.cdc f8d6e0586b0a20c7 52

flow scripts execute ./cadence/scripts/float/get_float_ids.cdc 0x179b6b1cb6755e31
flow scripts execute ./cadence/scripts/float/get_float.cdc 0x179b6b1cb6755e31 58

# Result: 
#   A.f8d6e0586b0a20c7.FLOAT.FLOATEvent(
#       uuid: 42, 
#       claimable: true, 
#       claimed: {0xf8d6e0586b0a20c7: A.f8d6e0586b0a20c7.FLOAT.TokenIdentifier(id: 45, address: 0xf8d6e0586b0a20c7, serial: 0)}, 
#       currentHolders: {0: A.f8d6e0586b0a20c7.FLOAT.TokenIdentifier(id: 45, address: 0xf8d6e0586b0a20c7, serial: 0)}, 
#       dateCreated: 1657155753.00000000, description: "TestDescription", eventId: 42, 
#       extraMetadata: 
#           {"prices": {"A.0ae53cb6e3f42a79.FlowToken.Vault": A.f8d6e0586b0a20c7.FLOAT.TokenInfo(path: /public/flowTokenReceiver, price: 100.00000000)}}, 
#       groups: {}, 
#       host: 0xf8d6e0586b0a20c7, 
#       image: "http://image.url", 
#       name: "TestName", 
#       totalSupply: 1, 
#       transferrable: true, 
#       url: "https://test.url/", 
#       verifiers: {"A.f8d6e0586b0a20c7.FLOATVerifiers.Limited": [A.f8d6e0586b0a20c7.FLOATVerifiers.Limited(capacity: 100)]})

flow transactions send ./cadence/transactions/EggFloat/registerEvent.cdc 49 "My Eggy Arlee" {}

flow transactions send ./cadence/transactions/EggFloat/claim.cdc 52
flow transactions send ./cadence/transactions/EggFloat/claim.cdc 58 --signer emulator-user-account1

flow scripts execute ./cadence/scripts/ArleeScene/getUserArleeSceneNFTs.cdc 0x179b6b1cb6755e31
