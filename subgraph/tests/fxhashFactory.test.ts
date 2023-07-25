import {
  describe,
  test,
  clearStore,
  beforeEach,
  afterEach,
} from "matchstick-as/assembly/index";
import { BigInt, Address } from "@graphprotocol/graph-ts";
import { handleNewProject } from "../src/mappings/fxhashFactory";
import { FxHashProjectCreated } from "../src/types/FxhashFactory/FxHashFactory";
import { createFxHashProjectCreatedEvent } from "./fxhashFactory_utils";

let fxHashProjectCreatedEvent: FxHashProjectCreated;

describe("Scoped / Nested block", () => {
  beforeEach(() => {
    const genTk = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    );
    const issuer = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    );
    const owner = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    );
    const timestamp = BigInt.fromI32(12);
    fxHashProjectCreatedEvent = createFxHashProjectCreatedEvent(
      genTk,
      issuer,
      owner,
      timestamp
    );
    handleNewProject(fxHashProjectCreatedEvent);
  });
  afterEach(() => {
    clearStore();
  });

  test("Single Project Created", () => {
    fxHashProjectCreatedEvent = createFxHashProjectCreatedEvent(
      Address.fromString("0x0000000000000000000000000000000000000002"),
      Address.fromString("0x0000000000000000000000000000000000000003"),
      Address.fromString("0x0000000000000000000000000000000000000004"),
      BigInt.fromI32(12)
    );
    handleNewProject(fxHashProjectCreatedEvent);
  });

  test("Multiple Projects Created", () => {
    fxHashProjectCreatedEvent = createFxHashProjectCreatedEvent(
      Address.fromString("0x0000000000000000000000000000000000000002"),
      Address.fromString("0x0000000000000000000000000000000000000003"),
      Address.fromString("0x0000000000000000000000000000000000000004"),
      BigInt.fromI32(12)
    );
    handleNewProject(fxHashProjectCreatedEvent);

    fxHashProjectCreatedEvent = createFxHashProjectCreatedEvent(
      Address.fromString("0x0000000000000000000000000000000000000002"),
      Address.fromString("0x0000000000000000000000000000000000000003"),
      Address.fromString("0x0000000000000000000000000000000000000004"),
      BigInt.fromI32(14)
    );
    handleNewProject(fxHashProjectCreatedEvent);
  });
});
