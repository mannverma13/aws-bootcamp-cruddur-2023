# Week 5 — DynamoDB and Serverless Caching

Amazon DynamoDB is a fully managed, serverless, key-value NoSQL database designed to run high-performance applications at any scale. DynamoDB offers built-in security, continuous backups, automated multi-Region replication, in-memory caching, and data import and export tools. It provides high availabilty,automatic backup.

Dynamo db is no swl db but can be use for SQl . using PartiQL, a SQL-compatible query language, to query, insert, update, and delete table data in DynamoDB.

## Read/write capacity mode
Amazon DynamoDB has two read/write capacity modes for processing reads and writes on your tables:

On-demand
Provisioned (default, free-tier eligible)

## On-demand
Amazon DynamoDB on-demand is a flexible billing option capable of serving thousands of requests per second without capacity planning. DynamoDB on-demand offers pay-per-request pricing for read and write requests so that you pay only for what you use.
For on-demand mode tables, you don't need to specify how much read and write throughput you expect your application to perform. DynamoDB charges you for the reads and writes that your application performs on your tables in terms of read request units and write request units.
On-demand mode is a good option if any of the following are true:

You create new tables with unknown workloads.
You have unpredictable application traffic.
You prefer the ease of paying for only what you use.

## Provisioned mode

If you choose provisioned mode, you specify the number of reads and writes per second that you require for your application. You can use auto scaling to adjust your table’s provisioned capacity automatically in response to traffic changes. This helps you govern your DynamoDB use to stay at or below a defined request rate in order to obtain cost predictability.

Provisioned mode is a good option if any of the following are true:

You have predictable application traffic.
You run applications whose traffic is consistent or ramps gradually.
You can forecast capacity requirements to control costs.


# DynamoDB auto scaling

DynamoDB auto scaling actively manages throughput capacity for tables and global secondary indexes. With auto scaling, you define a range (upper and lower limits) for read and write capacity units. You also define a target utilization percentage within that range. DynamoDB auto scaling seeks to maintain your target utilization, even as your application workload increases or decreases.
With DynamoDB auto scaling, a table or a global secondary index can increase its provisioned read and write capacity to handle sudden increases in traffic, without request throttling. When the workload decreases, DynamoDB auto scaling can decrease the throughput so that you don't pay for unused provisioned capacity.
## Global Secondary Index
To speed up queries on non-key attributes, you can create a global secondary index. A global secondary index contains a selection of attributes from the base table, but they are organized by a primary key that is different from that of the table. The index key does not need to have any of the key attributes from the table. It doesn't even need to have the same key schema as a table.
Every global secondary index must have a partition key, and can have an optional sort key. The index key schema can be different from the base table schema.
You can retrieve items from a global secondary index using the Query and Scan operations. The GetItem and BatchGetItem operations can't be used on a global secondary index.


