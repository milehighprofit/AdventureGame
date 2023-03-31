const main = async () => {
    const gameContractFactory = await hre.ethers.getContractFactory('CharacterCreation');
    const gameContract = await gameContractFactory.deploy ( 
    "Elon Musk", // Boss name
    "https://i.imgur.com/AksR0tt.png", // Boss image
    1000, // Boss hp
    50 // Boss attack damage
  );

    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);
    let txn;
    // We only have three characters.
    // an NFT w/ the character at index 2 of our array.
    txn2 = await gameContract.createRandomCharacter("Oskar", "Hansen")
    await txn2.wait(1)
    txn = await gameContract.mintCharacterNFT(0);
    await txn.wait(1);

    fightTxn = await gameContract.attackBoss()
    fightTxn.wait(1)
    fightTxn = await gameContract.attackBoss()
    fightTxn.wait(1)
    fightTxn = await gameContract.attackBoss()
    fightTxn.wait(1)
    fightTxn = await gameContract.attackBoss()
    fightTxn.wait(1)
    let returnedTokenUri = await gameContract.tokenURI(0);
    console.log("Token URI:", returnedTokenUri);
      // Get the value of the NFT's URI.
    
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