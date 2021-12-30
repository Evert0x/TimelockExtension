const { expect } = require('chai');
const { parseEther, parseUnits, id } = require('ethers/lib/utils');

const { prepare, deploy, solution, blockNumber, Uint16Max, Uint32Max } = require('./utilities');

const { constants } = require('ethers');

const { TimeTraveler } = require('./utilities/snapshot');

describe('TimelockControllerDetailed', function () {
  before(async function () {
    timeTraveler = new TimeTraveler(network.provider);

    await prepare(this, ['Test', 'TimelockControllerDetailed']);

    await deploy(this, [['cTest', this.Test, []]]);
    await deploy(this, [
      [
        'tcDetailed',
        this.TimelockControllerDetailed,
        [5, [this.alice.address], [this.alice.address]],
      ],
    ]);

    await timeTraveler.snapshot();
  });
  // describe('default', async function () {
  //   before(async function () {
  //     this.data = this.cTest.interface.encodeFunctionData('test2', [500]);
  //     this.sighash = this.cTest.interface.getSighash('test2(uint256)');
  //   });
  //   it('initial', async function () {
  //     await this.tcDetailed.schedule(
  //       this.cTest.address,
  //       0,
  //       this.data,
  //       constants.HashZero,
  //       id('1'),
  //       5,
  //     );
  //   });
  //   it('Set picky', async function () {
  //     console.log(this.sighash);
  //     await this.tcDetailed.updateDetailedMinDelay(this.cTest.address, this.sighash, 10);
  //   });
  //   it('do again', async function () {
  //     await this.tcDetailed.schedule(
  //       this.cTest.address,
  //       0,
  //       this.data,
  //       constants.HashZero,
  //       id('2'),
  //       11,
  //     );
  //   });
  // });
  describe('update delay', async function () {
    before(async function () {
      this.data = this.cTest.interface.encodeFunctionData('test2', [500]);
      this.sighash = this.cTest.interface.getSighash('test2(uint256)');

      this.updateSighash = this.tcDetailed.interface.getSighash(
        'updateDetailedMinDelay(bytes4,address,uint256)',
      );
      this.update = this.tcDetailed.interface.encodeFunctionData('updateDetailedMinDelay', [
        this.sighash,
        this.cTest.address,
        6,
      ]);

      this.grantSigHash = this.tcDetailed.interface.getSighash('grantRole(bytes32,address)');
      await timeTraveler.revertSnapshot();
    });
    it('Schedule', async function () {
      await this.tcDetailed.schedule(
        this.tcDetailed.address,
        0,
        this.update,
        constants.HashZero,
        id('1'),
        6,
      );
    });
    it('Execute', async function () {
      await timeTraveler.mine(10);

      await this.tcDetailed.execute(
        this.tcDetailed.address,
        0,
        this.update,
        constants.HashZero,
        id('1'),
      );
    });
    // it('do again', async function () {
    //   await this.tcDetailed.schedule(
    //     this.cTest.address,
    //     0,
    //     this.data,
    //     constants.HashZero,
    //     id('2'),
    //     11,
    //   );
    // });
  });
});
