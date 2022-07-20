# Infrastructure

## AWS Zones
**Primary** - us-east-2

**Standby** - us-west-1

## Servers and Clusters

### Table 1.1 Summary
| Asset      | Purpose           | Size                                                                   | Qty                                                             | DR                                                                                                           |
|------------|-------------------|------------------------------------------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| Asset name | Brief description | AWS size eg. t3.micro (if applicable, not all assets will have a size) | Number of nodes/replicas or just how many of a particular asset | Identify if this asset is deployed to DR, replicated, created in multiple locations or just stored elsewhere |
| Ubuntu Web | Running the Flask Application | t3.micro | 3 | Created in all AZ's supported in the region and deployed to DR site |
| EKS Control Plane | Coordinate K8s node activities | N\A | N\A | Managed by AWS and created in multiple AZs and deployed to DR site|
| EKS Nodes | Run containerized applications including Prometheus and Grafana stack | t3.medium | 2 | Created in multiple AZ's and deployed to DR site |
| VPC | Network for applications to run | /16 | 1 | Private and Public subnets in multiple AZs and created in DR |
| Web Application ALB | Entry point for multiple instances of the Flask applicaiton | N\A | 1 | Connected to target group members in multiple AZ's and created in DR |
| Grafana ALB | Entry point for Grafana application running in EKS pods | N\A | 1 | Connected to target group members in multiple AZ's and created in DR |
| Aurora MySQL| data repository for application | t3.small | 2 | Created in multiple AZ's and replicated from primary region to standby region |




### Descriptions
More detailed descriptions of each asset identified above.

## DR Plan
### Pre-Steps:
List steps you would perform to setup the infrastructure in the other region. It doesn't have to be super detailed, but high-level should suffice.

#### Infrastructure

1. Create Route 53 records for the primary and standby application instances and configure DNS failover policies to automatically handle an outage in the primary region

#### Utilities: Prometheus and Grafana

1. In the zone2 Terraform deployment, deploy the EKS cluster. Once the EKS cluster up is running, deploy Prometheus and Grafana.

2. Access the DR Grafana instance and verify DR deployment application metrics are displayed as expected with a sample user input.

#### Application
1. In the zone2 Terraform deployment, deploy the ALB and EC2 instances.

2. Verify the DR application instance works as expected.

#### Database
1. In the zone1 Terraform deployment, configure the automation as follows.
    1. Output the primary RDS cluster and writer instance ARNs for the standby RDS cluster deployment automation to use as an input.
    2. In the standby automation, specify the primary cluster arn as the replication_source_identifier and configure the primary instance arn as a dependency. 

## Steps:
You won't actually perform these steps, but write out what you would do to "fail-over" your application and database cluster to the other region. Think about all the pieces that were setup and how you would use those in the other region

1. Confirm that Route 53 failover routing for the application endpoint completed successfully, and the application is now accessible from the standby region instances.
2. Confirm the RDS cluster failed over.
3. Confirm the failed over application instance is able to read/write from/to the failed over RDS cluster.