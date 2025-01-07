# Canister Creation Canister

### Setup

Install mops (https://mops.one/docs/install)
Install motoko dependencies:

```bash
mops install
```

### Deploy

```bash
# Generate the bindings for the upload scripts and the frontend
dfx generate

# local
dfx deploy canister_creation_canister

# IC mainnet (caution!)
## development
dfx deploy --network development canister_creation_canister

## production
dfx deploy --ic canister_creation_canister

# Set DeVinci Backend as master canister (you have to deploy that canister first and then return with its id)
# local
dfx canister call canister_creation_canister setMasterCanisterId '("be2us-64aaa-aaaaa-qaabq-cai")'

# IC mainnet (caution!)
## development
dfx canister call --network development canister_creation_canister setMasterCanisterId '("sbflw-gyaaa-aaaal-qcbeq-cai")'

## production
dfx canister call --ic canister_creation_canister setMasterCanisterId '("xzpew-mqaaa-aaaai-acqza-cai")'

```

### Upload files

Setup python environment:

```
pip install -r requirements.txt
```

Run upload script - local:

```bash
# --------------------------------------------------------------------------
# IMPORTANT: ic-py might throw a timeout => patch it here:
# Ubuntu:
# /home/arjaan/miniconda3/envs/<your-env>/lib/python3.10/site-packages/httpx/_config.py
# Mac:
# /Users/arjaan/miniconda3/envs/<your-env>/lib/python3.10/site-packages/httpx/_config.py
# DEFAULT_TIMEOUT_CONFIG = Timeout(timeout=5.0)
DEFAULT_TIMEOUT_CONFIG = Timeout(timeout=99999999.0)
# And perhaps here:
# Ubuntu:
# /home/arjaan/miniconda3/envs/<your-env>/lib/python3.10/site-packages/httpcore/_backends/sync.py #L28-L29
# Mac:
# /Users/arjaan/miniconda3/envs/<your-env>/lib/python3.10/site-packages/httpcore/_backends/sync.py #L28-L29
#
class SyncStream(NetworkStream):
    def __init__(self, sock: socket.socket) -> None:
        self._sock = sock

    def read(self, max_bytes: int, timeout: typing.Optional[float] = None) -> bytes:
        exc_map: ExceptionMapping = {socket.timeout: ReadTimeout, OSError: ReadError}
        with map_exceptions(exc_map):
            # PATCH AB
            timeout = 999999999
            # ENDPATCH
            self._sock.settimeout(timeout)
            return self._sock.recv(max_bytes)
# ------------------------------------------------------------------------

# ========================================================================
# Upload the knowledgebase canister wasm
python3 -m scripts.upload_knowledgebase_canister --network local --canister canister_creation_canister --wasm files/arcmindvectordb.wasm --candid src/declarations/canister_creation_canister/canister_creation_canister.did
```

Run upload script - IC:

```bash
# To IC
## development
### Upload the knowledgebase canister wasm
python3 -m scripts.upload_knowledgebase_canister --network development --canister canister_creation_canister --wasm files/arcmindvectordb.wasm --candid src/declarations/canister_creation_canister/canister_creation_canister.did
### Upload the backend canister wasm
python3 -m scripts.upload_backend_canister --network development --canister canister_creation_canister --wasm files/DeVinci_backend.wasm --candid src/declarations/canister_creation_canister/canister_creation_canister.did

## production
### Upload the knowledgebase canister wasm
python3 -m scripts.upload_knowledgebase_canister --network ic --canister canister_creation_canister --wasm files/arcmindvectordb.wasm --candid src/declarations/canister_creation_canister/canister_creation_canister.did
### Upload the backend canister wasm
python3 -m scripts.upload_backend_canister --network ic --canister canister_creation_canister --wasm files/DeVinci_backend.wasm --candid src/declarations/canister_creation_canister/canister_creation_canister.did
```

### Test canister creation

```bash
dfx canister call canister_creation_canister whoami
dfx canister call canister_creation_canister amiController

# To test knowledgebase canister creation
dfx canister call canister_creation_canister testCreateKnowledgebaseCanister
# To test backend canister creation
dfx canister call canister_creation_canister testCreateBackendCanister

## Call endpoints on created knowledgebase canister
## Note: use newCanisterId printed by testCreateKnowledgebaseCanister
dfx canister call b77ix-eeaaa-aaaaa-qaada-cai size
dfx canister call b77ix-eeaaa-aaaaa-qaada-cai check_cycles_and_topup

Also see tests in arcmindvectordb/interact/

## Call endpoints on created backend canister
## Note: use newCanisterId printed by testCreateBackendCanister
dfx canister call by6od-j4aaa-aaaaa-qaadq-cai updateCanisterIsPrivate '(true)'
dfx canister call by6od-j4aaa-aaaaa-qaadq-cai setCanisterCreationCanisterId '("bkyz2-fmaaa-aaaaa-qaaaq-cai")'

# ----be carefull with these START ---
## In case the knowledgebase canister wasm has to be reset (use with caution):
dfx canister call canister_creation_canister reset_knowledgebase_canister_wasm

## Might come in handy during local testing
dfx ledger fabricate-cycles --canister canister_creation_canister
# ----be carefull with these END ---
```
