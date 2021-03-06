class ipsec::racoon_params {
	case $::osfamily {
		'FreeBSD':{
			$racoon_pkg = 'ipsec-tools'
			$racoon_conf = '/usr/local/etc/racoon/racoon.conf'
			$racoon_pskfile = '/usr/local/etc/racoon/psk.txt'
			$racoon_service = 'racoon'
			$ipsec_conf = '/etc/ipsec.conf'
			$ipsec_service = 'ipsec'
			$setkey_cmd = '/sbin/setkey'
			$racoon_usr = 'root'
			$racoon_grp = 'wheel'
			$racoon_certs = "/usr/local/etc/racoon/certs"
		}
		'OpenBSD':{
			$ikedaemon = 'isakmpd'
			$racoon_pkg = 'racoon-tools'
#			$racoon_conf = '/usr/local/etc/racoon/racoon.conf'
			$racoon_pskfile = '/usr/local/etc/racoon/psk.txt'
			$racoon_service = 'racoon'
#			$racoon_conf = '/etc/racoon.conf'
			$ipsec_service = 'racoon'
			$setkey_cmd = '/sbin/setkey'
			$racoon_usr = 'root'
			$racoon_grp = 'wheel'
			$racoon_certs = "/usr/local/etc/racoon/certs"
		}
		default: {
			$racoon_pkg = 'racoon'
			$racoon_conf = '/etc/racoon/racoon.conf'
			$racoon_pskfile = '/etc/racoon/psk.txt'
			$racoon_service = 'racoon'
			$ipsec_conf = '/etc/ipsec-tools.conf'
			$ipsec_service = 'setkey'
			$setkey_cmd = '/usr/sbin/setkey'
			$racoon_usr = 'root'
			$racoon_grp = 'root'
			$racoon_certs = "/etc/racoon/certs"
		}
	}	
}

