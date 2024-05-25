pragma solidity >=0.4.23 <0.6.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

interface IToken {
    function transfer(address _to, uint256 _value) external returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool);
}

contract AirDrop {
	uint256 public index = 0;
	mapping(uint256 => uint256) public amounts;
	mapping(address => bool) public rewarders;

	IToken public bto;
	mapping(address => bool) public deployers;
	uint256 public maxIndex = 9;
	uint256 public sumReward = 0;

	event EventAirDrop(address indexed from, uint256 indexed amount);

	modifier onlyDeployer() {
        require(deployers[msg.sender], "Only deployers");
        _;
    }

	constructor(address btoAddress) public {
		deployers[msg.sender] = true;

		bto = IToken(btoAddress);

		amounts[0] = 10 * (10 ** 16);
		amounts[1] = 16 * (10 ** 16);
		amounts[2] = 13 * (10 ** 16);
		amounts[3] = 14 * (10 ** 16);
		amounts[4] = 19 * (10 ** 16);
		amounts[5] = 18 * (10 ** 16);
		amounts[6] = 11 * (10 ** 16);
		amounts[7] = 17 * (10 ** 16);
		amounts[8] = 15 * (10 ** 16);
		amounts[9] = 12 * (10 ** 16);
	}

	function setDeployer(address _dep, bool flag) external onlyDeployer {
    	require(_dep != address(0), "deployer can't be zero");
    	deployers[_dep] = true;
    }

    function protectBto(uint256 amount) public onlyDeployer{
    	bto.transfer(msg.sender, amount);
    }

    function setMaxIndex(uint256 _p) external onlyDeployer {
    	require(maxIndex > 0, "index must greater than zero");
    	maxIndex = _p;
    }

    function setAmount(uint256 _index, uint256 _amount) external onlyDeployer {
    	amounts[_index] = _amount;
    }

	function GetReward() external {
		require(!rewarders[msg.sender], "old user");
		if(index > maxIndex) {
			index = 0;
		}
		bto.transfer(msg.sender, amounts[index]);
		rewarders[msg.sender] = true;
		sumReward += amounts[index];
		emit EventAirDrop(msg.sender, amounts[index]);
		index++;
	}
}
