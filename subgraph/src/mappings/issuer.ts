import { log } from "@graphprotocol/graph-ts";
import {
  Codex,
  IssuerMintedEvent,
  OnChainScript,
  Pricing,
  Reserve,
  Split,
} from "../types/schema";
import { IssuerMinted } from "../types/templates/Issuer/Issuer";

export function handleIssuerMinted(event: IssuerMinted): void {
  let transferEvent = new IssuerMintedEvent(
    event.transaction.hash.toHexString(),
  );

  let codex = new Codex(event.transaction.hash.toHexString());
  codex.inputType = event.params.params.codex.inputType;
  codex.value = event.params.params.codex.value;
  codex.codexId = event.params.params.codex.codexId;

  let reserves: Reserve[] = [];
  for (let i = 0; i < event.params.params.reserves.length; i++) {
    const methodId = event.params.params.reserves[i][0].toBigInt();
    let reserve = new Reserve(
      event.transaction.hash.toHexString() + "-" + methodId.toString(),
    );
    reserve.methodId = methodId;
    reserve.amount = event.params.params.reserves[i].amount;
    reserve.data = event.params.params.reserves[i].data;
    reserve.save();
    reserves.push(reserve);
  }

  let pricing = new Pricing(event.transaction.hash.toHexString());
  pricing.pricingId = event.params.params.pricing.pricingId;
  pricing.details = event.params.params.pricing.details;
  pricing.lockForReserves = event.params.params.pricing.lockForReserves;
  pricing.save();

  let primarySplit = new Split("P-" + event.transaction.hash.toHexString());
  primarySplit.recipient = event.params.params.primarySplit[0].toAddress();
  primarySplit.value = event.params.params.primarySplit[1].toBigInt();
  primarySplit.save();

  let royaltiesSplit = new Split("S-" + event.transaction.hash.toHexString());
  royaltiesSplit.recipient = event.params.params.royaltiesSplit[0].toAddress();
  royaltiesSplit.value = event.params.params.royaltiesSplit[1].toBigInt();
  royaltiesSplit.save();

  let onChainScripts: string[] = [];
  for (let i = 0; i < event.params.params.onChainScripts.length; i++) {
    let onChainScript = new OnChainScript(
      event.params.params.onChainScripts[i].name,
    );

    onChainScript.storageContractAddress =
      event.params.params.onChainScripts[i][1].toAddress();

    onChainScript.contractData =
      event.params.params.onChainScripts[i].contractData;
    onChainScript.wrapType = event.params.params.onChainScripts[i].wrapType;
    onChainScript.wrapPrefix = event.params.params.onChainScripts[i].wrapPrefix;
    onChainScript.wrapSuffix = event.params.params.onChainScripts[i].wrapSuffix;
    onChainScript.scriptContent =
      event.params.params.onChainScripts[i].scriptContent;
    onChainScript.save();
    onChainScripts.push(onChainScript.id);
  }

  transferEvent.codexData = codex.id;
  transferEvent.metadata = event.params.params.metadata;
  transferEvent.inputBytesSize = event.params.params.inputBytesSize;
  transferEvent.amount = event.params.params.amount;
  transferEvent.openEditionsClosingTime = event.params.params.openEditions.closingTime;
  transferEvent.mintTicketGracingPeriod = event.params.params.mintTicketSettings.gracingPeriod;
  transferEvent.reserves = reserves.map<string>((r) => r.id);
  transferEvent.pricing = pricing.id;
  transferEvent.primarySplit = primarySplit.id;
  transferEvent.royaltiesSplit = royaltiesSplit.id;
  transferEvent.enabled = event.params.params.enabled;
  transferEvent.tags = event.params.params.tags;
  transferEvent.onChainScripts = onChainScripts;
  transferEvent.address = event.address;
  transferEvent.timestamp = event.block.timestamp;
  transferEvent.save();
}
