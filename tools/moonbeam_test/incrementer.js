module.exports = {
    bytecode: '608060405234801561001057600080fd5b506040516102c93803806102c98339818101604052602081101561003357600080fd5b81019080805190602001909291905050508060008190555033600160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055505061022d8061009c6000396000f3fe608060405234801561001057600080fd5b506004361061004c5760003560e01c80637cf5dab0146100515780638381f58a1461007f5780638da5cb5b1461009d578063d826f88f146100e7575b600080fd5b61007d6004803603602081101561006757600080fd5b81019080803590602001909291905050506100f1565b005b6100876100ff565b6040518082815260200191505060405180910390f35b6100a5610105565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b6100ef61012b565b005b806000540160008190555050565b60005481565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1681565b600160009054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff16146101ee576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260098152602001807f4e6f74206f776e6572000000000000000000000000000000000000000000000081525060200191505060405180910390fd5b6000808190555056fea2646970667358221220f3f820ac6e6f35d082a2be0671e3a5edae0def581e4425899bd63066220d3c3e64736f6c63430006060033',
    ABI: [
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_initialValue",
                    "type": "uint256"
                }
            ],
            "stateMutability": "nonpayable",
            "type": "constructor"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_value",
                    "type": "uint256"
                }
            ],
            "name": "increment",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "number",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "owner",
            "outputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "reset",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        }
    ]
};

