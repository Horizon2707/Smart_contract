const { ethers } = require("hardhat");

async function main() {
  // Get the contract address (use the address from deployment)
  const contractAddress = "0x8672023d9EC09Ff4297D5740806589aB19a95965"; // Replace with your deployed contract address

  // Get the contract factory and instance
  const EscrowWithTimeout = await hre.ethers.getContractFactory(
    "EscrowWithTimeout"
  );
  const escrow = await EscrowWithTimeout.attach(contractAddress);

  // Get the signers (accounts)
  const [buyer, seller, arbitrator] = await hre.ethers.getSigners();

  // Check the current state of the contract
  let currentState = await escrow.state();
  console.log("Current state:", currentState);

  // Example: Buyer deposits funds (replace with the actual amount you want to deposit)
  const depositAmount = ethers.parseEther("1.0");
  console.log("Depositing funds...");
  const depositTx = await escrow
    .connect(buyer)
    .deposit({ value: depositAmount });
  await depositTx.wait();
  console.log("Funds deposited");

  //   // Confirm delivery (only the buyer should be able to call this)
  console.log("Confirming delivery...");
  const confirmDeliveryTx = await escrow.connect(buyer).confirmDelivery();
  await confirmDeliveryTx.wait();
  console.log("Delivery confirmed");
  //   console.log("Resetting contract state...");
  //   try {
  //     const resetTx = await escrow.connect(arbitrator).reset();
  //     await resetTx.wait();
  //   } catch (error) {
  //     console.error("Error resetting contract state:", error);
  //   }
  //   console.log("Contract state has been reset");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
