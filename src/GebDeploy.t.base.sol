pragma solidity ^0.6.7;

import {DSTest} from "ds-test/test.sol";
import {DSToken} from "ds-token/token.sol";
import {DSValue} from "ds-value/value.sol";
import {DSRoles} from "ds-roles/roles.sol";
import {DSGuard} from "ds-guard/guard.sol";
import {WETH9_} from "ds-weth/weth9.sol";

import "./GebDeploy.sol";
import {CollateralJoin} from "./AdvancedTokenAdapters.sol";
import {GovActions} from "./GovActions.sol";

abstract contract Hevm {
    function warp(uint256) virtual public;
}

abstract contract AuctionLike {
    function increaseBidSize(uint, uint, uint) virtual public;
    function decreaseSoldAmount(uint, uint, uint) virtual public;
    function settleAuction(uint) virtual public;
}

abstract contract CDPApprovalLike {
    function approveCDPModification(address guy) virtual public;
}

contract FakeUser {
    function doApprove(address token, address guy) public {
        DSToken(token).approve(guy);
    }

    function doCoinJoin(address obj, address cdp, uint wad) public {
        CoinJoin(obj).join(cdp, wad);
    }

    function doCoinExit(address obj, address guy, uint wad) public {
        CoinJoin(obj).exit(guy, wad);
    }

    function doEthJoin(address payable obj, address collateralSource, address cdp, uint wad) public {
        WETH9_(obj).deposit{value: wad}();
        WETH9_(obj).approve(address(collateralSource), uint(-1));
        CollateralJoin(collateralSource).join(cdp, wad);
    }

    function doModifyCDPCollateralization(
      address obj, bytes32 collateralType, address cdp, address collateralSource, address coin, int deltaCollateral, int deltaDebt
    ) public {
        CDPEngine(obj).modifyCDPCollateralization(collateralType, cdp, collateralSource, coin, deltaCollateral, deltaDebt);
    }

    function doTransferCDPCollateralAndDebt(
      address obj, bytes32 collateralType, address src, address dst, int deltaCollateral, int deltaDebt
    ) public {
        CDPEngine(obj).transferCDPCollateralAndDebt(collateralType, src, dst, deltaCollateral, deltaDebt);
    }

    function doCDPApprove(address approval, address guy) public {
        CDPApprovalLike(approval).approveCDPModification(guy);
    }

    function doIncreaseBidSize(address auction, uint id, uint amountToBuy, uint bid) public {
        AuctionLike(auction).increaseBidSize(id, amountToBuy, bid);
    }

    function doDecreaseSoldAmount(address obj, uint id, uint amountToBuy, uint bid) public {
        AuctionLike(obj).decreaseSoldAmount(id, amountToBuy, bid);
    }

    function doSettleAuction(address obj, uint id) public {
        AuctionLike(obj).settleAuction(id);
    }

    function doGlobalSettlementFreeCollateral(address globalSettlement, bytes32 collateralType) public {
        GlobalSettlement(globalSettlement).freeCollateral(collateralType);
    }

    function doESMBurnTokens(address collateralSource, address esm, uint256 wad) public {
        DSToken(collateralSource).approve(esm, uint256(-1));
        ESM(esm).burnTokens(wad);
    }

    receive() external payable {}
}

contract ProxyActions {
    DSPause pause;
    GovActions govActions;

    function modifyParameters(address who, bytes32 parameter, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("modifyParameters(address,bytes32,uint256)", who, parameter, data);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }

    function modifyParameters(address who, bytes32 collateralType, bytes32 parameter, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("modifyParameters(address,bytes32,bytes32,uint256)", who, collateralType, parameter, data);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }

    function updateRateAndModifyParameters(address who, bytes32 parameter, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("updateRateAndModifyParameters(address,bytes32,uint256)", who, parameter, data);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }

    function taxAllAndModifyParameters(address who, bytes32 parameter, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("taxAllAndModifyParameters(address,bytes32,uint256)", who, parameter, data);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }

    function taxSingleAndModifyParameters(address who, bytes32 collateralType, bytes32 parameter, uint256 data) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("taxSingleAndModifyParameters(address,bytes32,bytes32,uint256)", who, collateralType, parameter, data);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }

    function shutdownSystem(address globalSettlement) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("shutdownSystem(address)", globalSettlement);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }

    function setAuthority(address newAuthority) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("setAuthority(address,address)", pause, newAuthority);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }

    function setDelay(uint newDelay) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("setDelay(address,uint256)", pause, newDelay);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }

    function setAuthorityAndDelay(address newAuthority, uint newDelay) external {
        address      usr = address(govActions);
        bytes32      tag;  assembly { tag := extcodehash(usr) }
        bytes memory fax = abi.encodeWithSignature("setAuthorityAndDelay(address,address,uint256)", pause, newAuthority, newDelay);
        uint         eta = now;

        pause.scheduleTransaction(usr, tag, fax, eta);
        pause.executeTransaction(usr, tag, fax, eta);
    }
}

