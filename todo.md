# To Do

1. Work on rag feature

A script should convert PDF files into vector embeddings and store in a ArcMind DB Vector canister

User enters message and we use a convert the text to a Vector query to make a query to the vector db to get similar vectors to add as context when sending message to OpenAI

The vector context should not be part of the message of the user stored in the canister

2. Work on NFT feature
Currently we give tokens for completing quizzes, it's time to change to giving NFTs instead

Create an NFT minting canister with authority given to the backend canister, the nft would be called Knowledge Found

When user passes a test, they are assigned an NFT with a unique ID, with metadata (course name, mark, date, user id)

User should be able to view their NFTs in the frontend UI (Badges section)

If a user has not connected their principal a claimable object should be stored in a vector array on the user object called claimables, which will be claimed when they connect their principal.

To claim a claimable the user should go to the UI, see a section where they can view their claimables and click a button to claim it.