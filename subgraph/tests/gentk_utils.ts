import { ethereum, BigInt, Address, ByteArray } from "@graphprotocol/graph-ts";

import {
  OnChainTokenMetadataAssigned,
  TokenMetadataAssigned,
  Transfer,
} from "../src/types/templates/GenTk/GenTk";
import { newMockEvent } from "matchstick-as";
import {
  OffChainTokenMetadata,
  OnChainTokenMetadata,
} from "../src/types/schema";

export function createTransferEvent(
  from: Address,
  to: Address,
  tokenId: i32,
): Transfer {
  const transferEvent = changetype<Transfer>(newMockEvent());
  transferEvent.parameters = [
    new ethereum.EventParam("from", ethereum.Value.fromAddress(from)),
    new ethereum.EventParam("to", ethereum.Value.fromAddress(to)),
    new ethereum.EventParam("tokenId", ethereum.Value.fromI32(tokenId)),
  ];
  return transferEvent;
}

export function createTokenMetadataAssignedEvent(
  params: Array<ethereum.Tuple>,
): TokenMetadataAssigned {
  const tokenMetadataAssignedEvent = changetype<TokenMetadataAssigned>(
    newMockEvent(),
  );
  tokenMetadataAssignedEvent.parameters = [
    new ethereum.EventParam("_params", ethereum.Value.fromTupleArray(params)),
  ];
  return tokenMetadataAssignedEvent;
}

export function createOnChainTokenMetadataAssignedEvent(
  params: Array<ethereum.Tuple>,
): OnChainTokenMetadataAssigned {
  const onChainTokenMetadataAssignedEvent =
    changetype<OnChainTokenMetadataAssigned>(newMockEvent());
  onChainTokenMetadataAssignedEvent.parameters = [
    new ethereum.EventParam("_params", ethereum.Value.fromTupleArray(params)),
  ];
  return onChainTokenMetadataAssignedEvent;
}
