pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "../node_modules/iexec-solidity/contracts/ERC725_IdentityProxy/IERC725.sol";
import "../node_modules/iexec-solidity/contracts/ERC1154_OracleInterface/IERC1154.sol";
import "../node_modules/iexec-solidity/contracts/Libs/SafeMath.sol";
import "../node_modules/iexec-solidity/contracts/Libs/ECDSA.sol";

import "./libs/IexecODBLibCore.sol";
import "./libs/IexecODBLibOrders.sol";
import "./registries/RegistryBase.sol";
import "./CategoryManager.sol";
import "./IexecClerk.sol";

contract IexecHub is CategoryManager, IOracle, ECDSA
{
	using SafeMath          for uint256;
	using IexecODBLibOrders for *;

	/***************************************************************************
	 *                                Constants                                *
	 ***************************************************************************/
	uint256 public constant CONTRIBUTION_DEADLINE_RATIO = 7;
	uint256 public constant       REVEAL_DEADLINE_RATIO = 2;
	uint256 public constant        FINAL_DEADLINE_RATIO = 10;

	/***************************************************************************
	 *                             Other contracts                             *
	 ***************************************************************************/
	IexecClerk   public iexecclerk;
	RegistryBase public appregistry;
	RegistryBase public datasetregistry;
	RegistryBase public workerpoolregistry;

	/***************************************************************************
	 *                          Consensuses & Workers                          *
	 ***************************************************************************/
	mapping(bytes32 =>                    IexecODBLibCore.Task         ) m_tasks;
	mapping(bytes32 => mapping(address => IexecODBLibCore.Contribution)) m_contributions;
	mapping(address =>                    uint256                      ) m_workerScores;

	mapping(bytes32 => mapping(address => uint256                     )) m_logweight;
	mapping(bytes32 => mapping(bytes32 => uint256                     )) m_groupweight;
	mapping(bytes32 =>                    uint256                      ) m_totalweight;

	/***************************************************************************
	 *                                 Events                                  *
	 ***************************************************************************/
	event TaskInitialize(bytes32 indexed taskid, address indexed workerpool);
	event TaskContribute(bytes32 indexed taskid, address indexed worker, bytes32 hash);
	event TaskConsensus (bytes32 indexed taskid, bytes32 consensus);
	event TaskReveal    (bytes32 indexed taskid, address indexed worker, bytes32 digest);
	event TaskReopen    (bytes32 indexed taskid);
	event TaskFinalize  (bytes32 indexed taskid, bytes results);
	event TaskClaimed   (bytes32 indexed taskid);

	event AccurateContribution(address indexed worker, bytes32 indexed taskid);
	event FaultyContribution  (address indexed worker, bytes32 indexed taskid);

	/***************************************************************************
	 *                                Modifiers                                *
	 ***************************************************************************/
	modifier onlyScheduler(bytes32 _taskid)
	{
		require(msg.sender == iexecclerk.viewDeal(m_tasks[_taskid].dealid).workerpool.owner);
		_;
	}

	/***************************************************************************
	 *                               Constructor                               *
	 ***************************************************************************/
	constructor()
	public
	{
	}

	function attachContracts(
		address _iexecclerkAddress,
		address _appregistryAddress,
		address _datasetregistryAddress,
		address _workerpoolregistryAddress)
	external onlyOwner
	{
		require(address(iexecclerk) == address(0));
		iexecclerk         = IexecClerk  (_iexecclerkAddress  );
		appregistry        = RegistryBase(_appregistryAddress);
		datasetregistry    = RegistryBase(_datasetregistryAddress);
		workerpoolregistry = RegistryBase(_workerpoolregistryAddress);
	}

	/***************************************************************************
	 *                                Accessors                                *
	 ***************************************************************************/
	function viewTask(bytes32 _taskid)
	external view returns (IexecODBLibCore.Task memory)
	{
		return m_tasks[_taskid];
	}

	function viewContribution(bytes32 _taskid, address _worker)
	external view returns (IexecODBLibCore.Contribution memory)
	{
		return m_contributions[_taskid][_worker];
	}

	function viewScore(address _worker)
	external view returns (uint256)
	{
		return m_workerScores[_worker];
	}

	function checkResources(address app, address dataset, address workerpool)
	external view returns (bool)
	{
		require(                         appregistry.isRegistered(app));
		require(dataset == address(0) || datasetregistry.isRegistered(dataset));
		require(                         workerpoolregistry.isRegistered(workerpool));
		return true;
	}

	/***************************************************************************
	 *                         EIP 1154 PULL INTERFACE                         *
	 ***************************************************************************/
	function resultFor(bytes32 id)
	external view returns (bytes memory)
	{
		IexecODBLibCore.Task storage task = m_tasks[id];
		require(task.status == IexecODBLibCore.TaskStatusEnum.COMPLETED);
		return task.results;
	}

	/***************************************************************************
	 *                       Hashing and signature tools                       *
	 ***************************************************************************/
	function checkIdentity(address _identity, address _candidate, uint256 _purpose)
	internal view returns (bool valid)
	{
		return _identity == _candidate || IERC725(_identity).keyHasPurpose(keccak256(abi.encode(_candidate)), _purpose); // Simple address || Identity contract
	}

	/***************************************************************************
	 *                            Consensus methods                            *
	 ***************************************************************************/
	function initialize(bytes32 _dealid, uint256 idx)
	public returns (bytes32)
	{
		IexecODBLibCore.Deal memory deal = iexecclerk.viewDeal(_dealid);

		require(idx >= deal.botFirst                  );
		require(idx <  deal.botFirst.add(deal.botSize));

		bytes32 taskid  = keccak256(abi.encodePacked(_dealid, idx));
		IexecODBLibCore.Task storage task = m_tasks[taskid];
		require(task.status == IexecODBLibCore.TaskStatusEnum.UNSET);

		task.status               = IexecODBLibCore.TaskStatusEnum.ACTIVE;
		task.dealid               = _dealid;
		task.idx                  = idx;
		task.timeref              = m_categories[deal.category].workClockTimeRef;
		task.contributionDeadline = task.timeref.mul(CONTRIBUTION_DEADLINE_RATIO).add(deal.startTime);
		task.finalDeadline        = task.timeref.mul(       FINAL_DEADLINE_RATIO).add(deal.startTime);

		// setup denominator
		m_totalweight[taskid] = 1;

		emit TaskInitialize(taskid, iexecclerk.viewDeal(_dealid).workerpool.pointer);

		return taskid;
	}

	// TODO: make external w/ calldata
	function contribute(
		bytes32                _taskid,
		bytes32                _resultHash,
		bytes32                _resultSeal,
		address                _enclaveChallenge,
		ECDSA.signature memory _enclaveSign,
		ECDSA.signature memory _workerpoolSign)
	public
	{
		IexecODBLibCore.Task         storage task         = m_tasks[_taskid];
		IexecODBLibCore.Contribution storage contribution = m_contributions[_taskid][msg.sender];
		IexecODBLibCore.Deal         memory  deal         = iexecclerk.viewDeal(task.dealid);

		require(task.status               == IexecODBLibCore.TaskStatusEnum.ACTIVE       );
		require(task.contributionDeadline >  now                                         );
		require(contribution.status       == IexecODBLibCore.ContributionStatusEnum.UNSET);

		// Check that the worker + taskid + enclave combo is authorized to contribute (scheduler signature)
		require(checkIdentity(
			deal.workerpool.owner,
			recover(
				toEthSignedMessageHash(
					keccak256(abi.encodePacked(
						msg.sender,
						_taskid,
						_enclaveChallenge
					))
				),
				_workerpoolSign
			),
			4
		));

		// need enclave challenge if tag is set
		require(_enclaveChallenge != address(0) || (deal.tag[31] & 0x01 == 0));

		// Check enclave signature
		require(_enclaveChallenge == address(0) || checkIdentity(
			_enclaveChallenge,
			recover(
				toEthSignedMessageHash(
					keccak256(abi.encodePacked(
						_resultHash,
						_resultSeal
					))
				),
				_enclaveSign
			),
			4
		));

		// Update contribution entry
		contribution.status           = IexecODBLibCore.ContributionStatusEnum.CONTRIBUTED;
		contribution.resultHash       = _resultHash;
		contribution.resultSeal       = _resultSeal;
		contribution.enclaveChallenge = _enclaveChallenge;
		task.contributors.push(msg.sender);

		iexecclerk.lockContribution(task.dealid, msg.sender);

		emit TaskContribute(_taskid, msg.sender, _resultHash);

		// Contribution done → updating and checking concensus

		/*************************************************************************
		 *                           SCORE POLICY 1/3                            *
		 *                                                                       *
		 *                          see documentation!                           *
		 *************************************************************************/
		// k = 3
		uint256 weight = m_workerScores[msg.sender].div(3).max(3).sub(1);
		uint256 group  = m_groupweight[_taskid][_resultHash];
		uint256 delta  = group.max(1).mul(weight).sub(group);

		m_logweight  [_taskid][msg.sender ] = weight.log();
		m_groupweight[_taskid][_resultHash] = m_groupweight[_taskid][_resultHash].add(delta);
		m_totalweight[_taskid]              = m_totalweight[_taskid].add(delta);

		// Check consensus
		checkConsensus(_taskid, _resultHash);
	}
	function checkConsensus(
		bytes32 _taskid,
		bytes32 _consensus)
	private
	{
		uint256 trust = iexecclerk.viewDeal(m_tasks[_taskid].dealid).trust;
		if (m_groupweight[_taskid][_consensus].mul(trust) > m_totalweight[_taskid].mul(trust.sub(1)))
		{
			// Preliminary checks done in "contribute()"

			IexecODBLibCore.Task storage task = m_tasks[_taskid];
			uint256 winnerCounter = 0;
			for (uint256 i = 0; i < task.contributors.length; ++i)
			{
				address w = task.contributors[i];
				if
				(
					m_contributions[_taskid][w].resultHash == _consensus
					&&
					m_contributions[_taskid][w].status == IexecODBLibCore.ContributionStatusEnum.CONTRIBUTED // REJECTED contribution must not be count
				)
				{
					winnerCounter = winnerCounter.add(1);
				}
			}
			// msg.sender is a contributor: no need to check
			// require(winnerCounter > 0);
			task.status         = IexecODBLibCore.TaskStatusEnum.REVEALING;
			task.consensusValue = _consensus;
			task.revealDeadline = task.timeref.mul(REVEAL_DEADLINE_RATIO).add(now);
			task.revealCounter  = 0;
			task.winnerCounter  = winnerCounter;

			emit TaskConsensus(_taskid, _consensus);
		}
	}

	function reveal(
		bytes32 _taskid,
		bytes32 _resultDigest)
	external // worker
	{
		IexecODBLibCore.Task         storage task         = m_tasks[_taskid];
		IexecODBLibCore.Contribution storage contribution = m_contributions[_taskid][msg.sender];
		require(task.status             == IexecODBLibCore.TaskStatusEnum.REVEALING                       );
		require(task.revealDeadline     >  now                                                            );
		require(contribution.status     == IexecODBLibCore.ContributionStatusEnum.CONTRIBUTED             );
		require(contribution.resultHash == task.consensusValue                                            );
		require(contribution.resultHash == keccak256(abi.encodePacked(            _taskid, _resultDigest)));
		require(contribution.resultSeal == keccak256(abi.encodePacked(msg.sender, _taskid, _resultDigest)));

		contribution.status = IexecODBLibCore.ContributionStatusEnum.PROVED;
		task.revealCounter  = task.revealCounter.add(1);

		emit TaskReveal(_taskid, msg.sender, _resultDigest);
	}

	function reopen(
		bytes32 _taskid)
	external onlyScheduler(_taskid)
	{
		IexecODBLibCore.Task storage task = m_tasks[_taskid];
		require(task.status         == IexecODBLibCore.TaskStatusEnum.REVEALING);
		require(task.finalDeadline  >  now                                     );
		require(task.revealDeadline <= now
		     && task.revealCounter  == 0                                       );

		for (uint256 i = 0; i < task.contributors.length; ++i)
		{
			address worker = task.contributors[i];
			if (m_contributions[_taskid][worker].resultHash == task.consensusValue)
			{
				m_contributions[_taskid][worker].status = IexecODBLibCore.ContributionStatusEnum.REJECTED;
			}
		}

		m_totalweight[_taskid]                      = m_totalweight[_taskid].sub(m_groupweight[_taskid][task.consensusValue]);
		m_groupweight[_taskid][task.consensusValue] = 0;

		task.status         = IexecODBLibCore.TaskStatusEnum.ACTIVE;
		task.consensusValue = 0x0;
		task.revealDeadline = 0;
		task.winnerCounter  = 0;

		emit TaskReopen(_taskid);
	}

	function finalize(
		bytes32          _taskid,
		bytes   calldata _results)
	external onlyScheduler(_taskid)
	{
		IexecODBLibCore.Task storage task = m_tasks[_taskid];
		require(task.status        == IexecODBLibCore.TaskStatusEnum.REVEALING);
		require(task.finalDeadline >  now                                     );
		require(task.revealCounter == task.winnerCounter
		    || (task.revealCounter >  0  && task.revealDeadline <= now)       );

		task.status  = IexecODBLibCore.TaskStatusEnum.COMPLETED;
		task.results = _results;

		/**
		 * Stake and reward management
		 */
		iexecclerk.successWork(task.dealid);
		distributeRewards(_taskid);

		/**
		 * Event
		 */
		emit TaskFinalize(_taskid, _results);

		/**
		 * Callback for smartcontracts using EIP1154
		 */
		address callbackTarget = iexecclerk.viewDeal(task.dealid).callback;
		if (callbackTarget != address(0))
		{
			/**
			 * Call does not revert if the target smart contract is incompatible or reverts
			 *
			 * ATTENTION!
			 * This call is dangerous and target smart contract can charge the stack.
			 * Assume invalid state after the call.
			 * See: https://solidity.readthedocs.io/en/develop/types.html#members-of-addresses
			 *
			 * TODO: gas provided?
			 */
			require(gasleft() > 100000);
			callbackTarget.call.gas(100000)(abi.encodeWithSignature(
				"receiveResult(bytes32,bytes)",
				_taskid,
				_results
			));
		}
	}

	function distributeRewards(bytes32 _taskid)
	private
	{
		IexecODBLibCore.Task storage task = m_tasks[_taskid];
		IexecODBLibCore.Deal memory  deal = iexecclerk.viewDeal(task.dealid);

		uint256 i;
		address worker;

		uint256 totalLogWeight = 0;
		uint256 totalReward = iexecclerk.viewDeal(task.dealid).workerpool.price;

		for (i = 0; i < task.contributors.length; ++i)
		{
			worker = task.contributors[i];
			if (m_contributions[_taskid][worker].status == IexecODBLibCore.ContributionStatusEnum.PROVED)
			{
				totalLogWeight = totalLogWeight.add(m_logweight[_taskid][worker]);
			}
			else // ContributionStatusEnum.REJECT or ContributionStatusEnum.CONTRIBUTED (not revealed)
			{
				totalReward = totalReward.add(deal.workerStake);
			}
		}
		require(totalLogWeight > 0);

		// compute how much is going to the workers
		uint256 workersReward = totalReward.percentage(uint256(100).sub(deal.schedulerRewardRatio));

		for (i = 0; i < task.contributors.length; ++i)
		{
			worker = task.contributors[i];
			if (m_contributions[_taskid][worker].status == IexecODBLibCore.ContributionStatusEnum.PROVED)
			{
				uint256 workerReward = workersReward.mulByFraction(m_logweight[_taskid][worker], totalLogWeight);
				totalReward          = totalReward.sub(workerReward);

				iexecclerk.unlockAndRewardForContribution(task.dealid, worker, workerReward);

				// Only reward if replication happened
				if (task.contributors.length > 1)
				{
					/*******************************************************************
					 *                        SCORE POLICY 2/3                         *
					 *                                                                 *
					 *                       see documentation!                        *
					 *******************************************************************/
					m_workerScores[worker] = m_workerScores[worker].add(1);
					emit AccurateContribution(worker, _taskid);
				}
			}
			else // WorkStatusEnum.POCO_REJECT or ContributionStatusEnum.CONTRIBUTED (not revealed)
			{
				// No Reward
				iexecclerk.seizeContribution(task.dealid, worker);

				// Always punish bad contributors
				{
					/*******************************************************************
					 *                        SCORE POLICY 3/3                         *
					 *                                                                 *
					 *                       see documentation!                        *
					 *******************************************************************/
					// k = 3
					m_workerScores[worker] = m_workerScores[worker].mulByFraction(2,3);
					emit FaultyContribution(worker, _taskid);
				}
			}
		}
		// totalReward now contains the scheduler share
		iexecclerk.rewardForScheduling(task.dealid, totalReward);
	}

	function claim(
		bytes32 _taskid)
	public
	{
		IexecODBLibCore.Task storage task = m_tasks[_taskid];
		require(task.status == IexecODBLibCore.TaskStatusEnum.ACTIVE
		     || task.status == IexecODBLibCore.TaskStatusEnum.REVEALING);
		require(task.finalDeadline <= now);

		task.status = IexecODBLibCore.TaskStatusEnum.FAILLED;

		/**
		 * Stake management
		 */
		iexecclerk.failedWork(task.dealid);
		for (uint256 i = 0; i < task.contributors.length; ++i)
		{
			address worker = task.contributors[i];
			iexecclerk.unlockContribution(task.dealid, worker);
		}

		emit TaskClaimed(_taskid);
	}

	/***************************************************************************
	 *                            Array operations                             *
	 ***************************************************************************/
	function initializeArray(
		bytes32[] calldata _dealid,
		uint256[] calldata _idx)
	external returns (bool)
	{
		require(_dealid.length == _idx.length);
		for (uint i = 0; i < _dealid.length; ++i)
		{
			initialize(_dealid[i], _idx[i]);
		}
		return true;
	}

	function claimArray(
		bytes32[] calldata _taskid)
	external returns (bool)
	{
		for (uint i = 0; i < _taskid.length; ++i)
		{
			claim(_taskid[i]);
		}
		return true;
	}

	function initializeAndClaimArray(
		bytes32[] calldata _dealid,
		uint256[] calldata _idx)
	external returns (bool)
	{
		require(_dealid.length == _idx.length);
		for (uint i = 0; i < _dealid.length; ++i)
		{
			claim(initialize(_dealid[i], _idx[i]));
		}
		return true;
	}
}
