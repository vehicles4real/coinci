'use strict';

const { ethers, upgrades } = require('hardhat');

async function main() {
    const MinimumPriceSales = await ethers.getContractFactory('MinimumPriceSales');
    console.log('Deploying MinimumPriceSales...');
    const instance = await upgrades.deployProxy(MinimumPriceSales);
    await instance.deployed();
    console.log('MinimumPriceSales deployed to:', instance.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });