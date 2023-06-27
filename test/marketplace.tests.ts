import { ethers } from "hardhat";
import { Contract, ContractFactory, Signer } from "ethers";
import { expect } from "chai";

describe("Marketplace", function () {
  let marketplace: Contract;
  let erc20: Contract;
  let erc721: Contract;
  let erc1155: Contract;
  let admin: Signer;
  let buyer: Signer;
  let seller: Signer;
  let referrer: Signer;
  let royaltyReceiver: Signer;
  let treasury: Signer;

  beforeEach(async function () {
    const Marketplace: ContractFactory = await ethers.getContractFactory(
      "Marketplace"
    );
    const ERC20: ContractFactory = await ethers.getContractFactory("MockERC20");
    const ERC721: ContractFactory = await ethers.getContractFactory(
      "MockERC721"
    );
    const ERC1155: ContractFactory = await ethers.getContractFactory(
      "MockERC1155"
    );
    [admin, buyer, seller, treasury, royaltyReceiver, referrer] =
      await ethers.getSigners();

    marketplace = await Marketplace.deploy(
      await admin.getAddress(),
      1000,
      1000,
      1000,
      await treasury.getAddress()
    );
    erc20 = await ERC20.deploy(1000000000, await buyer.getAddress());
    erc721 = await ERC721.deploy(await royaltyReceiver.getAddress());
    erc1155 = await ERC1155.deploy();
    await marketplace.deployed();
    await erc20.deployed();
    await erc721.deployed();
    await erc1155.deployed();

    await erc721.mint(await seller.getAddress(), 0);
    await erc1155.mint(await seller.getAddress(), 0, 1000, "0x");

    await erc20
      .connect(buyer)
      .approve(
        marketplace.address,
        ethers.BigNumber.from(
          "115792089237316195423570985008687907853269984665640564039457584007913129639935"
        )
      );
    await erc721.connect(seller).setApprovalForAll(marketplace.address, true);
    await erc1155.connect(buyer).setApprovalForAll(marketplace.address, true);

    await marketplace.addCurrency(0, {
      currencyType: 0,
      currencyData: "0x",
      enabled: true,
    });
    await marketplace.addCurrency(1, {
      currencyType: 1,
      currencyData: ethers.utils.defaultAbiCoder.encode(
        ["address"],
        [erc20.address]
      ),
      enabled: true,
    });
    await marketplace.addCurrency(2, {
      currencyType: 3,
      currencyData: ethers.utils.defaultAbiCoder.encode(
        ["tuple(address,uint256)"],
        [[erc1155.address, 0]]
      ),
      enabled: true,
    });

    await marketplace.setAssetState(erc721.address, true);
  });

  describe("Listing", function () {
    it("should create and buy listing with ETH currency without referrer", async function () {
      await marketplace.connect(seller).list(erc721.address, 0, 0, 1000);
      const listing = await marketplace.listings(0);
      expect(listing.asset.assetContract).to.be.equal(erc721.address);
      expect(listing.asset.tokenId).to.be.equal(0);
      expect(listing.seller).to.be.equal(await seller.getAddress());
      expect(listing.currency).to.be.equal(0);
      expect(listing.amount).to.be.equal(1000);

      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace.connect(buyer).buyListing(0, [], {
          value: 1000,
        })
      ).to.changeEtherBalances(
        [buyer, seller, royaltyReceiver, treasury],
        [-1000, 800, 100, 100]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create and buy listing with ETH currency with referrer", async function () {
      await marketplace.connect(seller).list(erc721.address, 0, 0, 1000);
      const listing = await marketplace.listings(0);
      expect(listing.asset.assetContract).to.be.equal(erc721.address);
      expect(listing.asset.tokenId).to.be.equal(0);
      expect(listing.seller).to.be.equal(await seller.getAddress());
      expect(listing.currency).to.be.equal(0);
      expect(listing.amount).to.be.equal(1000);

      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace
          .connect(buyer)
          .buyListing(
            0,
            [{ referrer: await referrer.getAddress(), share: 1000 }],
            {
              value: 1000,
            }
          )
      ).to.changeEtherBalances(
        [buyer, seller, royaltyReceiver, treasury, referrer],
        [-1000, 800, 90, 100, 10]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create a listing with ERC20 currency without referrer", async function () {
      await marketplace.connect(seller).list(erc721.address, 0, 1, 1000);
      const listing = await marketplace.listings(0);
      expect(listing.asset.assetContract).to.be.equal(erc721.address);
      expect(listing.asset.tokenId).to.be.equal(0);
      expect(listing.seller).to.be.equal(await seller.getAddress());
      expect(listing.currency).to.be.equal(1);
      expect(listing.amount).to.be.equal(1000);
      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace.connect(buyer).buyListing(0, [], {
          value: 1000,
        })
      ).to.changeTokenBalances(
        erc20,
        [buyer, seller, royaltyReceiver, treasury],
        [-1000, 800, 100, 100]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create a listing with ERC20 currency with referrer", async function () {
      await marketplace.connect(seller).list(erc721.address, 0, 1, 1000);
      const listing = await marketplace.listings(0);
      expect(listing.asset.assetContract).to.be.equal(erc721.address);
      expect(listing.asset.tokenId).to.be.equal(0);
      expect(listing.seller).to.be.equal(await seller.getAddress());
      expect(listing.currency).to.be.equal(1);
      expect(listing.amount).to.be.equal(1000);
      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace
          .connect(buyer)
          .buyListing(
            0,
            [{ referrer: await referrer.getAddress(), share: 1000 }],
            {
              value: 1000,
            }
          )
      ).to.changeTokenBalances(
        erc20,
        [buyer, seller, royaltyReceiver, treasury, referrer],
        [-1000, 800, 90, 100, 10]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create a listing with ERC1155 currency without referrer", async function () {
      await marketplace.connect(seller).list(erc721.address, 0, 2, 1000);
      const listing = await marketplace.listings(0);
      expect(listing.asset.assetContract).to.be.equal(erc721.address);
      expect(listing.asset.tokenId).to.be.equal(0);
      expect(listing.seller).to.be.equal(await seller.getAddress());
      expect(listing.currency).to.be.equal(2);
      expect(listing.amount).to.be.equal(1000);
      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace.connect(buyer).buyListing(0, [], {
          value: 1000,
        })
      ).to.changeTokenBalances(
        erc1155,
        [buyer, seller, royaltyReceiver, treasury],
        [-1000, 800, 100, 100]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create a listing with ERC1155 currency with referrer", async function () {
      await marketplace.connect(seller).list(erc721.address, 0, 2, 1000);
      const listing = await marketplace.listings(0);
      expect(listing.asset.assetContract).to.be.equal(erc721.address);
      expect(listing.asset.tokenId).to.be.equal(0);
      expect(listing.seller).to.be.equal(await seller.getAddress());
      expect(listing.currency).to.be.equal(2);
      expect(listing.amount).to.be.equal(1000);
      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace.connect(buyer).buyListing(
          0,
          [{ referrer: await referrer.getAddress(), share: 1000 }],

          {
            value: 1000,
          }
        )
      ).to.changeTokenBalances(
        erc1155,
        [buyer, seller, royaltyReceiver, treasury, referrer],
        [-1000, 800, 90, 100, 10]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });
  });

  describe("Offer", function () {
    it("should create and accept an offer with ETH currency without referrer", async function () {
      const assets = [
        { assetContract: erc721.address, tokenId: 0 },
        { assetContract: erc721.address, tokenId: 1 },
      ];
      expect(
        await marketplace.connect(buyer).offer(assets, 1000, 0, {
          value: 1000,
        })
      ).to.changeEtherBalances([buyer, marketplace], [-1000, 1000]);

      const offer = await marketplace.offers(0);
      expect(offer.assets).to.be.equal(
        ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [assets.map((entry) => [entry.assetContract, entry.tokenId])]
        )
      );
      expect(offer.buyer).to.be.equal(await buyer.getAddress());
      expect(offer.currency).to.be.equal(0);
      expect(offer.amount).to.be.equal(1000);

      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace.connect(seller).acceptOffer(0, erc721.address, 0, [])
      ).to.changeEtherBalances(
        [marketplace, seller, royaltyReceiver, treasury],
        [-1000, 800, 100, 100]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create and accept an offer with ETH currency with referrer", async function () {
      const assets = [
        { assetContract: erc721.address, tokenId: 0 },
        { assetContract: erc721.address, tokenId: 1 },
      ];
      expect(
        await marketplace.connect(buyer).offer(assets, 1000, 0, {
          value: 1000,
        })
      ).to.changeEtherBalances([buyer, marketplace], [-1000, 1000]);

      const offer = await marketplace.offers(0);
      expect(offer.assets).to.be.equal(
        ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [assets.map((entry) => [entry.assetContract, entry.tokenId])]
        )
      );
      expect(offer.buyer).to.be.equal(await buyer.getAddress());
      expect(offer.currency).to.be.equal(0);
      expect(offer.amount).to.be.equal(1000);

      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace
          .connect(seller)
          .acceptOffer(0, erc721.address, 0, [
            { referrer: await referrer.getAddress(), share: 1000 },
          ])
      ).to.changeEtherBalances(
        [marketplace, seller, royaltyReceiver, treasury, referrer],
        [-1000, 800, 100, 90, 10]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create and accept an offer with ERC20 currency without referrer", async function () {
      const assets = [
        { assetContract: erc721.address, tokenId: 0 },
        { assetContract: erc721.address, tokenId: 1 },
      ];
      expect(
        await marketplace.connect(buyer).offer(assets, 1000, 1)
      ).to.changeTokenBalances(erc20, [buyer, marketplace], [-1000, 1000]);

      const offer = await marketplace.offers(0);
      expect(offer.assets).to.be.equal(
        ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [assets.map((entry) => [entry.assetContract, entry.tokenId])]
        )
      );
      expect(offer.buyer).to.be.equal(await buyer.getAddress());
      expect(offer.currency).to.be.equal(1);
      expect(offer.amount).to.be.equal(1000);

      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace.connect(seller).acceptOffer(0, erc721.address, 0, [])
      ).to.changeTokenBalances(
        erc20,
        [marketplace, seller, royaltyReceiver, treasury],
        [-1000, 800, 100, 100]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create and accept an offer with ERC20 currency with referrer", async function () {
      const assets = [
        { assetContract: erc721.address, tokenId: 0 },
        { assetContract: erc721.address, tokenId: 1 },
      ];
      expect(
        await marketplace.connect(buyer).offer(assets, 1000, 1)
      ).to.changeTokenBalances(erc20, [buyer, marketplace], [-1000, 1000]);

      const offer = await marketplace.offers(0);
      expect(offer.assets).to.be.equal(
        ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [assets.map((entry) => [entry.assetContract, entry.tokenId])]
        )
      );
      expect(offer.buyer).to.be.equal(await buyer.getAddress());
      expect(offer.currency).to.be.equal(1);
      expect(offer.amount).to.be.equal(1000);

      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace
          .connect(seller)
          .acceptOffer(0, erc721.address, 0, [
            { referrer: await referrer.getAddress(), share: 1000 },
          ])
      ).to.changeTokenBalances(
        erc20,
        [marketplace, seller, royaltyReceiver, treasury, referrer],
        [-1000, 800, 100, 90, 10]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create and accept an offer with ERC1155 currency without referrer", async function () {
      const assets = [
        { assetContract: erc721.address, tokenId: 0 },
        { assetContract: erc721.address, tokenId: 1 },
      ];
      expect(
        await marketplace.connect(buyer).offer(assets, 1000, 2)
      ).to.changeTokenBalances(erc1155, [buyer, marketplace], [-1000, 1000]);

      const offer = await marketplace.offers(0);
      expect(offer.assets).to.be.equal(
        ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [assets.map((entry) => [entry.assetContract, entry.tokenId])]
        )
      );
      expect(offer.buyer).to.be.equal(await buyer.getAddress());
      expect(offer.currency).to.be.equal(2);
      expect(offer.amount).to.be.equal(1000);

      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace.connect(seller).acceptOffer(0, erc721.address, 0, [])
      ).to.changeTokenBalances(
        erc1155,
        [marketplace, seller, royaltyReceiver, treasury],
        [-1000, 800, 100, 100]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });

    it("should create and accept an offer with ERC1155 currency with referrer", async function () {
      const assets = [
        { assetContract: erc721.address, tokenId: 0 },
        { assetContract: erc721.address, tokenId: 1 },
      ];
      expect(
        await marketplace.connect(buyer).offer(assets, 1000, 1, {
          value: 1000,
        })
      ).to.changeTokenBalances(erc20, [buyer, marketplace], [-1000, 1000]);

      const offer = await marketplace.offers(0);
      expect(offer.assets).to.be.equal(
        ethers.utils.defaultAbiCoder.encode(
          ["tuple(address,uint256)[]"],
          [assets.map((entry) => [entry.assetContract, entry.tokenId])]
        )
      );
      expect(offer.buyer).to.be.equal(await buyer.getAddress());
      expect(offer.currency).to.be.equal(1);
      expect(offer.amount).to.be.equal(1000);

      const preSaleOwner = await erc721.ownerOf(0);
      expect(preSaleOwner == (await seller.getAddress()));
      expect(
        await marketplace
          .connect(seller)
          .acceptOffer(0, erc721.address, 0, [
            { referrer: await referrer.getAddress(), share: 1000 },
          ])
      ).to.changeTokenBalances(
        erc20,
        [marketplace, seller, royaltyReceiver, treasury, referrer],
        [-1000, 800, 100, 90, 10]
      );
      const postSaleOwner = await erc721.ownerOf(0);
      expect(postSaleOwner == (await buyer.getAddress()));
      const postSaleListing = await marketplace.listings(0);
      expect(postSaleListing == undefined);
    });
  });
});
