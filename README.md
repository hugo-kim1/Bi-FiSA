# Bi-FiSA
## Contents
This repo contains the proof of reserves (PoR) smart contract codes for Bi-FiSA (submitted to Usenix Security 24').
The repo for the experiment of EDH and UDH protocol for the pause period of Bi-FiSA can be found at : <https://github.com/m0nd2y/Proof-Of-Reserves>

### Node.sol
This is where the management of the list of registered nodes is carried out.

### Key.sol
This is where the public key for a round is established.

### Round.sol
This is where a round of Bi-FiSA is managed.
Followings are available:
- Users and the exchange publishes snapshots.
- The list of registered users is managed
- The nodes publish the calculation of reserves, originated from the user's snapshots.
- The nodes publish the calculation of reserves, originated from the exchange's snapshots.
- The nodes publish the actual reserves.
- Nodes' votes for the next round is carried out.
