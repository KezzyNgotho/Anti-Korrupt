import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type ApiError = { 'ZeroAddress' : null } |
  { 'NotFound' : string } |
  { 'InvalidTokenId' : null } |
  { 'Unauthorized' : null } |
  { 'Other' : string };
export type ApiError__1 = { 'ZeroAddress' : null } |
  { 'NotFound' : string } |
  { 'InvalidTokenId' : null } |
  { 'Unauthorized' : null } |
  { 'Other' : string };
export interface AuthRecord { 'auth' : string }
export type AuthRecordResult = { 'ok' : AuthRecord } |
  { 'err' : ApiError__1 };
export interface Backend {
  'addAcls' : ActorMethod<[Principal], undefined>,
  'addAclsText' : ActorMethod<[string], undefined>,
  'addQuestion' : ActorMethod<[string, Question], Result>,
  'changeApiKey' : ActorMethod<[string], Result_1>,
  'changeOwner' : ActorMethod<[string], Result_1>,
  'claimTokens' : ActorMethod<[string], Result>,
  'connectUserToPrincipal' : ActorMethod<[string], Result>,
  'createCourse' : ActorMethod<[string, string], Result>,
  'createResource' : ActorMethod<
    [string, string, string, ResourceType__1],
    Result
  >,
  'enrollCourse' : ActorMethod<[string, string], Result>,
  'generateQuestionsForCourse' : ActorMethod<[string], Result_2>,
  'generateRandomNumber' : ActorMethod<[bigint], bigint>,
  'getAcls' : ActorMethod<[], Array<Principal>>,
  'getCourseKnowledgebase' : ActorMethod<[string], Result_9>,
  'getCourseQuestions' : ActorMethod<[string], Result_5>,
  'getCourseResources' : ActorMethod<[string], Result_8>,
  'getOwner' : ActorMethod<[], Principal>,
  'getProfile' : ActorMethod<[string], Result_7>,
  'getRandomCourseQuestions' : ActorMethod<[string, bigint], Result_5>,
  'getRunMessage' : ActorMethod<[string, string], Result_6>,
  'getRunQuestions' : ActorMethod<[string], Result_5>,
  'getRunStatus' : ActorMethod<[string], Result_4>,
  'getRunsInQueue' : ActorMethod<[], Array<SharedThreadRun>>,
  'getUserEnrolledCourse' : ActorMethod<[string, string], Result_3>,
  'get_icrc1_token_canister_id' : ActorMethod<[], string>,
  'listCourses' : ActorMethod<[], Array<SharedCourse>>,
  'loginOrRegiser' : ActorMethod<[string], Result>,
  'removeAcls' : ActorMethod<[Principal], Result_1>,
  'removeQuestion' : ActorMethod<[string, string], Result_1>,
  'removeResource' : ActorMethod<[string, string], Result_1>,
  'sendMessage' : ActorMethod<[string, string, string, string], Result_2>,
  'setAssistantId' : ActorMethod<[string], Result_1>,
  'setCanisterCreationCanisterId' : ActorMethod<[string], AuthRecordResult>,
  'setRunProcess' : ActorMethod<[string, boolean], Result_1>,
  'set_icrc1_token_canister' : ActorMethod<[Principal], Result_1>,
  'submitQuestionsAttempt' : ActorMethod<
    [string, Array<SubmittedAnswer>, string],
    Result
  >,
  'transform' : ActorMethod<[TransformArgs], CanisterHttpResponsePayload>,
  'updateCourse' : ActorMethod<[string, string, string], Result>,
}
export interface CanisterHttpResponsePayload {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface CanisterInfo {
  'canisterType' : CanisterType,
  'creationTimestamp' : bigint,
  'canisterAddress' : string,
}
export type CanisterType = { 'Knowledgebase' : null };
export interface HttpHeader { 'value' : string, 'name' : string }
export interface HttpResponsePayload {
  'status' : bigint,
  'body' : Uint8Array | number[],
  'headers' : Array<HttpHeader>,
}
export interface Message {
  'content' : string,
  'role' : MessageType,
  'runId' : [] | [string],
}
export type MessageType = { 'System' : null } |
  { 'User' : null };
export interface Message__1 {
  'content' : string,
  'role' : MessageType,
  'runId' : [] | [string],
}
export interface Question {
  'id' : string,
  'correctOption' : bigint,
  'description' : string,
  'options' : Array<QuestionOption>,
}
export interface QuestionOption { 'option' : bigint, 'description' : string }
export interface Resource {
  'id' : string,
  'url' : string,
  'title' : string,
  'rType' : ResourceType,
}
export type ResourceType = { 'Book' : null } |
  { 'Article' : null } |
  { 'Slides' : null } |
  { 'Video' : null };
export type ResourceType__1 = { 'Book' : null } |
  { 'Article' : null } |
  { 'Slides' : null } |
  { 'Video' : null };
export type Result = { 'ok' : string } |
  { 'err' : ApiError };
export type Result_1 = { 'ok' : null } |
  { 'err' : ApiError };
export type Result_2 = { 'ok' : SendMessageStatus } |
  { 'err' : SendMessageStatus };
export type Result_3 = { 'ok' : SharedEnrolledCourse } |
  { 'err' : ApiError };
export type Result_4 = { 'ok' : RunStatus__1 } |
  { 'err' : ApiError };
export type Result_5 = { 'ok' : Array<Question> } |
  { 'err' : ApiError };
export type Result_6 = { 'ok' : Message__1 } |
  { 'err' : ApiError };
export type Result_7 = { 'ok' : SharedUser } |
  { 'err' : ApiError };
export type Result_8 = { 'ok' : Array<Resource> } |
  { 'err' : ApiError };
export type Result_9 = { 'ok' : CanisterInfo } |
  { 'err' : ApiError };
export type RunStatus = { 'Failed' : null } |
  { 'Cancelled' : null } |
  { 'InProgress' : null } |
  { 'Completed' : null } |
  { 'Expired' : null };
export type RunStatus__1 = { 'Failed' : null } |
  { 'Cancelled' : null } |
  { 'InProgress' : null } |
  { 'Completed' : null } |
  { 'Expired' : null };
export type SendMessageStatus = { 'Failed' : string } |
  { 'ThreadLock' : { 'runId' : string } } |
  { 'Completed' : { 'runId' : string } };
export interface SharedCourse {
  'id' : string,
  'title' : string,
  'summary' : string,
}
export interface SharedEnrolledCourse {
  'id' : string,
  'messages' : Array<Message>,
  'completed' : boolean,
  'threadId' : string,
}
export interface SharedThreadRun {
  'job' : ThreadRunJob,
  'status' : RunStatus,
  'lastExecuted' : [] | [Time],
  'timestamp' : Time,
  'threadId' : string,
  'processing' : boolean,
  'runId' : string,
}
export interface SharedUser {
  'id' : string,
  'principal' : [] | [Principal],
  'fullname' : string,
  'claimableTokens' : bigint,
}
export interface SubmittedAnswer { 'option' : bigint, 'questionId' : string }
export type ThreadRunJob = { 'Question' : null } |
  { 'Message' : null };
export type Time = bigint;
export interface TransformArgs {
  'context' : Uint8Array | number[],
  'response' : HttpResponsePayload,
}
export interface _SERVICE extends Backend {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
