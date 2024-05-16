import { BigNumber, ethers } from "ethers";

const { utils } = ethers;

export function stringToBytes32(str: string): string {
  return utils.formatBytes32String(str);
}

export function randomBytes(len: number): string {
  return utils.hexlify(utils.randomBytes(len));
}

export function formatStruct(struct: Object): object {
  const res: any = {};
  for (const [key, value] of Object.entries(struct)) {
    if (!isNaN(parseInt(key))) {
      continue;
    }
    res[key] = BigNumber.isBigNumber(value) ? BigNumber.from(value) : value;
  }
  return res;
}
