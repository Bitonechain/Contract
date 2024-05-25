
/**
 *Submitted for verification at Etherscan.io on 2021-02-26
*/

pragma solidity ^0.4.26;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    string public name ;
    string public symbol;
    uint8 public constant decimals = 18;  
    uint256 public totalSupply;
	
	uint256 private constant INITIAL_SUPPLY = 0;

	mapping(address => bool) public deployers;

    mapping (address => uint256) public balanceOf;  // 
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);
	
	event Approval(address indexed owner, address indexed spender, uint256 value);

	event Mint(address indexed receiver, uint256 indexed amount);

	function TokenERC20(string tokenName, string tokenSymbol) public {
		totalSupply = INITIAL_SUPPLY;
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;

        deployers[msg.sender] = true;
    }

    modifier onlyDeployer() {
        require(deployers[msg.sender], "Only Deployer");
        _;
    }

    function setDeployer(address _dep, bool flag) public onlyDeployer {
    	require(_dep != address(0), "deployer can't be zero");
    	deployers[_dep] = flag;
    }

    function _transfer(address _from, address _to, uint _value) internal returns (bool) {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
		return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
		//require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }

    function mint(address receiver, uint256 amount) public onlyDeployer returns(bool success) {
    	balanceOf[receiver] += amount;
    	totalSupply += amount;
    	emit Mint(receiver, amount);
    	return true;
    }
}