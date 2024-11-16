import Text "mo:base/Text";
import { test; suite; expect } "mo:test/async";
import Utils "../Utils";
import JSON "mo:json.mo";
import Vector "mo:vector";

await suite(
  "Test utilities module",
  func() : async () {
    await test(
      "test hashing text",
      func() : async () {
        let result = Utils.hashText("Bob");
        expect.text(result).equal("cd9fb1e148ccd8442e5aa74904cc73bf6fb54d1d54d333bd596aa9bb4bb4e961");
      },
    );
    await test(
      "test uuid",
      func() : async () {
        let result = await Utils.uuid();
        let len = Text.size(result);
        expect.nat(len).equal(36);
      },
    );
    await test(
      "test get open ai run value",
      func() : async () {

        let open_ai_messages = JSON.parse("
        {
            \"object\": \"list\",
            \"data\": [
                {
                    \"id\": \"msg_Wo25cukH1UjdhjIFQvpJYx0j\",
                    \"object\": \"thread.message\",
                    \"created_at\": 1724773505,
                    \"assistant_id\": \"asst_XZBwCj5Y1RVhWH6dVLB8hl1m\",
                    \"thread_id\": \"thread_kBrvDwkgulFR6kciogmG3lxn\",
                    \"run_id\": \"run_W8s2VKzRCzy5Ak5NXM2tOfvX\",
                    \"role\": \"assistant\",
                    \"content\": [
                        {
                            \"type\": \"text\",
                            \"text\": {
                                \"value\": \"Hello\",
                                \"annotations\": []
                            }
                        }
                    ],
                    \"attachments\": [],
                    \"metadata\": {}
                }
            ],
            \"first_id\": \"msg_Wo25cukH1UjdhjIFQvpJYx0j\",
            \"last_id\": \"msg_hDQvx81p2bUMVd7BkjG608Cw\",
            \"has_more\": false
        }
        ");

        switch (open_ai_messages) {
          case (null) {
            assert false;
          };
          case (?json) {
            let result = Utils.getOpenAiRunValue(json, "run_W8s2VKzRCzy5Ak5NXM2tOfvX");
            switch (result) {
              case (?v) {
                expect.text(v).equal("Hello");
              };
              case (null) {
                assert false;
              };
            };
          };
        };
      },
    );
    await test(
      "test resourceEqual",
      func() : async () {
        let resourceA = {
          id = "1";
          title = "title";
          url = "url";
          rType = #Video;
        };
        let resourceB = {
          id = "1";
          title = "title";
          url = "url";
          rType = #Video;
        };
        let resourceC = {
          id = "2";
          title = "title";
          url = "url";
          rType = #Video;
        };
        var result = Utils.resourceEqual(resourceA, resourceB);
        assert result;
        result := Utils.resourceEqual(resourceA, resourceC);
        expect.bool(result).isFalse();
      },
    );
    await test(
      "test questionEqual",
      func() : async () {
        let questionA = {
          id = "1";
          description = "title";
          options = [
            { option = 1; description = "option 1" },
            { option = 2; description = "option 2" },
          ];
          correctOption = 0;
        };
        let questionB = {
          id = "1";
          description = "title";
          options = [
            { option = 1; description = "option 1" },
            { option = 2; description = "option 2" },
          ];
          correctOption = 0;
        };
        let questionC = {
          id = "2";
          description = "title";
          options = [
            { option = 1; description = "option 1" },
            { option = 2; description = "option 2" },
          ];
          correctOption = 0;
        };
        var result = Utils.questionEqual(questionA, questionB);
        assert result;
        result := Utils.questionEqual(questionA, questionC);
        expect.bool(result).isFalse();
      },
    );
    await test(
      "test vecContains",
      func() : async () {
        let resource: Utils.ModelConvertible = #resource(Vector.fromArray([
          {
            id = "1";
            title = "title";
            url = "url";
            rType = #Video;
          },
          {
            id = "2";
            title = "title";
            url = "url";
            rType = #Video;
          },
        ]));
        let question: Utils.ModelConvertible = #question(Vector.fromArray([
          {
            id = "1";
            description = "title";
            options = [
              { option = 1; description = "option 1" },
              { option = 2; description = "option 2" },
            ];
            correctOption = 0;
          },
          {
            id = "2";
            description = "title";
            options = [
              { option = 1; description = "option 1" },
              { option = 2; description = "option 2" },
            ];
            correctOption = 0;
          },
        ]));
        assert Utils.vecContains(resource, "1");
        expect.bool(Utils.vecContains(resource, "3")).isFalse();
        assert Utils.vecContains(question, "1");
        expect.bool(Utils.vecContains(question, "3")).isFalse();
      },
    );
    await test(
      "test createIcrcActor",
      func() : async () {
        let _ = await Utils.createIcrcActor("aaaaa-aa");
      },
    );
  },
);
