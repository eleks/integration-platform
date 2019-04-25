#--------------------------------------------------------------------------------
# predefine hosts ports here to use in confgs
#--------------------------------------------------------------------------------

data "null_data_source" "component_hosts" {
  inputs = {
    api  = "${module.kub.hostname}"
    apxw = "internal-only"                         # actually we are not publishing this server on public LB
  }
}


## hosts and ports separated because hosts are evaluated and ports - are constants
locals {
  component_ports = {
    # port_name = "local node public"
    api = {
      mhttps = "9443 31443 9444"
      mhttp  = "9763 31763 8283"
      https  = "8243 31243 8244"
      http   = "8280 31280 8281"
    }
    apxw = {
      # no public ports here. only kub-node ports
      thriftssl = "7712 30712" #Thrift SSL port for secure transport, where the client is authenticated to use WSO2 API-M Analytics.
      thrifttcp = "7612 30612" #Thrift TCP port where WSO2 API-M Analytics receives events from clients.
      apissl    = "7444 30744" #The default port for the Stream Processor Store API.
      mgwssl    = "9444 30944" #MSF4J HTTPS Port in the Stream Procesor. This is used by the Microgateway.
    }
  }
}

