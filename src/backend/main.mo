import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Nat64 "mo:base/Nat64";
import Error "mo:base/Error";
import Debug "mo:base/Debug";
import { recurringTimer } = "mo:base/Timer";
import Float "mo:base/Float";
import ICRC7Type "mo:icrc7-mo";
import CandyTypesLib "mo:candy_0_3_0/types";

import Utils "./Utils";
import Types "./Types";
import Request "request";

import Map "mo:map/Map";
import { thash } "mo:map/Map";
import Vector "mo:vector";
import JSON "mo:json.mo";
import ICRC1 "mo:icrc1-types";
import Prng "mo:prng";

shared ({ caller }) actor class Backend() = this {
  type Result<A, B> = Types.Result<A, B>;
  type SharedCourse = Types.SharedCourse;
  type User = Types.User;
  type SharedUser = Types.SharedUser;
  type Course = Types.Course;
  type Question = Types.Question;
  type ResourceType = Types.ResourceType;
  type QuestionOption = Types.QuestionOption;
  type Resource = Types.Resource;
  type EnrolledCourse = Types.EnrolledCourse;
  type SharedEnrolledCourse = Types.SharedEnrolledCourse;
  type SubmittedAnswer = Types.SubmittedAnswer;
  type RunStatus = Types.RunStatus;
  type ThreadRun = Types.ThreadRun;
  type SendMessageStatus = Types.SendMessageStatus;
  type Message = Types.Message;
  type SharedThreadRun = Types.SharedThreadRun;
  type EnrolledCourseProgress = Types.EnrolledCourseProgress;
  type ApiError = Types.ApiError;
  type MemoryVector = Types.MemoryVector;
  type KnowledgeFoundNFT = Types.KnowledgeFoundNFT;
  type NFTMetadata = Types.NFTMetadata;
  type ClaimableNFT = Types.ClaimableNFT;

  stable let members = Map.new<Text, User>();
  stable let courses = Map.new<Text, Course>();
  stable var threadRunQueue = Map.new<Text, ThreadRun>();
  stable var acls = Vector.new<Principal>();
  stable var courseThreads = Map.new<Text, Text>();
  stable let user_to_claimable_nfts = Map.new<Text, Map.Map<Text, NFTMetadata>>();

  stable var owner = caller;

  var icrc1Actor_ : ICRC1.Service = actor ("mxzaz-hqaaa-aaaar-qaada-cai");
  stable var icrc1TokenCanisterId_ : Text = "invalid";

  stable var nftCanisterId_ = "aaaaa-aa";
  var nftActor_ : KnowledgeFoundNFT = actor (nftCanisterId_);
  stable var tokenCounter = 0;

  stable var API_KEY : Text = "";
  stable var ASSISTANT_ID : Text = "";

  stable var seed : Nat32 = 0;
  let rng = Prng.SFC32a(); // or Prng.SFC32b()

  // Get current thread runs
  private func _getInProgressThreadRuns(threadId : Text) : [ThreadRun] {
    let runs = Map.filter(
      threadRunQueue,
      thash,
      func(_ : Text, v : ThreadRun) : Bool {
        return v.threadId == threadId and v.status == #InProgress;
      },
    );
    return Iter.toArray(Map.vals(runs));
  };

  // Get course by id
  private func _getCourse(id : Text) : ?Course {
    Map.get(courses, thash, id);
  };

  // Generate a random number
  private func _getRandomNumber(range : Nat) : Nat {
    assert range > 0;
    rng.init(Nat32.fromIntWrap(Time.now()));
    let val = Nat32.toNat(rng.next());
    let randN = val * range / 4294967296;
    Debug.print("Generated number: " # debug_show (randN));
    return randN;
  };

  // Generate a random number with seed
  private func _getRandomNumberWithSeed(range : Nat) : Nat {
    assert range > 0;
    seed := seed + 1;
    rng.init(Nat32.fromIntWrap(Time.now()) + seed);
    let val = Nat32.toNat(rng.next());
    let randN = val * range / 4294967296;
    Debug.print("Generated number: " # debug_show (randN) # " With seed " # debug_show (seed));
    return randN;
  };

  // Generate x unique random numbers
  private func generateXUniqueRandomNumbers(x : Nat, range : Nat) : [Nat] {
    let vec = Vector.new<Nat>();
    var idx : Nat = 0;
    while (idx < x) {
      let n = _getRandomNumberWithSeed(range);
      let hasValue = Vector.forSome<Nat>(vec, func x { x == n });
      if (hasValue == false) {
        Vector.add(vec, n);
        idx := idx + 1;
      };
    };
    Vector.toArray(vec);
  };

  // Check if caller is owner
  private func _isOwner(p : Principal) : Bool {
    Principal.equal(owner, p);
  };

  // Check if caller is allowed
  private func _isAllowed(p : Principal) : Bool {
    if (_isOwner(p)) {
      return true;
    };
    for (k in Vector.vals(acls)) {
      if (Principal.equal(p, k)) {
        return true;
      };
    };
    return false;
  };

  // get nft canister id
  public query func get_nft_canister_id() : async Text {
    nftCanisterId_;
  };

  // set nft canister
  public shared ({ caller }) func set_nft_canister(nftCanisterId : Text) : async Result<(), Text> {
    if (_isAllowed(caller) == false) return #err("Not authorized");

    let nftCanister = try {
      #ok(actor (nftCanisterId) : KnowledgeFoundNFT);
    } catch e #err(e);

    switch (nftCanister) {
      case (#ok(nftActor)) {
        nftActor_ := nftActor;
        nftCanisterId_ := nftCanisterId;
        #ok;
      };
      case (#err(e)) {
        #err("Failed to instantiate KnowledgeFoundNFT canister from given id(" # nftCanisterId # ") for reason " # Error.message(e));
      };
    };
  };

  // Generate random number
  public shared ({ caller }) func generateRandomNumber(range : Nat) : async Nat {
    _getRandomNumber(range);
  };

  // Get acls
  public query func getAcls() : async [Principal] {
    Vector.toArray(acls);
  };

  // Get owner
  public query func getOwner() : async Principal {
    owner;
  };

  // Add acls
  public shared ({ caller }) func addAcls(p : Principal) : () {
    assert _isOwner(caller);
    Vector.add(acls, p);
  };

  // Add acls text
  public shared ({ caller }) func addAclsText(p : Text) : () {
    assert _isOwner(caller);
    Vector.add(acls, Principal.fromText(p));
  };

  // Remove acls
  public shared ({ caller }) func removeAcls(p : Principal) : async Result<(), ApiError> {
    assert _isOwner(caller);
    let newAcls = Vector.new<Principal>();
    if (Vector.contains<Principal>(acls, p, Principal.equal) == false) {
      return #err(#NotFound("Principal not found"));
    };
    for (k in Vector.vals(acls)) {
      if (Principal.notEqual(p, k)) {
        Vector.add(newAcls, k);
      };
    };
    acls := newAcls;
    #ok();
  };

  // get token canister id
  public query func get_icrc1_token_canister_id() : async Text {
    icrc1TokenCanisterId_;
  };

  // set icrc1 token canister
  public shared ({ caller }) func set_icrc1_token_canister(tokenCanisterId : Principal) : async Result<(), ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);

    let icrc1Canister = try {
      #ok(await Utils.createIcrcActor(Principal.toText(tokenCanisterId)));
    } catch e #err(e);

    switch (icrc1Canister) {
      case (#ok(icrc1Actor)) {
        icrc1Actor_ := icrc1Actor;
        icrc1TokenCanisterId_ := Principal.toText(tokenCanisterId);
        #ok;
      };
      case (#err(e)) {
        #err(#Other("Failed to instantiate icrc1 token canister from given id(" # Principal.toText(tokenCanisterId) # ") for reason " # Error.message(e)));
      };
    };
  };

  public shared ({ caller }) func changeOwner(newOwner : Text) : async Result<(), ApiError> {
    if (not _isOwner(caller)) return #err(#Unauthorized);
    owner := Principal.fromText(newOwner);
    #ok();
  };

  // Set api key
  public shared ({ caller }) func changeApiKey(apiKey : Text) : async Result<(), ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    API_KEY := apiKey;
    #ok();
  };

  // Set assistant id
  public shared ({ caller }) func setAssistantId(id : Text) : async Result<(), ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    ASSISTANT_ID := id;
    #ok();
  };

  // List all courses
  public query func listCourses() : async [SharedCourse] {
    let filteredCourses = Vector.new<Types.SharedCourse>();
    for (course in Map.vals(courses)) {
      let sharedCourse = {
        id = course.id;
        title = course.title;
        summary = course.summary;
      };
      Vector.add(filteredCourses, sharedCourse);
    };
    return Vector.toArray(filteredCourses);
  };

  // Get user enrolled course details
  public query func getUserEnrolledCourse(courseId : Text, userId : Text) : async Result<SharedEnrolledCourse, ApiError> {
    let user = Map.get(members, thash, userId);
    switch (user) {
      case (?member) {
        let course = _getCourse(courseId);
        switch (course) {
          case (?c) {
            for (_course in Vector.vals(member.enrolledCourses)) {
              if (_course.id == c.id) {
                let sharedCourse = {
                  id = _course.id;
                  threadId = _course.threadId;
                  completed = _course.completed;
                  messages = Vector.toArray(_course.messages);
                };
                return #ok(sharedCourse);
              };
            };
            return #err(#NotFound("Course not enrolled"));
          };
          case (null) {
            return #err(#NotFound("Course not found"));
          };
        };
      };
      case (null) {
        return #err(#NotFound("User not found"));
      };
    };
  };

  // Enroll in a course
  public shared func enrollCourse(courseId : Text, userId : Text) : async Result<Text, ApiError> {
    let user = Map.get(members, thash, userId);
    switch (user) {
      case (?member) {
        let course = _getCourse(courseId);
        switch (course) {
          case (?c) {
            for (_course in Vector.vals(member.enrolledCourses)) {
              if (_course.id == c.id) {
                return #ok("Course already enrolled");
              };
            };

            // Create thread
            let headers : ?[Types.HttpHeader] = ?[
              {
                name = "Authorization";
                value = "Bearer " # API_KEY;
              },
              {
                name = "OpenAI-Beta";
                value = "assistants=v2";
              },
              {
                name = "x-forwarded-host";
                value = "api.openai.com";
              },
            ];

            let response = await Request.post(
              "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads",
              null,
              transform,
              headers,
            );

            if (response.status != 200) {
              return #err(#Other("Failed to create thread"));
            };

            var threadId = "";

            switch (response.body) {
              case (#Object(v)) {
                label findId for ((k, v) in v.vals()) {
                  if (k == "id") {
                    switch (v) {
                      case (#String(v)) {
                        threadId := v;
                        break findId;
                      };
                      case (_) {
                        return #err(#Other("Json parse failed"));
                      };
                    };
                  };
                };
              };
              case (_) {
                return #err(#Other("Json parse failed"));
              };
            };

            if (threadId == "") {
              return #err(#Other("Create thread failed"));
            };

            let messages = Vector.new<Message>();
            let enrolledCourse = {
              id = c.id;
              completed = false;
              threadId = threadId;
              messages = messages;
            };
            Vector.add(member.enrolledCourses, enrolledCourse);

            // Update course enrolled count
            let updatedCourse = {
              id = c.id;
              title = c.title;
              summary = c.summary;
              resources = c.resources;
              questions = c.questions;
              knowledgebase = c.knowledgebase;
            };
            Map.set(courses, thash, c.id, updatedCourse);
            return #ok("Course enrolled successfully");
          };
          case (null) {
            return #err(#NotFound("Course not found"));
          };
        };
      };
      case (null) {
        return #err(#NotFound("User not found"));
      };
    };
  };

  // Register a new user
  public shared ({ caller }) func loginOrRegiser(fullname : Text) : async Result<Text, ApiError> {
    let userId = Utils.hashText(fullname);
    let user = Map.get(members, thash, userId);
    var userP : ?Principal = null;

    if (not Principal.isAnonymous(caller)) {
      userP := ?caller;
    };

    switch (user) {
      case (?u) {
        return #ok(u.id);
      };
      case (null) {
        let newUser = {
          id = userId;
          fullname = fullname;
          principal = userP;
          var claimableTokens = 0;
          enrolledCourses = Vector.new<EnrolledCourse>();
        };
        Map.set(members, thash, userId, newUser);
        return #ok(userId);
      };
    };
  };

  // Connect user to principal
  public shared ({ caller }) func connectUserToPrincipal(userId : Text) : async Result<Text, ApiError> {
    let user = Map.get(members, thash, userId);
    if (Principal.isAnonymous(caller)) {
      return #err(#Unauthorized);
    };
    switch (user) {
      case (?u) {
        if (u.principal != null) {
          return #err(#Other("User already connected to principal"));
        };
        let newUser = {
          id = u.id;
          fullname = u.fullname;
          principal = ?caller;
          var claimableTokens = u.claimableTokens;
          enrolledCourses = u.enrolledCourses;
        };
        Map.set(members, thash, userId, newUser);
        #ok("User connected to principal successfully");
      };
      case (null) {
        return #err(#NotFound("User not found"));
      };
    };
  };

  // Get user profile
  public query func getProfile(userId : Text) : async Result<SharedUser, ApiError> {
    let user = Map.get(members, thash, userId);
    switch (user) {
      case (?member) {
        let sharedUser = {
          id = member.id;
          fullname = member.fullname;
          principal = member.principal;
          claimableTokens = member.claimableTokens;
        };
        return #ok(sharedUser);
      };
      case (null) {
        return #err(#NotFound("User not found"));
      };
    };
  };

  // Create a course
  public shared ({ caller }) func createCourse(title : Text, summary : Text) : async Result<Text, ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);

    let resources = Vector.new<Resource>();
    let questions = Vector.new<Question>();
    let courseId = await Utils.uuid();

    // Create knowledge base canister
    let result = try {
      #ok(await createKnowledgeBaseCanister());
    } catch e #err(e);

    switch (result) {
      case (#ok(knowledgebase)) {
        switch (knowledgebase) {
          case (#ok(info)) {
            let course = {
              id = courseId;
              title = title;
              summary = summary;
              resources = resources;
              questions = questions;
              knowledgebase = info;
            };
            Map.set(courses, thash, courseId, course);
            #ok(courseId);
          };
          case (#err(error)) {
            return #err(error);
          };
        };
      };
      case (#err(_)) {
        return #err(#Other("Error creating course knowledgebase"));
      };
    };

  };

  public func getCourseKnowledgebase(courseId : Text) : async Result<Types.CanisterInfo, ApiError> {
    let course = _getCourse(courseId);
    switch (course) {
      case (?c) {
        #ok(c.knowledgebase);
      };
      case (null) {
        #err(#NotFound("Course not found"));
      };
    };
  };

  // Create new resource for course
  public shared ({ caller }) func createResource(courseId : Text, title : Text, url : Text, rType : ResourceType) : async Result<Text, ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    let course = _getCourse(courseId);
    switch (course) {
      case (?c) {
        let resource = {
          id = await Utils.uuid();
          title = title;
          url = url;
          rType = rType;
        };
        Vector.add(c.resources, resource);
        let updatedCourse = {
          id = c.id;
          title = c.title;
          summary = c.summary;
          resources = c.resources;
          questions = c.questions;
          knowledgebase = c.knowledgebase;
        };
        Map.set(courses, thash, c.id, updatedCourse);
        return #ok("Resource created successfully");
      };
      case (null) {
        return #err(#NotFound("Course not found"));
      };
    };
  };

  // Get course resources
  public query func getCourseResources(courseId : Text) : async Result<[Resource], ApiError> {
    let course = _getCourse(courseId);
    switch (course) {
      case (?c) {
        return #ok(Vector.toArray(c.resources));
      };
      case (null) {
        return #err(#NotFound("Course not found"));
      };
    };
  };

  // Remove resource from course
  public shared ({ caller }) func removeResource(courseId : Text, resourceId : Text) : async Result<(), ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    let course = _getCourse(courseId);
    switch (course) {
      case (?c) {
        let contains = Utils.vecContains(#resource(c.resources), resourceId);
        if (contains == false) {
          return #err(#NotFound("Resource not found"));
        };
        let newResources = Vector.new<Resource>();
        for (k in Vector.vals(c.resources)) {
          if (k.id != resourceId) {
            Vector.add(newResources, k);
          };
        };
        let updatedCourse = {
          id = c.id;
          title = c.title;
          summary = c.summary;
          resources = newResources;
          questions = c.questions;
          knowledgebase = c.knowledgebase;
        };
        Map.set(courses, thash, c.id, updatedCourse);
      };
      case (null) {
        return #err(#NotFound("Course not found"));
      };
    };
    #ok();
  };

  // Update course details
  public shared ({ caller }) func updateCourse(courseId : Text, title : Text, summary : Text) : async Result<Text, ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    let course = _getCourse(courseId);
    switch (course) {
      case (?c) {
        let updatedCourse = {
          id = c.id;
          title = title;
          summary = summary;
          resources = c.resources;
          questions = c.questions;
          knowledgebase = c.knowledgebase;
        };
        Map.set(courses, thash, c.id, updatedCourse);
        return #ok("Course updated successfully");
      };
      case (null) {
        return #err(#NotFound("Course not found"));
      };
    };
  };

  // Add a question to a course
  public shared ({ caller }) func addQuestion(courseId : Text, data : Question) : async Result<Text, ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    let course = _getCourse(courseId);
    switch (course) {
      case (?c) {
        let question = {
          id = await Utils.uuid();
          options = data.options;
          correctOption = data.correctOption;
          description = data.description;
        };
        Vector.add(c.questions, question);
        let updatedCourse = {
          id = c.id;
          title = c.title;
          summary = c.summary;
          resources = c.resources;
          questions = c.questions;
          knowledgebase = c.knowledgebase;
        };
        Map.set(courses, thash, c.id, updatedCourse);
        return #ok("Question added successfully");
      };
      case (null) {
        return #err(#NotFound("Course not found"));
      };
    };
  };

  // Remove question from a course
  public shared ({ caller }) func removeQuestion(courseId : Text, questionId : Text) : async Result<(), ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    let course = _getCourse(courseId);
    switch (course) {
      case (?c) {
        let contains = Utils.vecContains(#question(c.questions), questionId);
        if (contains == false) {
          return #err(#NotFound("Question not found"));
        };
        let newQuestions = Vector.new<Question>();
        for (k in Vector.vals(c.questions)) {
          if (k.id != questionId) {
            Vector.add<Question>(newQuestions, k);
          };
        };
        let updatedCourse = {
          id = c.id;
          title = c.title;
          summary = c.summary;
          resources = c.resources;
          questions = newQuestions;
          knowledgebase = c.knowledgebase;
        };
        Map.set(courses, thash, c.id, updatedCourse);
      };
      case (null) {
        return #err(#NotFound("Course not found"));
      };
    };
    #ok();
  };

  // Get course questions
  public query func getCourseQuestions(courseId : Text) : async Result<[Question], ApiError> {
    let course = _getCourse(courseId);
    switch (course) {
      case (null) { #err(#NotFound("Course not found")) };
      case (?c) {
        #ok(Vector.toArray(c.questions));
      };
    };
  };

  // Get random course questions
  public query func getRandomCourseQuestions(courseId : Text, questionCount : Nat) : async Result<[Question], ApiError> {
    let course = _getCourse(courseId);
    switch (course) {
      case (?c) {
        let questions = Vector.new<Question>();
        let len = Vector.size(c.questions);

        if (len == 0) {
          return #err(#Other("Course has no questions"));
        };
        if (questionCount > len) {
          return #err(#Other("Question count " # Nat.toText(questionCount) # " is greater than the number of questions " # Nat.toText(len)));
        };

        let choices = generateXUniqueRandomNumbers(questionCount, len);

        for (number in choices.vals()) {
          Debug.print("Random: " # debug_show (number));
          let question = Vector.get(c.questions, number);
          Vector.add(questions, question);
        };

        return #ok(Vector.toArray(questions));
      };
      case (null) {
        return #err(#NotFound("Course not found"));
      };
    };
  };

  // Submit questions attempt
  public shared ({ caller }) func submitQuestionsAttempt(courseId : Text, answers : [SubmittedAnswer], userId : Text) : async Result<Text, ApiError> {
    let user = Map.get(members, thash, userId);
    switch (user) {
      case (?member) {
        let course = _getCourse(courseId);
        switch (course) {
          case (?c) {

            var enrolledCourse : ?EnrolledCourse = null;

            label findCourse for (_course in Vector.vals(member.enrolledCourses)) {
              if (_course.id == c.id) {
                enrolledCourse := ?_course;
                break findCourse;
              };
            };

            switch (enrolledCourse) {
              case (null) {
                return #err(#NotFound("Course not enrolled"));
              };
              case (?enrolledCourse) {

                let len = Vector.size(c.questions);
                if (len == 0) {
                  return #err(#Other("Course has no questions"));
                };
                if (Array.size(answers) > len) {
                  return #err(#Other("Number of answers is greater than the number of questions"));
                };

                var correctCount = 0;
                for (answer in answers.vals()) {
                  for (question in Vector.vals(c.questions)) {
                    if (question.id == answer.questionId) {
                      if (question.correctOption == answer.option) {
                        correctCount += 1;
                      };
                    };
                  };
                };

                if (((Float.fromInt(correctCount) * 100.0) / Float.fromInt(Array.size(answers))) < 80.0) {
                  return #err(#Other("You must get at least 80% to complete the course, please try again"));
                };

                var enrolledCourseIndex = 0;
                label findCourse for (i in Iter.range(0, Vector.size(member.enrolledCourses))) {
                  if (Vector.get(member.enrolledCourses, i).id == c.id) {
                    enrolledCourseIndex := i;
                    break findCourse;
                  };
                };

                let previousValue = Vector.get(member.enrolledCourses, enrolledCourseIndex);
                if (previousValue.completed) {
                  return #err(#Other("You have already completed this course before"));
                };

                let metadata : NFTMetadata = {
                  courseId = c.id;
                  userId = userId;
                  courseTitle = c.title;
                  user = caller;
                  userName = member.fullname;
                  issued_on = Time.now();
                  mark = correctCount;
                };

                if (not Principal.isAnonymous(caller)) {
                  let icrc1Canister = try {
                    #ok(await Utils.createIcrcActor(icrc1TokenCanisterId_));
                  } catch e #err(e);

                  switch (icrc1Canister) {
                    case (#ok(icrc1Actor)) {
                      // Transfer tokens to user
                      // Make the icrc1 intercanister transfer call, catching if error'd:
                      let response : Result<ICRC1.TransferResult, Text> = try {
                        let decimal = 100000000;
                        #ok(await icrc1Actor.icrc1_transfer({ amount = 10 * decimal; created_at_time = null; from_subaccount = null; fee = null; memo = null; to = { owner = caller; subaccount = null } }));
                      } catch (e) {
                        #err(Error.message(e));
                      };

                      // Parse the results of the icrc1 intercansiter transfer call:
                      switch (response) {
                        case (#ok(transferResult)) {
                          switch (transferResult) {
                            case (#Ok _) {};
                            case (#Err _) {
                              return #err(
                                #Other("The icrc1 transfer call could not be completed as requested.")
                              );
                            };
                          };
                        };
                        case (#err(k)) {
                          return #err(
                            #Other("The intercanister icrc1 transfer call caught an error: " # k)
                          );
                        };
                      };
                    };
                    case (#err(_)) {
                      return #err(#Other("Internal transfer error"));
                    };
                  };

                  // Mint NFT
                  let candyMetadata : CandyTypesLib.CandyShared = #Class([
                    {
                      immutable = false;
                      name = "courseId";
                      value = #Text(metadata.courseId);
                    },
                    {
                      immutable = false;
                      name = "courseTitle";
                      value = #Text(metadata.courseTitle);
                    },
                    {
                      immutable = false;
                      name = "userId";
                      value = #Text(metadata.userId);
                    },
                    {
                      immutable = false;
                      name = "user";
                      value = #Text(Principal.toText(metadata.user));
                    },
                    {
                      immutable = false;
                      name = "userName";
                      value = #Text(metadata.userName);
                    },
                    {
                      immutable = false;
                      name = "mark";
                      value = #Nat(metadata.mark);
                    },
                    {
                      immutable = false;
                      name = "issued_on";
                      value = #Int(metadata.issued_on);
                    },
                  ]);
                  tokenCounter := tokenCounter + 1;
                  let tokens : ICRC7Type.SetNFTRequest = [{
                    token_id = tokenCounter;
                    owner = ?{ owner = metadata.user; subaccount = null };
                    override = true;
                    created_at_time = null;
                    memo = ?Text.encodeUtf8("Issued Knowledge Found NFT");
                    metadata = candyMetadata;
                  }];
                  let nfts = await nftActor_.icrcX_mint(tokens);
                  let nft = nfts[0];
                  switch (nft) {
                    case (#Ok(tokId)) {
                      switch (tokId) {
                        case (null) {
                          return #err(#Other("Failed to mint Knowledge Found NFT"));
                        };
                        case (?tokenId) {};
                      };
                    };
                    case (#Err(err)) {
                      switch (err) {
                        case (#NonExistingTokenId) {
                          return #err(#Other("Non existing token id"));
                        };
                        case (#TokenExists) {
                          return #err(#Other("Token already exists"));
                        };
                        case (#TooOld) {
                          return #err(#Other("Transaction is too old"));
                        };
                        case (#GenericError(e)) {
                          return #err(#Other("Generic error: " # debug_show (e.error_code) # ", Message: " # e.message));
                        };
                        case (#CreatedInFuture(e)) {
                          return #err(#Other("Created in future: " # debug_show (e.ledger_time)));
                        };
                      };
                    };
                    case (#GenericError(e)) {
                      return #err(#Other("Generic error: " # debug_show (e.error_code) # ", Message: " # e.message));
                    };
                  };
                } else {
                  // Increment claimable tokens
                  member.claimableTokens := member.claimableTokens + 10;

                  // Update user claimable nfts
                  let claimableNfts = Map.get(user_to_claimable_nfts, thash, userId);
                  switch (claimableNfts) {
                    case (null) {
                      let newClaimableNfts = Map.new<Text, NFTMetadata>();
                      Map.set(newClaimableNfts, thash, await Utils.uuid(), metadata);
                      Map.set(user_to_claimable_nfts, thash, userId, newClaimableNfts);
                    };
                    case (?t) {
                      Map.set(t, thash, await Utils.uuid(), metadata);
                      Map.set(user_to_claimable_nfts, thash, userId, t);
                    };
                  };
                };

                // Updated enrolled course to completed
                let updatedECourse : EnrolledCourse = {
                  id = enrolledCourse.id;
                  threadId = enrolledCourse.threadId;
                  completed = true;
                  messages = enrolledCourse.messages;
                };
                Vector.put(member.enrolledCourses, enrolledCourseIndex, updatedECourse);

                // Update user object
                Map.set(members, thash, userId, member);
                #ok("You have successfully completed the course");
              };
            };
          };
          case (null) {
            return #err(#NotFound("Course not found"));
          };
        };
      };
      case (null) {
        return #err(#NotFound("User not found"));
      };
    };
  };

  // Claim tokens
  public shared ({ caller }) func claimTokens(userId : Text) : async Result<Text, ApiError> {
    if (Principal.isAnonymous(caller)) {
      return #err(#Unauthorized);
    };
    let user = Map.get(members, thash, userId);
    switch (user) {
      case (?member) {
        switch (member.principal) {
          case (null) {
            return #err(#Other("User not connected to principal"));
          };
          case (?p) {
            if (Principal.notEqual(caller, p)) {
              return #err(#Unauthorized);
            };
            if (member.claimableTokens == 0) {
              return #err(#Other("No tokens to claim"));
            };

            let icrc1Canister = try {
              #ok(await Utils.createIcrcActor(icrc1TokenCanisterId_));
            } catch e #err(e);

            // TODO: Make this more secure by using sub accounts instead
            switch (icrc1Canister) {
              case (#ok(icrc1Actor)) {
                // Make the icrc1 intercanister transfer call, catching if error'd:
                let response : Result<ICRC1.TransferResult, Text> = try {
                  let decimal = 100000000;
                  #ok(await icrc1Actor.icrc1_transfer({ amount = member.claimableTokens * decimal; created_at_time = null; from_subaccount = null; fee = null; memo = null; to = { owner = caller; subaccount = null } }));
                } catch (e) {
                  #err(Error.message(e));
                };

                // Parse the results of the icrc1 intercansiter transfer call:
                switch (response) {
                  case (#ok(transferResult)) {
                    switch (transferResult) {
                      case (#Ok _) {};
                      case (#Err _) {
                        return #err(
                          #Other("The icrc1 transfer call could not be completed as requested.")
                        );
                      };
                    };
                  };
                  case (#err(k)) {
                    return #err(
                      #Other("The intercanister icrc1 transfer call caught an error: " # k)
                    );
                  };
                };

                // Reset claimable tokens
                member.claimableTokens := 0;
                Map.set(members, thash, userId, member);
                #ok("Tokens claimed successfully");
              };
              case (#err(_)) {
                return #err(#Other("Internal transfer error"));
              };
            };
          };
        };
      };
      case (null) {
        return #err(#NotFound("User not found"));
      };
    };
  };

  public func get_user_claimable_nfts(userId : Text) : async Result<[ClaimableNFT], Text> {
    let nfts = Map.get(user_to_claimable_nfts, thash, userId);
    switch (nfts) {
      case (null) {
        #ok([]);
      };
      case (?t) {
        let claimableNfts = Vector.new<ClaimableNFT>();
        for (k in Map.keys(t)) {
          switch (Map.get(t, thash, k)) {
            case (null) {};
            case (?metadata) {
              let claimableNft : ClaimableNFT = {
                id = k;
                metadata = metadata;
              };
              Vector.add(claimableNfts, claimableNft);
            };
          };
        };
        #ok(Vector.toArray(claimableNfts));
      };
    };
  };

  // Claim NFTs
  public shared ({ caller }) func claimNFTs(userId : Text, claimableId : Text) : async Result<Text, ApiError> {
    if (Principal.isAnonymous(caller)) {
      return #err(#Unauthorized);
    };
    let user = Map.get(members, thash, userId);
    switch (user) {
      case (?member) {
        switch (member.principal) {
          case (null) {
            return #err(#Other("User not connected to principal"));
          };
          case (?p) {
            if (Principal.notEqual(caller, p)) {
              return #err(#Unauthorized);
            };
            switch (Map.get(user_to_claimable_nfts, thash, userId)) {
              case (null) {
                return #err(#Other("No NFTs to claim"));
              };
              case (?claimableNfts) {
                switch (Map.get(claimableNfts, thash, claimableId)) {
                  case (null) {
                    return #err(#NotFound("Claimable NFT not found"));
                  };
                  case (?metadata) {
                    let candyMetadata : CandyTypesLib.CandyShared = #Class([
                      {
                        immutable = false;
                        name = "courseId";
                        value = #Text(metadata.courseId);
                      },
                      {
                        immutable = false;
                        name = "courseTitle";
                        value = #Text(metadata.courseTitle);
                      },
                      {
                        immutable = false;
                        name = "userId";
                        value = #Text(metadata.userId);
                      },
                      {
                        immutable = false;
                        name = "user";
                        value = #Text(Principal.toText(metadata.user));
                      },
                      {
                        immutable = false;
                        name = "userName";
                        value = #Text(metadata.userName);
                      },
                      {
                        immutable = false;
                        name = "mark";
                        value = #Nat(metadata.mark);
                      },
                      {
                        immutable = false;
                        name = "issued_on";
                        value = #Int(metadata.issued_on);
                      },
                    ]);
                    tokenCounter := tokenCounter + 1;
                    let tokens : ICRC7Type.SetNFTRequest = [{
                      token_id = tokenCounter;
                      owner = ?{ owner = caller; subaccount = null };
                      override = true;
                      created_at_time = null;
                      memo = ?Text.encodeUtf8("Issued Knowledge Found NFT");
                      metadata = candyMetadata;
                    }];
                    let nfts = await nftActor_.icrcX_mint(tokens);
                    let nft = nfts[0];
                    switch (nft) {
                      case (#Ok(tokId)) {
                        switch (tokId) {
                          case (null) {
                            return #err(#Other("Failed to mint Knowledge Found NFT"));
                          };
                          case (?tokenId) {
                            Map.delete(claimableNfts, thash, claimableId);
                            Map.set(user_to_claimable_nfts, thash, userId, claimableNfts);
                            return #ok("NFT claimed successfully");
                          };
                        };
                      };
                      case (#Err(err)) {
                        switch (err) {
                          case (#NonExistingTokenId) {
                            return #err(#Other("Non existing token id"));
                          };
                          case (#TokenExists) {
                            return #err(#Other("Token already exists"));
                          };
                          case (#TooOld) {
                            return #err(#Other("Transaction is too old"));
                          };
                          case (#GenericError(e)) {
                            return #err(#Other("Generic error: " # debug_show (e.error_code) # ", Message: " # e.message));
                          };
                          case (#CreatedInFuture(e)) {
                            return #err(#Other("Created in future: " # debug_show (e.ledger_time)));
                          };
                        };
                      };
                      case (#GenericError(e)) {
                        return #err(#Other("Generic error: " # debug_show (e.error_code) # ", Message: " # e.message));
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
      case (null) {
        return #err(#NotFound("User not found"));
      };
    };
  };

  // Http response transformer
  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
    let transformed : Types.CanisterHttpResponsePayload = {
      status = raw.response.status;
      body = raw.response.body;
      headers = [
        {
          name = "Content-Security-Policy";
          value = "default-src 'self'";
        },
        { name = "Referrer-Policy"; value = "strict-origin" },
        { name = "Permissions-Policy"; value = "geolocation=(self)" },
        {
          name = "Strict-Transport-Security";
          value = "max-age=63072000";
        },
        { name = "X-Frame-Options"; value = "DENY" },
        { name = "X-Content-Type-Options"; value = "nosniff" },
      ];
    };
    transformed;
  };

  // Send new message in an enrolled course chat
  public shared func sendMessage(threadId : Text, prompt : Text, knowledgebaseContent : Text, userId : Text) : async Result<SendMessageStatus, SendMessageStatus> {
    let user = Map.get(members, thash, userId);
    switch (user) {
      case (?member) {
        var enrolledCourse : ?EnrolledCourse = null;
        var enrolledCourseIdx = 0;

        label findCourseIdx for (_course in Vector.vals(member.enrolledCourses)) {
          if (_course.threadId == threadId) {
            enrolledCourse := ?_course;
            break findCourseIdx;
          };
          enrolledCourseIdx := enrolledCourseIdx + 1;
        };

        switch (enrolledCourse) {
          case (null) {
            return #err(#Failed("Enrolled course with thread id not found"));
          };
          case (?eCourse) {
            // Check if there is no pending run
            let inProgressRuns = _getInProgressThreadRuns(threadId);
            if (Array.size(inProgressRuns) > 0) {
              return #err(#ThreadLock({ runId = inProgressRuns[0].runId }));
            };

            var data = #Object([
              ("role", #String("user")),
              ("content", #String("Prompt: " # prompt # "\n\n This is an additional context provided to give you more context on the question if it's relevant\n\n" # knowledgebaseContent)),
            ]);

            let headers : ?[Types.HttpHeader] = ?[
              {
                name = "Authorization";
                value = "Bearer " # API_KEY;
              },
              {
                name = "OpenAI-Beta";
                value = "assistants=v2";
              },
              {
                name = "x-forwarded-host";
                value = "api.openai.com";
              },
            ];

            let response = await Request.post(
              "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads/" # threadId # "/messages",
              ?data,
              transform,
              headers,
            );

            if (response.status != 200) {
              return #err(#Failed("Failed to create message"));
            };

            let newMessage = {
              runId = null;
              content = prompt;
              role = #User;
            };

            Vector.add(eCourse.messages, newMessage);
            Vector.put(member.enrolledCourses, enrolledCourseIdx, eCourse);
            Map.set(members, thash, userId, member);

            var courseTitle = "";
            let course = _getCourse(eCourse.id);
            switch (course) {
              case (?c) {
                courseTitle := c.title;
              };
              case (null) {};
            };

            // Create instruction
            var instruction = "Teach me about /TOPIC/. I want to learn about the topic in a way that's engaging and interactive.My name is /NAME/Please ask me questions, provide examples, and gauge my understanding as we go along. I'll respond with my thoughts and questions, and you can adjust your teaching approach accordingly. Let's get started! Desired Response: The model should be able to provide references to the pages in the document where more information can be found. The model should respond with a question or request that gauges the user's prior knowledge or understanding of the topic. The model should provide examples or analogies to help illustrate key concepts. The model should ask follow-up questions to ensure the user understands the material. The model should adjust its teaching approach based on the user's responses. The model should only respond to questions related to what it has been trained with using file search. The model should refer to the user by their name, if the model does not know the user's name the model can ask. The model should respond to questions not related to corruption with a message like `I'm here to help you learn about /TOPIC/. Let's focus on that for now.` Any variant of it is okay. The model response should be in markdown format. Evaluation Criteria: The model's ability to engage the user in a conversation about the topic. The model's ability to gauge the user's understanding and adjust its teaching approach accordingly. The model's ability to provide clear and concise explanations of key concepts. The model's ability to use examples and analogies to illustrate complex ideas.";
            instruction := Text.replace(instruction, #text "/TOPIC/", courseTitle);
            instruction := Text.replace(instruction, #text "/NAME/", member.fullname);

            // Create new run
            data := #Object([
              ("assistant_id", #String(ASSISTANT_ID)),
              ("instructions", #String(instruction)),
            ]);

            Debug.print("RUN CREATE REQUEST");
            Debug.print(JSON.show(data));

            let runResponse = await Request.post(
              "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads/" # threadId # "/runs",
              ?data,
              transform,
              headers,
            );

            Debug.print("RUN CREATE RESPONSE");
            Debug.print(JSON.show(runResponse.body));

            var runId = "";

            switch (runResponse.body) {
              case (#Object(v)) {
                label findId for ((k, v) in v.vals()) {
                  if (k == "id") {
                    switch (v) {
                      case (#String(v)) {
                        runId := v;
                        break findId;
                      };
                      case (_) {
                        return #err(#Failed("Json parse failed"));
                      };
                    };
                  };
                };
              };
              case (_) {
                return #err(#Failed("Json parse failed"));
              };
            };

            if (runId == "") {
              return #err(#Failed("Run failed"));
            };

            let threadRun = {
              runId = runId;
              threadId = threadId;
              status = #InProgress;
              timestamp = Time.now();
              lastExecuted = null;
              var processing = false;
              job = #Message;
            };

            Map.set<Text, ThreadRun>(threadRunQueue, thash, runId, threadRun);
            return #ok(#Completed({ runId = runId }));
          };
        };
      };
      case (null) {
        return #err(#Failed("Member not found"));
      };
    };

  };

  // Get run id status
  public query func getRunStatus(runId : Text) : async Result<RunStatus, ApiError> {
    let run = Map.get(threadRunQueue, thash, runId);
    switch (run) {
      case (null) {
        #err(#NotFound("Run ID not found"));
      };
      case (?r) {
        #ok(r.status);
      };
    };
  };

  // Generate questions
  public shared ({ caller }) func generateQuestionsForCourse(courseId : Text) : async Result<SendMessageStatus, SendMessageStatus> {
    if (not _isAllowed(caller)) return #err(#Failed("Unauthorized"));

    // Get or create thread
    var threadId = Map.get(courseThreads, thash, courseId);

    switch (threadId) {
      case (null) {
        // Create thread
        let headers : ?[Types.HttpHeader] = ?[
          {
            name = "Authorization";
            value = "Bearer " # API_KEY;
          },
          {
            name = "OpenAI-Beta";
            value = "assistants=v2";
          },
          {
            name = "x-forwarded-host";
            value = "api.openai.com";
          },
        ];

        var data = #Object([]);

        let response = await Request.post(
          "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads",
          ?data,
          transform,
          headers,
        );

        Debug.print(debug_show (response.status));
        Debug.print(JSON.show(response.body));

        if (response.status != 200) {
          return #err(#Failed("Failed to create thread"));
        };

        switch (response.body) {
          case (#Object(v)) {
            label findId for ((k, v) in v.vals()) {
              if (k == "id") {
                switch (v) {
                  case (#String(v)) {
                    threadId := ?v;
                    break findId;
                  };
                  case (_) {
                    return #err(#Failed("Json parse failed"));
                  };
                };
              };
            };
          };
          case (_) {
            return #err(#Failed("Json parse failed"));
          };
        };
      };
      case (_) {};
    };

    // After successful thread creation, generate questions
    switch (threadId) {
      case (?threadId) {
        Map.set(courseThreads, thash, courseId, threadId);
        // Check if there a pending run for this course thread
        let runs = _getInProgressThreadRuns(threadId);
        if (Array.size(runs) > 0) {
          return #err(#ThreadLock({ runId = runs[0].runId }));
        };

        let course = _getCourse(courseId);

        switch (course) {
          case (null) { return #err(#Failed("Course not found ")) };
          case (?c) {
            let prompt = "Create 10 questions in JSON format for the course titled"
            # c.title
            # " with description: '" # c.summary # "'."
            # "Note: This data should be taken from the resources."
            # "IMPORTANT: Return only the valid json format, no extra text, just the json file, don't explain"
            # " Don't add the ```json``` text"
            # "JSON Structure:"
            # "[{"
            # "'q': '',"
            # "'o': ['Option 0','Option 1','Option 2','Option 3'],"
            # "'a': '0'"
            # "}]";

            let data = #Object([
              ("role", #String("user")),
              ("content", #String(prompt)),
            ]);

            let headers : ?[Types.HttpHeader] = ?[
              {
                name = "Authorization";
                value = "Bearer " # API_KEY;
              },
              {
                name = "OpenAI-Beta";
                value = "assistants=v2";
              },
              {
                name = "x-forwarded-host"; // Using a proxy due to IPV6 issues
                value = "api.openai.com";
              },
            ];

            let response = await Request.post(
              "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads/" # threadId # "/messages",
              ?data,
              transform,
              headers,
            );

            Debug.print("ADD MESSAGE RESPONSE");
            Debug.print(debug_show (response.status));
            Debug.print(JSON.show(response.body));

            if (response.status != 200) {
              return #err(#Failed("Failed to create message"));
            };

            // Create new run
            let data2 = #Object([
              ("assistant_id", #String(ASSISTANT_ID)),
              ("instructions", #String("You are a helpful assistant, here to train users on the impacts of corruption and how to mitigate them based on the files you have been trained with and all your responses must be in json format")),
            ]);

            Debug.print("DATA RUN");
            Debug.print(JSON.show(data));
            Debug.print("https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads/" # threadId # "/runs");
            let runResponse = await Request.post(
              "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads/" # threadId # "/runs",
              ?data2,
              transform,
              headers,
            );

            Debug.print("RUN RESPONSE");
            Debug.print(JSON.show(runResponse.body));

            var runId = "";

            switch (runResponse.body) {
              case (#Object(v)) {
                label findId for ((k, v) in v.vals()) {
                  if (k == "id") {
                    switch (v) {
                      case (#String(v)) {
                        runId := v;
                        break findId;
                      };
                      case (_) {
                        return #err(#Failed("Json parse failed"));
                      };
                    };
                  };
                };
              };
              case (_) {
                return #err(#Failed("Json parse failed"));
              };
            };

            if (runId == "") {
              return #err(#Failed("Run failed"));
            };

            let threadRun = {
              runId = runId;
              threadId = threadId;
              status = #InProgress;
              timestamp = Time.now();
              lastExecuted = null;
              var processing = false;
              job = #Question;
            };

            Map.set<Text, ThreadRun>(threadRunQueue, thash, runId, threadRun);
            return #ok(#Completed({ runId = runId }));
          };
        };
      };
      case (null) {
        return #err(#Failed("Thread is not available"));
      };
    };
  };

  // Get run message
  public shared func getRunMessage(runId : Text, userId : Text) : async Result<Message, ApiError> {
    let user = Map.get(members, thash, userId);
    switch (user) {
      case (?member) {
        let _r = Map.get(threadRunQueue, thash, runId);
        switch (_r) {
          case (null) { #err(#NotFound("Run not found")) };
          case (?run) {
            if (run.processing or run.status != #Completed) {
              return #err(#Other("A run is still processing"));
            };
            run.processing := true;
            Map.set(threadRunQueue, thash, run.runId, run);

            var enrolledCourse : ?EnrolledCourse = null;
            var enrolledCourseIdx = 0;

            label findCourse for (_course in Vector.vals(member.enrolledCourses)) {
              if (_course.threadId == run.threadId) {
                enrolledCourse := ?_course;
                break findCourse;
              };
              enrolledCourseIdx := enrolledCourseIdx + 1;
            };

            switch (enrolledCourse) {
              case (null) { #err(#NotFound("Enrolled course not found")) };
              case (?eCourse) {
                let headers : ?[Types.HttpHeader] = ?[
                  {
                    name = "Authorization";
                    value = "Bearer " # API_KEY;
                  },
                  {
                    name = "OpenAI-Beta";
                    value = "assistants=v2";
                  },
                  {
                    name = "x-forwarded-host";
                    value = "api.openai.com";
                  },
                ];

                let response = await Request.get(
                  "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads/" # run.threadId # "/messages",
                  transform,
                  headers,
                );

                // Get message content from JSON response
                var value : ?Text = Utils.getOpenAiRunValue(response.body, run.runId);

                // Update enrolled course messages
                switch (value) {
                  case (null) { #err(#Other("Run has no message")) };
                  case (?v) {
                    switch (run.job) {
                      case (#Message) {
                        let newMessage : Message = {
                          runId = ?run.runId;
                          content = v;
                          role = #System;
                        };
                        Vector.add<Message>(eCourse.messages, newMessage);
                        Vector.put(member.enrolledCourses, enrolledCourseIdx, eCourse);
                        Map.set(members, thash, userId, member);
                        let updatedRun = {
                          runId = run.runId;
                          threadId = run.threadId;
                          status = run.status;
                          timestamp = run.timestamp;
                          lastExecuted = ?Time.now();
                          job = run.job;
                          var processing = false;
                        };
                        Map.set<Text, ThreadRun>(threadRunQueue, thash, run.runId, updatedRun);
                        return #ok(newMessage);
                      };
                      case (_) {
                        #err(#Other("Invalid run job"));
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
      case (null) {
        #err(#NotFound("User not found"));
      };
    };
  };

  // Set run processing status
  public shared ({ caller }) func setRunProcess(runId : Text, processing : Bool) : async Result<(), ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    let newRun = Map.get(threadRunQueue, thash, runId);
    switch (newRun) {
      case (null) {
        return #err(#NotFound("Run not found"));
      };
      case (?n) {
        n.processing := processing;
        #ok(Map.set(threadRunQueue, thash, runId, n));
      };
    };
  };

  // Get run questions
  public shared ({ caller }) func getRunQuestions(runId : Text) : async Result<[Question], ApiError> {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    let _r = Map.get(threadRunQueue, thash, runId);
    switch (_r) {
      case (null) { #err(#NotFound("Run not found")) };
      case (?run) {
        if (run.processing or run.status != #Completed) {
          return #err(#Other("A run is still processing"));
        };
        run.processing := true;
        Map.set(threadRunQueue, thash, run.runId, run);

        var course : ?Course = null;

        label findCourse for ((k, v) in Map.entries(courseThreads)) {
          if (v == run.threadId) {
            course := _getCourse(k);
            break findCourse;
          };
        };

        switch (course) {
          case (null) { #err(#Other("Course not found for thread id")) };
          case (?c) {
            let headers : ?[Types.HttpHeader] = ?[
              {
                name = "Authorization";
                value = "Bearer " # API_KEY;
              },
              {
                name = "OpenAI-Beta";
                value = "assistants=v2";
              },
              {
                name = "x-forwarded-host";
                value = "api.openai.com";
              },
            ];

            let response = await Request.get(
              "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads/" # run.threadId # "/messages",
              transform,
              headers,
            );

            var value : ?Text = Utils.getOpenAiRunValue(response.body, run.runId);

            switch (value) {
              case (null) { #err(#Other("Run has no message")) };
              case (?v) {

                Debug.print("Run value");
                Debug.print(v);

                switch (run.job) {
                  case (#Question) {
                    var jsonText = Text.trimStart(v, #text "```json");
                    jsonText := Text.trimEnd(v, #text "```");
                    let json = JSON.parse(jsonText);
                    switch (json) {
                      case (null) { return #err(#Other("Bad json format")) };
                      case (?j) {
                        switch (j) {
                          case (#Array(v)) {
                            let qsItems = c.questions;
                            for (i in v.vals()) {
                              switch (i) {
                                case (#Object(v)) {
                                  var description = "";
                                  var correctOption = 0;
                                  let options = Vector.new<QuestionOption>();
                                  for ((k, v) in v.vals()) {
                                    switch (k) {
                                      case ("q") {
                                        switch (v) {
                                          case (#String(v)) {
                                            description := v;
                                          };
                                          case (_) {
                                            return #err(#Other("Expected: String"));
                                          };
                                        };
                                      };
                                      case ("o") {
                                        switch (v) {
                                          case (#Array(v)) {
                                            var idx = 0;
                                            for (i in v.vals()) {
                                              let option = {
                                                option = idx;
                                                description = switch (i) {
                                                  case (#String(v)) {
                                                    v;
                                                  };
                                                  case (_) { "" };
                                                };
                                              };
                                              Vector.add(options, option);
                                              idx := idx + 1;
                                            };
                                          };
                                          case (_) {
                                            return #err(#Other("Expected: Array"));
                                          };
                                        };
                                      };
                                      case ("a") {
                                        switch (v) {
                                          case (#String(v)) {
                                            switch (Nat.fromText(v)) {
                                              case (null) {
                                                return #err(#Other("Invalid option"));
                                              };
                                              case (?n) {
                                                correctOption := n;
                                              };
                                            };
                                          };
                                          case (_) {
                                            return #err(#Other("Expected: String for answer"));
                                          };
                                        };
                                      };
                                      case (_) {
                                        return #err(#Other("Expected: q, a or o"));
                                      };
                                    };
                                  };
                                  let aOptions = Vector.toArray(options);
                                  let qsItem = {
                                    id = await Utils.uuid();
                                    description = description;
                                    correctOption = correctOption;
                                    options = aOptions;
                                  };
                                  Vector.add<Question>(qsItems, qsItem);
                                };
                                case (_) {
                                  return #err(#Other("Unexpected json format"));
                                };
                              };
                            };
                            let updatedCourse = {
                              id = c.id;
                              title = c.title;
                              summary = c.summary;
                              resources = c.resources;
                              questions = qsItems;
                              knowledgebase = c.knowledgebase;
                            };
                            Map.set(courses, thash, c.id, updatedCourse);

                            let updatedRun = {
                              runId = run.runId;
                              threadId = run.threadId;
                              status = run.status;
                              timestamp = run.timestamp;
                              lastExecuted = ?Time.now();
                              job = run.job;
                              var processing = false;
                            };
                            Map.set<Text, ThreadRun>(threadRunQueue, thash, run.runId, updatedRun);
                            return #ok(Vector.toArray(qsItems));
                          };
                          case (_) {
                            return #err(#Other("Expected array of questions"));
                          };
                        };
                      };
                    };
                  };
                  case (_) {
                    return #err(#Other("Invalid run job"));
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  // Get in progress thread runs
  public query func getRunsInQueue() : async [SharedThreadRun] {
    let sharedRuns = Vector.new<SharedThreadRun>();
    for (k in Map.vals(threadRunQueue)) {
      if (k.processing) {
        let sharedRun = {
          runId = k.runId;
          threadId = k.threadId;
          status = k.status;
          timestamp = k.timestamp;
          lastExecuted = k.lastExecuted;
          job = k.job;
          processing = true;
        };
        Vector.add(sharedRuns, sharedRun);
      } else {
        let sharedRun = {
          runId = k.runId;
          threadId = k.threadId;
          status = k.status;
          timestamp = k.timestamp;
          lastExecuted = k.lastExecuted;
          job = k.job;
          processing = false;
        };
        Vector.add(sharedRuns, sharedRun);
      };

    };
    Vector.toArray(sharedRuns);
  };

  // Jobs
  private func pollRuns() : async () {
    // Poll for run status
    label queue for (run in Map.vals(threadRunQueue)) {
      if (run.processing) {
        continue queue;
      };
      run.processing := true;
      Debug.print("Processing " # run.runId);
      Map.set(threadRunQueue, thash, run.runId, run);

      switch (run.status) {
        case (#InProgress) {
          // Poll run id
          let headers : ?[Types.HttpHeader] = ?[
            {
              name = "Authorization";
              value = "Bearer " # API_KEY;
            },
            {
              name = "OpenAI-Beta";
              value = "assistants=v2";
            },
            {
              name = "x-forwarded-host";
              value = "api.openai.com";
            },
          ];

          let resResult = try {
            #ok(
              await Request.get(
                "https://idempotent-proxy-cf-worker.zensh.workers.dev/v1/threads/" # run.threadId # "/runs/" # run.runId,
                transform,
                headers,
              )
            );
          } catch e #err(e);

          var runStatus : RunStatus = #InProgress;

          switch (resResult) {
            case (#err(e)) {
              Debug.print("Error: " # Error.message(e));
            };
            case (#ok(response)) {
              Debug.print(debug_show (response.status));
              Debug.print(JSON.show(response.body));

              if (response.status != 200) {
                runStatus := #Failed;
              } else {
                var status = "";
                switch (response.body) {
                  case (#Object(v)) {
                    label findId for ((k, v) in v.vals()) {
                      if (k == "status") {
                        switch (v) {
                          case (#String(v)) {
                            status := v;
                            break findId;
                          };
                          case (_) {};
                        };
                      };
                    };
                  };
                  case (_) {};
                };

                Debug.print("Run status: " # status);
                switch (status) {
                  case ("in_progress") {
                    runStatus := #InProgress;
                  };
                  case ("queued") {
                    runStatus := #InProgress;
                  };
                  case ("completed") {
                    runStatus := #Completed;
                  };
                  case ("failed") {
                    runStatus := #Failed;
                  };
                  case ("cancelled") {
                    runStatus := #Cancelled;
                  };
                  case ("expired") {
                    runStatus := #Expired;
                  };
                  case (_) {
                    runStatus := #Failed;
                  };
                };
              };
            };
          };

          let updatedRun = {
            runId = run.runId;
            threadId = run.threadId;
            status = runStatus;
            timestamp = run.timestamp;
            lastExecuted = ?Time.now();
            job = run.job;
            var processing = false;
          };
          Debug.print("Updating run: " # debug_show (runStatus));
          Map.set<Text, ThreadRun>(threadRunQueue, thash, run.runId, updatedRun);
        };
        case (_) {
          switch (run.lastExecuted) {
            case (null) {};
            case (?timestamp) {
              let LIFESPAN = 60 * 60000000000; // 5 mins in nano secs
              if (Time.now() - timestamp > LIFESPAN) {
                // Run has exceeded lifespan and should be removed
                Map.delete<Text, ThreadRun>(threadRunQueue, thash, run.runId);
              };
            };
          };
        };
      };
      let newRun = Map.get(threadRunQueue, thash, run.runId);
      switch (newRun) {
        case (null) {};
        case (?n) {
          n.processing := false;
          Debug.print("Finished Processing " # run.runId);
          Map.set<Text, ThreadRun>(threadRunQueue, thash, run.runId, n);
        };
      };
    };
  };

  // Timers
  ignore recurringTimer<system>(#seconds 5, pollRuns);

  stable var CANISTER_CREATION_CANISTER_ID : Text = "bkyz2-fmaaa-aaaaa-qaaaq-cai";
  var canisterCreationCanister : Types.CanisterCreator = actor (CANISTER_CREATION_CANISTER_ID);
  public shared (msg) func setCanisterCreationCanisterId(_canister_creation_canister_id : Text) : async Types.AuthRecordResult {
    if (not _isAllowed(caller)) return #err(#Unauthorized);
    CANISTER_CREATION_CANISTER_ID := _canister_creation_canister_id;
    canisterCreationCanister := actor (CANISTER_CREATION_CANISTER_ID);
    let authRecord = {
      auth = "You set the creation canister for this canister.";
    };
    return #ok(authRecord);
  };

  public shared ({ caller }) func addEmbedding(canisterId: Text, content : Text, embedding: [Float]) : async Result<Text, ApiError> {
    let vdb : Types.ArcMind = actor (canisterId);
    #ok(await vdb.add({ content = content; embeddings = embedding }));
  };

  // Course Knowledge base
  private func createKnowledgeBaseCanister() : async Types.CourseCanisterCreationResult {
    let canisterConfiguration : Types.CanisterCreationConfiguration = {
      canisterType = #Knowledgebase;
      owner = Principal.fromActor(this);
    };
    let createCanisterResult : Types.CanisterCreationResult = await canisterCreationCanister.createCanister(canisterConfiguration);
    Debug.print("Create canister result");
    Debug.print(debug_show (createCanisterResult));

    switch (createCanisterResult) {
      case (#Err(createCanisterError)) {
        return #err(#Other(debug_show (createCanisterError)));
      };
      case (#Ok(createCanisterSuccess)) {
        // Create new entry for user
        let newCanisterInfo : Types.CanisterInfo = {
          canisterType : Types.CanisterType = #Knowledgebase;
          creationTimestamp : Nat64 = Nat64.fromNat(Int.abs(Time.now()));
          canisterAddress : Text = createCanisterSuccess.newCanisterId;
        };
        return #ok(newCanisterInfo);
      };
    };
  };
};
