import Text "mo:base/Text";
import { test; suite; expect } "mo:test/async";
import Request "../request";
import JSON "mo:json.mo";
import Vector "mo:vector";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Debug "mo:base/Debug";

await suite(
  "Test request module",
  func() : async () {
    await test(
      "test getHost",
      func() : async () {
        let result = Request.getHost("https://example.com");
        expect.text(result).equal("example.com");
        expect.text(Request.getHost("http://example.com")).equal("example.com");
      },
    );
    await test(
      "test getPort",
      func() : async () {
        expect.text(Request.getPort("https://example.com")).equal(":443");
        expect.text(Request.getPort("http://example.com")).equal(":80");
      },
    );
    await test(
      "test formatHttpResponse",
      func() : async () {
        let json = "{\"key\":\"val.ue\"}";
        let response = await Request.formatHttpResponse({
          status = 200;
          headers = [];
          body = Blob.toArray(Text.encodeUtf8(json));
        });
        let expected = JSON.parse("{\"key\":\"value\"}");
        expect.nat(response.status).equal(200);
        switch expected {
          case (?expected) {
            expect.text(JSON.show(response.body)).equal(JSON.show(expected));
          };
          case (null) {
            assert false;
          };
        };
      },
    );
    await test(
      "test getHeaders",
      func() : async () {
        let headers = await Request.getHeaders("https://example.com", null);
        expect.nat(Array.size(headers)).equal(4);
        expect.text(headers[0].name).equal("Host");
        expect.text(headers[0].value).equal("example.com:443");
      },
    );
  },
);
