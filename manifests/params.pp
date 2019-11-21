
#params

class ipsec::params {
	case $::osfamily {
		'FreeBSD':{
			$default_ike_daemon = 'racoon'
		}
		'OpenBSD':{
			$default_ike_daemon = 'isakmpd'
		}
		default: {
			$default_ike_daemon = 'strongswan'
		}
	}	
}

