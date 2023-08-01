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

describe("FxHash factory handlers", () => {
  beforeEach(() => {
    const genTk = Address.fromString(
      "0x0000000000000000000000000000000000000001",
    );
    const issuer = Address.fromString(
      "0x0000000000000000000000000000000000000001",
    );
    const owner = Address.fromString(
      "0x0000000000000000000000000000000000000001",
    );
    fxHashProjectCreatedEvent = createFxHashProjectCreatedEvent(
      genTk,
      issuer,
      owner,
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
      Address.fromString("0x0000000000000000000000000000000000000004")
    );
    handleNewProject(fxHashProjectCreatedEvent);
  });

  test("Multiple Projects Created", () => {
    fxHashProjectCreatedEvent = createFxHashProjectCreatedEvent(
      Address.fromString("0x0000000000000000000000000000000000000002"),
      Address.fromString("0x0000000000000000000000000000000000000003"),
      Address.fromString("0x0000000000000000000000000000000000000004")
    );
    handleNewProject(fxHashProjectCreatedEvent);

    fxHashProjectCreatedEvent = createFxHashProjectCreatedEvent(
      Address.fromString("0x0000000000000000000000000000000000000002"),
      Address.fromString("0x0000000000000000000000000000000000000003"),
      Address.fromString("0x0000000000000000000000000000000000000004")
    );
    handleNewProject(fxHashProjectCreatedEvent);
  });
});
