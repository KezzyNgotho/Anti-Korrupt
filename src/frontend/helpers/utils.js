import { Actor, HttpAgent } from "@dfinity/agent";
import { createActor, idlFactory } from "../../declarations/backend";
import { createActor as createNftActor } from "../../declarations/knowledge_found_nft";

export const BACKEND_CANISTER_ID = process.env.BACKEND_CANISTER_ID;
export const CANISTER_ID_KNOWLEDGE_FOUND_NFT = process.env.CANISTER_ID_KNOWLEDGE_FOUND_NFT;

export function errorToText(variant) {
  if (typeof variant === "string") {
    return variant;
  }
  if ("Unauthorized" in variant) {
    return "You are not authorized to perform this action.";
  }
  if ("InvalidTokenId" in variant) {
    return "Invalid token ID.";
  }
  if ("ZeroAddress" in variant) {
    return "Zero address.";
  }
  const keys = Object.keys(variant);
  if (keys.length !== 0) {
    const val = variant[keys[0]];
    if (val) {
      return val;
    }
    return keys[0];
  }
  return "Unknown error.";
}

export const IsDev = process.env.NODE_ENV !== "production";

export function getHost() {
  return IsDev ? "http://127.0.0.1:4943" : "https://icp-api.io";
}

export async function createBackend() {
  return createActor(BACKEND_CANISTER_ID, {
    agentOptions: {
      host: getHost(),
    },
  });
}

export async function initializeBackend() {
  try {
    const agent = await HttpAgent.create({
      host: getHost(),
    });

    // Fetch root key only in development or local environments
    if (IsDev) {
      await agent.fetchRootKey();
    }

    // Initialize the Actor for the backend canister
    const backend = Actor.createActor(idlFactory, {
      agent,
      canisterId: process.env.CANISTER_ID_BACKEND, // Replace with your actual canister ID
    });

    console.log("Backend initialized successfully.");

    return backend;
  } catch (error) {
    console.error("Error initializing backend:", error);
  }
}


export async function createKnowledgeFoundNft() {
	if (!CANISTER_ID_KNOWLEDGE_FOUND_NFT) {
		throw new Error('Knowledge Found NFT canister ID is not defined.');
	}
	return createNftActor(CANISTER_ID_KNOWLEDGE_FOUND_NFT, {
		agentOptions: {
			host: getHost()
		}
	});
}

/**
 * @param {any[][]} data
 */
export function convertArrayToObjects(data) {
	// Handle empty or invalid input
	if (!Array.isArray(data) || data.length === 0) {
		return null;
	}

	// Process each credential in the array
	const credentialObj = {};

	// Process each field in the credential
	data[0].forEach((field) => {
		const [key, value] = field;

		// Handle special case for meta field which contains a Map
		if (key === 'meta' && value.Map) {
			// @ts-ignore
			credentialObj[key] = {};
			// @ts-ignore
			value.Map.forEach(([metaKey, metaValue]) => {
				// @ts-ignore
				credentialObj[key][metaKey] = extractValue(metaValue);
			});
		} else {
			// @ts-ignore
			credentialObj[key] = extractValue(value);
		}
	});

	return credentialObj;
}

// Helper function to extract the actual value from the data structure
/**
 * @param {any} value
 */
export function extractValue(value) {
	if (value.Text) return value.Text;
	if (value.Blob) return value.Blob;
	if (value.Int) return value.Int;
	if (value.Nat) return value.Nat;
	if (value.Float) return value.Float;
	return value;
}
