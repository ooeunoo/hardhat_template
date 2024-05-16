import { ethers } from "hardhat";
import { expect } from "chai";

import { SignerWithAddress, Contract, constants, randomBytes, formatStruct, time, BigNumber } from "../../utils";

const { AddressZero, NegativeOne, Zero, One, Two } = constants;
const Three: BigNumber = BigNumber.from(3);

const { duration, increaseTo, latest } = time;

export function ERC721Scripts() {
  describe("ERC721Mock", function () {
    const MAIN_CONTRACT = "ERC721All";

    // Players
    let owner: SignerWithAddress;
    let user1: SignerWithAddress;
    let user2: SignerWithAddress;
    let user3: SignerWithAddress;

    // Token Init Property
    let token: Contract;
    let tokenName: string = "ERC721";
    let tokenSymbol: string = "ERC721";

    before(async function () {
      const accounts = await ethers.getSigners();
      [owner, user1, user2, user3] = accounts;
    });

    beforeEach(async function () {
      const tokenContract = await ethers.getContractFactory(MAIN_CONTRACT, owner);
      token = await tokenContract.deploy(tokenName, tokenSymbol);
    });

    describe("ERC721 Metadata", function () {
      it("Optional: returns the name of the token", async function () {
        expect(await token.name()).to.equal(tokenName);
      });
      it("Optional: returns the symbol of the token", async function () {
        expect(await token.symbol()).to.equal(tokenSymbol);
      });
    });
  });
}
