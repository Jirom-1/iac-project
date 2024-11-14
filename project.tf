module "ecs"{
    source = "./modules/ecs"
    project_name = "emburse-interview"
    container_name = "cs-848-viz"
    image_name = "ghcr.io/jirom-1/cs-848-visualization-project:main"
    private_registry_secret_arn = "arn:aws:secretsmanager:ca-central-1:935297230760:secret:emburseTest-4TSrz9"
    port = 80
    subnets = [module.networking.public_subnet_1_id, module.networking.public_subnet_2_id, module.networking.public_subnet_3_id]
    vpc_id = module.networking.vpc_id
    alb_target_group_arn = module.alb.alb-target-group-arn
}


module "networking" {
    source = "./modules/networking"
    vpc_cidr = "10.0.0.0/16"
    public_subnet_cidr_1 = "10.0.1.0/24"
    public_subnet_cidr_2 = "10.0.2.0/24"
    public_subnet_cidr_3 = "10.0.3.0/24"
    # private_subnet_cidr = "10.0.2.0/24"
}

module "alb"{
    source = "./modules/alb"
    project-name = "emburse-interview"
    subnets =  [module.networking.public_subnet_1_id, module.networking.public_subnet_2_id, module.networking.public_subnet_3_id]
    vpc_id = module.networking.vpc_id
}
