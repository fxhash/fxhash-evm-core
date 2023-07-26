import {
  describe,
  test,
  clearStore,
  beforeEach,
  afterEach,
} from "matchstick-as/assembly/index";
import { BigInt, Address } from "@graphprotocol/graph-ts";
import { handleTransfer } from "../src/mappings/gentk";
import { createTransferEvent } from "./gentk_utils";
import { Transfer } from "../src/types/templates/GenTk/GenTk";

describe("GenTk Handlers", () => {
  beforeEach(() => {
    // Initialize your events here
  });

  afterEach(() => {
    clearStore();
  });

  test("handleTransfer correctly processes the Transfer event", () => {
    let transferEvent = createTransferEvent(
      Address.fromString("0x0000000000000000000000000000000000000001"),
      Address.fromString("0x0000000000000000000000000000000000000002"),
      1,
    );
    handleTransfer(transferEvent);
  });
});
