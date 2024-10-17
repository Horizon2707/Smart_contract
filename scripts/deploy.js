async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const EscrowWithTimeout = await ethers.getContractFactory(
    "EscrowWithTimeout"
  );
  const escrow = await EscrowWithTimeout.deploy(
    "0x64D56674d85aCbD1Ef2ed09344FA7f41E23F3565",
    "0x7c958cCe6CF2b74ceda713401bCE17AE43d3399a", // Replace with the arbitrator's address
    600 // Delivery time (600 seconds = 10 minutes)
  );

  console.log("Escrow contract deployed to:", escrow.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
