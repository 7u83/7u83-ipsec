#

class ipsec::isakmpd_params {
	case $::osfamily {
		'FreeBSD':{
			$pkg_name = "security/isakmpd"
			$pkg_provider = "portsng"
			$ipsec_conf = '/etc/ipsec.conf'
	
			$isakmpd_service = 'isakmpd'
			$setkey_cmd = '/sbin/ipsecctl -f /etc/ipsec.conf'
		}
		'OpenBSD':{
			$isakmpd_service = 'isakmpd'
			$pkg_name = false
			$pkg_provider = undef
			$ipsec_conf = '/etc/ipsec.conf'
			$setkey_cmd = '/sbin/ipsecctl -f /etc/ipsec.conf'
		}
		default: {
			$racoon_pkg = 'racoon'
			$racoon_conf = '/etc/racoon/racoon.conf'
			$racoon_pskfile = '/etc/racoon/psk.txt'
			$racoon_service = 'racoon'
			$ipsec_conf = '/etc/racoon-tools.conf'
			$racoon_service = 'setkey'
			$setkey_cmd = '/usr/sbin/setkey'
			$racoon_usr = 'root'
			$racoon_grp = 'root'
		}
	}	
}

