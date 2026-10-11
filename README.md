# Arlequin Cadence contracts

Cadence contracts, transactions and scripts for Arlequin, deployed with the [Flow CLI](https://developers.flow.com/tools/flow-cli).

## Account keys

`flow.json` does not store private keys for non-emulator accounts. The `testnet-account` key is read from the `TESTNET_PRIVATE_KEY` environment variable (`"privateKey": "$TESTNET_PRIVATE_KEY"`).

The Flow CLI resolves every account when it loads `flow.json`, so `TESTNET_PRIVATE_KEY` must be set for any `flow` command run in this project, including emulator commands. For emulator-only work you can set it to any `ECDSA_secp256k1` key, for example a fresh one from `flow keys generate --sig-algo ECDSA_secp256k1`.

### Deploying to testnet

1. Copy the example file and fill in the hex-encoded private key of `testnet-account` (`0xe7fd8b1148e021b2`). It must be an `ECDSA_secp256k1` / `SHA3_256` key at index 0 on that account, as declared in `flow.json`.

   ```sh
   cp .env.example .env
   ```

2. Export the variables into your shell and deploy:

   ```sh
   set -a; . ./.env; set +a
   flow project deploy --network testnet --update
   ```

   You can also skip `.env` and run `export TESTNET_PRIVATE_KEY=...` directly. In CI, provide `TESTNET_PRIVATE_KEY` as a secret environment variable.

`.env` and `*.pkey` / `*.key` files are git-ignored. Never commit a private key.
