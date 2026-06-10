resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"           
  subnet_ids = var.private_subnet_ids     


  tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_db_instance" "main" {
  identifier        = "finflow-db"                    
  engine            = "postgres"                       
                                                    
  engine_version    = "15.4"                        
  instance_class    = "db.t3.micro"                 
                                                    

  allocated_storage     = 20                        
  max_allocated_storage = 100                      
                                            

  db_name  = "finflow"                              
  username = var.db_username                       
  password = var.db_password                        
                                                    

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]          

  multi_az = true                                   
                                                                                                
  backup_retention_period = 7                       
                                                    
  backup_window           = "03:00-04:00"           
  maintenance_window      = "Mon:04:00-Mon:05:00"   

  storage_encrypted = true     

  publicly_accessible = false                       

  deletion_protection      = false   #for dev in prod would be true for both prot and skip                 
  skip_final_snapshot      = true                  
                                                    
  final_snapshot_identifier = "finflow-db-final"     

  tags = {
    Name        = "${var.project_name}-db"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_db_instance" "replica" {
   identifier          = "finflow-db-replica"
   replicate_source_db = aws_db_instance.main.identifier
   instance_class      = "db.t3.micro"             
   publicly_accessible = false
   storage_encrypted   = true
   skip_final_snapshot = true

   tags = {
     Name        = "${var.project_name}-db-replica"
    Environment = var.environment
    Project     = var.project_name
   }
 }