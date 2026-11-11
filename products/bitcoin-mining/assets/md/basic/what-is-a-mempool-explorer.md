\# What Is a Mempool Explorer?



A \*\*mempool explorer\*\* is a tool for inspecting pending Bitcoin transactions before they are confirmed in a block.



It provides a visual view into the transaction queue maintained by a Bitcoin node.



\## What You Can See



A mempool explorer can help you inspect:



\- pending and unconfirmed transactions

\- transaction fee rates

\- transaction sizes

\- current mempool activity

\- projected upcoming blocks

\- historical mempool information



\## The Mempool



A mempool, short for \*\*memory pool\*\*, contains transactions that a Bitcoin node knows about but that have not yet been confirmed in a block.



There is no single global Bitcoin mempool.



Each node maintains its own mempool, so two nodes can temporarily have different sets of transactions.



\## Projected Blocks



One useful visualization is the \*\*projected block\*\*.



Instead of displaying pending transactions only as a list, transactions can be grouped into estimated future blocks.



Conceptually:



Pending transactions

&#x20;       |

&#x20;       v

+-------------------+

| Projected Block 1 |

+-------------------+

&#x20;       |

&#x20;       v

+-------------------+

| Projected Block 2 |

+-------------------+

&#x20;       |

&#x20;       v

&#x20;      ...

&#x20;       |

&#x20;       v

+-------------------+

| Confirmed Block   |

+-------------------+



Projected blocks are estimates.



The transactions that eventually appear in a mined Bitcoin block can differ from the projection.



\## Why It Matters



A mempool explorer makes Bitcoin's transaction pipeline easier to understand.



It helps users observe the transition:



\*\*Transaction created → Mempool → Block candidate → Confirmed block\*\*



This is useful for:



\- understanding network activity

\- examining pending transactions

\- comparing fee rates

\- estimating transaction priority

\- learning how transactions move toward confirmation



\## Mempool Explorer vs. Block Explorer



A \*\*mempool explorer\*\* focuses primarily on transactions waiting for confirmation.



A \*\*block explorer\*\* focuses primarily on information already recorded in the blockchain.



Together they provide a view of both sides of the transaction lifecycle:



\*\*Pending → Confirmed\*\*



\## Key Concept



The mempool is not the blockchain.



It is the temporary transaction queue that exists before transactions are included in confirmed blocks.

