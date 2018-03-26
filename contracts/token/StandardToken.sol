pragma solidity ^ 0.4.2;

import './SafeMath.sol';
import './ERC20.sol';
import './OG_ERC223.sol';
import './OG_ERC223ReceivingContract.sol';
 /**
 * @title Standard implementation of erc223 token
 */
contract StandardToken is ERC20, OG_ERC223 {
    using SafeMath
    for uint;

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;


    /**
     * @dev Standard ERC223 token constructor
     *
     * @param name The name of the new coin.
     * @param symbol The symbol for the new coin
     * @param decimals The amount in how divisble the token is.
     * @param totalSupply Pretty self explanatory
     */
    function StandardToken(string name, string symbol, uint8 decimals, uint256 totalSupply) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply;
        balances[msg.sender] = totalSupply;
    }

    /**
     * @dev Name getter function
     *
     * @return Returns the name of the currency / token
     */
    function name() public view returns(string) {
        return _name;
    }


    /**
     * @dev Symbol getter function
     *
     * @return Returns the symbol of the currency / token
     */
    function symbol() public view returns(string) {
        return _symbol;
    }

    /**
     * @dev Decimal getter function
     *
     * @return Returns the allowed number of decimal places of the currency / token
     */
    function decimals() public view returns(uint8) {
        return _decimals;
    }

    /**
     * @dev Total Supply getter function
     *
     * @return uint256 Returns the Total Supply of the currency / token
     */
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    /**
     * @dev Transfer wihout additional data function
     *
     * @param _to The address of the receipent
     * @param _value The amount to send 
     * @return bool Whether or not function fired succesfully 
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Balance checking function
     *
     * @param _owner The address of the owner
     * @return uint256 The balance of the owner
     */
    function balanceOf(address _owner) public view returns(uint256 balance) {
        return balances[_owner];
    }

    /**
     * @dev Transfer with additional data function
     *
     * @param _to The address of the receipent
     * @param _value The amount to send 
     * @param bytes The data to send 
     */
    function transfer(address _to, uint _value, bytes _data) public {
        require(_value > 0);
        if (isContract(_to)) {
            OG_ERC223ReceivingContract receiver = OG_ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value, _data);
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns(uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
        allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    function isContract(address _addr) private returns(bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length: = extcodesize(_addr)
        }
        return (length > 0);
    }


}