contract GebDeployTestBase is DSTest, ProxyActions {
    Hevm hevm;

    CDPEngineFactory                         cdpEngineFactory;
    TaxCollectorFactory                      taxCollectorFactory;
    AccountingEngineFactory                  accountingEngineFactory;
    LiquidationEngineFactory                 liquidationEngineFactory;
    StabilityFeeTreasuryFactory              stabilityFeeTreasuryFactory;
    CoinFactory                              coinFactory;
    CoinJoinFactory                          coinJoinFactory;
    PreSettlementSurplusAuctionHouseFactory  preSettlementSurplusAuctionHouseFactory;
    PostSettlementSurplusAuctionHouseFactory postSettlementSurplusAuctionHouseFactory;
    DebtAuctionHouseFactory                  debtAuctionHouseFactory;
    CollateralAuctionHouseFactory            collateralAuctionHouseFactory;
    OracleRelayerFactory                     oracleRelayerFactory;
    GlobalSettlementFactory                  globalSettlementFactory;
    RedemptionRateSetterFactory              redemptionRateSetterFactory;
    EmergencyRateSetterFactory               emergencyRateSetterFactory;
    MoneyMarketSetterFactory                 moneyMarketSetterFactory;
    ESMFactory                               esmFactory;
    CoinSavingsAccountFactory                coinSavingsAccountFactory;
    SettlementSurplusAuctioneerFactory       settlementSurplusAuctioneerFactory;
    PauseFactory                             pauseFactory;

    GebDeploy gebDeploy;

    DSToken prot;
    DSValue orclETH;
    DSValue orclCOL;
    DSValue orclCOIN;

    DSRoles authority;

    WETH9_ weth;
    CollateralJoin ethJoin;
    CollateralJoin colJoin;

    CDPEngine                         cdpEngine;
    TaxCollector                      taxCollector;
    AccountingEngine                  accountingEngine;
    LiquidationEngine                 liquidationEngine;
    StabilityFeeTreasury              stabilityFeeTreasury;
    Coin                              coin;
    CoinJoin                          coinJoin;
    PreSettlementSurplusAuctionHouse  preSettlementSurplusAuctionHouse;
    PostSettlementSurplusAuctionHouse postSettlementSurplusAuctionHouse;
    DebtAuctionHouse                  debtAuctionHouse;
    OracleRelayer                     oracleRelayer;
    RedemptionRateSetter              redemptionRateSetter;
    EmergencyRateSetter               emergencyRateSetter;
    MoneyMarketSetter                 moneyMarketSetter;
    CoinSavingsAccount                coinSavingsAccount;
    GlobalSettlement                  globalSettlement;
    SettlementSurplusAuctioneer       settlementSurplusAuctioneer;
    ESM                               esm;

    CollateralAuctionHouse ethCollateralAuctionHouse;

    DSToken col;
    CollateralAuctionHouse colAuctionHouse;

    FakeUser user1;
    FakeUser user2;

    bytes32[] collateralTypes;
    uint256[] liquidationPenalties;

    // --- Math ---
    uint256 constant ONE = 10 ** 27;
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function ray(uint x) internal pure returns (uint z) {
        z = x * 10 ** 9;
    }

    function setUp() public {
        cdpEngineFactory = new CDPEngineFactory();
        taxCollectorFactory = new TaxCollectorFactory();
        accountingEngineFactory = new AccountingEngineFactory();
        liquidationEngineFactory = new LiquidationEngineFactory();
        coinFactory = new CoinFactory();
        coinJoinFactory = new CoinJoinFactory();
        preSettlementSurplusAuctionHouseFactory = new PreSettlementSurplusAuctionHouseFactory();
        postSettlementSurplusAuctionHouseFactory = new PostSettlementSurplusAuctionHouseFactory();
        debtAuctionHouseFactory = new DebtAuctionHouseFactory();
        collateralAuctionHouseFactory = new CollateralAuctionHouseFactory();
        oracleRelayerFactory = new OracleRelayerFactory();
        redemptionRateSetterFactory = new RedemptionRateSetterFactory();
        emergencyRateSetterFactory = new EmergencyRateSetterFactory();
        moneyMarketSetterFactory = new MoneyMarketSetterFactory();
        stabilityFeeTreasuryFactory = new StabilityFeeTreasuryFactory();
        settlementSurplusAuctioneerFactory = new SettlementSurplusAuctioneerFactory();
        globalSettlementFactory = new GlobalSettlementFactory();
        pauseFactory = new PauseFactory();
        govActions = new GovActions();
        esmFactory = new ESMFactory();
        coinSavingsAccountFactory = new CoinSavingsAccountFactory();

        gebDeploy = new GebDeploy();

        gebDeploy.setFirstFactoryBatch(
          cdpEngineFactory,
          taxCollectorFactory,
          accountingEngineFactory,
          liquidationEngineFactory,
          coinFactory,
          coinJoinFactory,
          coinSavingsAccountFactory,
          settlementSurplusAuctioneerFactory
        );

        gebDeploy.setSecondFactoryBatch(
          preSettlementSurplusAuctionHouseFactory,
          postSettlementSurplusAuctionHouseFactory,
          debtAuctionHouseFactory,
          collateralAuctionHouseFactory,
          oracleRelayerFactory,
          redemptionRateSetterFactory,
          globalSettlementFactory,
          esmFactory
        );

        gebDeploy.setThirdFactoryBatch(
          pauseFactory,
          emergencyRateSetterFactory,
          moneyMarketSetterFactory,
          stabilityFeeTreasuryFactory
        );

        prot = new DSToken("PROT");
        prot.setAuthority(new DSGuard());
        orclETH = new DSValue();
        orclCOL = new DSValue();
        orclCOIN = new DSValue();
        authority = new DSRoles();
        authority.setRootUser(address(this), true);

        user1 = new FakeUser();
        user2 = new FakeUser();
        address(user1).transfer(100 ether);
        address(user2).transfer(100 ether);

        hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
        hevm.warp(0);
    }

    function rad(uint wad) internal pure returns (uint) {
        return wad * 10 ** 27;
    }

    function deployBondKeepAuth() public {
        gebDeploy.deployCDPEngine();
        gebDeploy.deployCoin("Rai Reflex Bond", "RAI", 99);
        gebDeploy.deployTaxation();
        gebDeploy.deployRateSetter(address(orclCOIN));
        gebDeploy.deployAuctions(address(prot));
        gebDeploy.deployAccountingEngine();
        gebDeploy.deployStabilityFeeTreasury();
        gebDeploy.deploySettlementSurplusAuctioneer();
        gebDeploy.deployLiquidator();
        gebDeploy.deployShutdown(address(prot), address(0x0), 10);
        gebDeploy.deployPause(0, authority);

        cdpEngine = gebDeploy.cdpEngine();
        taxCollector = gebDeploy.taxCollector();
        accountingEngine = gebDeploy.accountingEngine();
        liquidationEngine = gebDeploy.liquidationEngine();
        preSettlementSurplusAuctionHouse = gebDeploy.preSettlementSurplusAuctionHouse();
        postSettlementSurplusAuctionHouse = gebDeploy.postSettlementSurplusAuctionHouse();
        debtAuctionHouse = gebDeploy.debtAuctionHouse();
        coin = gebDeploy.coin();
        coinJoin = gebDeploy.coinJoin();
        oracleRelayer = gebDeploy.oracleRelayer();
        globalSettlement = gebDeploy.globalSettlement();
        esm = gebDeploy.esm();
        pause = gebDeploy.pause();
        redemptionRateSetter = gebDeploy.redemptionRateSetter();
        settlementSurplusAuctioneer = gebDeploy.settlementSurplusAuctioneer();
        stabilityFeeTreasury = gebDeploy.stabilityFeeTreasury();

        authority.setRootUser(address(pause.proxy()), true);
        gebDeploy.giveControl(address(pause.proxy()));

        weth = new WETH9_();
        ethJoin = new CollateralJoin(address(cdpEngine), "ETH", address(weth));
        gebDeploy.deployCollateral("ETH", address(ethJoin), address(orclETH), 5 * 10**26);
        gebDeploy.addAuthToCollateralAuctionHouse("ETH", address(pause.proxy()));

        col = new DSToken("COL");
        colJoin = new CollateralJoin(address(cdpEngine), "COL", address(col));
        gebDeploy.deployCollateral("COL", address(colJoin), address(orclCOL), 5 * 10**26);
        gebDeploy.addAuthToCollateralAuctionHouse("COL", address(pause.proxy()));

        // Set CDPEngine Params
        this.modifyParameters(address(cdpEngine), bytes32("globalDebtCeiling"), uint(10000 * 10 ** 45));
        this.modifyParameters(address(cdpEngine), bytes32("ETH"), bytes32("debtCeiling"), uint(10000 * 10 ** 45));
        this.modifyParameters(address(cdpEngine), bytes32("COL"), bytes32("debtCeiling"), uint(10000 * 10 ** 45));

        orclETH.updateResult(bytes32(uint(300 * 10 ** 18))); // Price 300 COIN = 1 ETH (precision 18)
        orclCOL.updateResult(bytes32(uint(45 * 10 ** 18))); // Price 45 COIN = 1 COL (precision 18)
        orclCOIN.updateResult(bytes32(uint(1 * 10 ** 18))); // Price 1 COIN = 1 USD
        (ethCollateralAuctionHouse,) = gebDeploy.collateralTypes("ETH");
        (colAuctionHouse,) = gebDeploy.collateralTypes("COL");
        this.modifyParameters(address(oracleRelayer), "ETH", "liquidationCRatio", uint(1500000000 ether));
        this.modifyParameters(address(oracleRelayer), "ETH", "safetyCRatio", uint(1500000000 ether));
        this.modifyParameters(address(oracleRelayer), "COL", "liquidationCRatio", uint(1100000000 ether));
        this.modifyParameters(address(oracleRelayer), "COL", "safetyCRatio", uint(1100000000 ether));

        oracleRelayer.updateCollateralPrice("ETH");
        oracleRelayer.updateCollateralPrice("COL");
        (,,uint safetyPrice,,,uint liquidationPrice) = cdpEngine.collateralTypes("ETH");
        assertEq(safetyPrice, 300 * ONE * ONE / 1500000000 ether);
        assertEq(safetyPrice, liquidationPrice);
        (,, safetyPrice,,,liquidationPrice) = cdpEngine.collateralTypes("COL");
        assertEq(safetyPrice, 45 * ONE * ONE / 1100000000 ether);
        assertEq(safetyPrice, liquidationPrice);

        DSGuard(address(prot.authority())).permit(address(debtAuctionHouse), address(prot), bytes4(keccak256("mint(address,uint256)")));
        DSGuard(address(prot.authority())).permit(address(preSettlementSurplusAuctionHouse), address(prot), bytes4(keccak256("burn(address,uint256)")));
        DSGuard(address(prot.authority())).permit(address(postSettlementSurplusAuctionHouse), address(prot), bytes4(keccak256("burn(address,uint256)")));

        prot.mint(100 ether);
    }

    function deployStableKeepAuth() public {
        gebDeploy.deployCDPEngine();
        gebDeploy.deployCoin("Rai Stable Coin", "RAI", 99);
        gebDeploy.deployTaxation();
        gebDeploy.deploySavingsAccount();
        gebDeploy.deployEmergencyRateSetter(address(orclCOIN));
        gebDeploy.deployMoneyMarketSetter(address(orclCOIN));
        gebDeploy.deployAuctions(address(prot));
        gebDeploy.deployAccountingEngine();
        gebDeploy.deployStabilityFeeTreasury();
        gebDeploy.deploySettlementSurplusAuctioneer();
        gebDeploy.deployLiquidator();
        gebDeploy.deployShutdown(address(prot), address(0x0), 10);
        gebDeploy.deployPause(0, authority);

        cdpEngine = gebDeploy.cdpEngine();
        taxCollector = gebDeploy.taxCollector();
        accountingEngine = gebDeploy.accountingEngine();
        liquidationEngine = gebDeploy.liquidationEngine();
        preSettlementSurplusAuctionHouse = gebDeploy.preSettlementSurplusAuctionHouse();
        postSettlementSurplusAuctionHouse = gebDeploy.postSettlementSurplusAuctionHouse();
        debtAuctionHouse = gebDeploy.debtAuctionHouse();
        coinSavingsAccount = gebDeploy.coinSavingsAccount();
        coin = gebDeploy.coin();
        coinJoin = gebDeploy.coinJoin();
        oracleRelayer = gebDeploy.oracleRelayer();
        globalSettlement = gebDeploy.globalSettlement();
        esm = gebDeploy.esm();
        pause = gebDeploy.pause();
        emergencyRateSetter = gebDeploy.emergencyRateSetter();
        moneyMarketSetter = gebDeploy.moneyMarketSetter();
        settlementSurplusAuctioneer = gebDeploy.settlementSurplusAuctioneer();
        stabilityFeeTreasury = gebDeploy.stabilityFeeTreasury();

        authority.setRootUser(address(pause.proxy()), true);
        gebDeploy.giveControl(address(pause.proxy()));

        weth = new WETH9_();
        ethJoin = new CollateralJoin(address(cdpEngine), "ETH", address(weth));
        gebDeploy.deployCollateral("ETH", address(ethJoin), address(orclETH), 5 * 10**26);
        gebDeploy.addAuthToCollateralAuctionHouse("ETH", address(pause.proxy()));

        col = new DSToken("COL");
        colJoin = new CollateralJoin(address(cdpEngine), "COL", address(col));
        gebDeploy.deployCollateral("COL", address(colJoin), address(orclCOL), 5 * 10**26);
        gebDeploy.addAuthToCollateralAuctionHouse("COL", address(pause.proxy()));

        // Set CDPEngine Params
        this.modifyParameters(address(cdpEngine), bytes32("globalDebtCeiling"), uint(10000 * 10 ** 45));
        this.modifyParameters(address(cdpEngine), bytes32("ETH"), bytes32("debtCeiling"), uint(10000 * 10 ** 45));
        this.modifyParameters(address(cdpEngine), bytes32("COL"), bytes32("debtCeiling"), uint(10000 * 10 ** 45));

        orclETH.updateResult(bytes32(uint(300 * 10 ** 18))); // Price 300 COIN = 1 ETH (precision 18)
        orclCOL.updateResult(bytes32(uint(45 * 10 ** 18))); // Price 45 COIN = 1 COL (precision 18)
        orclCOIN.updateResult(bytes32(uint(1 * 10 ** 18))); // Price 1 COIN = 1 USD
        (ethCollateralAuctionHouse,) = gebDeploy.collateralTypes("ETH");
        (colAuctionHouse,) = gebDeploy.collateralTypes("COL");
        this.modifyParameters(address(oracleRelayer), "ETH", "liquidationCRatio", uint(1500000000 ether));
        this.modifyParameters(address(oracleRelayer), "ETH", "safetyCRatio", uint(1500000000 ether));
        this.modifyParameters(address(oracleRelayer), "COL", "liquidationCRatio", uint(1100000000 ether));
        this.modifyParameters(address(oracleRelayer), "COL", "safetyCRatio", uint(1100000000 ether));
        oracleRelayer.updateCollateralPrice("ETH");
        oracleRelayer.updateCollateralPrice("COL");
        (,,uint safetyPrice,,,uint liquidationPrice) = cdpEngine.collateralTypes("ETH");
        assertEq(safetyPrice, 300 * ONE * ONE / 1500000000 ether);
        assertEq(safetyPrice, liquidationPrice);
        (,, safetyPrice,,,liquidationPrice) = cdpEngine.collateralTypes("COL");
        assertEq(safetyPrice, 45 * ONE * ONE / 1100000000 ether);
        assertEq(safetyPrice, liquidationPrice);

        DSGuard(address(prot.authority())).permit(address(debtAuctionHouse), address(prot), bytes4(keccak256("mint(address,uint256)")));
        DSGuard(address(prot.authority())).permit(address(preSettlementSurplusAuctionHouse), address(prot), bytes4(keccak256("burn(address,uint256)")));
        DSGuard(address(prot.authority())).permit(address(postSettlementSurplusAuctionHouse), address(prot), bytes4(keccak256("burn(address,uint256)")));

        prot.mint(100 ether);
    }

    // Bond
    function deployBond() public {
        deployBondKeepAuth();
        gebDeploy.releaseAuth();
    }
    function deployBondWithCreatorPermissions() public {
        deployBondKeepAuth();
        gebDeploy.addCreatorAuth();
        gebDeploy.releaseAuth();
    }

    // Stablecoin
    function deployStable() public {
        deployStableKeepAuth();
        gebDeploy.releaseAuth();
    }
    function deployStableWithCreatorPermissions() public {
        deployStableKeepAuth();
        gebDeploy.addCreatorAuth();
        gebDeploy.releaseAuth();
    }

    // Utils
    function release() public {
        gebDeploy.releaseAuth();
    }

    receive() external payable {}
}
