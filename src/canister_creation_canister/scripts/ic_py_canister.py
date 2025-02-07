"""Returns the ic-py Canister instance, for calling the endpoints."""

import getpass
import os
import sys
import platform
import pexpect
import subprocess
from pathlib import Path
from typing import Optional
from ic.canister import Canister  # type: ignore
from ic.client import Client  # type: ignore
from ic.identity import Identity  # type: ignore
from ic.agent import Agent  # type: ignore
from icpp.run_shell_cmd import run_shell_cmd

ROOT_PATH = Path(__file__).parent.parent

# We use dfx to get some information.
# On Windows, dfx must be installed in wsl.
DFX = "dfx"
RUN_IN_POWERSHELL = False
if platform.win32_ver()[0]:
    DFX = "wsl --% dfx"
    RUN_IN_POWERSHELL = True


def run_dfx_command(cmd: str, requires_password: bool = False) -> Optional[str]:
    """
    Runs dfx command as a subprocess with support for interactive password input using pexpect
    
    Args:
        cmd: The dfx command to run
        requires_password: Whether the command requires password input
    
    Returns:
        The command output if successful, None otherwise
    """
    try:
        if requires_password:
            # Create the process with pexpect
            child = pexpect.spawn(cmd, encoding='utf-8')
            
            # Wait for password prompt
            index = child.expect(['Please enter the passphrase for your identity:', pexpect.EOF, pexpect.TIMEOUT], timeout=30)
            
            if index == 0:  # Password prompt received
                # Get password from environment variable or prompt user
                password = os.environ.get('DFX_IDENTITY_PASSWORD')
                if not password:
                    # Use raw_input instead of getpass since we're already managing the prompt
                    from getpass import getpass
                    password = getpass("Enter password: ")
                
                child.sendline(password)
                
                # Wait for command to complete
                index = child.expect(['-----END EC PRIVATE KEY-----', pexpect.EOF, pexpect.TIMEOUT], timeout=30)
                output = child.before
                
                if index != 0:
                    print(f"Failed dfx command: '{cmd}' with error: \n{output}")
                    sys.exit(1)
                    
                return output.strip()
            else:
                print(f"Failed to get password prompt. Command output: {child.before}")
                sys.exit(1)
        else:
            # Use original implementation for non-password commands
            return run_shell_cmd(
                cmd,
                capture_output=True,
                run_in_powershell=RUN_IN_POWERSHELL,
            ).rstrip("\n")
            
    except Exception as e:
        print(f"Failed dfx command: '{cmd}' with error: \n{str(e)}")
        sys.exit(1)
    return None

def get_canister(
    canister_name: str,
    candid_path: Path,
    network: str = "local",
    canister_id: Optional[str] = "",
) -> Canister:
    """Returns an ic_py Canister instance"""

    # Check if the network is up
    print(f"--\nChecking if the {network} network is up...")
    run_dfx_command(f"{DFX} ping {network} ")
    print("Ok!")

    # Set the network URL
    if network == "local":
        replica_port = run_dfx_command(f"{DFX} info replica-port  ")
        replica_rev = run_dfx_command(f"{DFX} info replica-rev  ")
        webserver_port = run_dfx_command(f"{DFX} info webserver-port  ")
        networks_json_path = run_dfx_command(f"{DFX} info networks-json-path  ")
        print(f"replica-port       = {replica_port}")
        print(f"replica-rev        = {replica_rev}")
        print(f"webserver-port     = {webserver_port}")
        print(f"networks-json-path = {networks_json_path}")

        network_url = f"http://localhost:{replica_port}"
    else:
        # https://smartcontracts.org/docs/interface-spec/index.html#http-interface
        network_url = "https://ic0.app"

    print(f"Network URL        = {network_url}")

    # Get the name of the current identity
    identity_whoami = run_dfx_command(f"{DFX} identity whoami ")
    print(f"Using identity = {identity_whoami}")

    # Try to get the id of the canister if not provided explicitly
    # This only works from the same directory as where you deployed from.
    # So we also provide the option to just pass in the canister_id directly
    if canister_id == "":
        canister_id = run_dfx_command(
            f"{DFX} canister --network {network} id {canister_name} "
        )
    print(f"Canister ID = {canister_id}")

    # Get the private key of the current identity
    private_key = run_dfx_command(f"{DFX} identity export {identity_whoami} ", requires_password=True)

    # Create an Identity instance using the private key
    identity = Identity.from_pem(private_key)

    # Create an HTTP client instance for making HTTPS calls to the IC
    # https://smartcontracts.org/docs/interface-spec/index.html#http-interface
    client = Client(url=network_url)

    # Create an IC agent to communicate with IC canisters
    agent = Agent(identity, client)

    # Read canister's candid from file
    with open(
        candid_path,
        "r",
        encoding="utf-8",
    ) as f:
        canister_did = f.read()

    # Create a Canister instance
    return Canister(agent=agent, canister_id=canister_id, candid=canister_did)
