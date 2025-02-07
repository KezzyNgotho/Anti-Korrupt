// Adds the WebGL backend to the global backend registry.
import "@tensorflow/tfjs-backend-webgl";
import { TensorFlowEmbeddings } from "langchain/embeddings/tensorflow";

import {
  store,
} from "../store";

import { getResourceAsArray } from "./setup_knowledgebase";

const getDataEntries = async (pathToUploadedPdf) => {
  const dataEntries = [];
  // @ts-ignore
  const knowledgePages: [] = await getResourceAsArray(pathToUploadedPdf);
  for (let index = 0; index < knowledgePages.length; index++) {
    const dataEntry = {
      id: index,
      content: knowledgePages[index],
    };
    dataEntries.push(dataEntry);
  }
  return dataEntries;
};

let embeddingsModel = new TensorFlowEmbeddings();

export const searchCourseKnowledgebase = async (courseId: string, searchText: string) => {
  if (!embeddingsModel) {
    embeddingsModel = new TensorFlowEmbeddings();
  }

  const embeddingResult = await embeddingsModel.embedQuery(searchText);
  console.log("Embedding result", embeddingResult);
  console.log("Embedding result", embeddingResult.join(";"));
  try {
    const courseKnowledgebaseCanister =
      await store.getActorForCourseKnowledgebaseCanister(courseId);
    console.log("Course Knowledgebase Canister", courseKnowledgebaseCanister);
    let searchResponse = await courseKnowledgebaseCanister.search(
      { 'Embeddings': embeddingResult },
      BigInt(1),
    );
    console.log("searchResponse", searchResponse);
    if (searchResponse.length > 0) {
      if (searchResponse[0] && searchResponse[0].length > 0) {
        return searchResponse[0][0].content;
      }
    }
    return "";
  } catch (error) {
    console.error("Error in searchUserKnowledgebase: ", error);
  }
};

export const addPdfToCourseKnowledgebase = async (pathToPdf: string, courseId: string) => {
  if (!pathToPdf) {
    return;
  }
  if (!embeddingsModel) {
    embeddingsModel = new TensorFlowEmbeddings();
    console.log("Created embedding class")
  }
  const start = performance.now() / 1000;

  try {
    console.log("Getting data entries")
    const existingDataEntries = await getDataEntries(pathToPdf);
    console.log("Got data entries", existingDataEntries.length)
    const textsToEmbed = existingDataEntries.map((dataEntry) =>
      JSON.stringify(dataEntry),
    );
    let promises = [];
    for (const text of textsToEmbed) {
      // Generate embeddings and then push each backend actor call to the promises array
      promises.push(embedAndAddChunk(text, embeddingsModel, courseId));
    }

    console.log("Fullfilling embed and chunk promises");
    const results = await Promise.allSettled(promises);
    results.forEach((result) => {
      if (result.status === "fulfilled") {
        console.info("in addPdfToCourseKnowledgebase result ", result.value);
      } else {
        console.error("Failed to process: ", result.reason);
      }
    });
  } catch (error) {
    console.error("Error in addPdfToCourseKnowledgebase: ", error);
    return false;
  }

  const end = performance.now() / 1000;
  console.log(`Debug: generateEmbeddings took ${(end - start).toFixed(2)}s`);
  return true;
};

const embedAndAddChunk = async (text: string, embeddingsModel: TensorFlowEmbeddings, courseId: string) => {
  console.log("Getting course knowledge base canister")
  const courseKnowledgebaseCanister = await store.getActorForCourseKnowledgebaseCanister(courseId);
  console.log("Got course knowledge base canister", courseKnowledgebaseCanister)
  // Generate embeddings for a chunk of text
  return embeddingsModel.embedQuery(text).then((embeddingResult) => {
    // and add the chunk to the vector database
    return courseKnowledgebaseCanister.add({
      content: text,
      embeddings: embeddingResult,
    })
  });
};
