"""Uploads knowledgebase canister wasm

Run with:

    python -m scripts.upload_knowledgebase_canister.py
"""

# pylint: disable=invalid-name, too-few-public-methods, no-member, too-many-statements

import sys
from pathlib import Path
from typing import Generator
from .ic_py_canister import get_canister
from .parse_args_upload import parse_args
from ic.principal import Principal

ROOT_PATH = Path(__file__).parent.parent.parent.parent

#  0 - none
#  1 - minimal
#  2 - a lot
DEBUG_VERBOSE = 1


def main() -> int:
    """Uploads the knowledgebase canister wasm."""

    args = parse_args()

    network = args.network
    canister_id = args.canister_id
    candid_path = ROOT_PATH / args.candid
    dfx_json_path = ROOT_PATH / "dfx.json"

    print(
        f"Summary:"
        f"\n - network         = {network}"
        f"\n - canister_id     = {canister_id}"
        f"\n - dfx_json_path   = {dfx_json_path}"
        f"\n - candid_path     = {candid_path}"
    )

    # ---------------------------------------------------------------------------
    # get ic-py based Canister instance
    arcmind = get_canister("", candid_path, network, canister_id)

    print("--\nCreating canister")

    
    response = arcmind.add({
      "content": "test",
      "embeddings": [encode([{ 'type': Types.Float32, 'value': -0.007229743991047144 }])]
    })
    print("Response:")
    print(response)

    # ---------------------------------------------------------------------------
    return 0


if __name__ == "__main__":
    sys.exit(main())
