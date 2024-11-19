import { writable } from "svelte/store";
import type { Principal } from "@dfinity/principal";
import type { HttpAgent, Identity } from "@dfinity/agent";
import { StoicIdentity } from "ic-stoic-identity";
import { AuthClient } from "@dfinity/auth-client";
import {
  backend,
  createActor as createBackendCanisterActor,
  idlFactory as backendIdlFactory,
} from "../declarations/backend";
import { createBackendActor, getIdentityProvider } from "./helpers/auth";
import { BACKEND_CANISTER_ID, getHost } from "./helpers/utils";

export const HOST = getHost();

let authClient : AuthClient;

const days = BigInt(30);
const hours = BigInt(24);
const nanosecondsPerHour = BigInt(3600000000000);

export type State = {
  isAuthed: "plug" | "stoic" | "nfid" | "internetidentity" | null;
  userId: string | null;
  backendActor: typeof backend;
  principal: Principal;
  accountId: string;
  error: string;
  isLoading: boolean;
};

const defaultState: State = {
  isAuthed: null,
  userId: localStorage.getItem("globalState") ? JSON.parse(localStorage.getItem("globalState")).userId : null,
  backendActor: createBackendCanisterActor(BACKEND_CANISTER_ID, {
    agentOptions: { host: HOST },
  }),
  principal: null,
  accountId: "",
  error: "",
  isLoading: false,
};

