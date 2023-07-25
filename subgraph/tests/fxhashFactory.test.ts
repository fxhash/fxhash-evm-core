import { expect } from "chai";
import { describe, it } from "mocha";
import { Address, BigInt } from "@graphprotocol/graph-ts";
import { FxHashProjectCreated } from "../src/types/FxhashFactory/FxHashFactory";
import { handleNewProject } from "../src/mappings/fxhashFactory";
import { createFxHashProjectCreatedEvent } from "./fxhashFactory_utils";
import { ProjectCreationEvent } from "../src/types/schema";

const fxHashProjectCreatedEvent = createFxHashProjectCreatedEvent(
  Address.fromString("0x0000000000000000000000000000000000000001"),
  Address.fromString("0x0000000000000000000000000000000000000002"),
  Address.fromString("0x0000000000000000000000000000000000000003"),
  BigInt.fromI32(Date.now())
);

describe("handleNewProject", function () {
  it("correctly processes the input data from the smart contract", function () {
    // Call the handler with the event
    handleNewProject(fxHashProjectCreatedEvent);

    // Load the saved ProjectCreationEvent from the store
    const projectCreationEvent = ProjectCreationEvent.load(
      fxHashProjectCreatedEvent.transaction.hash.toHexString()
    );

    // Check that the event data was processed and saved correctly
    expect(projectCreationEvent.gentk).to.equal(
      fxHashProjectCreatedEvent.params._genTk
    );
    expect(projectCreationEvent.issuer).to.equal(
      fxHashProjectCreatedEvent.params._issuer
    );
    expect(projectCreationEvent.owner).to.equal(
      fxHashProjectCreatedEvent.params._owner
    );
    expect(projectCreationEvent.blockTimestamp).to.equal(
      fxHashProjectCreatedEvent.block.timestamp
    );
  });
});
