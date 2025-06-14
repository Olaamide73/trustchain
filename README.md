# TrustChain

A secure and decentralized inheritance management system built on the Stacks blockchain.

## Overview

TrustChain is a smart contract that enables users to create digital vaults with inheritance rules. It implements a guardian-based system where designated guardians can approve asset transfers to beneficiaries after a period of inactivity.

## Features

- Create vaults with designated beneficiaries and guardians
- Multi-signature guardian approval system
- Time-locked inheritance activation
- Secure asset claiming process for beneficiaries
- Built with Clarity language on Stacks blockchain

## Contract Functions

- `create-vault`: Create a new vault with beneficiary and guardians
- `approve-unlock`: Guardians can approve vault unlocking
- `unlock-vault`: Execute vault unlock after majority approval and inactivity period
- `claim-assets`: Beneficiaries can claim assets from unlocked vaults
- `get-vault`: Read vault information

