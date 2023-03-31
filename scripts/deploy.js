const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('CharacterCreation');
  const gameContract = await gameContractFactory.deploy ( 
  "Elon Musk", // Boss name
  "https://i.imgur.com/AksR0tt.png", // Boss image
  1000, // Boss hp
  50 // Boss attack damage
  )
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);
  
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();