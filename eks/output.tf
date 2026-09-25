output "cluster_id" {
  value = aws_eks_cluster.java_app.id
}

output "node_group_id" {
  value = aws_eks_node_group.java_app.id
}

output "vpc_id" {
  value = aws_vpc.java_app_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.java_app_subnet[*].id
}