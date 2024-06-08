// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "curvy/curvy/lib/forge-std/src/Test.sol";
import "curvy/curvy/src/LinearCurve.sol";

contract LinearCurveTest is Test {
    LinearCurve linearCurve;

    function setUp() public {
        linearCurve = new LinearCurve();
    }

    function testValidateDelta() public {
        bool result = linearCurve.validateDelta(100);
        assertTrue(result);
    }

    function testValidateSpotPrice() public {
        bool result = linearCurve.validateSpotPrice(200);
        assertTrue(result);
    }

    function testGetBuyInfo() public {
        (
            CurveErrorCodes.Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 inputValue,
            uint256 protocolFee
        ) = linearCurve.getBuyInfo(100, 10, 5, 1 ether, 0.05 ether);

        assertEq(uint256(error), uint256(CurveErrorCodes.Error.OK));
        assertEq(newSpotPrice, 150); // 100 + 10*5
        assertEq(newDelta, 10);
        assertEq(inputValue, 575); // Simplified for example
        assertEq(protocolFee, 28.75 ether); // Simplified for example
    }

    function testGetSellInfo() public {
        (
            CurveErrorCodes.Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 outputValue,
            uint256 protocolFee
        ) = linearCurve.getSellInfo(200, 10, 5, 1 ether, 0.05 ether);

        assertEq(uint256(error), uint256(CurveErrorCodes.Error.OK));
        assertEq(newSpotPrice, 150); // Simplified for example
        assertEq(newDelta, 10);
        assertEq(outputValue, 875); // Simplified for example
        assertEq(protocolFee, 43.75 ether); // Simplified for example
    }
}
