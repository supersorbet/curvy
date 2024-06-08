// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import {ICurve} from "./ICurve.sol";
import {CurveErrorCodes} from "./CurveErrorCodes.sol";
import {FixedPointMathLib} from "curvy/curvy/lib/forge-std/lib/solady/src/utils/FixedPointMathLib.sol";

contract LinearCurve is ICurve, CurveErrorCodes {
    using FixedPointMathLib for uint256;

    function validateDelta(uint128 /*delta*/) external pure override returns (bool valid) {
        return true;
    }

    function validateSpotPrice(uint128 /* newSpotPrice */) external pure override returns (bool) {
        return true;
    }

    function getBuyInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier
    )
        external
        pure
        override
        returns (
            Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 inputValue,
            uint256 protocolFee
        )
    {
        if (numItems == 0) {
            return (Error.INVALID_NUMITEMS, 0, 0, 0, 0);
        }

        uint256 newSpotPrice_ = spotPrice + delta * numItems;
        if (newSpotPrice_ > type(uint128).max) {
            return (Error.SPOT_PRICE_OVERFLOW, 0, 0, 0, 0);
        }
        newSpotPrice = uint128(newSpotPrice_);

        uint256 buySpotPrice = spotPrice + delta;
        inputValue = numItems * buySpotPrice + (numItems * (numItems - 1) * delta) / 2;

        protocolFee = inputValue.fmul(protocolFeeMultiplier, FixedPointMathLib.WAD);
        inputValue += inputValue.fmul(feeMultiplier, FixedPointMathLib.WAD);
        inputValue += protocolFee;

        newDelta = delta;
        error = Error.OK;
    }

    function getSellInfo(
        uint128 spotPrice,
        uint128 delta,
        uint256 numItems,
        uint256 feeMultiplier,
        uint256 protocolFeeMultiplier
    )
        external
        pure
        override
        returns (
            Error error,
            uint128 newSpotPrice,
            uint128 newDelta,
            uint256 outputValue,
            uint256 protocolFee
        )
    {
        if (numItems == 0) {
            return (Error.INVALID_NUMITEMS, 0, 0, 0, 0);
        }

        uint256 totalPriceDecrease = delta * numItems;
        if (spotPrice < totalPriceDecrease) {
            newSpotPrice = 0;
            uint256 numItemsTillZeroPrice = spotPrice / delta + 1;
            numItems = numItemsTillZeroPrice;
        } else {
            newSpotPrice = spotPrice - uint128(totalPriceDecrease);
        }

        outputValue = numItems * spotPrice - (numItems * (numItems - 1) * delta) / 2;
        protocolFee = outputValue.fmul(protocolFeeMultiplier, FixedPointMathLib.WAD);
        outputValue -= outputValue.fmul(feeMultiplier, FixedPointMathLib.WAD);
        outputValue -= protocolFee;

        newDelta = delta;
        error = Error.OK;
    }
}
