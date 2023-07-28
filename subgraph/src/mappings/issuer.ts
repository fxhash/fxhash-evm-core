import { log } from "@graphprotocol/graph-ts";
import {
  Codex,
  IssuerBurnedEvent,
  IssuerMintedEvent,
  IssuerModUpdatedEvent,
  IssuerUpdatedEvent,
  OnChainScript,
  PriceUpdatedEvent,
  Pricing,
  Reserve,
  Split,
} from "../types/schema";
import {
  IssuerBurned,
  IssuerMinted,
  IssuerModUpdated,
  IssuerUpdated,
  PriceUpdated,
} from "../types/templates/Issuer/Issuer";

export function handleIssuerMinted(event: IssuerMinted): void {
  let issuerMintedEvent = new IssuerMintedEvent(
    event.transaction.hash.toHexString(),
  );

  let codex = new Codex(event.transaction.hash.toHexString());
  codex.inputType = event.params.params.codex.inputType;
  codex.value = event.params.params.codex.value;
  codex.codexId = event.params.params.codex.codexId;

  let reserves: Reserve[] = [];
  for (let i = 0; i < event.params.params.reserves.length; i++) {
    const methodId = event.params.params.reserves[i].methodId;
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
  /**
   *  TODO: This is a hack to get around the fact that
   *  event.params.params.primarySplit.receiver and event.params.params.primarySplit.percent
   *  can't be called directly, it gives an error saying that it's not a the type it expects
   *  I am even surprised it works tbh
   *     🛠  Mapping aborted at ~lib/@graphprotocol/graph-ts/chain/ethereum.ts, line 53, column 7, with message: Ethereum value is not an address
      wasm backtrace:
        0: 0x3e58 - <unknown>!~lib/@graphprotocol/graph-ts/chain/ethereum/ethereum.Value#toAddress
   **/
  primarySplit.recipient = event.params.params.primarySplit[0].toAddress();
  //TODO: same hack here
  primarySplit.value = event.params.params.primarySplit[1].toBigInt();
  primarySplit.save();

  let royaltiesSplit = new Split("S-" + event.transaction.hash.toHexString());
  //TODO: same hack here
  royaltiesSplit.recipient = event.params.params.royaltiesSplit[0].toAddress();
  //TODO: same hack here
  royaltiesSplit.value = event.params.params.royaltiesSplit[1].toBigInt();
  royaltiesSplit.save();

  let onChainScripts: string[] = [];
  for (let i = 0; i < event.params.params.onChainScripts.length; i++) {
    let onChainScript = new OnChainScript(
      event.params.params.onChainScripts[i].name,
    );

    //TODO: same hack here
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

  issuerMintedEvent.codexData = codex.id;
  issuerMintedEvent.metadata = event.params.params.metadata;
  issuerMintedEvent.inputBytesSize = event.params.params.inputBytesSize;
  issuerMintedEvent.amount = event.params.params.amount;
  issuerMintedEvent.openEditionsClosingTime =
    event.params.params.openEditions.closingTime;
  issuerMintedEvent.mintTicketGracingPeriod =
    event.params.params.mintTicketSettings.gracingPeriod;
  issuerMintedEvent.reserves = reserves.map<string>((r) => r.id);
  issuerMintedEvent.pricing = pricing.id;
  issuerMintedEvent.primarySplit = primarySplit.id;
  issuerMintedEvent.royaltiesSplit = royaltiesSplit.id;
  issuerMintedEvent.enabled = event.params.params.enabled;
  issuerMintedEvent.tags = event.params.params.tags;
  issuerMintedEvent.onChainScripts = onChainScripts;
  issuerMintedEvent.address = event.address;
  issuerMintedEvent.timestamp = event.block.timestamp;
  issuerMintedEvent.level = event.block.number;
  issuerMintedEvent.save();
}

export function handleIssuerBurned(event: IssuerBurned): void {
  let issuerBurnedEvent = new IssuerBurnedEvent(
    event.transaction.hash.toHexString(),
  );
  issuerBurnedEvent.issuer = event.address;
  issuerBurnedEvent.timestamp = event.block.timestamp;
  issuerBurnedEvent.level = event.block.number;
  issuerBurnedEvent.save();
}

export function handleIssuerModUpdated(event: IssuerModUpdated): void {
  let issuerModUpdatedEvent = new IssuerModUpdatedEvent(
    event.transaction.hash.toHexString(),
  );
  issuerModUpdatedEvent.tags = event.params.tags;
  issuerModUpdatedEvent.issuer = event.address;
  issuerModUpdatedEvent.timestamp = event.block.timestamp;
  issuerModUpdatedEvent.level = event.block.number;
  issuerModUpdatedEvent.save();
}

export function handleIssuerUpdated(event: IssuerUpdated): void {
  let issuerModUpdatedEvent = new IssuerUpdatedEvent(
    event.transaction.hash.toHexString(),
  );

  let primarySplit = new Split("P-" + event.transaction.hash.toHexString());
  //TODO: same hack here
  primarySplit.recipient = event.params.params.primarySplit[0].toAddress();
  //TODO: same hack here
  primarySplit.value = event.params.params.primarySplit[1].toBigInt();
  primarySplit.save();

  let royaltiesSplit = new Split("S-" + event.transaction.hash.toHexString());
  //TODO: same hack here
  royaltiesSplit.recipient = event.params.params.royaltiesSplit[0].toAddress();
  //TODO: same hack here
  royaltiesSplit.value = event.params.params.royaltiesSplit[1].toBigInt();
  royaltiesSplit.save();

  issuerModUpdatedEvent.primarySplit = primarySplit.id;
  issuerModUpdatedEvent.royaltiesSplit = royaltiesSplit.id;
  issuerModUpdatedEvent.enabled = event.params.params.enabled;
  issuerModUpdatedEvent.issuer = event.address;
  issuerModUpdatedEvent.timestamp = event.block.timestamp;
  issuerModUpdatedEvent.level = event.block.number;
  issuerModUpdatedEvent.save();
}

export function handlePriceUpdated(event: PriceUpdated): void {
  let priceUpdatedEvent = new PriceUpdatedEvent(
    event.transaction.hash.toHexString(),
  );
  let pricing = new Pricing(event.transaction.hash.toHexString());
  pricing.pricingId = event.params.params.pricingId;
  pricing.details = event.params.params.details;
  pricing.lockForReserves = event.params.params.lockForReserves;
  pricing.save();

  priceUpdatedEvent.issuer = event.address;
  priceUpdatedEvent.pricing = pricing.id;
  priceUpdatedEvent.timestamp = event.block.timestamp;
  priceUpdatedEvent.level = event.block.number;
  priceUpdatedEvent.save();
}
