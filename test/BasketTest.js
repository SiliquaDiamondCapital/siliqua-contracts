require('babel-register');
require('babel-polyfill');

import { assertRevert, assertError } from './helpers/assertRevert';
const BigNumber = web3.BigNumber;

const Basket = artifacts.require('Basket');

function checkEventEmitted(log, eventName) {
  log.event.should.be.eq(eventName);
}

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should()

const expect = require('chai').expect

console.log('------------------------------------------------------');
console.log('---- Basic contract functions for the Siliqua DXT ----');
console.log('------------------------------------------------------');

contract('Basket', accounts => {
  const [creator, owner, user1, user2, user3] = accounts;

  let basket = null;

  const sentByCreator = { from: creator };
  const sentByOwner = { from: owner };
  const sentByUser1 = { from: user1 };
  const sentByUser2 = { from: user2 };
  const sentByUser3 = { from: user3 };

  // Create basket
  const creationParams = {
    gas: 9e8,
    gasPrice: 21e9,
    from: creator
  };

  beforeEach(async () => {
    basket = await Basket.new('Diamond 1', 'DIA1', 0, creationParams);
    await basket.addDiamond(0, 'ipfs://QmPXME1oRtoT627YKaDPDQ3PwA8tdP9rWuAAweLzqSwAWT/doc.pdf', sentByCreator);
    await basket.addDiamond(1, 'ipfs://QmPXME1oRtoT627YKaDPDQ3PwA8tdP9rWuAAweLzqSwAWT/doc.pdf', sentByCreator);
    await basket.setTotalAmount(2000);
    await basket.setAvailableAmount(1000);
  })

  describe('Token variables', () => {
    it('Name is correct', async () => {
      const name = await basket.name();
      name.should.be.eq('Diamond 1');
    });
    it('Symbol is correct', async () => {
      const symbol = await basket.symbol();
      symbol.should.be.eq('DIA1');
    });
    it('Decimals is correct', async () => {
      const decimals = await basket.decimals();
      decimals.should.be.bignumber.equal(0);
    });
  });

  describe('Diamonds', async () => {
    it('Add 2 diamonds to basket', async () => {
      const totalSupply = await basket.numStones();
      totalSupply.should.be.bignumber.equal(2);
    })
    it('Total value of basket is correct', async () => {
      const totalValue = await basket.totalSupply();
      totalValue.should.be.bignumber.equal(2000);
    })
    it('Total available value of basket is correct', async () => {
      const availableValue = await basket.totalAvailable();
      availableValue.should.be.bignumber.equal(1000);
    })
  });
  describe('Ticket buy / sell', async () => {
    it('Add user1 to whitelist', async () => {
      const { logs } = await basket.addAddressToWhitelist(user1, sentByCreator);
      const log = logs[0];
      log.event.should.be.eq('WhitelistedAddressAdded');
      log.args.addr.should.be.equal(user1);
    })
    it('Buy ticket as whitelisted user1', async () => {
      await basket.addAddressToWhitelist(user1, sentByCreator);
      await basket.buyTicket(100, sentByUser1);
      const ticketValue = await basket.balanceOf(user1);
      ticketValue.should.be.bignumber.equal(100);
    })
    it('Buy ticket fails if user is not on whitelist', async () => {
      await basket.addAddressToWhitelist(user1, sentByCreator);
      await assertRevert(basket.buyTicket(100, sentByUser2));
    });
    it('Sell ticket as whitelisted user1', async () => {
      await basket.addAddressToWhitelist(user1, sentByCreator);
      await basket.buyTicket(100, sentByUser1);
      await basket.sellTicket(50, sentByUser1);
      const ticketValue = await basket.balanceOf(user1);
      ticketValue.should.be.bignumber.equal(50);
    })
    it('Sell ticket fails if user is not on whitelist', async () => {
      await basket.addAddressToWhitelist(user1, sentByCreator);
      await basket.buyTicket(100, sentByUser1);
      await basket.removeAddressFromWhitelist(user1, sentByCreator);
      await assertRevert(basket.sellTicket(50, sentByUser1));
    })
  });
  describe('Transfer and allowance', async () => {
    it('Transfer ticket as user1 to user2', async () => {
      await basket.addAddressToWhitelist(user1, sentByCreator);
      await basket.buyTicket(100, sentByUser1);
      await basket.transfer(user2, 100, sentByUser1);
      const ticketValue = await basket.balanceOf(user2);
      ticketValue.should.be.bignumber.equal(100);
    })
    it('Give allowance to user2 as user1', async () => {
      await basket.approve(user2, 100, sentByUser1);
      const allowance = await basket.allowance(user1, user2);
      allowance.should.be.bignumber.equal(100);
    })
    it('TransferFrom user1 to user3 as allowed user2', async () => {
      await basket.addAddressToWhitelist(user1, sentByCreator);
      await basket.buyTicket(100, sentByUser1);
      await basket.approve(user2, 100, sentByUser1);
      const { logs } = await basket.transferFrom(user1, user3, 100, sentByUser2);
      const log = logs[0];
      log.event.should.be.eq('Transfer');
      log.args._from.should.be.equal(user1);
      log.args._to.should.be.equal(user3);
      const ticketValue = await basket.balanceOf(user3);
      ticketValue.should.be.bignumber.equal(100);
    })
  })

}); // End contract
