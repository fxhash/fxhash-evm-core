import {
  TokenTransferEvent,
  TokenMetadataAssignedEvent,
  OffChainTokenMetadata,
  OnChainTokenMetadata,
} from "../types/schema";
import {
  Transfer,
  TokenMetadataAssigned,
  OnChainTokenMetadataAssigned,
} from "../types/templates/GenTk/GenTk";
import { Value, log } from "@graphprotocol/graph-ts";

export function handleTransfer(event: Transfer): void {
  let transferEvent = new TokenTransferEvent(
    event.transaction.hash.toHexString(),
  );
  transferEvent.from = event.params.from;
  transferEvent.to = event.params.to;
  transferEvent.contract = event.address;
  transferEvent.tokenId = event.params.tokenId;
  transferEvent.timestamp = event.block.timestamp;
  transferEvent.save();
}

export function handleTokenMetadataAssigned(
  event: TokenMetadataAssigned,
): void {
  let transferEvent = new TokenMetadataAssignedEvent(
    event.transaction.hash.toHexString(),
  );
  transferEvent.offChainMetadata = [];
  transferEvent.onChainMetadata = [];
  for (let i: i32 = 0; i < event.params._params.length; i++) {
    let value = event.params._params[i];
    let metadataEntry = new OffChainTokenMetadata(
      `${event.address.toHexString()}:${value.tokenId.toString()}`,
    );
    metadataEntry.metadata = value.metadata;
    metadataEntry.save();
    transferEvent.offChainMetadata.push(metadataEntry.id);
  }
  transferEvent.timestamp = event.block.timestamp;
  transferEvent.save();
}

export function handleOnChainTokenMetadataAssigned(
  event: OnChainTokenMetadataAssigned,
): void {
  let transferEvent = new TokenMetadataAssignedEvent(
    event.transaction.hash.toHexString(),
  );
  transferEvent.offChainMetadata = [];
  transferEvent.onChainMetadata = [];
  for (let i: i32 = 0; i < event.params._params.length; i++) {
    let value = event.params._params[i];
    let metadataEntry = new OnChainTokenMetadata(
      `${event.address.toHexString()}:${value.tokenId.toString()}`,
    );
    metadataEntry.metadata = value.metadata;
    metadataEntry.save();
    transferEvent.onChainMetadata.push(metadataEntry.id);
  }
  transferEvent.timestamp = event.block.timestamp;
  transferEvent.save();
}
