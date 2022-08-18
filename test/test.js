

const { expect } = require("chai");
const { ethers, web3 } = require("hardhat");
const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert,
    balance, // Assertions for transactions that should fail
  } = require('@openzeppelin/test-helpers');


const { erc20Abi } = require("../scripts/Abi.js")

const ether = require("@openzeppelin/test-helpers/src/ether.js");
const { LogDescription } = require("ethers/lib/utils");


const geistStaking = ethers.utils.getAddress("0x49c93a95dbcc9A6A4D8f77E59c038ce5020e82f8")
const geistStakingAbi = [{"inputs":[{"internalType":"address","name":"_stakingToken","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"token","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Recovered","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"reward","type":"uint256"}],"name":"RewardAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":true,"internalType":"address","name":"rewardsToken","type":"address"},{"indexed":false,"internalType":"uint256","name":"reward","type":"uint256"}],"name":"RewardPaid","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"token","type":"address"},{"indexed":false,"internalType":"uint256","name":"newDuration","type":"uint256"}],"name":"RewardsDurationUpdated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Staked","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"user","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Withdrawn","type":"event"},{"inputs":[{"internalType":"address","name":"_rewardsToken","type":"address"}],"name":"addReward","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"claimableRewards","outputs":[{"components":[{"internalType":"address","name":"token","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"internalType":"struct MultiFeeDistribution.RewardData[]","name":"rewards","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"earnedBalances","outputs":[{"internalType":"uint256","name":"total","type":"uint256"},{"components":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"unlockTime","type":"uint256"}],"internalType":"struct MultiFeeDistribution.LockedBalance[]","name":"earningsData","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"exit","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getReward","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"_rewardsToken","type":"address"}],"name":"getRewardForDuration","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_rewardsToken","type":"address"}],"name":"lastTimeRewardApplicable","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"lockDuration","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"lockedBalances","outputs":[{"internalType":"uint256","name":"total","type":"uint256"},{"internalType":"uint256","name":"unlockable","type":"uint256"},{"internalType":"uint256","name":"locked","type":"uint256"},{"components":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"unlockTime","type":"uint256"}],"internalType":"struct MultiFeeDistribution.LockedBalance[]","name":"lockData","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"lockedSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"bool","name":"withPenalty","type":"bool"}],"name":"mint","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"minters","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"mintersAreSet","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"tokenAddress","type":"address"},{"internalType":"uint256","name":"tokenAmount","type":"uint256"}],"name":"recoverERC20","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"rewardData","outputs":[{"internalType":"uint256","name":"periodFinish","type":"uint256"},{"internalType":"uint256","name":"rewardRate","type":"uint256"},{"internalType":"uint256","name":"lastUpdateTime","type":"uint256"},{"internalType":"uint256","name":"rewardPerTokenStored","type":"uint256"},{"internalType":"uint256","name":"balance","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"_rewardsToken","type":"address"}],"name":"rewardPerToken","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"rewardTokens","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"}],"name":"rewards","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"rewardsDuration","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address[]","name":"_minters","type":"address[]"}],"name":"setMinters","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"bool","name":"lock","type":"bool"}],"name":"stake","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"stakingToken","outputs":[{"internalType":"contract IMintableToken","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"totalBalance","outputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"unlockedBalance","outputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"address","name":"","type":"address"}],"name":"userRewardPerTokenPaid","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"withdrawExpiredLocks","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"user","type":"address"}],"name":"withdrawableBalance","outputs":[{"internalType":"uint256","name":"amount","type":"uint256"},{"internalType":"uint256","name":"penaltyAmount","type":"uint256"}],"stateMutability":"view","type":"function"}]

const fakeLP = ethers.utils.getAddress("0x30A92a4EEca857445F41E4Bb836e64D66920F1C0")
const addrZero = ethers.utils.getAddress("0x0000000000000000000000000000000000000000")
const geist = ethers.utils.getAddress("0xd8321AA83Fb0a4ECd6348D4577431310A6E0814d")
const gUSDC = ethers.utils.getAddress("0xe578c856933d8e1082740bf7661e379aa2a30b26")
const gFTM = ethers.utils.getAddress("0x39b3bd37208cbade74d0fcbdbb12d606295b430a")
const USDC = ethers.utils.getAddress("0x04068da6c83afcfa0e13ba15a6696662335d5b75")
const gftmGateway = ethers.utils.getAddress("0x47102245FEa0F8D35a6b28E54505e9FfD83d0704")
const spookyrouter = ethers.utils.getAddress("0xF491e7B69E4244ad4002BC14e878a34207E38c29")


const tokenRewards = [
    gFTM,
    
    gUSDC,
    
    ethers.utils.getAddress("0x940f41f0ec9ba1a34cf001cc03347ac092f5f6b5"),
    
    ethers.utils.getAddress("0x07e6332dd090d287d3489245038daf987955dcfb"),
    
    ethers.utils.getAddress("0x25c130b2624cf12a4ea30143ef50c5d68cefa22f"),
    
    ethers.utils.getAddress("0x38aca5484b8603373acc6961ecd57a6a594510a3"),
    
    
    ethers.utils.getAddress("0x690754a168b022331caa2467207c61919b3f8a98"),
    
    ethers.utils.getAddress("0xc664fc7b8487a3e10824cda768c1d239f2403bbe")
]

const underlyingToken = [

    ethers.utils.getAddress("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83"),
    
    USDC,
    
    ethers.utils.getAddress("0x049d68029688eAbF473097a2fC38ef61633A3C7A"),
    
    ethers.utils.getAddress("0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E"),
    
    ethers.utils.getAddress("0x74b23882a30290451A17c44f4F05243b6b58C76d"),
    
    ethers.utils.getAddress("0x321162Cd933E2Be498Cd2267a90534A804051b11"),
    
    ethers.utils.getAddress("0x1E4F97b9f9F913c46F1632781732927B9019C68b"),
    
    ethers.utils.getAddress("0x82f0B8B456c1A451378467398982d4834b6829c1")
]

describe("LiGeist TEST UNIT", function () {
   
    beforeEach(async () => {
        
        await ethers.provider.send('evm_increaseTime', [1]);
        await ethers.provider.send('evm_mine');
    });
    
    it("Prepare contracts", async function () {
        
        accounts = await ethers.getSigners();
        owner = accounts[0]

        geistStakingContract = new ethers.Contract(geistStaking, geistStakingAbi, owner   )  
        
        geistContract = new ethers.Contract(geist, erc20Abi, owner   )  
        
        gUSDCContract = new ethers.Contract(gUSDC, erc20Abi, owner   )  


    });


    it("Deploy Contracts", async function () {

        // deploy
        data = await ethers.getContractFactory("LiGeist");
        ligeistContract = await data.deploy();
        txDeployed = await ligeistContract.deployed();
        expect(await ligeistContract.owner()).to.equal(owner.address)


        // upgradeable contract
        data = await ethers.getContractFactory("LiGEISTChef");
        ligeistChefContract = await upgrades.deployProxy(data,[gUSDC], {initializer: 'initialize'});
        txDeployed = await ligeistChefContract.deployed();
        expect(await ligeistChefContract.owner()).to.equal(owner.address)

        // upgradeable contract
        // initialize(address _geist, address _lockedGeist, address _gFTM, address _gUSDC, address _USDC, address _gftmGateway
        data = await ethers.getContractFactory("LiGeistStrategy");
        ligeiststrategyContract = await upgrades.deployProxy(data,[geist, geistStaking,gFTM, gUSDC, USDC, gftmGateway ], {initializer: 'initialize'});
        txDeployed = await ligeiststrategyContract.deployed();
        expect(await ligeiststrategyContract.owner()).to.equal(owner.address)

        // deploy
        data = await ethers.getContractFactory("LiGeistManager");
        ligeistManagerContract = await data.deploy(ligeiststrategyContract.address, ligeistContract.address);
        txDeployed = await ligeistManagerContract.deployed();
        expect(await ligeistManagerContract.owner()).to.equal(owner.address)


    });

    it("Set operator to liGeist as liGeistManager", async function () {
        
        await ligeistContract.setOperator(ligeistManagerContract.address)

        expect(await ligeistContract.operator()).to.equal(ligeistManagerContract.address)
        
        await expectRevert(
            ligeistContract.mint(owner.address, 100),
            '!authorized'
        )    
    });

    it("Set operator to liGeistChef as ligeistStrategy", async function () {
        
        await ligeistChefContract.setExternalAddr(ligeiststrategyContract.address, true)

        expect(await ligeistChefContract.externalAddr(ligeiststrategyContract.address)).to.equal(true)
            
    });

    it("Set ligeistChef and lpChef to ligeistStrategy", async function () {
        
        await ligeiststrategyContract.setLiGeistChef(ligeistChefContract.address) //setLPChef

        expect(await ligeiststrategyContract.liGeistChef()).to.equal(ligeistChefContract.address)

        await ligeiststrategyContract.setLPChef(ligeistChefContract.address) //setLPChef

        expect(await ligeiststrategyContract.lpChef()).to.equal(ligeistChefContract.address)
        
    });

    it("Whitelist manager to strategy", async function () {
        
        await ligeiststrategyContract.whitelistStrategy(ligeistManagerContract.address) 

        expect(await ligeiststrategyContract.isStrategy(ligeistManagerContract.address) ).to.equal(true)    
    });

    it("Set manager to strategy", async function () {
        
        await ligeiststrategyContract.setManager(ligeistManagerContract.address) //ligeistManagerContract

        expect(await ligeiststrategyContract.liGeistManager() ).to.equal(ligeistManagerContract.address)    
    });
    it("Set router to strategy", async function () {
        
        await ligeiststrategyContract.setRouter(spookyrouter) //ligeistManagerContract

        expect(await ligeiststrategyContract.router() ).to.equal(spookyrouter)    
    });


    

    it("Add liGeist and LP Pools (80/20) to liGeistChef", async function () {

        
        expect(await ligeistChefContract.poolLength()).to.equal(0)
        //await ligeistChefContract.setDistributionRate(0)
        await ligeistChefContract.add(800, ligeistContract.address, addrZero)
        expect(await ligeistChefContract.poolLength()).to.equal(1)

        // we use linspirit-spirit as example
        await ligeistChefContract.add(200, fakeLP, addrZero)
        expect(await ligeistChefContract.poolLength()).to.equal(2)

    });

    
    it("Add geist token rewards and underlying", async function () {
        //console.log('rewlen: ', await (ligeiststrategyContract.rewardTokenLen()))

        for(i=0; i < tokenRewards.length; i++){
            if(tokenRewards[i] != gFTM && tokenRewards[i] != gUSDC){
                await ligeiststrategyContract.addGeistReward(tokenRewards[i], underlyingToken[i])
            }
        }
        expect(await (ligeiststrategyContract.rewardTokenLen())).to.equal(tokenRewards.length)
        //console.log('rewlen: ', await (ligeiststrategyContract.rewardTokenLen()))
    });


    it("", async function () {
        geistHolder = ethers.utils.getAddress("0x3ddfa8ec3052539b6c9549f12cea2c295cff5296")
        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [geistHolder],
        });
        signer = await ethers.getSigner(geistHolder)
        _balance = await geistContract.balanceOf(geistHolder)
        _amount = ethers.utils.parseEther("1")
        await geistContract.connect(signer).transfer(owner.address, _amount);
        expect(await geistContract.balanceOf(owner.address)).to.equal(_amount)
        await hre.network.provider.request({
            method: "hardhat_stopImpersonatingAccount",
            params: [geistHolder],
        });
       
    });

    it("Should create first lock", async function () {
        await geistContract.approve(ligeistManagerContract.address, _amount)
        //console.log("geist:\t", (await geistContract.balanceOf(owner.address)).toString())

        await ligeistManagerContract.initialLock(_amount)

        expect(await ligeistContract.totalSupply()).to.equal(_amount)
        expect(await ligeistContract.balanceOf(owner.address)).to.equal(_amount)
        //console.log("liGeist:\t", (await ligeistContract.balanceOf(owner.address)).toString())

        //console.log((await ligeiststrategyContract.lockedBalances() ).toString())
        expect((await ligeiststrategyContract.lockedBalances() )[0]).to.equal(_amount)  //total
        expect((await ligeiststrategyContract.lockedBalances() )[1]).to.equal(0)        //unlocked
        expect((await ligeiststrategyContract.lockedBalances() )[2]).to.equal(_amount)  //locked
        
    });



    it("Should increase amount", async function () {

        geistHolder = ethers.utils.getAddress("0x3ddfa8ec3052539b6c9549f12cea2c295cff5296")
        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [geistHolder],
        });
        signer = await ethers.getSigner(geistHolder)

        var oldAmount = _amount
        _amount = ethers.utils.parseEther("100")
        var sumAmount = 0
        //sumAmount = _amount + parseInt(oldAmount)

        await geistContract.connect(signer).approve(ligeistManagerContract.address, _amount)
        /*console.log("geist:\t", (await geistContract.balanceOf(signer.address) /1e18).toString())
        console.log("_amount:\t", (_amount/1e18).toString())
        console.log("oldAmount:\t", (oldAmount/1e18).toString())
        console.log("sumAmount:\t", (sumAmount/1e18).toString())*/

        await ligeistManagerContract.connect(signer).deposit(_amount)

        //expect(await ligeistContract.totalSupply()).to.equal(sumAmount)

        expect(await ligeistContract.balanceOf(signer.address)).to.equal(_amount)
        //console.log("liGeist:\t", (await ligeistContract.balanceOf(owner.address)).toString())

        //console.log((await ligeiststrategyContract.lockedBalances() ).toString())
        //expect((await ligeiststrategyContract.lockedBalances() )[0]).to.equal(sumAmount)  //total
        expect((await ligeiststrategyContract.lockedBalances() )[1]).to.equal(0)        //unlocked
        //expect((await ligeiststrategyContract.lockedBalances() )[2]).to.equal(sumAmount)  //locked

        await hre.network.provider.request({
            method: "hardhat_stopImpersonatingAccount",
            params: [geistHolder],
        });
        
    });



    it("Should get rewards after 1 week", async function () {
        
        await ethers.provider.send('evm_increaseTime', [86400*7]);
        await ethers.provider.send('evm_mine');
        len = await ligeiststrategyContract.rewardTokenLen()
        /*for(i=0; i < len; i++){
            console.log( (await ligeiststrategyContract.geistRewards(i)).toString())
            console.log( (await ligeiststrategyContract.geistRewardsUnderlying(i)).toString())
            console.log("--------------------------------------------")
        }*/

        expect(await gUSDCContract.balanceOf(ligeistChefContract.address)).to.equal(0)

        await ligeiststrategyContract.claimRewards()

        expect(await gUSDCContract.balanceOf(ligeistChefContract.address)).to.above(0)

        //console.log((await gUSDCContract.balanceOf(ligeistChefContract.address)).toString())

    });

    it("Should depositAll in epoch2", async function () {

        geistHolder = ethers.utils.getAddress("0x3ddfa8ec3052539b6c9549f12cea2c295cff5296")
        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [geistHolder],
        });
        signer = await ethers.getSigner(geistHolder)

        _amount = await geistContract.balanceOf(signer.address)

        await geistContract.connect(signer).approve(ligeistManagerContract.address, _amount)
        await ligeistManagerContract.connect(signer).depositAll()

        //expect(await ligeistContract.totalSupply()).to.equal(sumAmount)

        //console.log("liGeist:\t", (await ligeistContract.balanceOf(owner.address)).toString())

        //console.log((await ligeiststrategyContract.lockedBalances() ).toString())

        await hre.network.provider.request({
            method: "hardhat_stopImpersonatingAccount",
            params: [geistHolder],
        });
        
    });

    it("Should withdraw and relock", async function () {

        await ethers.provider.send('evm_increaseTime', [86400*7*15]);
        await ethers.provider.send('evm_mine');
    
        locked = await ligeiststrategyContract.lockedBalances()
        //console.log("locked bef:", locked.toString())

        await ligeiststrategyContract.withdrawAndRelock()
        locked = await ligeiststrategyContract.lockedBalances()
        //console.log("locked aft:",locked.toString())

    });



    it("Should withdraw and send to owner.address", async function () {

        await ethers.provider.send('evm_increaseTime', [86400*7*13]);
        await ethers.provider.send('evm_mine');
    
        locked = await ligeiststrategyContract.lockedBalances()
        //console.log("locked bef:", locked.toString())

        await ligeiststrategyContract.withdrawaExpiredLocksTo(owner.address)
        locked = await ligeiststrategyContract.lockedBalances()
        //console.log("locked aft:",locked.toString())
        bal = await geistContract.balanceOf(owner.address)
        //console.log("bal aft:",bal.toString())

    });

    it("Should get rewards", async function () {
        
        await ethers.provider.send('evm_increaseTime', [86400*7]);
        await ethers.provider.send('evm_mine');
        len = await ligeiststrategyContract.rewardTokenLen()
        /*for(i=0; i < len; i++){
            console.log( (await ligeiststrategyContract.geistRewards(i)).toString())
            console.log( (await ligeiststrategyContract.geistRewardsUnderlying(i)).toString())
            console.log("--------------------------------------------")
        }*/
        
        
        console.log('chef bal bef: ',(await gUSDCContract.balanceOf(ligeistChefContract.address)).toString())

        await ligeiststrategyContract.claimRewards()

        console.log('chef bal aft: ',(await gUSDCContract.balanceOf(ligeistChefContract.address)).toString())
        console.log('chef rew / s: ',(await ligeistChefContract.rewardPerSecond()).toString() ) 
    });


});