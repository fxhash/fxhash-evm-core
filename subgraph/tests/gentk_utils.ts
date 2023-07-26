import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts";

import { Transfer } from "../src/types/templates/GenTk/GenTk";
import { newMockEvent } from "matchstick-as";

export function createTransferEvent(
  from: Address,
  to: Address,
  tokenId: i32,
): Transfer {
  const transferEvent = changetype<Transfer>(newMockEvent());
  transferEvent.parameters = [
    new ethereum.EventParam("from", ethereum.Value.fromAddress(from)),
    new ethereum.EventParam("to", ethereum.Value.fromAddress(to)),
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromI32(tokenId),
    ),
  ];
  return transferEvent;
}

// export function createTokenMetadataAssignedEvent(
//   params: Array<{ tokenId: BigInt; metadata: string }>,
// ): TokenMetadataAssigned {
//   const tokenMetadataAssignedEvent = changetype<TokenMetadataAssigned>(
//     newMockEvent(),
//   );
//   tokenMetadataAssignedEvent.params._params = params;
//   return tokenMetadataAssignedEvent;
// }

// export function createOnChainTokenMetadataAssignedEvent(
//   params: Array<{ tokenId: BigInt; metadata: Bytes }>,
// ): OnChainTokenMetadataAssigned {
//   const onChainTokenMetadataAssignedEvent =
//     changetype<OnChainTokenMetadataAssigned>(newMockEvent());
//   onChainTokenMetadataAssignedEvent.params._params = params;
//   onChainTokenMetadataAssignedEvent.transaction.hash = crypto.keccak256(
//     ByteArray.fromUTF8("test"),
//   );
//   return onChainTokenMetadataAssignedEvent;
// }
