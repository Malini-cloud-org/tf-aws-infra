output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.csye6225_vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.csye6225_vpc.cidr_block
}

output "vpc_tags" {
  description = "Tags assigned to the VPC"
  value       = aws_vpc.csye6225_vpc.tags
}

output "rds_endpoint" {
  value       = aws_db_instance.rds_instance.endpoint
  description = "The endpoint of the RDS instance"
}

output "a_record" {
  # value = aws_route53_record.ec2_a_record.fqdn # Fully qualified domain name
  value = aws_route53_record.load_balancer_record.fqdn
}

# Output the ARN of the SNS topic
output "sns_topic_arn" {
  value       = aws_sns_topic.user_creation_topic.arn
  description = "The ARN of the SNS topic"
}
