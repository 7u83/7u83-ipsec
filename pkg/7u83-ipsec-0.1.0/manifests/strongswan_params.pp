#

class ipsec::strongswan_params {
	case $::osfamily {
		'FreeBSD':{
			$pkg_name = "strongswan"
			$ipsec_conf = '/usr/local/etc/ipsec.conf'
			$service_name = 'strongswan'
			# strongswan's startup script confuses pupets 
			# service enable, so we cannot enable the service
			$service_enable = undef
			$secrets_usr = 'root'
			$secrets_grp = 'wheel'
			$secrets_file = '/usr/local/etc/ipsec.secrets'

		}
		default: {
			$pkg_name = "strongswan"
			$ipsec_conf = '/etc/ipsec.conf'
			$service_name = 'strongswan'
			$service_enable = true
			$secrets_usr = 'root'
			$secrets_grp = 'root'
			$secrets_file = '/etc/ipsec.secrets'
		}
	}	
}

