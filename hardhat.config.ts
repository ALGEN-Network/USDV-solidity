import { HardhatUserConfig } from "hardhat/config";
import '@openzeppelin/hardhat-upgrades';
import "@nomicfoundation/hardhat-toolbox";

const mainAccout = process.env.MNEMONIC as string;

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    algen2_test: {
      url: "https://rpc.alg2-test.algen.network",
      accounts: [mainAccout],
      allowUnlimitedContractSize: true
    },
    mesher: {
      url: "https://rpc.mesher.algen.network",
      accounts: [mainAccout],
      allowUnlimitedContractSize: true
    },
    mesher_test: {
      url: "https://rpc.mesher-test.algen.network",
      accounts: [mainAccout],
      allowUnlimitedContractSize: true
    },
    algen_test: {
      url: "https://rpc.test.algen.network",
      accounts: [mainAccout],
      allowUnlimitedContractSize: true
    }
  }
};

export default config;
