import { IcrcLedgerCanister, IcrcMetadataResponseEntries } from "@dfinity/ledger-icrc";
import { createAgent } from "@dfinity/utils";
import { createClient } from "./auth";
import { createBackend } from "./utils";
import { HOST } from "../store";
import { Principal } from "@dfinity/principal";

export const M_SYMBOL = IcrcMetadataResponseEntries.SYMBOL;
export const M_NAME = IcrcMetadataResponseEntries.NAME;
export const M_DECIMALS = IcrcMetadataResponseEntries.DECIMALS;

/**
 * Create an ICRC ledger canister
 */
export async function createLedgerCanister() {
  const client = await createClient();

  if (!client.isAuthenticated()) {
    throw new Error("User not authenticated");
  }

  const backend = await createBackend();
  const MY_LEDGER_CANISTER_ID = await backend.get_icrc1_token_canister_id();

  const agent = await createAgent({
    identity: client.getIdentity(),
    host: HOST,
    fetchRootKey: true,
  });

  return IcrcLedgerCanister.create({
    agent,
    canisterId: Principal.fromText(MY_LEDGER_CANISTER_ID),
  });
}
