import { FxHashProjectCreated } from "../types/FxhashFactory/FxHashFactory";
import { ProjectCreationEvent } from "../types/schema";
import { GenTk, Issuer } from "../types/templates";

export function handleNewProject(event: FxHashProjectCreated): void {
  // Start indexing the exchange; `event.params.exchange` is the
  // address of the new exchange contract
  GenTk.create(event.params._genTk);
  Issuer.create(event.params._issuer);

  let projectCreationEvent = new ProjectCreationEvent(
    event.transaction.hash.toHexString()
  );
  projectCreationEvent.gentk = event.params._genTk;
  projectCreationEvent.issuer = event.params._issuer;
  projectCreationEvent.owner = event.params._owner;
  projectCreationEvent.blockTimestamp = event.block.timestamp;
  projectCreationEvent.save();
}
