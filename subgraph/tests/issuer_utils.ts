import {
  ethereum,
  BigInt,
  Address,
  ByteArray,
  Bytes,
} from "@graphprotocol/graph-ts";

import { newMockEvent, log } from "matchstick-as";
import {
  IssuerBurned,
  IssuerMinted,
  IssuerModUpdated,
  IssuerUpdated,
  PriceUpdated,
  ReserveUpdated,
  SupplyBurned,
  TokenMinted,
  TokenMintedWithTicket,
} from "../src/types/templates/Issuer/Issuer";

export function newCodex(
  inputType: BigInt,
  value: Bytes,
  codexId: BigInt,
  issuer: Address,
): ethereum.Tuple {
  let tuple = new ethereum.Tuple(3);
  tuple[0] = ethereum.Value.fromUnsignedBigInt(inputType);
  tuple[1] = ethereum.Value.fromBytes(value);
  tuple[2] = ethereum.Value.fromUnsignedBigInt(codexId);
  tuple[3] = ethereum.Value.fromAddress(issuer);
  return tuple;
}

export function newReserve(
  methodId: BigInt,
  amount: BigInt,
  data: Bytes,
): ethereum.Tuple {
  let tuple = new ethereum.Tuple(3);
  tuple[0] = ethereum.Value.fromUnsignedBigInt(methodId);
  tuple[1] = ethereum.Value.fromUnsignedBigInt(amount);
  tuple[2] = ethereum.Value.fromBytes(data);
  return tuple;
}

export function newPricing(
  pricingId: BigInt,
  details: Bytes,
  lockForReserves: boolean,
): ethereum.Tuple {
  let tuple = new ethereum.Tuple(3);
  tuple[0] = ethereum.Value.fromUnsignedBigInt(pricingId);
  tuple[1] = ethereum.Value.fromBytes(details);
  tuple[2] = ethereum.Value.fromBoolean(lockForReserves);
  return tuple;
}

export function newSplit(recipient: Address, value: BigInt): ethereum.Tuple {
  let tuple = new ethereum.Tuple(2);
  tuple[0] = ethereum.Value.fromAddress(recipient);
  tuple[1] = ethereum.Value.fromUnsignedBigInt(value);
  return tuple;
}

export function newOnChainScript(
  name: string,
  storageContractAddress: Address,
  contractData: Bytes,
  wrapType: i32,
  wrapPrefix: Bytes,
  wrapSufix: Bytes,
  scriptContent: Bytes,
): ethereum.Tuple {
  let tuple = new ethereum.Tuple(7);
  tuple[0] = ethereum.Value.fromString(name);
  tuple[1] = ethereum.Value.fromAddress(storageContractAddress);
  tuple[2] = ethereum.Value.fromBytes(contractData);
  tuple[3] = ethereum.Value.fromI32(wrapType);
  tuple[4] = ethereum.Value.fromBytes(wrapPrefix);
  tuple[5] = ethereum.Value.fromBytes(wrapSufix);
  tuple[6] = ethereum.Value.fromBytes(scriptContent);
  return tuple;
}

export function newOpenEdition(
  openEditionId: BigInt,
  openEditionData: Bytes,
): ethereum.Tuple {
  let tuple = new ethereum.Tuple(2);
  tuple[0] = ethereum.Value.fromUnsignedBigInt(openEditionId);
  tuple[1] = ethereum.Value.fromBytes(openEditionData);
  return tuple;
}

export function newMintTicketSettings(
  mintTicketSettingsId: BigInt,
  mintTicketSettingsData: string,
): ethereum.Tuple {
  let tuple = new ethereum.Tuple(2);
  tuple[0] = ethereum.Value.fromUnsignedBigInt(mintTicketSettingsId);
  tuple[1] = ethereum.Value.fromString(mintTicketSettingsData);
  return tuple;
}

