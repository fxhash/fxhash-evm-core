import { newMockEvent } from "matchstick-as";
import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts";
import { FxHashProjectCreated } from "../src/types/FxhashFactory/FxHashFactory";

export function createFxHashProjectCreatedEvent(
  genTk: Address,
  issuer: Address,
  owner: Address,
): FxHashProjectCreated {
  const fxHashProjectCreatedEvent = changetype<FxHashProjectCreated>(
    newMockEvent(),
  );
  fxHashProjectCreatedEvent.parameters = [
    new ethereum.EventParam("_genTk", ethereum.Value.fromAddress(genTk)),
    new ethereum.EventParam("_issuer", ethereum.Value.fromAddress(issuer)),
    new ethereum.EventParam("_owner", ethereum.Value.fromAddress(owner)),
  ];

  return fxHashProjectCreatedEvent;
}