export const createStore = ({
  whitelist,
  host,
}: {
  whitelist?: string[];
  host?: string;
}) => {
  const { subscribe, update } = writable<State>(defaultState);
  let globalState: State;

  subscribe((value) => {
    globalState = value;
    localStorage.setItem("globalState", JSON.stringify({
      isAuthed: value.isAuthed,
      userId: value.userId,
      accountId: value.accountId,
    }));
  });

  const setUserId = async (fullname: string) => {
    const { backendActor } = globalState;
    const response = (await backendActor.loginOrRegiser(fullname)) as any;
    if (response.err) {
      return response.err;
    }
    update((state) => ({
      ...state,
      userId: response.ok,
    }));
  }

  const initUserSettings = async (backendActor) => {};

  const nfidConnect = async () => {
    const APPLICATION_NAME = "Anti-Korrupt";
    const APPLICATION_LOGO_URL = "https://vdfyi-uaaaa-aaaai-acptq-cai.ic0.app/favicon.ico"; //TODO: change
    const AUTH_PATH = "/authenticate/?applicationName="+APPLICATION_NAME+"&applicationLogo="+APPLICATION_LOGO_URL+"#authorize";

    authClient = await AuthClient.create();
    if (await authClient.isAuthenticated()) {
      const identity = await authClient.getIdentity();
      initNfid(identity);
    } else {
      await authClient.login({
        onSuccess: async () => {
          const identity = await authClient.getIdentity();
          initNfid(identity);
        },
        identityProvider: "https://nfid.one" + AUTH_PATH,
          /* process.env.DFX_NETWORK === "ic"
            ? "https://nfid.one" + AUTH_PATH
            : process.env.LOCAL_NFID_CANISTER + AUTH_PATH, */
        // Maximum authorization expiration is 30 days
        maxTimeToLive: days * hours * nanosecondsPerHour,
        windowOpenerFeatures:
          `left=${window.screen.width / 2 - 525 / 2}, `+
          `top=${window.screen.height / 2 - 705 / 2},` +
          `toolbar=0,location=0,menubar=0,width=525,height=705`,
        // See https://docs.nfid.one/multiple-domains
        // for instructions on how to use derivationOrigin
        // derivationOrigin: "https://<canister_id>.ic0.app"
      });
    };
  };

  const initNfid = async (identity: Identity) => {
    const backendActor = createBackendCanisterActor(BACKEND_CANISTER_ID, {
      agentOptions: {
        identity,
        host: HOST,
      },
    });

    if (!backendActor) {
      console.warn("couldn't create backend actor");
      return;
    };

    await initUserSettings(backendActor);

    localStorage.setItem('isAuthed', "nfid"); // Set flag to indicate existing login for future sessions

    update((state) => ({
      ...state,
      backendActor,
      principal: identity.getPrincipal(),
      accountId: null,
      isAuthed: "nfid",
    }));

    console.log("nfid is authed");
  };

  const internetIdentityConnect = async () => {
    authClient = await AuthClient.create();
    if (await authClient.isAuthenticated()) {
      const identity = authClient.getIdentity();
      initInternetIdentity(identity);
    } else {
      await authClient.login({
        onSuccess: async () => {
          const identity = authClient.getIdentity();
          initInternetIdentity(identity);
        },
        identityProvider: getIdentityProvider(),
        // Maximum authorization expiration is 30 days
        maxTimeToLive: days * hours * nanosecondsPerHour,
        windowOpenerFeatures:
          `left=${window.screen.width / 2 - 525 / 2}, ` +
          `top=${window.screen.height / 2 - 705 / 2},` +
          `toolbar=0,location=0,menubar=0,width=525,height=705`,
      });
    };
  };

  const initInternetIdentity = async (identity: Identity) => {
    console.log("identity: ", identity.getPrincipal().toText());
    const backendActor = await createBackendActor(identity);

    if (!backendActor) {
      console.warn("couldn't create backend actor");
      return;
    };

    if (globalState.userId) {
      const res = await backendActor.connectUserToPrincipal(globalState.userId);
      console.log("connectUserToPrincipal: ", res);
    }

    localStorage.setItem('isAuthed', "internetidentity"); // Set flag to indicate existing login for future sessions

    update((state) => ({
      ...state,
      backendActor,
      principal: identity.getPrincipal(),
      accountId: null,
      isAuthed: "internetidentity",
    }));

    console.log("internetidentity is authed");
  };

  const stoicConnect = () => {
    StoicIdentity.load().then(async (identity) => {
      if (identity !== false) {
        // ID is a already connected wallet!
      } else {
        // No existing connection, lets make one!
        identity = await StoicIdentity.connect();
      }
      initStoic(identity);
    });
  };

  const initStoic = async (identity: Identity & { accounts(): string }) => {
    const backendActor = createBackendCanisterActor(BACKEND_CANISTER_ID, {
      agentOptions: {
        identity,
        host: HOST,
      },
    });

    if (!backendActor) {
      console.warn("couldn't create backend actor");
      return;
    };

    await initUserSettings(backendActor);

    // the stoic agent provides an `accounts()` method that returns accounts associated with the principal
    let accounts = JSON.parse(await identity.accounts());

    localStorage.setItem('isAuthed', "stoic"); // Set flag to indicate existing login for future sessions

    update((state) => ({
      ...state,
      backendActor,
      principal: identity.getPrincipal(),
      accountId: accounts[0].address, // we take the default account associated with the identity
      isAuthed: "stoic",
    }));

    console.log("stoic is authed");
  };

  const plugConnect = async () => {
    // check if plug is installed in the browser
    if (window.ic?.plug === undefined) {
      window.open("https://plugwallet.ooo/", "_blank");
      return;
    };

    // check if plug is connected
    const plugConnected = await window.ic?.plug?.isConnected();
    if (!plugConnected) {
      try {
        console.log({
          whitelist,
          host,
        });
        await window.ic?.plug.requestConnect({
          whitelist,
          host,
        });
        console.log("plug connected");
      } catch (e) {
        console.warn(e);
        return;
      };
    };

    await initPlug();
  };

  const initPlug = async () => {
    // check whether agent is present
    // if not create it
    if (!window.ic?.plug?.agent) {
      console.warn("no agent found");
      const result = await window.ic?.plug?.createAgent({
        whitelist,
        host,
      });
      result
        ? console.log("agent created")
        : console.warn("agent creation failed");
    };
    // check if createActor method is available
    if (!window.ic?.plug?.createActor) {
      console.warn("no createActor found");
      return;
    }

    // Fetch root key for certificate validation during development
    if (process.env.DFX_NETWORK !== "ic") {
      window.ic.plug.agent.fetchRootKey().catch((err) => {
        console.warn(
          "Unable to fetch root key. Check to ensure that your local replica is running",
        );
        console.error(err);
      });
    };

    const backendActor = (await window.ic?.plug.createActor({
      canisterId: BACKEND_CANISTER_ID,
      interfaceFactory: backendIdlFactory,
    })) as typeof backend;

    if (!backendActor) {
      console.warn("couldn't create backend actor");
      return;
    };

    await initUserSettings(backendActor);

    const principal = await window.ic.plug.agent.getPrincipal();

    localStorage.setItem('isAuthed', "plug"); // Set flag to indicate existing login for future sessions

    update((state) => ({
      ...state,
      backendActor,
      principal,
      accountId: window.ic.plug.sessionManager.sessionData.accountId,
      isAuthed: "plug",
    }));

    console.log("plug is authed");
  };

  const disconnect = async () => {
    // Check isAuthed to determine which method to use to disconnect
    if (globalState.isAuthed === "plug") {
      try {
        await window.ic?.plug?.disconnect();
        // wait for 500ms to ensure that the disconnection is complete
        await new Promise((resolve) => setTimeout(resolve, 500));
        const plugConnected = await window.ic?.plug?.isConnected();
        if (plugConnected) {
          console.log("plug disconnect failed, trying once more");
          await window.ic?.plug?.disconnect();
        };
      } catch (error) {
        console.error("Plug disconnect error: ", error);
      };
    } else if (globalState.isAuthed === "stoic") {
      try {
        StoicIdentity.disconnect();
      } catch (error) {
        console.error("StoicIdentity disconnect error: ", error);
      };
    } else if (globalState.isAuthed === "nfid") {
      try {
        await authClient.logout();
      } catch (error) {
        console.error("NFid disconnect error: ", error);
      };
    } else if (globalState.isAuthed === "internetidentity") {
      try {
        await authClient.logout();
      } catch (error) {
        console.error("Internet Identity disconnect error: ", error);
      };
    }

    clearState();
  };

  const clearState = () => {
    update(() => {
      return {
        ...defaultState,
        userId: undefined,
      };
    }
  )}

  const checkExistingLoginAndConnect = async () => {
    // Check login state if user is already logged in
    const isAuthed = localStorage.getItem('isAuthed'); // Accessing Local Storage to check login state
    if (isAuthed) {
      const authClient = await AuthClient.create();
      if (await authClient.isAuthenticated()) {
        if (isAuthed === "nfid") {
          console.log("NFID connection detected");
          nfidConnect();
        } else if (isAuthed === "internetidentity") {
          console.log("Internet Identity connection detected");
          internetIdentityConnect();
        } else if (isAuthed === "plug") {
          console.log("Plug connection detected");
          plugConnect();
        } else if (isAuthed === "stoic") {
          console.log("Stoic connection detected");
          stoicConnect();
        };
      };
    };
  };

  return {
    setUserId,
    subscribe,
    update,
    plugConnect,
    stoicConnect,
    nfidConnect,
    internetIdentityConnect,
    disconnect,
    checkExistingLoginAndConnect,
    clearState,
  };
};

