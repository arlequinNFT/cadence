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
flow transactions send "./cadence/transactions/Flow/mint.cdc" 1000.0 0x01cf0e2f2f715450
flow transactions send "./cadence/transactions/Flow/mint.cdc" 1000.0 0x179b6b1cb6755e31
flow transactions send "./cadence/transactions/Flow/mint.cdc" 1000.0 0xf3fcd2c1a78f5eee

flow project deploy --network emulator

flow transactions send ./cadence/transactions/float/setup_account.cdc

flow transactions send ./cadence/transactions/ArleeScene/setMintable.cdc true 

flow transactions send ./cadence/transactions/mintSceneNFT.cdc hiCID {} 

flow transactions send ./cadence/transactions/transferArleeScene.cdc f8d6e0586b0a20c7 0

# Float -> Egg tests

# Float
flow transactions send ./cadence/transactions/float/setup_account.cdc

echo "Creating Float Event"
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

echo "Users Claims their Float"
# event, host, secret
flow transactions send ./cadence/transactions/float/claim.cdc 49 0xf8d6e0586b0a20c7 "secret" --signer emulator-user-account1
flow transactions send ./cadence/transactions/float/claim.cdc 49 0xf8d6e0586b0a20c7 "secret" --signer emulator-user-account2

flow scripts execute ./cadence/scripts/float/get_float_ids.cdc 0x179b6b1cb6755e31
flow scripts execute ./cadence/scripts/float/get_float_ids.cdc 0xf3fcd2c1a78f5eee
flow scripts execute ./cadence/scripts/float/get_float.cdc 0x179b6b1cb6755e31 55
flow scripts execute ./cadence/scripts/float/get_float.cdc 0xf3fcd2c1a78f5eee 61

echo "Register FloatEvent -> Eggs"
# flow transactions send ./cadence/transactions/EggFloat/registerEvent_template.cdc 49
flow transactions send ./cadence/transactions/EggFloat/registerEvent.cdc 49 '["cid1","cid2","cid3"]' '[{"trait":"gnarly"},{"trait":"dope"},{"trait":"funky"}]' "[10,40,50]"

# Admin Co-signed (floatID, signer)
./bash/adminSignedClaim.sh 55 emulator-user-account1
./bash/adminSignedClaim.sh 61 emulator-user-account2

#flow transactions build ./cadence/transactions/EggFloat/claim.cdc 58 --authorizer "emulator-user-account1","emulator-account" --save claim.rlp -y --filter payload 
#flow transactions sign claim.rlp --signer "emulator-user-account1" --include payload --filter payload --save claim.rlp -y
#flow transactions sign claim.rlp --signer "emulator-account"       --include payload --filter payload --save claim.rlp -y
#flow transactions send-signed claim.rlp -y

flow scripts execute ./cadence/scripts/ArleeScene/getUserArleeSceneNFTs.cdc 0x179b6b1cb6755e31
flow scripts execute ./cadence/scripts/ArleeScene/getUserArleeSceneNFTs.cdc 0xf3fcd2c1a78f5eee


# Setup 2nd Float Event
flow transactions send ./cadence/transactions/float/create_event.cdc f8d6e0586b0a20c7 true SecondTestEvent SecondTestEvent "http://SecondTestEvent.url" "https://SecondTestEvent.url/" true false 1230000.0 1000.0 false "z" true 100 \[\] true 100.0
#66

# Claim the float
flow transactions send ./cadence/transactions/float/claim.cdc 66 f8d6e0586b0a20c7 "secret" --signer emulator-user-account1
# 69
flow transactions send ./cadence/transactions/float/claim.cdc 66 f8d6e0586b0a20c7 "secret" --signer emulator-user-account2
#72

# get metadata
flow scripts execute ./cadence/scripts/float/get_float.cdc 0x179b6b1cb6755e31 69
flow scripts execute ./cadence/scripts/float/get_float.cdc 0xf3fcd2c1a78f5eee 72

# try to claim float (not registered should fail)
flow transactions send ./cadence/transactions/EggFloat/claim.cdc 69 #insufficient signers
./bash/adminSignedClaim.sh 69 emulator-user-account1 
./bash/adminSignedClaim.sh 72 emulator-user-account2
# This egg is not an arlee egg float!

# flow transactions send ./cadence/transactions/EggFloat/registerEvent_template.cdc 66 
flow transactions send ./cadence/transactions/EggFloat/registerEvent.cdc 66 '["firstCID","secondCID","thirdCID"]'   '[{"rarity":"legendary"},{"rarity":"rare"},{"rarity":"common"}]' "[1,2,3]"


# Now can claim :)
./bash/adminSignedClaim.sh 69 emulator-user-account1
./bash/adminSignedClaim.sh 72 emulator-user-account2

# Check the arlees out
flow scripts execute ./cadence/scripts/ArleeScene/getUserArleeSceneNFTs.cdc 0x179b6b1cb6755e31
flow scripts execute ./cadence/scripts/ArleeScene/getUserArleeSceneNFTs.cdc 0xf3fcd2c1a78f5eee