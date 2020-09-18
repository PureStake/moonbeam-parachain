const Web3 = require('web3');
// Contracts Bytecode and ABI
const number = require('./number');
const incrementer = require('./incrementer');
const raffle = require('./raffle');

// Provider
const web3 = new Web3('http://localhost:56143'); //Local

// Address 1
const pk1 = 'd28f820024280474ab313447152a51d455b175b483616a3c12d4436f5af2563e';
const address1 = '0x3B7E10affe74b33ea824e8DdDc68e71D8D762dFd';
// Address 2
const pk2 = '1dedbcdd07bceabe8215e27934ef66728aeb33db4dc3e6956a358673c587effe';
const address2 = '0xCFf06fA90f2346d09AEBEe8Af3B22b4046233642';
// Address 3
const pk3 = '3d54c605b53da120025e53bc6f01be4f2c406d64a5a0575460465207eabe83aa';
const address3 = '0x567268dE6E5849B0105b7967BDc6e1980d103ACC';

const wait = async () => {
	// await new Promise(resolve => {
	// 	setTimeout(resolve, 100);
	// });
};

// Send funds from one account to othe account with private key
const tx = async (addressFrom, pk, addressTo, amount) => {
    console.log(
        `Attempting to make transaction from ${addressFrom} to ${addressTo}`
    );


    const stx = await web3.eth.accounts.signTransaction(
        {
            from: addressFrom,
            to: addressTo,
            value: web3.utils.toWei(amount, 'ether'),
            gas: '4294967295',
        },
        pk
	);
	await wait();

    // Deploy transaction
    const rcp = await web3.eth.sendSignedTransaction(
        stx.rawTransaction
    );
	await wait();

    console.log(
        `Transaction successful with hash: ${rcp.transactionHash}`
    );
};

// Deploy contract passing the addressFrom, private key, bytecode and ABI (input is optional)
const deployContract = async (addressFrom, pk, bytecode, ABI, constructorInput = []) => {
    console.log('Attempting to deploy from account:', addressFrom);

    const contractInstance = new web3.eth.Contract(ABI);

    const tx = contractInstance.deploy({
        data: bytecode,
        arguments: constructorInput,
    });

    const stx = await web3.eth.accounts.signTransaction(
        {
            from: addressFrom,
            data: tx.encodeABI(),
            gas: '4294967295',
        },
        pk
	);

	await wait();

    const rcp = await web3.eth.sendSignedTransaction(
        stx.rawTransaction
    );
    console.log('Contract deployed at address', rcp.contractAddress);
    return rcp.contractAddress;
};

// Make a call to a contract passing the contractAddress, ABI and method
const contractCall = async (contractAddress, ABI, method) => {
    const contractInstance = new web3.eth.Contract(ABI, contractAddress);

    console.log(`Making a call to contract at address ${contractAddress}`);
    const data = await contractInstance.methods[method]().call();
    console.log(`The current number stored is: ${data}`);
};

// Send a tx to a contract passing the addressFrom, private key, contractAddress, ABI, method, input of the method, and value (eth)
const contractTx = async (addressFrom, pk, contractAddress, ABI, method, methodInput, value) => {
    const contractInstance = new web3.eth.Contract(ABI, contractAddress);
    let encoded = 0;

    if (methodInput !== null) {
        encoded = contractInstance.methods[method](methodInput).encodeABI();
    } else {
        encoded = contractInstance.methods[method]().encodeABI();
    };

    console.log(
        `Calling the contract's method ${method} with input ${methodInput} at address ${contractAddress}`
    );
    const tx = await web3.eth.accounts.signTransaction(
        {
            from: addressFrom,
            to: contractAddress,
            data: encoded,
            gas: '4294967295',
            value: await web3.utils.toWei(value, 'ether')
        },
        pk
    );

	await wait();
    const stx = await web3.eth.sendSignedTransaction(
        tx.rawTransaction
    );
    console.log(`Tx successfull with hash: ${stx.transactionHash}`);
};

const test = async () => {
    await tx(address1, pk1, address2, '10');
	await wait();
    await tx(address1, pk1, address3, '10');
	await wait();

    // Number Contract (simple)
    numberAddress = await deployContract(address1, pk1, number.bytecode, number.ABI);
    await contractCall(numberAddress, number.ABI, 'number');
	await wait();

    // Incrementer Contract (Medium)
    incrementerAddress = await deployContract(address1, pk1, incrementer.bytecode, incrementer.ABI, [5]);
    await contractCall(incrementerAddress, number.ABI, 'number');
	await wait();
    await contractTx(address1, pk1, incrementerAddress, incrementer.ABI, 'increment', '5', '0');
	await wait();
    await contractCall(incrementerAddress, number.ABI, 'number');
	await wait();

    // Raffle Contract (Dangerous)
    raffleAddress = await deployContract(address1, pk1, raffle.bytecode, raffle.ABI);
    await contractTx(address1, pk1, raffleAddress, raffle.ABI, 'setCharity', address2, '0');
	await wait();
    await contractTx(address1, pk1, raffleAddress, raffle.ABI, 'play', null, '1');
	await wait();
    await contractTx(address2, pk2, raffleAddress, raffle.ABI, 'play', null, '1');
	await wait();
    await contractTx(address3, pk3, raffleAddress, raffle.ABI, 'play', null, '1');
	await wait();
    await contractTx(address1, pk1, raffleAddress, raffle.ABI, 'draw', null, '0');
	await wait();
    await contractTx(address1, pk1, raffleAddress, raffle.ABI, 'draw', null, '0');
	await wait();

};

test();

