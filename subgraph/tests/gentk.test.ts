import {
  describe,
  test,
  clearStore,
  beforeEach,
  afterEach,
} from "matchstick-as/assembly/index";
import { Address, Bytes, ethereum } from "@graphprotocol/graph-ts";
import {
  handleTransfer,
  handleTokenMetadataAssigned,
  handleOnChainTokenMetadataAssigned,
} from "../src/mappings/gentk";
import {
  createTransferEvent,
  createTokenMetadataAssignedEvent,
  createOnChainTokenMetadataAssignedEvent,
} from "./gentk_utils";

describe("GenTk Handlers", () => {
  beforeEach(() => {});

  afterEach(() => {
    clearStore();
  });

  test("handleTransfer correctly processes the Transfer event", () => {
    let transferEvent = createTransferEvent(
      Address.fromString("0x0000000000000000000000000000000000000001"),
      Address.fromString("0x0000000000000000000000000000000000000002"),
      12,
    );
    handleTransfer(transferEvent);
  });

  test("handleTokenMetadataAssigned correctly processes the TokenMetadataAssigned event", () => {
    const id = 1;
    const meta = "ipfs://1234";
    let tuple = new ethereum.Tuple(2);
    tuple[0] = ethereum.Value.fromI32(id);
    tuple[1] = ethereum.Value.fromString(meta);
    let tokenMetadataAssignedEvent = createTokenMetadataAssignedEvent([tuple]);
    handleTokenMetadataAssigned(tokenMetadataAssignedEvent);
  });

  test("handleOnChainTokenMetadataAssigned correctly processes the OnChainTokenMetadataAssigned event", () => {
    const id = 1;
    const meta = "ipfs://1234";
    let tuple = new ethereum.Tuple(2);
    tuple[0] = ethereum.Value.fromI32(id);
    tuple[1] = ethereum.Value.fromBytes(
      Bytes.fromHexString("0x0000000000000000000000000000000000000001"),
    );
    let tokenMetadataAssignedEvent = createOnChainTokenMetadataAssignedEvent([
      tuple,
    ]);
    handleOnChainTokenMetadataAssigned(tokenMetadataAssignedEvent);
  });
});