export const store = createStore({
  whitelist: [BACKEND_CANISTER_ID],
  host: HOST,
});

declare global {
  interface Window {
    ic: {
      plug: {
        agent: HttpAgent;
        sessionManager: {
          sessionData: {
            accountId: string;
          };
        };
        getPrincipal: () => Promise<Principal>;
        deleteAgent: () => void;
        requestConnect: (options?: {
          whitelist?: string[];
          host?: string;
        }) => Promise<any>;
        createActor: (options: {}) => Promise<typeof backend>;
        isConnected: () => Promise<boolean>;
        disconnect: () => Promise<boolean>;
        createAgent: (args?: {
          whitelist: string[];
          host?: string;
        }) => Promise<undefined>;
        requestBalance: () => Promise<
          Array<{
            amount: number;
            canisterId: string | null;
            image: string;
            name: string;
            symbol: string;
            value: number | null;
          }>
        >;
        requestTransfer: (arg: {
          to: string;
          amount: number;
          opts?: {
            fee?: number;
            memo?: string;
            from_subaccount?: number;
            created_at_time?: {
              timestamp_nanos: number;
            };
          };
        }) => Promise<{ height: number }>;
      };
      infinityWallet: {
        getPrincipal: () => Promise<Principal>;
        requestConnect: (options?: {
          whitelist?: string[];
          //host?: string;
        }) => Promise<any>;
        createActor: (options: {
          canisterId: string;
          interfaceFactory: any;
          host?: string;
        }) => Promise<typeof backend>;
        isConnected: () => Promise<boolean>;
        getUserAssets: () => Promise<any>;
        batchTransactions: () => Promise<any>;
      };
    };
  }
}
