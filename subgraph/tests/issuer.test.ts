import {
  describe,
  test,
  clearStore,
  beforeEach,
  afterEach,
} from "matchstick-as/assembly/index";
import {
  createIssuerBurnedEvent,
  createIssuerMintedEvent,
  newCodex,
  newMintTicketSettings,
  newOnChainScript,
  newOpenEdition,
  newPricing,
  newReserve,
  newSplit,
} from "./issuer_utils";
import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts";
import { handleIssuerBurned, handleIssuerMinted } from "../src/mappings/issuer";

describe("Issuer Handlers", () => {
  beforeEach(() => {});

  afterEach(() => {
    clearStore();
  });

  test("handleIssuerMinted correctly processes the IssuerMinted event", () => {
    let event = createIssuerMintedEvent(
      newCodex(
        BigInt.fromI32(1),
        Bytes.fromHexString("0x01"),
        BigInt.fromI32(10),
        Address.fromString("0x0000000000000000000000000000000000000001"),
      ),
      Bytes.fromHexString("0x01"),
      BigInt.fromI32(10),
      BigInt.fromI32(10),
      newOpenEdition(BigInt.fromI32(100), Bytes.fromHexString("0x01")),
      newMintTicketSettings(BigInt.fromI32(1), "0x01"),
      [
        newReserve(
          BigInt.fromI32(0),
          BigInt.fromI32(100),
          Bytes.fromHexString("0x01"),
        ),
        newReserve(
          BigInt.fromI32(1),
          BigInt.fromI32(200),
          Bytes.fromHexString("0x02"),
        ),
      ],
      newPricing(BigInt.fromI32(1), Bytes.fromHexString("0x01"), false),
      newSplit(
        Address.fromString("0x0000000000000000000000000000000000000001"),
        BigInt.fromI32(100),
      ),
      newSplit(
        Address.fromString("0x0000000000000000000000000000000000000002"),
        BigInt.fromI32(200),
      ),
      true,
      [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(3)],
      [
        newOnChainScript(
          "script1",
          Address.fromString("0x0000000000000000000000000000000000000011"),
          Bytes.fromHexString("0x01"),
          1,
          Bytes.fromHexString("0x01"),
          Bytes.fromHexString("0x02"),
          Bytes.fromHexString("0x03"),
        ),
        newOnChainScript(
          "script2",
          Address.fromString("0x0000000000000000000000000000000000000021"),
          Bytes.fromHexString("0x02"),
          2,
          Bytes.fromHexString("0x01"),
          Bytes.fromHexString("0x02"),
          Bytes.fromHexString("0x03"),
        ),
      ],
    );

    handleIssuerMinted(event);
  });

  test("handleIssuerBurned correctly processes the IssuerBurned event", () => {
    let event = createIssuerBurnedEvent();
    handleIssuerBurned(event);
  });
});
