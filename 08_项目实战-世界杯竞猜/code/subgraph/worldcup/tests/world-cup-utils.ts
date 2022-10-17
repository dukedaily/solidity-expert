import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import { ClaimReward, Finialize, Play } from "../generated/WorldCup/WorldCup"

export function createClaimRewardEvent(
  _claimer: Address,
  _amt: BigInt
): ClaimReward {
  let claimRewardEvent = changetype<ClaimReward>(newMockEvent())

  claimRewardEvent.parameters = new Array()

  claimRewardEvent.parameters.push(
    new ethereum.EventParam("_claimer", ethereum.Value.fromAddress(_claimer))
  )
  claimRewardEvent.parameters.push(
    new ethereum.EventParam("_amt", ethereum.Value.fromUnsignedBigInt(_amt))
  )

  return claimRewardEvent
}

export function createFinializeEvent(
  _currRound: i32,
  _winners: Array<Address>,
  currAvalBalance: BigInt,
  _giftAmt: BigInt
): Finialize {
  let finializeEvent = changetype<Finialize>(newMockEvent())

  finializeEvent.parameters = new Array()

  finializeEvent.parameters.push(
    new ethereum.EventParam(
      "_currRound",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(_currRound))
    )
  )
  finializeEvent.parameters.push(
    new ethereum.EventParam(
      "_winners",
      ethereum.Value.fromAddressArray(_winners)
    )
  )
  finializeEvent.parameters.push(
    new ethereum.EventParam(
      "currAvalBalance",
      ethereum.Value.fromUnsignedBigInt(currAvalBalance)
    )
  )
  finializeEvent.parameters.push(
    new ethereum.EventParam(
      "_giftAmt",
      ethereum.Value.fromUnsignedBigInt(_giftAmt)
    )
  )

  return finializeEvent
}

export function createPlayEvent(
  _currRound: i32,
  _player: Address,
  _country: i32
): Play {
  let playEvent = changetype<Play>(newMockEvent())

  playEvent.parameters = new Array()

  playEvent.parameters.push(
    new ethereum.EventParam(
      "_currRound",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(_currRound))
    )
  )
  playEvent.parameters.push(
    new ethereum.EventParam("_player", ethereum.Value.fromAddress(_player))
  )
  playEvent.parameters.push(
    new ethereum.EventParam(
      "_country",
      ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(_country))
    )
  )

  return playEvent
}