export function createIssuerMintedEvent(
  codex: ethereum.Tuple,
  metadata: Bytes,
  inputBytesSize: BigInt,
  amount: BigInt,
  openEditions: ethereum.Tuple,
  mintTicketSettings: ethereum.Tuple,
  reserves: ethereum.Tuple[],
  pricing: ethereum.Tuple,
  primarySplit: ethereum.Tuple,
  royaltiesSplit: ethereum.Tuple,
  enabled: boolean,
  tags: BigInt[],
  onChainScripts: ethereum.Tuple[],
): IssuerMinted {
  const issuerMintedEvent = changetype<IssuerMinted>(newMockEvent());
  let mintIssuerInput: ethereum.Tuple = new ethereum.Tuple(13);
  mintIssuerInput[0] = ethereum.Value.fromTuple(codex);
  mintIssuerInput[1] = ethereum.Value.fromBytes(metadata);
  mintIssuerInput[2] = ethereum.Value.fromUnsignedBigInt(inputBytesSize);
  mintIssuerInput[3] = ethereum.Value.fromUnsignedBigInt(amount);
  mintIssuerInput[4] = ethereum.Value.fromTuple(openEditions);
  mintIssuerInput[5] = ethereum.Value.fromTuple(mintTicketSettings);
  mintIssuerInput[6] = ethereum.Value.fromTupleArray(reserves);
  mintIssuerInput[7] = ethereum.Value.fromTuple(pricing);
  mintIssuerInput[8] = ethereum.Value.fromTuple(primarySplit);
  mintIssuerInput[9] = ethereum.Value.fromTuple(royaltiesSplit);
  mintIssuerInput[10] = ethereum.Value.fromBoolean(enabled);
  mintIssuerInput[11] = ethereum.Value.fromUnsignedBigIntArray(tags);
  mintIssuerInput[12] = ethereum.Value.fromTupleArray(onChainScripts);

  issuerMintedEvent.parameters = [
    new ethereum.EventParam(
      "params",
      ethereum.Value.fromTuple(mintIssuerInput),
    ),
  ];
  return issuerMintedEvent;
}

export function createIssuerBurnedEvent(): IssuerBurned {
  return changetype<IssuerBurned>(newMockEvent());
}

export function createIssuerModUpdatedEvent(
  tags: Array<BigInt>,
): IssuerModUpdated {
  let event = changetype<IssuerModUpdated>(newMockEvent());
  event.parameters = [
    new ethereum.EventParam("tags", ethereum.Value.fromSignedBigIntArray(tags)),
  ];
  return event;
}

export function createIssuerUpdatedEvent(
  primarySplit: ethereum.Tuple,
  royaltiesSplit: ethereum.Tuple,
  enabled: boolean,
): IssuerUpdated {
  let event = changetype<IssuerUpdated>(newMockEvent());
  let updateIssuerInput: ethereum.Tuple = new ethereum.Tuple(3);
  updateIssuerInput[0] = ethereum.Value.fromTuple(primarySplit);
  updateIssuerInput[1] = ethereum.Value.fromTuple(royaltiesSplit);
  updateIssuerInput[2] = ethereum.Value.fromBoolean(enabled);
  event.parameters = [
    new ethereum.EventParam(
      "params",
      ethereum.Value.fromTuple(updateIssuerInput),
    ),
  ];
  return event;
}

export function createPriceUpdatedEvent(pricing: ethereum.Tuple): PriceUpdated {
  let event = changetype<PriceUpdated>(newMockEvent());
  event.parameters = [
    new ethereum.EventParam("params", ethereum.Value.fromTuple(pricing)),
  ];
  return event;
}

export function createReserveUpdatedEvent(
  reserves: Array<ethereum.Tuple>,
): ReserveUpdated {
  let event = changetype<ReserveUpdated>(newMockEvent());
  event.parameters = [
    new ethereum.EventParam("params", ethereum.Value.fromTupleArray(reserves)),
  ];
  return event;
}

export function createSuplyBurnedEvent(amount: BigInt): SupplyBurned {
  let event = changetype<SupplyBurned>(newMockEvent());
  event.parameters = [
    new ethereum.EventParam(
      "amount",
      ethereum.Value.fromUnsignedBigInt(amount),
    ),
  ];
  return event;
}

export function createTokenMintedEvent(
  inputBytes: Bytes,
  referrer: Address,
  reserveInput: Bytes,
  createTicket: boolean,
  recipient: Address,
): TokenMinted {
  let event = changetype<TokenMinted>(newMockEvent());
  let input = new ethereum.Tuple(5);
  input[0] = ethereum.Value.fromBytes(inputBytes);
  input[1] = ethereum.Value.fromAddress(referrer);
  input[2] = ethereum.Value.fromBytes(reserveInput);
  input[3] = ethereum.Value.fromBoolean(createTicket);
  input[4] = ethereum.Value.fromAddress(recipient);
  event.parameters = [
    new ethereum.EventParam("params", ethereum.Value.fromTuple(input)),
  ];
  return event;
}

export function createTokenMintedWithTicketEvent(
  ticketId: BigInt,
  intputBytes: Bytes,
  recipient: Address
): TokenMintedWithTicket {
  let event = changetype<TokenMintedWithTicket>(newMockEvent());
  let input = new ethereum.Tuple(3);
  input[0] = ethereum.Value.fromUnsignedBigInt(ticketId);
  input[1] = ethereum.Value.fromBytes(intputBytes);
  input[2] = ethereum.Value.fromAddress(recipient);
  event.parameters = [
    new ethereum.EventParam("params", ethereum.Value.fromTuple(input)),
  ];
  return event;
}
