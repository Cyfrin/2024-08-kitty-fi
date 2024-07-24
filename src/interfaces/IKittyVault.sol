// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

interface IKittyVault {
    function getUserVaultMeowllateralInEuros(address _user) external view returns (uint256);
    function executeDepawsit(address _user, uint256 _ameownt) external;
    function executeWhiskdrawal(address _user, uint256 _ameownt) external;
}