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


# ------------------------------------------------------------------------------
def read_file_bytes(file_path: Path) -> bytes:
    """Returns the file as a bytes array"""
    file_bytes = b""
    try:
        with open(file_path, "rb") as file:
            file_bytes = file.read()

    except FileNotFoundError:
        print(f"ERROR: Unable to open the file {file_path}!")
        sys.exit(1)

    return file_bytes




def main() -> int:
    """Uploads the knowledgebase canister wasm."""

    args = parse_args()

    network = args.network
    canister_name = args.canister
    canister_id = args.canister_id
    candid_path = ROOT_PATH / args.candid
    dfx_json_path = ROOT_PATH / "dfx.json"

    print(
        f"Summary:"
        f"\n - network         = {network}"
        f"\n - canister        = {canister_name}"
        f"\n - canister_id     = {canister_id}"
        f"\n - dfx_json_path   = {dfx_json_path}"
        f"\n - candid_path     = {candid_path}"
    )

    # ---------------------------------------------------------------------------
    # get ic-py based Canister instance
    canister_creator = get_canister(canister_name, candid_path, network, canister_id)

    print("--\nCreating canister")

    response = canister_creator.createCanister({
      "canisterType": { "Knowledgebase": None },
      "owner": Principal.from_str("kldbt-2s57r-o3g7f-26yxa-2yyqv-uzmp7-bhuxq-o2zda-kvebw-y4ljs-vae")
    })  # pylint: disable=no-member
    if "Ok" in response[0].keys():
        print(response)
    else:
        print("Something went wrong:")
        print(response)
        sys.exit(1)

    # ---------------------------------------------------------------------------
    return 0


if __name__ == "__main__":
    sys.exit(main())
