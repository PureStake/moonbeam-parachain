Moonbeam Automated Tests

To get started run npm install

This is preconfigured to work with Alan's Node, to test it in some other place you need to modify the Provider to the correct RPC endpoint in the testscript.js file:


The Test performs the following:
	- Sends two transactions of 10 tokens to address2 and address3 (you can import them to MetaMask with the private keys)
	- Deploy a simple Number contract and make a call to it to check its value (default its 2)
	- Deploy the Incrementer contract with an initial value of 5, then sends a tx to increment its value to 10. Makes a call to check the value.
	- Deploys the Raffle contract. Sets the charity to address2. Makes the three accounts (with funds) enter the Raffle. Draw two winners, when the second tx is sent, it transfer the Raffle funds (3 Eth) to address2.
