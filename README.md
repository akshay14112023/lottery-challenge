# Design Decisions

One of the main aspects of this assignment was to create an S3 bucket and load the CSV dataset into S3. I chose Terraform for this challenge, acknowledging its suitability. Despite its limitation for things that change very often, Terraform proved effective for this assignment.

Loading the dataset into Athena was achieved using Terraform. While alternatives like CloudWatch Events + AWS Lambda could be considered, I opted for Terraform becuase the data loading for this challenge needs to be done only once, i.e., very infrequently.

Another critical decision was where to deploy Superset and how to deploy it. I selected Amazon Elastic Kubernetes Service (EKS) mostly due to my familiarity with it. Other solutions, such as ECS, Fargate, EKS, Hashi-Nomad, and Consul, could be considered based on trade-offs related to the application use case, team experience, and conformity with a certain orchestration platform, etc.

Regarding how to deploy superset, I used Helm and Terraform again. While I agree that Terraform may not be the best option for installing applications in Kubernetes clusters, in an ideal scenario, I would use something like ArgoCD or FluxCD, designed specifically for this purpose. Helm was chosen for its effectiveness in packaging Kubernetes applications.

Regarding Terraform code structure, I aimed to use public modules for the sake of this challenge as suggested to expedite the development process. Created different files for various parts of the system to impreove readabilit. I also added comments as required to provide clarity and context for anyone looking at the codebase.

Please go through it and let me know your thoughts!

# Deliverables


## Terraform plan file

[terraform-plan.txt](./terraform-plan.txt)

Ran the follwoing commands to get the plan file in a readable format. 

```
terraform plan -out tf.plan
terraform show -no-color tf.plan > terraform-plan.txt
```
## URLS

- [Superset Application URL](http://add046aa86fa84360a00c95c07dc6d6f-2049517730.us-east-1.elb.amazonaws.com)
- [Dashboard URL for Lottery Mega Millions 2002 Analytics](http://add046aa86fa84360a00c95c07dc6d6f-2049517730.us-east-1.elb.amazonaws.com/superset/dashboard/p/7rvBWDzQY8z/)

## SQL queries

### Top 5 Common Winning Numbers

```sql
SELECT winning_numbers, COUNT(winning_numbers) as frequency
FROM draw_details
GROUP BY winning_numbers
ORDER BY frequency DESC
LIMIT 5;
```


### Average Multiplier Value
```sql
SELECT
 avg(multiplier) from draw_details
```

### Top 5 Mega Ball Numbers

```sql
SELECT mega_ball, COUNT(mega_ball) as frequency
FROM draw_details
GROUP BY mega_ball
ORDER BY frequency DESC
LIMIT 5;
```


### Lotteries draw weekday vs weekend
```sql
SELECT
  CASE WHEN DAY_OF_WEEK(date_parse(draw_date, '%m/%d/%Y')) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END AS day_type,
  COUNT(*) AS draw_count
FROM
  draw_details
GROUP BY
  CASE WHEN DAY_OF_WEEK(date_parse(draw_date, '%m/%d/%Y')) IN (1, 7) THEN 'Weekend' ELSE 'Weekday' END;
```
