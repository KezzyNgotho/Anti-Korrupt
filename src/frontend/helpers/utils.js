import { Actor, HttpAgent } from "@dfinity/agent";
import { createActor, idlFactory } from "../../declarations/backend";

export const BACKEND_CANISTER_ID = process.env.BACKEND_CANISTER_ID;

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
