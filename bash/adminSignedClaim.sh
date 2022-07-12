# ./adminSignedClaim.sh 58 emulator-user-account1

flow transactions build ./cadence/transactions/EggFloat/claim.cdc $1 --authorizer "$2","emulator-account" --filter payload --save claim.rlp -y 
flow transactions sign claim.rlp --signer "$2"                                          --include payload --filter payload --save claim.rlp -y
flow transactions sign claim.rlp --signer "emulator-account"                            --include payload --filter payload --save claim.rlp -y
flow transactions send-signed                                                                                                     claim.rlp -y
