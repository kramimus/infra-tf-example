resource "aws_elasticache_subnet_group" "cachegroup" {
  name       = "cache-subnet"
  subnet_ids = ["${aws_subnet.subneta.id}", "${aws_subnet.subnetb.id}"]
}

resource "aws_elasticache_cluster" "cache" {
  cluster_id = "cache"
  engine = "memcached"
  node_type = "cache.t2.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.memcached1.4"
  port = 11211
  security_group_ids = ["${aws_security_group.private_instance.id}"]
  subnet_group_name = "${aws_elasticache_subnet_group.cachegroup.name}"
}  

resource "aws_route53_record" "cache_hostname" {
  zone_id = "${aws_route53_zone.private_zone.zone_id}"
  name = "cache.${aws_route53_zone.private_zone.name}"
  type = "CNAME"
  ttl = 60
  records = ["${aws_elasticache_cluster.cache.cache_nodes.0.address}"]
}

