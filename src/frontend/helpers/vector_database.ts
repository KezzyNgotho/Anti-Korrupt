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
  try {
    const courseKnowledgebaseCanister =
      await store.getActorForCourseKnowledgebaseCanister(courseId);
    let searchResponse = await courseKnowledgebaseCanister.search(
      { Embeddings: embeddingResult },
      BigInt(1),
    );
    if (searchResponse.length > 0) {
      if (searchResponse[0] && searchResponse[0].length > 0) {
        return searchResponse[0][0].content;
      }
    }
    return false;
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
  }
  const start = performance.now() / 1000;

  try {
    const existingDataEntries = await getDataEntries(pathToPdf);
    const textsToEmbed = existingDataEntries.map((dataEntry) =>
      JSON.stringify(dataEntry),
    );
    let promises = [];
    for (const text of textsToEmbed) {
      // Generate embeddings and then push each backend actor call to the promises array
      promises.push(embedAndAddChunk(text, embeddingsModel, courseId));
    }

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
  const courseKnowledgebaseCanister =
  await store.getActorForCourseKnowledgebaseCanister(courseId);
  // Generate embeddings for a chunk of text
  return embeddingsModel.embedQuery(text).then((embeddingResult) => {
    // and add the chunk to the vector database
    return courseKnowledgebaseCanister.add({
      content: text,
      embeddings: embeddingResult,
    });
  });
};
