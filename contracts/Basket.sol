pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import './BasketBase.sol';

contract Basket is BasketBase {
  using SafeMath for uint256;

  struct Diamond {
    uint256 diamondId;
    string mediaUri;
  }

  // Events
  event AddDiamond(uint256 diamondId);
  event RemoveDiamond(uint256 diamondId);
  event AvailableBasketAmountSet(uint256 availableAmount);
  event TotalBasketAmountSet(uint256 totalAmount);

  event BuyTicket(address buyer, uint256 value);
  event SellTicket(address seller, uint256 value);

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _approved, uint256 _value);

  mapping(uint256 => Diamond) public diamonds;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 public numStones;
  uint256 public totalBasketAmount;
  uint256 public availableBasketAmount;
  mapping(address => uint256) balances;

  constructor(string _name, string _symbol, uint256 _decimals) public {
    name_ = _name;
    symbol_ = _symbol;
    decimals_ = _decimals;
    owner = msg.sender;
    numStones = 0;
    totalBasketAmount = 0;
    availableBasketAmount = 0;
  }

  /**
   * @dev Gets the total value of all assets
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() public view returns (uint256) {
    return totalBasketAmount;
  }

  /**
   * @dev Gets the total value for sale in tickets
   * @return uint256 representing the total amount of available tokens
   */
  function totalAvailable() public view returns (uint256) {
    return availableBasketAmount;
  }

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return balances[_owner];
  }

  /**
   * @dev Transfer tokens from the calling address to another
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * setAvailableAmount - set the available amount in the atomic unit of this token
   *
   * @param _availableAmount uint256 description
   * @return boolean if successful
   */
  function setAvailableAmount(uint256 _availableAmount) public onlyOwner returns (bool) {
    require(_availableAmount > 0);
    require(_availableAmount < totalBasketAmount);
    availableBasketAmount = _availableAmount;
    emit AvailableBasketAmountSet(availableBasketAmount);
    return true;
  }

  /**
   * setTotalAmount - set the total amount available for tickets
   *
   * @param _totalAmount uint256 - total amount of the token
   * @return boolean if successful
   */
  function setTotalAmount(uint256 _totalAmount) public onlyOwner returns (bool) {
    require(_totalAmount > 0);
    require(availableBasketAmount < _totalAmount);
    totalBasketAmount = _totalAmount;
    emit TotalBasketAmountSet(totalBasketAmount);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
    * @dev Add a diamond to the basket. Can only be called by the owner of the Basket.
    *      Generates a AddDiamond event
    * @param diamondId Id of the diamond.
    * @param mediaUri The location of verifcation media
   */
  function addDiamond(uint256 diamondId, string mediaUri) onlyOwner canMint public returns (bool) {
    Diamond memory diamond = Diamond({
      diamondId: diamondId,
      mediaUri: mediaUri
    });
    numStones = numStones.add(1);
    diamonds[diamondId] = diamond;
    emit AddDiamond(diamondId);
    return true;
  }

  /**
    * @dev Removes a diamond from the basket. Can only be called by the owner of the Basket.
    *      Generates a RemoveDiamond event
    * @param diamondId Id of the diamond.
   */
  function removeDiamond(uint256 diamondId) onlyOwner public {
    require(diamonds[diamondId].diamondId != 0);
    numStones = numStones.sub(1);
    delete diamonds[diamondId];
    emit RemoveDiamond(diamondId);
  }

  /**
    * @dev Allows a person to buy a ticket (piece) of the basket.
    *      Generates a BuyTicket event
    * @param value The amount of the ticket to buy.
   */
  function buyTicket(uint256 value) onlyWhitelisted public returns(bool) {
    require(availableBasketAmount > value);
    availableBasketAmount = availableBasketAmount.sub(value);
    balances[msg.sender] = balances[msg.sender].add(value);
    emit BuyTicket(msg.sender, value);
    return true;
  }

  /**
    * @dev Allows a person to sell his/her ticket (piece) of the basket.
    *      Generates a SellTicket event
    * @param value The amount of the ticket to sell.
   */
  function sellTicket(uint256 value) onlyWhitelisted public returns(bool) {
    require(balances[msg.sender] >= value);
    balances[msg.sender] = balances[msg.sender].sub(value);
    availableBasketAmount = availableBasketAmount.add(value);
    emit SellTicket(msg.sender, value);
    return true;
  }

}
