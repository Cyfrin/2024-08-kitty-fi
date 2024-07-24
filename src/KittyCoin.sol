// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract KittyCoin is ERC20 {
    error KittyCoin__OnlyKittyPoolCanMintOrBurn();

    address private pool;

    modifier onlyKittyPool() {
        require(msg.sender == pool, KittyCoin__OnlyKittyPoolCanMintOrBurn());
        _;
    }

    constructor(address _pool) ERC20("Kitty Token", "MEOWDY") {
        pool = _pool;
    }

    function mint(address _to, uint256 _amount) external onlyKittyPool {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyKittyPool {
        _burn(_from, _amount);
    }
}