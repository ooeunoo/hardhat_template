import { network, ethers } from "hardhat";
import { BigNumber } from "./type";

async function advanceBlock(): Promise<void> {
  await network.provider.send("evm_mine", []);
}

async function latestBlock(): Promise<BigNumber> {
  const block = await ethers.provider.getBlock("latest");
  return BigNumber.from(block.number);
}

async function advanceBlockTo(target: BigNumber): Promise<void> {
  const currentBlock = await latestBlock();
  const start = Date.now();
  let notified;
  if (target.lt(currentBlock))
    throw Error(
      `Target block #(${target}) is lower than current block #(${currentBlock})`
    );
  while ((await latestBlock()).lt(target)) {
    if (!notified && Date.now() - start >= 5000) {
      notified = true;
      console.log(
        "advanceBlockTo: Advancing too many blocks is causing this test to be slow."
      );
    }
    await advanceBlock();
  }
}

async function latest(): Promise<BigNumber> {
  const block = await ethers.provider.getBlock("latest");
  return BigNumber.from(block.timestamp);
}

async function increase(duration: BigNumber): Promise<void> {
  await network.provider.send("evm_increaseTime", [duration.toNumber()]);
  await advanceBlock();
}

async function increaseTo(target: BigNumber): Promise<void> {
  const now = await latest();

  if (target.lt(now))
    throw Error(
      `Cannot increase current time (${now}) to a moment in the past (${target})`
    );
  const diff = target.sub(now);
  await increase(diff);
}

const duration = {
  seconds: function (val: number | string | BigNumber) {
    return BigNumber.from(val);
  },
  minutes: function (val: number | string | BigNumber) {
    return BigNumber.from(val).mul(this.seconds("60"));
  },
  hours: function (val: number | string | BigNumber) {
    return BigNumber.from(val).mul(this.minutes("60"));
  },
  days: function (val: number | string | BigNumber) {
    return BigNumber.from(val).mul(this.hours("24"));
  },
  weeks: function (val: number | string | BigNumber) {
    return BigNumber.from(val).mul(this.days("7"));
  },
  years: function (val: number | string | BigNumber) {
    return BigNumber.from(val).mul(this.days("365"));
  },
};

export const time = {
  duration,
  increaseTo,
  latest,
  advanceBlockTo,
  latestBlock,
};
