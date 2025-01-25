output "juice_shop_instance_ip" {
  description = "Public IP of the Juice Shop VM"
  value       = module.juice_shop_instance.public_ip
}