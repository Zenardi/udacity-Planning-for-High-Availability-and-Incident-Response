resource "random_integer" "sufix" {
  min = 11111
  max = 99999
}


variable primary_db_cluster_arn {}

resource "aws_rds_cluster_parameter_group" "cluster_pg-s" {
  name   = "udacity-pg-s-${random_integer.sufix.result}"
  family = "aurora5.6"
  depends_on = [var.primary_db_instance_arn]

  parameter {
    name  = "binlog_format"    
    value = "MIXED"
    apply_method = "pending-reboot"
  }

  parameter {
    name = "log_bin_trust_function_creators"
    value = 1
    apply_method = "pending-reboot"
  }
}

resource "aws_db_subnet_group" "udacity_db_subnet_group" {
  name       = "udacity_db_subnet_group_${random_integer.sufix.result}"
  subnet_ids = var.private_subnet_ids
}

resource "aws_rds_cluster" "udacity_cluster-s" {
  cluster_identifier              = "udacity-db-cluster-s"
  availability_zones              = ["us-west-1a", "us-west-1b"]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_pg-s.name
  vpc_security_group_ids          = [aws_security_group.db_sg_2.id]
  db_subnet_group_name            = aws_db_subnet_group.udacity_db_subnet_group.name
  engine_mode                     = "provisioned"
  engine_version                  = "5.6.mysql_aurora.1.19.1" 
  skip_final_snapshot             = true
  storage_encrypted               = false
  master_username                 = "udacitysre42"
  master_password                 = "B4rbut8ch4rs"
  backup_retention_period         = 5
  replication_source_identifier   = var.primary_db_cluster_arn
  depends_on = [aws_rds_cluster_parameter_group.cluster_pg-s]
}

resource "aws_rds_cluster_instance" "udacity_instance-s" {
  count                = var.db_count
  identifier           = "udacity-db-instance-${count.index}-s"
  cluster_identifier   = aws_rds_cluster.udacity_cluster-s.id
  instance_class       = "db.t2.small"
  db_subnet_group_name = aws_db_subnet_group.udacity_db_subnet_group.name  
}

resource "aws_security_group" "db_sg_2" {
  name   = "udacity-db-sg-${random_integer.sufix.result}"
  vpc_id =  var.vpc_id

  ingress {
    from_port   = 3306
    protocol    = "TCP"
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    protocol    = "TCP"
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }
}