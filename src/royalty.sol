// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

contract RoyaltyVault {
    address treasuryWallet;
    address communityFund;
    address owner;
    address investorsAccount;
//30% to community
// 24.5% to treasury
//35% to owners
// 10.5% to owner
    uint256 treasuryBasisPoint = 2450;
    uint256 communityBasisPoint = 3000;
    uint256 ownerBasisPoint = 3500;
    uint256 investorsBasisPoint = 1050;

    error notOwner();
    error transferToAddress0();
    error transferedFail();
    event transferAll(uint tres, uint comm, uint owner, uint investor);

    constructor(address _treasuryWallet, address _communityFund,address _investorsAccount ) payable {
        owner = msg.sender;
        assert(_treasuryWallet != address(0));
        treasuryWallet = _treasuryWallet;
        assert(_communityFund != address(0));
        communityFund = _communityFund;
        assert(_investorsAccount != address(0));
        investorsAccount = _investorsAccount;
    }

    function distributeRoyalty() external {
        if (msg.sender != owner) revert notOwner();
        (
            address treasury,
            address community,
            address _owner,
            address investors
        ) = checkForAddress0();
        uint256 treasuryAllocation = calculateTreasuryFund();
        uint256 communityAllocation = calculateCommunityFund();
        uint256 ownerAllocation = calculateOwnerFund();
        uint256 investorsAllocation = calculateinvestorsFund();


        payable(treasury).transfer(treasuryAllocation);
        payable(community).transfer(communityAllocation);
        payable(_owner).transfer(ownerAllocation);

        payable(investors).transfer(investorsAllocation);

        emit transferAll(treasuryAllocation, communityAllocation, ownerAllocation, investorsAllocation);
    }

    function calculateTreasuryFund()
        public
        view
        returns (uint256 treasuryAllocation)
    {
        uint256 amount = address(this).balance;
        treasuryAllocation = (amount * treasuryBasisPoint) / 10000;
    }

    function calculateCommunityFund()
        public
        view
        returns (uint256 communityAllocation)
    {
        uint256 amount = address(this).balance;
        communityAllocation = (amount * communityBasisPoint) / 10000;
    }

    function calculateOwnerFund()
        public
        view
        returns (uint256 ownerAllocation)
    {
        uint256 amount = address(this).balance;
        ownerAllocation = (amount * ownerBasisPoint) / 10000;
    }

    function calculateinvestorsFund()
        public
        view
        returns (uint256 investorsAllocation)
    {
        uint256 amount = address(this).balance;
        investorsAllocation = (amount * investorsBasisPoint) / 10000;
    }

    function checkForAddress0()
        private
        view
        returns (
            address treasury,
            address community,
            address _owner,
            address investors
        )
    {
        if (
            treasuryWallet == address(0) ||
            communityFund == address(0) ||
            owner == address(0) ||
            investorsAccount == address(0)
        ) revert transferToAddress0();
        return (treasury, community, _owner, investors);
    }

    receive() external payable{}
}
