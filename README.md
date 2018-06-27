# Siliqua Contracts
This repo contains solidity contracts for the Siliqua diamond backed tokens (DXT). A Diamond Exchange Token combines traits of a non-fungible asset registry with an erc20 token. This way token balances can be backed by physical registered assets like a diamond. At this stage there is only the smart contract for a Basket. The Basket.sol contract represents a single basket of diamonds on the Siliqua platform.

## Testing the contracts
Make sure you have nodejs installed.
1. Then run `npm install`
2. Run `npm run test` (this will start ganache-cli & run the truffle tests)

![A function overview of the basket contract](https://github.com/SiliquaDiamondCapital/siliqua-contracts/blob/master/images/smart_contract.png)

### Diamond properties
The storage of information on a registered asset is done in a JSON file of which the mediaUri is registered in the contract. Examples of json files to describe a diamond or basket can be found in the examples folder.

The storage of Diamond properties is done by storing a media URI (IPFS or swarm) together with the diamondId in the smart contract. The basket maintains a list of diamonds that are in the basket.

`diamondId` - The unique id of the diamond. The id is generated within the Siliqua platform.  
`mediaUri` - Contains the location where details on this diamond can be found

#### Basket methods
`addDiamond` - Add a diamond to the basket. Can only be called by the owner of the Basket.  
`removeDiamond` - Removes a diamond from the basket. Can only be called by the owner of the Basket.  
`buyTicket` - Allows a person to buy tokens of the basket.  
`sellTicket` - Allows a person to sell an amount tokens of the basket.  

#### ERC20 methods
`totalSupply` - Get the total token supply.  
`availableSupply` - Get the total token supply that is available for purchase.  
`balanceOf` - Get the token balance of an address.  
`transfer` - Transfer an amount of token balance to an address from your address.  
`approve` - Approve another address to spend in your name. (useful for next method)  
`allowance` - Get the amount that and address can still spend.  
`transferFrom` - Send an amount of tokens from an address to another address.

### Events
The basket contract can emit the following events:

#### Basket
- AddDiamond
- RemoveDiamond
- TotalBasketAmountSet
- AvailableBasketAmountSet
- OwnershipTransferred

#### Whitelist / minting
- WhitelistedAddressAdded
- MintersAddressAdded
- MintersAddressRemoved
- MintFinished

#### Buy/sell/transfer
- BuyTicket
- SellTicket
- Transfer
- Approval

---
NOTE: This code is not audited yet.
