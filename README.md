# Anti-Korrupt

Anti-Korrupt is live on the Internet Computer.

If you like, you can give it a try [here](https://px7id-byaaa-aaaak-albiq-cai.icp0.io/).

[Backend Canister](https://a4gq6-oaaaa-aaaab-qaa4q-cai.raw.icp0.io/?id=pq6ox-maaaa-aaaak-albia-cai)

Checkout the [design](https://miro.com/app/board/uXjVLfeaOGQ=/?share_link_id=752667331634) for the project on Miro.

## About

Anti-Korrupt is an AI-driven educational platform designed to increase global awareness about corruption. The platform offers interactive courses powered by blockchain technology, helping users understand corruption’s impact through AI-assisted learning modules and quizzes. Target users include students, educators, anti-corruption advocates, government employees, and the general public interested in governance and transparency.

## Key Features

- **Decentralized**: Operates directly within internet computer. Users can choose if they want to log in with a name or their internet identity. Their chats are stored on the decentralized cloud and under their control.
- **Fast**: Built on Internet Computer communicating with OpenAI using HTTPS Outcalls. Faster than Web LLMs and support any kinds of devices.
- **Personalized**: Users engage in meaningful conversations and ask questions, all while ensuring their privacy.
- **Private**: Users engagement with each course assistant is private to the user. No chat will mix up with another. This is because a new thread is created for each user enrolling for each course, separating thread messages.
- **Prompt Tutor**: Users are taught and don't just need to prompt the course assistant every time.
- **Incentivised Learning**: Users earn ACT tokens when they complete courses by taking course quizzes.

## 🚧 Milestones and Progress

- [x] User Authentication System
- [x] Course Management System
- [x] Role Based Access for staff
- [x] User Course Enrollment and Progress Tracking
- [x] Course Chat Assistant
- [x] Assessment Engine & Token Rewards
- [x] Unit and E2E Tests for Core Features

## 🚧 Future plans

- [ ] Migrate AI model 100% to the IC

### How Anti-Korrupt Works

Anti-Korrupt comprises a frontend canister and a backend canister which integrates the OpenAI Assistant with chat history storage. Here's a glimpse of how Anti-Korrupt is structured:

#### Frontend Canister

The frontend canister serves the user interface, including HTML, CSS, and JavaScript files.

#### Offchain LLM

The AI model is pre-trained and stored off-chain. Using OpenAI's GPT-3 model, the AI can generate human-like text responses to user inputs. the canister interacts with this model using ICP HTTPS Outcalls.

#### Backend Canister

The backend canister enables users to persist their chats, if they choose to (Anti-Korrupt can be used without logging in). All of this is achieved in a decentralized manner through the Internet Computer, ensuring high availability and scalability.

## Internet Computer Resources

Anti-Korrupt is built and hosted on the Internet Computer. To learn more about it, see the following documentation available online:

- [Quick Start](https://sdk.dfinity.org/docs/quickstart/quickstart-intro.html)
- [SDK Developer Tools](https://sdk.dfinity.org/docs/developers-guide/sdk-guide.html)
- [Motoko Programming Language Guide](https://sdk.dfinity.org/docs/language-guide/motoko.html)
- [Motoko Language Quick Reference](https://sdk.dfinity.org/docs/language-guide/language-manual.html)
- [JavaScript API Reference](https://erxue-5aaaa-aaaab-qaagq-cai.raw.ic0.app)

## Running the project locally

If you want to run this project locally, you can use the following commands:

### Install dependencies

```bash
npm install
```

### Install mops

```bash
npm install -g ic-mops
```

### Start a local replica

```bash
dfx start --background
```

Note: this starts a local replica of the Internet Computer (IC) which includes the canisters state stored from previous sessions.
If you want to start a clean local IC replica (i.e. all canister state is erased) run instead:

```bash
dfx start --clean --background
```

### Setting up DFX deps

The project depends on internet identity as an optional dependency locally.

- Initialize the dependencies:

```bash
dfx deps init
```

- Install the dependencies:

```bash
dfx deps pull
```

- Deploy the dependencies:

```bash
dfx deps deploy
```

### Deploy the canisters locally

- Deploy the backend canister:

```bash
dfx deploy backend
```

- Deploy the token ledger:

```bash
# ./cli createToken <identity> icrc1_ledger_canister <ic|local>
# example
./cli createToken default icrc1_ledger_canister local
```

- Deploy the frontend canister:

Using the local replica:

```bash
dfx deploy DeVinci_frontend
```

Alternative: Run a local vite UI

```bash
npm run vite
```

### Helper CLI Canister Calls

A cli has been provided to interact with the canisters easily using the CLI. To use the cli, run the following command:

```bash
./cli
```

For example to list courses, run the following command:

```bash
./cli listCourses
```

### Seeding the backend canister

To seed the backend canister with some data, run the following command:

```bash
./seed.sh
```

### Running tests

There are unit tests for canister modules and actors.

#### Unit tests

To run the unit tests, use the following command:

```bash
mops test
```

#### Actor tests

First you need to have `ic-repl` installed. Learn more about [ic-repl](https://github.com/dfinity/ic-repl).

Go to the [releases page](https://github.com/dfinity/ic-repl/releases)

Download and install a version compatible with your machine.

Linux:

```bash
wget https://github.com/dfinity/ic-repl/releases/download/0.7.6/ic-repl-linux64

// move to /usr/bin
sudo mv ic-repl-linux64 /usr/bin/ic-repl
sudo chmod +x /usr/bin/ic-repl
```

To test the actor, use the following command:

```bash
ic-repl backend.test.sh -v
```

### Deployment to the Internet Computer mainnet

Deploy the code as canisters to the live IC where it's accessible via regular Web browsers.

```bash
dfx deploy backend --ic
dfx deploy DeVinci_frontend --ic
./cli createToken default icrc1_ledger_canister ic
```

## Credits

Serving this app and hosting the data securely and in a decentralized way is made possible by the [Internet Computer](https://internetcomputer.org/)

## Cycles for Production Canisters

Due to the IC's reverse gas model, developers charge their canisters with cycles to pay for any used computational resources. The following can help with managing these cycles.

[Fund wallet with cycles (from ICP)](https://medium.com/dfinity/internet-computer-basics-part-3-funding-a-cycles-wallet-a724efebd111)

### Top up cycles

```bash
dfx identity get-wallet --ic
dfx wallet balance --ic
dfx canister status backend --ic
dfx canister status DeVinci_frontend --ic
dfx canister deposit-cycles 3T backend --ic
dfx canister deposit-cycles 3T DeVinci_frontend --ic
```
