#!ic-repl
load "prelude.sh";

identity bob;
identity alice;

// Deploy backend canister
let wasm = file(".dfx/local/canisters/backend/backend.wasm");
let init = record {
  caller = alice;
};
let S = install(wasm, init, null);


// Deploy ledger canister
function deploy_token() {
  identity minter;
  identity archive_controller;
  let wasm = file(".dfx/local/canisters/icrc1_ledger_canister/icrc1_ledger_canister.wasm.gz");
  let init = variant {Init = record {
      token_symbol = "ACT";
      token_name = "AntiCorruptionToken";
      minting_account = record { owner = minter };
      transfer_fee = (10000:nat);
      metadata = vec {};
      feature_flags = opt record{icrc2 = true};
      initial_balances = vec { record { record { owner = alice; }; (10000000000000:nat); }; };
      archive_options = record {
          num_blocks_to_archive = (1000:nat64);
          trigger_threshold = (2000:nat64);
          controller_id = archive_controller;
          cycles_for_archive_creation = opt (10000000000000:nat64);
      };
    }
  };
  identity alice;
  install(wasm, init, null);
};
// let L = deploy_token();


function test_generate_random_number() {
  identity alice;  
  call S.generateRandomNumber(10);
  assert lte(_, 10) == true;
};

function test_owner() {
  identity alice;  
  call S.getOwner();
  assert _ == alice;

  call S.changeOwner(stringify(bob));
  assert _ == variant { ok };
  call S.getOwner();
  assert _ == bob;
  identity bob;
  call S.changeOwner(stringify(alice));
};

function test_acls() {
  identity alice;
  call S.getAcls();
  assert _.size() == (0: nat);

  call S.addAcls(bob);
  call S.getAcls();
  assert _.size() == (1: nat);

  call S.removeAcls(bob);
  assert _ == variant { ok };
  call S.getAcls();
  assert _.size() == (0: nat);

  call S.removeAcls(bob);
  assert _ == variant { err = variant { NotFound = "Principal not found" } };
};

function test_token_canister() {
  identity alice;  
  call S.get_icrc1_token_canister_id();
  assert _ == "invalid";

  call S.set_icrc1_token_canister(L);
  assert _ == variant { ok };
};

function test_api_key() {
  identity alice;
  call S.changeApiKey("test");
  assert _ == variant { ok };

  call S.addAcls(bob);
  identity bob;
  call S.changeApiKey("test");
  assert _ == variant { ok };

  identity malice;
  call S.changeApiKey("test");
  assert _ == variant { err = variant { Unauthorized } };
};

function test_assistant_id() {
  identity alice;
  call S.setAssistantId("test");
  assert _ == variant { ok };

  call S.addAcls(bob);
  identity bob;
  call S.setAssistantId("test");
  assert _ == variant { ok };

  identity malice;
  call S.setAssistantId("test");
  assert _ == variant { err = variant { Unauthorized } };
};

function test_login_or_register() {
  identity user1;
  let res1 = call S.loginOrRegiser("user1");
  let res2 = call S.loginOrRegiser("user1");
  assert res1 == res2;
};

function test_connect_user_principal() {
  identity anonymous;
  call S.loginOrRegiser("user2");
  let id = _.ok;
  identity user2;
  call S.connectUserToPrincipal(id);
  assert _.ok == "User connected to principal successfully";
  call S.connectUserToPrincipal(id);
  assert _.err.Other == "User already connected to principal";
  call S.connectUserToPrincipal("unknown");
  assert _.err.NotFound == "User not found";
};

function test_get_profile() {
  identity user3;
  call S.loginOrRegiser("user3");
  let id = _.ok;
  let res = call S.getProfile(id);
  assert res.ok.id == id;
  assert res.ok.fullname == "user3";
  assert res.ok.claimableTokens == (0:nat);
  assert res.ok."principal" == opt user3;
};

function test_courses() {
  // Test list courses
  call S.listCourses();
  assert _.size() == (0:nat);

  // Test create course
  identity alice;
  call S.createCourse("test", "test");
  let courseId = _.ok;
  call S.listCourses();
  assert _.size() == (1:nat);

  // Test update course
  call S.updateCourse(courseId, "new title", "new summary");
  assert _.ok == "Course updated successfully";
  call S.updateCourse("fake", "new title", "new summary");
  assert _.err.NotFound == "Course not found";
};

function test_course_resources() {
  identity alice;
  call S.createCourse("test", "test");
  let courseId = _.ok;

  // Test create resource
  call S.createResource(courseId, "test", "test", variant { Book });
  assert _.ok == "Resource created successfully";
  call S.createResource("fake", "test", "test", variant { Book });
  assert _.err.NotFound == "Course not found";

  // Test get course resources
  let res = call S.getCourseResources(courseId);
  assert res.ok.size() == (1:nat);
  let resourceId = res.ok[0].id;

  // Test remove resource
  call S.removeResource(courseId, resourceId);
  assert _ == variant { ok };
  call S.getCourseResources(courseId);
  assert _.ok.size() == (0:nat);
  call S.removeResource(courseId, "fake");
  assert _.err.NotFound == "Resource not found";
  call S.removeResource("fake", "fake");
  assert _.err.NotFound == "Course not found";
};

function test_course_questions() {
  identity alice;
  call S.createCourse("test", "test");
  let courseId = _.ok;

  // Test add question
  let question = record {
    correctOption=(0: nat);
    description="test";
    id="";
    options=vec {
      record { description = "option1"; option = (0:nat); };
      record { description = "option2"; option = (1:nat); };
    };
  };
  call S.addQuestion(courseId, question);
  assert _.ok == "Question added successfully";
  call S.addQuestion("fake", question);
  assert _.err.NotFound == "Course not found";

  // Test get course questions
  let res = call S.getCourseQuestions(courseId);
  let questionId = res.ok[0].id;
  assert res.ok.size() == (1:nat);
  call S.getCourseQuestions("fake");
  assert _.err.NotFound == "Course not found";

  // Test remove question
  call S.removeQuestion(courseId, questionId);
  assert _ == variant { ok };
  call S.removeQuestion(courseId, "fake");
  assert _.err.NotFound == "Question not found";
  call S.removeQuestion("fake", "fake");
  assert _.err.NotFound == "Course not found";
};

function test_random_course_questions() {
  identity alice;
  call S.createCourse("test", "test");
  let courseId = _.ok;

  // Test get random course questions
  let question = record {
    correctOption=(0: nat);
    description="test";
    id="";
    options=vec {
      record { description = "option1"; option = (0:nat); };
      record { description = "option2"; option = (1:nat); };
    };
  };
  call S.addQuestion(courseId, question);
  call S.addQuestion(courseId, question);
  call S.addQuestion(courseId, question);
  call S.addQuestion(courseId, question);
  let res = call S.getCourseQuestions(courseId);
  assert res.ok.size() == (4:nat);
  let res = call S.getRandomCourseQuestions(courseId, 3);
  assert res.ok.size() == (3:nat);
  let q1 = res.ok[0].id;
  let q2 = res.ok[1].id;
  let q3 = res.ok[2].id;
  assert q1 != q2;
  assert q1 != q3;
  assert q2 != q3;
};

// Run tests
test_generate_random_number();
test_owner();
test_acls();
test_token_canister();
test_api_key();
test_assistant_id();
test_login_or_register();
test_connect_user_principal();
test_get_profile();
test_courses();
test_course_resources();
test_course_questions();
test_random_course_questions();
