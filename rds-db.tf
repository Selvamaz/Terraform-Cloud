
# Private Subnet group for Database
resource "aws_db_subnet_group" "dev-db-Subnet-Group" {
  name       = "dev-db-subnet-group"
  subnet_ids = [aws_subnet.dev-private-sub-01.id, aws_subnet.dev-private-sub-02.id]

  tags = {
    Name = "Dev DB Sub Group"
  }
}

# RDS Postgres Database installed in Private Subnet Machines
resource "aws_db_instance" "dev-db-server" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "postgres"
  engine_version       = "16"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = "admin123"
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
  depends_on = [ aws_db_subnet_group.dev-db-Subnet-Group ]
  db_subnet_group_name = aws_db_subnet_group.dev-db-Subnet-Group.id
  vpc_security_group_ids = [aws_security_group.dev-private-sg.id]
}